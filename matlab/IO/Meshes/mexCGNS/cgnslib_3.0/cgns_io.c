/*-------------------------------------------------------------------------
This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from
the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not
   be misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
-------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#if defined(_WIN32) && !defined(__NUTC__)
#include <io.h>
#else
#include <unistd.h>
#endif
#include <errno.h>

#include "cgns_io.h"
#include "adf/ADF.h"
#ifdef BUILD_HDF5
#include "adfh/ADFH.h"
#endif
#ifdef BUILD_XML
#include "adfx/ADFX.h"
#endif
#ifdef MEM_DEBUG
#include "cg_malloc.h"
#endif

typedef struct {
    int type;
    int mode;
    double rootid;
} cgns_io;

static int num_open = 0;
static int num_iolist = 0;
static cgns_io *iolist;

static char *cgio_ErrorMessage[] = {
    "no error",
    "invalid cgio index",
    "malloc/realloc failed",
    "unknown file open mode",
    "invalid file type",
    "filename is NULL or empty",
    "character string is too small",
    "file was not found",
    "pathname is NULL or empty",
    "no match for pathname",
    "error opening file for reading",
    "file opened in read-only mode",
    "NULL or empty string",
    "invalid configure option",
    "rename of tempfile file failed",
    "too many open files"
};
#define CGIO_MAX_ERRORS (sizeof(cgio_ErrorMessage)/sizeof(char *))

#define set_error(E) (last_err = E)
#define get_error()  last_err

static int last_err = CGIO_ERR_NONE;
static int last_type = CGIO_FILE_NONE;

static int cgio_n_paths = 0;
static char **cgio_paths = 0;

/*=========================================================
 * support routines
 *=========================================================*/

static cgns_io *get_cgnsio (int cgio_num, int write) {
    if (--cgio_num < 0 || cgio_num >= num_iolist) {
        last_err = CGIO_ERR_BAD_CGIO;
        return NULL;
    }
    if (write && iolist[cgio_num].mode == CGIO_MODE_READ) {
        last_err = CGIO_ERR_READ_ONLY;
        return NULL;
    }
    last_type = iolist[cgio_num].type;
    last_err = CGIO_ERR_NONE;
    return &iolist[cgio_num];
}

/*---------------------------------------------------------*/

static size_t compute_data_size (const char *data_type,
    int ndims, const int *dims)
{
    int size;
    unsigned long count;

    size = cgio_compute_data_size (data_type, ndims, dims, &count);
    return (size_t)size * (size_t)count;
}

/*---------------------------------------------------------*/

static int recurse_nodes (int input, double InputID,
    int output, double OutputID, int follow_links, int depth)
{
    int n, nchild, cnt, name_len, file_len;
    char name[CGIO_MAX_NAME_LENGTH+1];
    char *link_name, *link_file;
    double childID, newID;

    /* Copy the data from the current input node to the output node */

    if (depth && cgio_copy_node(input, InputID, output, OutputID))
        return 1;

    /* Loop through the children of the current node */

    if (cgio_number_children(input, InputID, &nchild))
        return 1;
    for (n = 1; n <= nchild; n++) {
        if (cgio_children_ids(input, InputID, n, 1, &cnt, &childID) ||
            cgio_get_name(input, childID, name) ||
            cgio_is_link(input, childID, &name_len))
            return 1;
        if (name_len) {
            if (cgio_link_size(input, childID, &file_len, &name_len))
                return 1;
        }
        if (name_len && (file_len == 0 || follow_links == 0)) {
            link_file = (char *) malloc (file_len + name_len + 2);
            if (link_file == NULL) {
                set_error(CGIO_ERR_MALLOC);
                return 1;
            }
            link_name = link_file + file_len + 1;
            if (cgio_get_link(input, childID, link_file, link_name)) {
                free (link_name);
                return 1;
            }
            link_file[file_len] = 0;
            link_name[name_len] = 0;
            if (cgio_create_link(output, OutputID, name, link_file,
                    link_name, &newID)) {
                free (link_file);
                return 1;
            }
            free (link_file);
        }
        else {
            if (cgio_create_node(output, OutputID, name, &newID) ||
                recurse_nodes(input, childID, output, newID,
                    follow_links, ++depth))
                return 1;
        }
    }
    return 0;
}

/*---------------------------------------------------------*/

static int rewrite_file (int cginp, const char *filename)
{
    int cgout, ierr;
    cgns_io *input, *output;
    char *tmpfile, *linkfile = NULL;
#ifdef S_IFLNK
    struct stat st;
#endif

    input = get_cgnsio(cginp, 0);
    if (input->mode != CGIO_MODE_READ && cgio_flush_to_disk(cginp))
        return get_error();

#ifdef S_IFLNK
    if (!lstat(filename, &st) && (st.st_mode & S_IFLNK) == S_IFLNK) {
        int len;
        linkfile = (char *)malloc(st.st_size + 1);
        if (linkfile == NULL)
            return set_error(CGIO_ERR_MALLOC);
        len = readlink(filename, linkfile, st.st_size + 1);
        if (len < 0 || len > st.st_size) {
            free(linkfile);
            linkfile = NULL;
        }
        else {
            linkfile[len] = 0;
        }
    }
#endif
    if (linkfile == NULL) {
        tmpfile = (char *)malloc(strlen(filename) + 6);
        if (tmpfile == NULL)
            return set_error(CGIO_ERR_MALLOC);
        sprintf(tmpfile, "%s.temp", filename);
    }
    else {
        tmpfile = (char *)malloc(strlen(linkfile) + 6);
        if (tmpfile == NULL) {
            free(linkfile);
            return set_error(CGIO_ERR_MALLOC);
        }
        sprintf(tmpfile, "%s.temp", linkfile);
    }
    unlink(tmpfile);

    if (cgio_open_file(tmpfile, CGIO_MODE_WRITE, input->type, &cgout)) {
        unlink(tmpfile);
        free(tmpfile);
        if (linkfile != NULL) free(linkfile);
        return get_error();
    }
    output = get_cgnsio(cgout, 0);

    ierr = recurse_nodes(cginp, input->rootid, cgout, output->rootid, 0, 0);
    cgio_close_file (cgout);

    if (ierr) {
        unlink(tmpfile);
        free(tmpfile);
        if (linkfile != NULL) free(linkfile);
        return set_error(ierr);
    }

    ierr = CGIO_ERR_NONE;
    cgio_close_file (cginp);
    if (linkfile == NULL) {
        unlink(filename);
        if (rename(tmpfile, filename))
            ierr = CGIO_ERR_FILE_RENAME;
    }
    else {
        unlink(linkfile);
        if (rename(tmpfile, linkfile))
            ierr = CGIO_ERR_FILE_RENAME;
        free(linkfile);
    }
    free(tmpfile);
    return set_error(ierr);
}

/*=========================================================
 * paths for searching for linked-to files
 *=========================================================*/

int cgio_path_add (const char *path)
{
    if (path == NULL || !*path)
        return set_error(CGIO_ERR_NULL_FILE);
    if (cgio_n_paths)
        cgio_paths = (char **) realloc (cgio_paths,
            (cgio_n_paths+1) * sizeof(char *));
    else
        cgio_paths = (char **) malloc (sizeof(char *));
    if (cgio_paths == NULL) {
        cgio_n_paths = 0;
        return set_error(CGIO_ERR_MALLOC);
    }
    cgio_paths[cgio_n_paths] = (char *) malloc (strlen(path)+1);
    if (cgio_paths[cgio_n_paths] == NULL)
        return set_error(CGIO_ERR_MALLOC);
    strcpy(cgio_paths[cgio_n_paths], path);
    cgio_n_paths++;
    return set_error(CGIO_ERR_NONE);
}

/*---------------------------------------------------------*/

int cgio_path_delete (const char *path)
{
    int n;

    if (cgio_n_paths == 0) {
        if (path != NULL)
            return set_error(CGIO_ERR_NO_MATCH);
        return set_error(CGIO_ERR_NONE);
    }
    if (path != NULL) {
        for (n = 0; n < cgio_n_paths; n++) {
            if (cgio_paths[n] != NULL &&
                0 == strcmp(path, cgio_paths[n])) {
                free(cgio_paths[n]);
                cgio_paths[n] = NULL;
                return set_error(CGIO_ERR_NONE);
            }
        }
        return set_error(CGIO_ERR_NO_MATCH);
    }
    for (n = 0; n < cgio_n_paths; n++) {
        if (cgio_paths[n] != NULL)
            free(cgio_paths[n]);
    }
    free(cgio_paths);
    cgio_n_paths = 0;
    cgio_paths = NULL;
    return set_error(CGIO_ERR_NONE);
}

/*---------------------------------------------------------*/

int cgio_find_file (const char *filename, int file_type,
    int max_path_len, char *pathname) {
    int n, size, len, type;
    char *p, *s;

    if (filename == NULL || !*filename)
        return set_error(CGIO_ERR_NULL_FILE);
    size = max_path_len - 1 - strlen(filename);
    if (size < 0) return set_error(CGIO_ERR_TOO_SMALL);
    if (cgio_check_file(filename, &type) == CGIO_ERR_NONE &&
       (file_type == CGIO_FILE_NONE || file_type == type)) {
        strcpy(pathname, filename);
        return set_error(CGIO_ERR_NONE);
    }
    if (get_error() == CGIO_ERR_TOO_MANY)
        return CGIO_ERR_TOO_MANY;

    /* full path */

    if (*filename == '/'
#ifdef _WIN32
        || *filename == '\\' || *(filename+1) == ':'
#endif
    ) return set_error(CGIO_ERR_NOT_FOUND);

    size -= 1;

    /* check file type environment variable */

    if (file_type == CGIO_FILE_ADF || file_type == CGIO_FILE_ADF2)
        p = getenv ("ADF_LINK_PATH");
#ifdef BUILD_HDF5
    else if (file_type == CGIO_FILE_HDF5)
        p = getenv ("HDF5_LINK_PATH");
#endif
#ifdef BUILD_XML
    else if (file_type == CGIO_FILE_XML)
        p = getenv ("XML_LINK_PATH");
#endif
    else
        p = NULL;
    while (p != NULL && *p) {
#ifdef _WIN32
        if (NULL == (s = strchr (p, ';')))
#else
        if (NULL == (s = strchr (p, ':')))
#endif
            len = strlen(p);
        else
            len = (int)(s++ - p);
        if (len) {
            if (len > size) return set_error(CGIO_ERR_TOO_SMALL);
            strncpy (pathname, p, len);
#ifdef _WIN32
            for (n = 0; n < len; n++) {
                if (*p == '\\') *p = '/';
            }
#endif
            p = pathname + len;
            if (*(p-1) != '/')
                *p++ = '/';
            strcpy (p, filename);
            if (cgio_check_file(pathname, &type) == CGIO_ERR_NONE &&
               (file_type == CGIO_FILE_NONE || file_type == type))
                return set_error(CGIO_ERR_NONE);
        }
        p = s;
    }

    /* check $CGNS_LINK_PATH environment variable */

    p = getenv ("CGNS_LINK_PATH");
    while (p != NULL && *p) {
#ifdef _WIN32
        if (NULL == (s = strchr (p, ';')))
#else
        if (NULL == (s = strchr (p, ':')))
#endif
            len = strlen(p);
        else
            len = (int)(s++ - p);
        if (len) {
            if (len > size) return set_error(CGIO_ERR_TOO_SMALL);
            strncpy (pathname, p, len);
#ifdef _WIN32
            for (n = 0; n < len; n++) {
                if (*p == '\\') *p = '/';
            }
#endif
            p = pathname + len;
            if (*(p-1) != '/')
                *p++ = '/';
            strcpy (p, filename);
            if (cgio_check_file(pathname, &type) == CGIO_ERR_NONE &&
               (file_type == CGIO_FILE_NONE || file_type == type))
                return set_error(CGIO_ERR_NONE);
        }
        p = s;
    }

    /* check list of search paths */

    for (n = 0; n < cgio_n_paths; n++) {
        for (p = cgio_paths[n]; p != NULL && *p; ) {
#ifdef _WIN32
            if (NULL == (s = strchr (p, ';')))
#else
            if (NULL == (s = strchr (p, ':')))
#endif
                len = strlen(p);
            else
                len = (int)(s++ - p);
            if (len) {
                if (len > size) return set_error(CGIO_ERR_TOO_SMALL);
                strncpy (pathname, p, len);
#ifdef _WIN32
                for (n = 0; n < len; n++) {
                    if (*p == '\\') *p = '/';
                }
#endif
                p = pathname + len;
                if (*(p-1) != '/')
                    *p++ = '/';
                strcpy (p, filename);
                if (cgio_check_file(pathname, &type) == CGIO_ERR_NONE &&
                   (file_type == CGIO_FILE_NONE || file_type == type))
                    return set_error(CGIO_ERR_NONE);
            }
            p = s;
        }
    }

    return set_error(CGIO_ERR_NOT_FOUND);
}

/*=========================================================
 * utility routines independent of open files
 *=========================================================*/

int cgio_is_supported (int file_type)
{
    if (file_type == CGIO_FILE_ADF || file_type == CGIO_FILE_ADF2)
        return set_error(CGIO_ERR_NONE);
#ifdef BUILD_HDF5
    if (file_type == CGIO_FILE_HDF5)
        return set_error(CGIO_ERR_NONE);
#endif
#ifdef BUILD_XML
    if (file_type == CGIO_FILE_XML)
        return set_error(CGIO_ERR_NONE);
#endif
    return set_error(CGIO_ERR_FILE_TYPE);
}

/*---------------------------------------------------------*/

int cgio_configure (int what, void *value)
{
    int ierr = CGIO_ERR_BAD_OPTION;

    if (what > 300) {
#ifdef BUILD_XML
        ierr = ADFX_Configure(what-300, value);
#endif
    }
    else if (what > 200) {
#ifdef BUILD_HDF5
        ADFH_Configure(what-200, value, &ierr);
#endif
    }
/* nothing here yet
    else if (what > 100) {
    }
*/
    return set_error(ierr);
}

/*---------------------------------------------------------*/

void cgio_cleanup ()
{
    if (num_open) {
        int n;
        num_open++;
        for (n = 0; n < num_iolist; n++) {
            if (iolist[n].type != CGIO_FILE_NONE)
                cgio_close_file(n + 1);
        }
        free(iolist);
        num_iolist = 0;
        num_open = 0;
    }
    cgio_path_delete(NULL);
}

/*---------------------------------------------------------*/

int cgio_check_file (const char *filename, int *file_type)
{
    int n;
    char *p, buf[256];
    FILE *fp;
    static char *HDF5sig = "\211HDF\r\n\032\n";
    struct stat st;

    if (access (filename, 0) || stat (filename, &st) ||
        S_IFREG != (st.st_mode & S_IFREG))
        return set_error(CGIO_ERR_NOT_FOUND);

    *file_type = CGIO_FILE_NONE;
    if (NULL == (fp = fopen (filename, "rb"))) {
        if (errno == EMFILE)
            return set_error(CGIO_ERR_TOO_MANY);
        return set_error(CGIO_ERR_FILE_OPEN);
    }
    fread (buf, 1, sizeof(buf), fp);
    buf[sizeof(buf)-1] = 0;
    fclose (fp);

    /* check for ADF */

    if (0 == strncmp (&buf[4], "ADF Database Version", 20)) {
        *file_type = CGIO_FILE_ADF;
        return set_error(CGIO_ERR_NONE);
    }

    /* check for HDF5 */

    for (n = 0; n < 8; n++) {
        if (buf[n] != HDF5sig[n]) break;
    }
    if (n == 8) {
        *file_type = CGIO_FILE_HDF5;
        return set_error(CGIO_ERR_NONE);
    }

    /* check for XML */

    for (n = 0; n < sizeof(buf)-1; n++) {
        if (!isascii (buf[n]))
            return set_error(CGIO_ERR_FILE_TYPE);
    }
    for (p = buf; *p && isspace(*p); p++)
        ;
    if (0 == strncmp (p, "<?xml", 5)) {
        while ((p = strchr (p, 'A')) != NULL) {
            if (0 == strncmp (p, "ADFXfile", 8)) {
                *file_type = CGIO_FILE_XML;
                return set_error(CGIO_ERR_NONE);
            }
            p++;
        }
    }

    return set_error(CGIO_ERR_FILE_TYPE);
}

/*---------------------------------------------------------*/

int cgio_compute_data_size (const char *data_type,
    int ndims, const int *dims, unsigned long *count)
{
    if (ndims > 0) {
        int i;
        *count = (unsigned long)dims[0];
        for (i = 1; i < ndims; i++)
            *count *= (unsigned long)dims[i];
    }
    else {
        *count = 0;
    }
    switch (*data_type) {
        case 'B':
        case 'C':
            return 1;
        case 'I':
        case 'U':
            if (data_type[1] == '4') return sizeof(int);
            if (data_type[1] == '8') return sizeof(long);
            break;
        case 'R':
            if (data_type[1] == '4') return sizeof(float);
            if (data_type[1] == '8') return sizeof(double);
            break;
        case 'X':
            if (data_type[1] == '4') return (2 * sizeof(float));
            if (data_type[1] == '8') return (2 * sizeof(double));
            break;
    }
    return 0;
}

/*=========================================================
 * file operations
 *=========================================================*/

int cgio_open_file (const char *filename, int file_mode,
    int file_type, int *cgio_num)
{
    int n, type, ierr;
    char *fmode;
    double rootid;

    *cgio_num = 0;
    switch(file_mode) {
        case CGIO_MODE_READ:
        case 'r':
        case 'R':
            if (cgio_check_file(filename, &type))
                return get_error();
            file_type = type;
            file_mode = CGIO_MODE_READ;
            fmode = "READ_ONLY";
            break;
        case CGIO_MODE_WRITE:
        case 'w':
        case 'W':
            file_mode = CGIO_MODE_WRITE;
            fmode = "NEW";
            break;
        case CGIO_MODE_MODIFY:
        case 'm':
        case 'M':
            if (cgio_check_file(filename, &type))
                return get_error();
            file_type = type;
            file_mode = CGIO_MODE_MODIFY;
            fmode = "OLD";
            break;
        default:
            return set_error(CGIO_ERR_FILE_MODE);
    }
    last_type = file_type;
    if (file_type == CGIO_FILE_ADF || file_type == CGIO_FILE_ADF2) {
        ADF_Database_Open(filename, fmode, "NATIVE", &rootid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (file_type == CGIO_FILE_HDF5) {
        ADFH_Database_Open(filename, fmode, "NATIVE", &rootid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (file_type == CGIO_FILE_XML) {
        ierr = ADFX_Open_File(filename, fmode, &rootid);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    if (num_iolist == 0) {
        num_iolist = 5;
        iolist = (cgns_io *) malloc (num_iolist * sizeof(cgns_io));
        if (iolist == NULL) {
            fprintf(stderr, "malloc failed for IO list\n");
            exit(1);
        }
        for (n = 0; n < num_iolist; n++)
            iolist[n].type = CGIO_FILE_NONE;
    }
    for (n = 0; n < num_iolist; n++) {
        if (iolist[n].type == CGIO_FILE_NONE)
            break;
    }
    if (n == num_iolist) {
        num_iolist++;
        iolist = (cgns_io *) realloc (iolist, num_iolist * sizeof(cgns_io));
        if (iolist == NULL) {
            fprintf(stderr, "realloc failed for IO list\n");
            exit(1);
        }
    }
    iolist[n].type = file_type;
    iolist[n].mode = file_mode;
    iolist[n].rootid = rootid;
    *cgio_num = n + 1;
    num_open++;

    return set_error(CGIO_ERR_NONE);
}

/*---------------------------------------------------------*/

int cgio_close_file (int cgio_num)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Database_Close(cgio->rootid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Database_Close(cgio->rootid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Close_File(cgio->rootid, 0);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    cgio->type = CGIO_FILE_NONE;
    if (--num_open == 0) {
        free(iolist);
        num_iolist = 0;
    }
    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_compress_file (int cgio_num, const char *filename)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        if (rewrite_file (cgio_num, filename)) {
            ierr = get_error();
            cgio_close_file(cgio_num);
            return set_error(ierr);
        }
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        if (rewrite_file (cgio_num, filename)) {
            ierr = get_error();
            cgio_close_file(cgio_num);
            return set_error(ierr);
        }
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Close_File(cgio->rootid, 1);
        if (ierr) return set_error(ierr);
        cgio->type = CGIO_FILE_NONE;
        if (--num_open == 0) {
            free(iolist);
            num_iolist = 0;
        }
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_copy_file (int cgio_num_inp, int cgio_num_out,
    int follow_links)
{
    cgns_io *input, *output;

    if ((input  = get_cgnsio(cgio_num_inp, 0)) == NULL ||
        (output = get_cgnsio(cgio_num_out, 1)) == NULL)
        return get_error();
    if (input->mode != CGIO_MODE_READ &&
        cgio_flush_to_disk(cgio_num_inp))
        return get_error();
    if (recurse_nodes(cgio_num_inp, input->rootid,
            cgio_num_out, output->rootid, follow_links, 0))
        return get_error();
    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_flush_to_disk (int cgio_num)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();
    if (cgio->mode == CGIO_MODE_READ) return CGIO_ERR_NONE;

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Flush_to_Disk(cgio->rootid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Flush_to_Disk(cgio->rootid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Flush_to_Disk(cgio->rootid);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*=========================================================
 * file information
 *=========================================================*/

int cgio_library_version (int cgio_num, char *version)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Library_Version(version, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Library_Version(version, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Library_Version(version);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_file_version (int cgio_num, char *file_version,
    char *creation_date, char *modified_date)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Database_Version(cgio->rootid, file_version,
            creation_date, modified_date, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Database_Version(cgio->rootid, file_version,
            creation_date, modified_date, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_File_Version(cgio->rootid, file_version,
            creation_date, modified_date);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_root_id (int cgio_num, double *rootid)
{
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();
    *rootid = cgio->rootid;

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_file_type (int cgio_num, int *file_type)
{
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();
    *file_type = cgio->type;

    return CGIO_ERR_NONE;
}

/*=========================================================
 * error handling
 *=========================================================*/

void cgio_error_code (int *errcode, int *file_type)
{
    *errcode = last_err;
    *file_type = last_type;
}

/*---------------------------------------------------------*/

int cgio_error_message (int max_len, char *error_msg)
{
    char msg[ADF_MAX_ERROR_STR_LENGTH+1];

    if (last_err <= 0) {
        int errcode = -last_err;
        if (errcode >= CGIO_MAX_ERRORS)
            strcpy(msg, "unknown cgio error message");
        else
            strcpy(msg, cgio_ErrorMessage[errcode]);
    }
    else if (last_type == CGIO_FILE_ADF || last_type == CGIO_FILE_ADF2) {
        ADF_Error_Message(last_err, msg);
    }
#ifdef BUILD_HDF5
    else if (last_type == CGIO_FILE_HDF5) {
        ADFH_Error_Message(last_err, msg);
    }
#endif
#ifdef BUILD_XML
    else if (last_type == CGIO_FILE_XML) {
        ADFX_Error_Message(last_err, msg);
    }
#endif
    else {
        strcpy(msg, "unknown error message");
    }
    strncpy(error_msg, msg, max_len-1);
    error_msg[max_len-1] = 0;
    return last_err;
}

/*---------------------------------------------------------*/

void cgio_error_exit (const char *msg)
{
    fflush(stdout);
    if (msg != NULL && *msg)
        fprintf(stderr, "%s:", msg);
    if (last_err) {
        char errmsg[81];
        cgio_error_message(sizeof(errmsg), errmsg);
        fprintf(stderr, "%s", errmsg);
    }
    putc('\n', stderr);
    cgio_cleanup();
    exit(1);
}

/*=========================================================
 * basic node operations
 *=========================================================*/

int cgio_create_node (int cgio_num, double pid,
    const char *name, double *id)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Create(pid, name, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Create(pid, name, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Create_Node(pid, name, id);
        if (ierr > 0) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_new_node (int cgio_num, double pid, const char *name,
    const char *label, const char *data_type, int ndims,
    const int *dims, const void *data, double *id)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Create(pid, name, id, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADF_Set_Label(*id, label, &ierr);
        if (ierr > 0) return set_error(ierr);
        if (data_type != NULL && strcmp(data_type, "MT")) {
            ADF_Put_Dimension_Information(*id, data_type, ndims, dims, &ierr);
            if (ierr > 0) return set_error(ierr);
            if (data != NULL) {
                ADF_Write_All_Data(*id, (const char *)data, &ierr);
                if (ierr > 0) return set_error(ierr);
            }
        }
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Create(pid, name, id, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADFH_Set_Label(*id, label, &ierr);
        if (ierr > 0) return set_error(ierr);
        if (data_type != NULL && strcmp(data_type, "MT")) {
            ADFH_Put_Dimension_Information(*id, data_type, ndims, dims, &ierr);
            if (ierr > 0) return set_error(ierr);
            if (data != NULL) {
                ADFH_Write_All_Data(*id, (const char *)data, &ierr);
                if (ierr > 0) return set_error(ierr);
            }
        }
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_New_Node(pid, name, label, data_type,
                  ndims, dims, data, id);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_delete_node (int cgio_num, double pid, double id)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Delete(pid, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Delete(pid, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Delete_Node(pid, id);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_move_node (int cgio_num, double pid, double id,
    double new_pid)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Move_Child(pid, id, new_pid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Move_Child(pid, id, new_pid, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Move_Node(pid, id, new_pid);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_copy_node (int cgio_num_inp, double id_inp,
    int cgio_num_out, double id_out)
{
    cgns_io *input, *output;
    char label[CGIO_MAX_NAME_LENGTH+1];
    char data_type[CGIO_MAX_NAME_LENGTH+1];
    int ierr = 0, ndims, dims[CGIO_MAX_DIMENSIONS];
    size_t data_size = 0;
    void *data = NULL;

    if ((input  = get_cgnsio(cgio_num_inp, 0)) == NULL ||
        (output = get_cgnsio(cgio_num_out, 1)) == NULL)
        return get_error();

    /* read the input node data */

    if (input->type == CGIO_FILE_ADF || input->type == CGIO_FILE_ADF2) {
        ADF_Get_Label(id_inp, label, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADF_Get_Data_Type(id_inp, data_type, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADF_Get_Number_of_Dimensions(id_inp, &ndims, &ierr);
        if (ierr > 0) return set_error(ierr);
        if (ndims > 0) {
            ADF_Get_Dimension_Values(id_inp, dims, &ierr);
            if (ierr > 0) return set_error(ierr);
            data_size = compute_data_size(data_type, ndims, dims);
            if (data_size) {
                data = malloc(data_size);
                if (data == NULL) return set_error(CGIO_ERR_MALLOC);
                ADF_Read_All_Data(id_inp, (char *)data, &ierr);
                if (ierr > 0) {
                    free(data);
                    return set_error(ierr);
                }
            }
        }
    }
#ifdef BUILD_HDF5
    else if (input->type == CGIO_FILE_HDF5) {
        ADFH_Get_Label(id_inp, label, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADFH_Get_Data_Type(id_inp, data_type, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADFH_Get_Number_of_Dimensions(id_inp, &ndims, &ierr);
        if (ierr > 0) return set_error(ierr);
        if (ndims > 0) {
            ADFH_Get_Dimension_Values(id_inp, dims, &ierr);
            if (ierr > 0) return set_error(ierr);
            data_size = compute_data_size(data_type, ndims, dims);
            if (data_size) {
                data = malloc(data_size);
                if (data == NULL) return set_error(CGIO_ERR_MALLOC);
                ADFH_Read_All_Data(id_inp, (char *)data, &ierr);
                if (ierr > 0) {
                    free(data);
                    return set_error(ierr);
                }
            }
        }
    }
#endif
#ifdef BUILD_XML
    else if (input->type == CGIO_FILE_XML) {
        if ((ierr = ADFX_Get_Label(id_inp, label)) != 0 ||
            (ierr = ADFX_Get_Data_Type(id_inp, data_type)) != 0 ||
            (ierr = ADFX_Get_Dimensions (id_inp, &ndims, dims)) != 0)
            return set_error(ierr);
        if (ndims > 0) {
            data_size = compute_data_size(data_type, ndims, dims);
            if (data_size) {
                data = malloc(data_size);
                if (data == NULL) return set_error(CGIO_ERR_MALLOC);
                ierr = ADFX_Read_All_Data(id_inp, data);
                if (ierr > 0) {
                    free(data);
                    return set_error(ierr);
                }
            }
        }
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    /* write data to output node */

    if (output->type == CGIO_FILE_ADF || output->type == CGIO_FILE_ADF2) {
        ADF_Set_Label(id_out, label, &ierr);
        if (ierr <= 0) {
            ADF_Put_Dimension_Information(id_out, data_type, ndims,
                dims, &ierr);
            if (ierr <= 0 && data_size)
                ADF_Write_All_Data(id_out, (const char *)data, &ierr);
        }
        if (data_size) free(data);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (output->type == CGIO_FILE_HDF5) {
        ADFH_Set_Label(id_out, label, &ierr);
        if (ierr <= 0) {
            ADFH_Put_Dimension_Information(id_out, data_type, ndims,
                dims, &ierr);
            if (ierr <= 0 && data_size)
                ADFH_Write_All_Data(id_out, (const char *)data, &ierr);
        }
        if (data_size) free(data);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (output->type == CGIO_FILE_XML) {
        ierr = ADFX_Set_Label(id_out, label);
        if (ierr == 0) {
            ierr = ADFX_Set_Dimensions(id_out, data_type, ndims, dims);
            if (ierr == 0 && data_size)
                ierr = ADFX_Write_All_Data(id_out, data);
        }
        if (data_size) free(data);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        if (data_size) free(data);
        set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_release_id (int cgio_num, double id)
{
#ifdef BUILD_HDF5
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();
    if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Release_ID(id);
    }
#endif

    return CGIO_ERR_NONE;
}

/*=========================================================
 * links
 *=========================================================*/

int cgio_is_link (int cgio_num, double id, int *link_len)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Is_Link(id, link_len, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Is_Link(id, link_len, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Is_Link(id, link_len);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_link_size (int cgio_num, double id, int *file_len,
    int *name_len)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Link_Size(id, file_len, name_len, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Link_Size(id, file_len, name_len, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Link_Size(id, file_len, name_len);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_create_link (int cgio_num, double pid, const char *name,
    const char *filename, const char *name_in_file, double *id)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Link(pid, name, filename, name_in_file, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Link(pid, name, filename, name_in_file, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Create_Link(pid, name, filename, name_in_file, id);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_link (int cgio_num, double id,
    char *filename, char *name_in_file)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Link_Path(id, filename, name_in_file, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Link_Path(id, filename, name_in_file, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Link(id, filename, name_in_file);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*=========================================================
 * node children
 *=========================================================*/

int cgio_number_children (int cgio_num, double id,
    int *num_children)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Number_of_Children(id, num_children, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Number_of_Children(id, num_children, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Number_Children(id, num_children);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_children_ids (int cgio_num, double pid,
    int start, int max_ret, int *num_ret, double *ids)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Children_IDs(pid, start, max_ret, num_ret, ids, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Children_IDs(pid, start, max_ret, num_ret, ids, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Children_IDs(pid, start, max_ret, num_ret, ids);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_children_names (int cgio_num, double pid, int start, int max_ret,
    int name_len, int *num_ret, char *names)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Children_Names(pid, start, max_ret, name_len-1,
            num_ret, names, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Children_Names(pid, start, max_ret, name_len,
            num_ret, names, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Children_Names(pid, start, max_ret, name_len,
                   num_ret, names);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*=========================================================
 * read nodes
 *=========================================================*/

int cgio_get_node_id (int cgio_num, double pid,
    const char *name, double *id)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Node_ID(pid, name, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Node_ID(pid, name, id, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Node_ID(pid, name, id);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_name (int cgio_num, double id, char *name)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Name(id, name, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Name(id, name, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Name(id, name);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_label (int cgio_num, double id, char *label)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Label(id, label, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Label(id, label, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Label(id, label);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_data_type (int cgio_num, double id, char *data_type)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Data_Type(id, data_type, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Data_Type(id, data_type, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Data_Type(id, data_type);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_data_size (int cgio_num, double id, unsigned long *data_size)
{
    int ierr, byte, ndims, dims[CGIO_MAX_DIMENSIONS];
    char data_type[CGIO_MAX_NAME_LENGTH];
    cgns_io *cgio;

    *data_size = 0;
    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Data_Type(id, data_type, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADF_Get_Number_of_Dimensions(id, &ndims, &ierr);
        if (ierr > 0) return set_error(ierr);
        if (ndims > 0) {
            ADF_Get_Dimension_Values(id, dims, &ierr);
            if (ierr > 0) return set_error(ierr);
        }
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Data_Type(id, data_type, &ierr);
        if (ierr > 0) return set_error(ierr);
        ADFH_Get_Number_of_Dimensions(id, &ndims, &ierr);
        if (ierr > 0) return set_error(ierr);
        if (ndims > 0) {
            ADFH_Get_Dimension_Values(id, dims, &ierr);
            if (ierr > 0) return set_error(ierr);
        }
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Data_Type(id, data_type);
        if (ierr) return set_error(ierr);
        ierr = ADFX_Get_Dimensions(id, &ndims, dims);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    byte = cgio_compute_data_size(data_type, ndims, dims, data_size);
    *data_size *= (unsigned long)byte;
    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_get_dimensions (int cgio_num, double id,
    int *num_dims, int *dims)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Get_Number_of_Dimensions(id, num_dims, &ierr);
        if (NULL != dims && ierr <= 0 && *num_dims > 0)
            ADF_Get_Dimension_Values(id, dims, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Get_Number_of_Dimensions(id, num_dims, &ierr);
        if (NULL != dims && ierr <= 0 && *num_dims > 0)
            ADFH_Get_Dimension_Values(id, dims, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Get_Dimensions(id, num_dims, dims);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_read_all_data (int cgio_num, double id, void *data)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Read_All_Data(id, (char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Read_All_Data(id, (char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Read_All_Data(id, data);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_read_data (int cgio_num, double id,
    const int *s_start, const int *s_end, const int *s_stride,
    int m_num_dims, const int *m_dims, const int *m_start,
    const int *m_end, const int *m_stride, void *data)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 0)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Read_Data(id, s_start, s_end, s_stride, m_num_dims,
            m_dims, m_start, m_end, m_stride, (char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Read_Data(id, s_start, s_end, s_stride, m_num_dims,
            m_dims, m_start, m_end, m_stride, (char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Read_Data(id, s_start, s_end, s_stride, m_num_dims,
                    m_dims, m_start, m_end, m_stride, data);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*=========================================================
 * write nodes
 *=========================================================*/

int cgio_set_name (int cgio_num, double pid, double id,
    const char *name)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Put_Name(pid, id, name, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Put_Name(pid, id, name, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Set_Name(pid, id, name);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_set_label (int cgio_num, double id, const char *label)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Set_Label(id, label, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Set_Label(id, label, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Set_Label(id, label);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_set_dimensions (int cgio_num, double id,
    const char *data_type, int num_dims, const int *dims)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Put_Dimension_Information(id, data_type, num_dims, dims, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Put_Dimension_Information(id, data_type, num_dims, dims, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Set_Dimensions(id, data_type, num_dims, dims);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_write_all_data (int cgio_num, double id,
    const void *data)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Write_All_Data(id, (const char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Write_All_Data(id, (const char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Write_All_Data(id, data);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

/*---------------------------------------------------------*/

int cgio_write_data (int cgio_num, double id,
    const int *s_start, const int *s_end, const int *s_stride,
    int m_num_dims, const int *m_dims, const int *m_start,
    const int *m_end, const int *m_stride, const void *data)
{
    int ierr;
    cgns_io *cgio;

    if ((cgio = get_cgnsio(cgio_num, 1)) == NULL)
        return get_error();

    if (cgio->type == CGIO_FILE_ADF || cgio->type == CGIO_FILE_ADF2) {
        ADF_Write_Data(id, s_start, s_end, s_stride, m_num_dims,
            m_dims, m_start, m_end, m_stride, (const char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#ifdef BUILD_HDF5
    else if (cgio->type == CGIO_FILE_HDF5) {
        ADFH_Write_Data(id, s_start, s_end, s_stride, m_num_dims,
            m_dims, m_start, m_end, m_stride, (const char *)data, &ierr);
        if (ierr > 0) return set_error(ierr);
    }
#endif
#ifdef BUILD_XML
    else if (cgio->type == CGIO_FILE_XML) {
        ierr = ADFX_Write_Data(id, s_start, s_end, s_stride, m_num_dims,
                  m_dims, m_start, m_end, m_stride, data);
        if (ierr) return set_error(ierr);
    }
#endif
    else {
        return set_error(CGIO_ERR_FILE_TYPE);
    }

    return CGIO_ERR_NONE;
}

