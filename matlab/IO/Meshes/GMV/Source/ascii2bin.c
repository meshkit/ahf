
/*  To compile:                            */
/*  cc -o ascii2bin ascii2bin.c gmvread.c  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gmvread.h"
#include "gmvwrite.c"

void error_message(char *);
void do_header(void);
void do_nodes(void);
void do_nodev(void);
void do_cells(void);
void do_faces(void);
void do_vfaces(void);
void do_xfaces(void);
void do_materials(void);
void do_velocity(void);
void do_variables(void);
void do_flags(void);
void do_polygons(void);
void do_tracers(void);
void do_probtime(void);
void do_cycleno(void);
void do_nodeids(void);
void do_cellids(void);
void do_surface(void);
void do_surfmats(void);
void do_surfvel(void);
void do_surfvars(void);
void do_surfflag(void);
void do_units(void);
void do_vinfo(void);
void do_traceids(void);
void do_faceids(void);
void do_surfids(void);
void do_groups(void);
void do_subvars(void);
void do_codename(void);
void do_codever(void);
void do_simdate(void);

char gmvfilename[200];

int main(int argc, char **argv)
{
  int ierr, iend;

   if (argc != 3)
     {
      error_message("Error...wrong number of arguments!");
      exit(0);
     }

   /*  Open gmvfile without reading fromfiles.  */
   strcpy(gmvfilename,argv[1]);
   ierr = gmvread_open_fromfileskip(gmvfilename);
   if (ierr > 0) exit(0);

   gmvwrite_openfile_cxir(argv[2],4,8);

   /*  Loop thrhough file until GMVEND.  */
   iend = 0;
   while (iend == 0)
     {
      gmvread_data();

      /*  Check for GMVEND.  */
      if (gmv_data.keyword == GMVEND)
        {
         iend = 1;
         gmvwrite_closefile();
        }

      /*  Check for GMVERROR.  */
      if (gmv_data.keyword == GMVERROR)
        {
         iend = 1;
        }

      /*  Process the data.  */
      switch (gmv_data.keyword)
        {
         case(NODES):
            if (gmv_data.num2 == NODES)
               do_nodes();
            else if (gmv_data.num2 == NODE_V)
               do_nodev();
            break;
         case(CELLS):
            do_cells();
            break;
         case(FACES):
            do_faces();
            break;
         case(VFACES):
            do_vfaces();
            break;
         case(XFACES):
            do_xfaces();
            break;
         case(MATERIAL):
            do_materials();
            break;
         case(VELOCITY):
	    do_velocity();
            break;
         case(VARIABLE):
            do_variables();
            break;
         case(FLAGS):
            do_flags();
            break;
         case(POLYGONS):
            do_polygons();
            break;
         case(TRACERS):
            do_tracers();
            break;
         case(PROBTIME):
            do_probtime();
            break;
         case(CYCLENO):
            do_cycleno();
            break;
         case(NODEIDS):
            do_nodeids();
            break;
         case(CELLIDS):
            do_cellids();
            break;
         case(SURFACE):
            do_surface();
            break;
         case(SURFMATS):
            do_surfmats();
            break;
         case(SURFVEL):
            do_surfvel();
            break;
         case(SURFVARS):
            do_surfvars();
            break;
         case(SURFFLAG):
            do_surfflag();
            break;
         case(UNITS):
            do_units();
            break;
         case(VINFO):
            do_vinfo();
            break;
         case(TRACEIDS):
            do_traceids();
            break;
         case(GROUPS):
            do_groups();
            break;
         case(FACEIDS):
            do_faceids();
            break;
         case(SURFIDS):
            do_surfids();
            break;
         case(SUBVARS):
            do_subvars();
            break;
         case(CODENAME):
            do_codename();
            break;
         case(CODEVER):
            do_codever();
            break;
         case(SIMDATE):
            do_simdate();
            break;
         case(GMVEND):
            break;
        }
     }

   printf("Success!\n");
   return 0;
}

/* --------------------------------------------------------------- */

void do_probtime(void)
{
  double ptime;

  printf("Converting problem time.\n");
  ptime = gmv_data.doubledata1[0];
  gmvwrite_probtime(ptime);
}

/* --------------------------------------------------------------- */

void do_cycleno(void)
{
  int cycle;

  printf("Converting cycle number.\n");
  cycle = gmv_data.num;
  gmvwrite_cycleno(cycle);
}

/* --------------------------------------------------------------- */

void do_tracers(void)
{
  int ntrace, i;
  double *x, *y, *z, *data;
  char word1[40];

   if (gmv_data.datatype == XYZ)
     {
      printf("Converting tracers.\n");
      ntrace = gmv_data.num;
      if (ntrace > 0)
        {
         x = (double *) malloc(sizeof(double) * ntrace);
         y = (double *) malloc(sizeof(double) * ntrace);
         z = (double *) malloc(sizeof(double) * ntrace);
         for (i = 0; i < ntrace; i++)
           {
            x[i] = gmv_data.doubledata1[i];
            y[i] = gmv_data.doubledata2[i];
            z[i] = gmv_data.doubledata3[i];
           }
        }
      gmvwrite_tracers_header(ntrace, x, y, z);
      free(x);  free(y);  free(z);
      return;
     }

   if (gmv_data.datatype == TRACERDATA)
     {
      ntrace = gmv_data.num;
      strcpy(word1,gmv_data.name1);
      data = (double *) malloc(sizeof(double) * ntrace);
      for (i = 0; i < ntrace; i++)
         data[i] = gmv_data.doubledata1[i];
      gmvwrite_tracers_name_data(ntrace, word1, data);
      free(data);
      return;
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_tracers_endtrace();
}

/* --------------------------------------------------------------- */

void do_polygons(void)
{
  int matno, nverts, i;
  static int first = 1;
  double *x, *y, *z;
  char ffname[200];

   if (gmv_data.datatype == REGULAR)
     {
      if (first)
        {
         first = 0;
         printf("Converting polygons.\n");
         gmvwrite_polygons_header();   
        }
      nverts = gmv_data.ndoubledata1;
      x = (double *) malloc(sizeof(double) * nverts);
      y = (double *) malloc(sizeof(double) * nverts);
      z = (double *) malloc(sizeof(double) * nverts);
      matno = gmv_data.num;
      nverts = gmv_data.ndoubledata1;
      for (i = 0; i < nverts; i++)
        {
         x[i] = gmv_data.doubledata1[i];
         y[i] = gmv_data.doubledata2[i];
         z[i] = gmv_data.doubledata3[i];
        }
      gmvwrite_polygons_data(nverts, matno, x, y, z);
      free(x);  free(y);  free(z);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_polygons_fromfile(ffname);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_polygons_endpoly();
}

/* --------------------------------------------------------------- */

void do_flags(void)
{
  char ffname[200], flagname[33], fnames[33];
  int d_type, numtypes, *flagdata;
  int i, numdat;
  static int ifirst = 1;

   if (gmv_data.datatype == CELL || gmv_data.datatype == NODE)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting flags.\n");
         gmvwrite_flag_header();
        }
      if (gmv_data.datatype == CELL) d_type = 0;
      if (gmv_data.datatype == NODE) d_type = 1;
      numdat = gmv_data.num;
      strcpy(flagname,gmv_data.name1);
      numtypes = gmv_data.num2;
      gmvwrite_flag_name(flagname, numtypes, d_type);
      
      for (i = 0; i < numtypes; i++)
        {
         strcpy(fnames,&gmv_data.chardata1[i*33]);
         gmvwrite_flag_subname(fnames);
        }

      flagdata = (int *) malloc(sizeof(int) * numdat);
      for (i = 0; i < numdat; i++)
         flagdata[i] = gmv_data.longdata1[i];
      gmvwrite_flag_data(d_type, flagdata);
      free(flagdata);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_flag_fromfile(ffname);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_flag_endflag();
}

/* --------------------------------------------------------------- */

void do_variables(void)
{
  char varname[40];
  int d_type;
  int i, numdat;
  static int ifirst = 1;
  double *var_data;

   if (gmv_data.datatype == CELL || gmv_data.datatype == NODE ||
       gmv_data.datatype == FACE)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting variables.\n");
         gmvwrite_variable_header();
        }
      if (gmv_data.datatype == CELL) d_type = 0;
      if (gmv_data.datatype == NODE) d_type = 1;
      if (gmv_data.datatype == FACE) d_type = 2;
      numdat = gmv_data.num;
      strcpy(varname,gmv_data.name1);
      var_data = (double *) malloc(sizeof(double) * numdat);
      for (i = 0; i < numdat; i++)
         var_data[i] = gmv_data.doubledata1[i];
      gmvwrite_variable_name_data(d_type, varname, var_data);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_variable_endvars();
}

/* --------------------------------------------------------------- */

void do_velocity(void)
{
  int d_type;
  int nvel, i;
  double *u, *v, *w;

   printf("Converting velocities.\n");
   if (gmv_data.datatype == CELL) d_type = 0;
   if (gmv_data.datatype == NODE) d_type = 1;
   if (gmv_data.datatype == FACE) d_type = 2;
   nvel = gmv_data.num;
   u = (double *) malloc(sizeof(double) * nvel);
   v = (double *) malloc(sizeof(double) * nvel);
   w = (double *) malloc(sizeof(double) * nvel);
   for (i = 0; i < nvel; i++)
     {
      u[i] = gmv_data.doubledata1[i];
      v[i] = gmv_data.doubledata2[i];
      w[i] = gmv_data.doubledata3[i];
     }
   gmvwrite_velocity_data(d_type, u, v, w);
   free(u);  free(v);  free(w);
}

/* --------------------------------------------------------------- */

void do_materials(void)
{
  int n_mats, d_type, *matids;
  int nmatdata, i;
  char matname[40], ffname[200];

   printf("Converting materials.\n");

   if (gmv_data.datatype == CELL ||
       gmv_data.datatype == NODE)
     {
      if (gmv_data.datatype == CELL) d_type = 0;
      if (gmv_data.datatype == NODE) d_type = 1;
      n_mats = gmv_data.num;
      gmvwrite_material_header(n_mats, d_type);
      for (i = 0; i < n_mats; i++)
        {
         strncpy(matname,&gmv_data.chardata1[i*33],32);
         *(matname+32) = (char) 0;
         gmvwrite_material_name(matname);
        }
      nmatdata = gmv_data.nlongdata1;
      matids = (int *) malloc(sizeof(int) * nmatdata);
      for (i = 0; i < nmatdata; i++)
         matids[i] = gmv_data.longdata1[i];
      gmvwrite_material_ids(matids, d_type);
      free(matids);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_material_fromfile(ffname);
     }
}

/* --------------------------------------------------------------- */

void do_cells(void)
{
  char cellname[10], ffname[200];
  static int ifirst = 1;
  int ncells, i;
  long ffncells;
  int *daughters, n_faces, *n_verts, *verts, num_verts, sum_verts;

   if (gmv_data.datatype == FROMFILE)
     {
      printf("Converting cells.\n");
      strcpy(ffname,gmv_data.chardata1);
      ffncells = gmv_data.num;
      gmvwrite_cells_fromfile(ffname,ffncells);
      ncells = gmv_data.num;
     }
   
   else if (gmv_data.datatype == AMR)
     {
      printf("Converting amr cells.\n");
      ncells = gmv_data.num;
      daughters = (int *) malloc(sizeof(int) * ncells);
      for (i = 0; i < ncells; i++)
         daughters[i] = gmv_data.longdata1[i];
      gmvwrite_cells_amr(&ncells, &ncells, daughters);
      free(daughters);
     }

   else if (gmv_data.datatype == ENDKEYWORD)
     {
      if (gmv_data.num2 == 0)
        {
         printf("Converting cells.\n");
         ncells = gmv_data.num2;
         gmvwrite_cell_header(&ncells);
        }
      return;
     }
   
   else 
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting cells.\n");
         ncells = gmv_data.num;
         gmvwrite_cell_header(&ncells);
        }

      if (gmv_data.datatype == GENERAL)
        {
         n_faces = gmv_data.num2;
         n_verts = (int *) malloc(sizeof(int) * n_faces);
         for (i = 0; i < n_faces; i++)
            n_verts[i] = gmv_data.longdata1[i];
         sum_verts = gmv_data.nlongdata2;
         verts = (int *) malloc(sizeof(int) * sum_verts);
         for (i = 0; i < sum_verts; i++)
            verts[i] = gmv_data.longdata2[i];
         gmvwrite_general_cell_type("general ", n_verts, n_faces, verts);
         free(n_verts);  free(verts);
        }

      if (gmv_data.datatype == REGULAR || gmv_data.datatype == VFACE3D ||
          gmv_data.datatype == VFACE2D)
        {
         strncpy(cellname,gmv_data.name1,8);
         *(cellname+8) = (char) 0;
         num_verts = gmv_data.num2;
         verts = (int *) malloc(sizeof(int) * num_verts);
         for (i = 0; i < num_verts; i++)
            verts[i] = gmv_data.longdata1[i];
         gmvwrite_cell_type(cellname, num_verts, verts);
	 free(verts);
        }
     }
}

/* --------------------------------------------------------------- */

void do_faces(void)
{
  char ffname[200];
  static int ifirst = 1;
  int numfaces, numcells, i;
  long ffncells;
  int nverts, *verts, cellid1, cellid2;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting faces.\n");
         numfaces = gmv_data.num;
         numcells = gmv_data.num2;
         gmvwrite_face_header(&numfaces, &numcells);
        }
      nverts = gmv_data.nlongdata1 - 2;
      verts = (int *) malloc(sizeof(int) * nverts);
      for (i = 0; i < nverts; i++)
         verts[i] = gmv_data.longdata1[i];
      cellid1 = gmv_data.longdata1[nverts];
      cellid2 = gmv_data.longdata1[nverts+1];
      gmvwrite_face_data(nverts, verts, &cellid1, &cellid2);
      free(verts);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      printf("Converting faces.\n");
      strcpy(ffname,gmv_data.chardata1);
      numfaces = gmv_data.num;
      numcells = gmv_data.num2;
      ffncells = gmv_data.num2;
      gmvwrite_faces_fromfile(ffname,ffncells);
     }

   if (gmv_data.datatype == ENDKEYWORD) return;
}

/* --------------------------------------------------------------- */

void do_vfaces(void)
{
  char ffname[200];
  static int ifirst = 1;
  int numfaces, numcells, i;
  long ffncells;
  int nverts, *verts, facepe, oppface, oppfacepe, cellid;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting vfaces.\n");
         numfaces = gmv_data.num;
         gmvwrite_vface_header(&numfaces);
        }
      nverts = gmv_data.nlongdata1;
      verts = (int *) malloc(sizeof(int) * nverts);
      for (i = 0; i < nverts; i++)
         verts[i] = gmv_data.longdata1[i];
      facepe = gmv_data.longdata2[0];
      oppface = gmv_data.longdata2[1];
      oppfacepe = gmv_data.longdata2[2];
      cellid = gmv_data.longdata2[3];
      gmvwrite_vface_data(nverts,facepe,&oppface,oppfacepe,&cellid,verts);
      free(verts);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      printf("Converting vfaces.\n");
      strcpy(ffname,gmv_data.chardata1);
      numfaces = gmv_data.num;
      numcells = gmv_data.num2;
      ffncells = gmv_data.num2;
      gmvwrite_vfaces_fromfile(ffname,ffncells);
     }

   if (gmv_data.datatype == ENDKEYWORD) return;
}

/* --------------------------------------------------------------- */

void do_xfaces(void)
{
  char ffname[200];
  static int ifirst = 1, numfaces, numcells;
  int i, j;
  long ffncells;
  static long totverts, *nverts, *verts, *facepe, *oppface, *oppfacepe, *cellid;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting xfaces.\n");
         numfaces = gmv_data.num;
         gmvwrite_xface_header(&numfaces);
        }
      if (gmv_data.num2 == 0)
        {
         nverts = (long *)malloc(sizeof(long) * numfaces);
         for (i = 0; i < numfaces; i++)
            nverts[i] = gmv_data.longdata1[i];
         totverts = gmv_data.nlongdata2;
         verts = (long *)malloc(sizeof(long) * totverts);
         for (i = 0; i < totverts; i++)
            verts[i] = gmv_data.longdata2[i];
        }
      if (gmv_data.num2 == 1)
        {
         cellid = (long *)malloc(sizeof(long) * numfaces);
         for (i = 0; i < numfaces; i++)
            cellid[i] = gmv_data.longdata1[i];
        }
      if (gmv_data.num2 == 2)
        {
         oppface = (long *)malloc(sizeof(long) * numfaces);
         for (i = 0; i < numfaces; i++)
            oppface[i] = gmv_data.longdata1[i];
        }
      if (gmv_data.num2 == 3)
        {
         facepe = (long *)malloc(sizeof(long) * numfaces);
         for (i = 0; i < numfaces; i++)
            facepe[i] = gmv_data.longdata1[i];
        }
      if (gmv_data.num2 == 4)
        {
         oppfacepe = (long *)malloc(sizeof(long) * numfaces);
         for (i = 0; i < numfaces; i++)
            oppfacepe[i] = gmv_data.longdata1[i];
        }
     }

   if (gmv_data.datatype == FROMFILE)
     {
      printf("Converting xfaces.\n");
      strcpy(ffname,gmv_data.chardata1);
      numfaces = gmv_data.num;
      numcells = gmv_data.num2;
      ffncells = gmv_data.num2;
      gmvwrite_xfaces_fromfile(ffname,numfaces,numcells);
     }

   if (gmv_data.datatype == ENDKEYWORD)
     {
      gmvwrite_xface_data(totverts,nverts,verts,cellid,oppface,
                          facepe,oppfacepe);
      free(nverts);  free(verts);  free(cellid);  free(oppface);
      free(facepe);  free(oppfacepe);
     }
}

/* --------------------------------------------------------------- */

void do_nodes(void)
{
  char ffname[200];
  int nx, ny, nz, num;
  int nnodes, i;
  long ffnnodes;
  double *x, *y, *z;
  double x0, y0, z0, dx, dy, dz;

   printf("Converting nodes.\n");

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      ffnnodes = gmv_data.num;
      gmvwrite_nodes_fromfile(ffname, ffnnodes);
      nnodes = ffnnodes;
     }

   else if (gmv_data.datatype == UNSTRUCT ||
            gmv_data.datatype == LOGICALLY_STRUCT)
     {
      nnodes = gmv_data.num;
      if (nnodes > 0)
        {
         x = (double *) malloc(sizeof(double) * nnodes);
         y = (double *) malloc(sizeof(double) * nnodes);
         z = (double *) malloc(sizeof(double) * nnodes);
         for (i = 0; i < nnodes; i++)
           {
            x[i] = gmv_data.doubledata1[i];
            y[i] = gmv_data.doubledata2[i];
            z[i] = gmv_data.doubledata3[i];
           }
        }
      if (gmv_data.datatype == LOGICALLY_STRUCT)
        {
         nx = gmv_data.ndoubledata1;
         ny = gmv_data.ndoubledata2;
         nz = gmv_data.ndoubledata3;
         gmvwrite_node_data_lstruct(&nx, &ny, &nz, x, y, z);
        }
      else
        {
         num = nnodes;
         gmvwrite_node_data(&num, x, y, z);
        }
      free(x);  free(y);  free(z);
     }

   else if (gmv_data.datatype == STRUCT)
     {
      nx = gmv_data.ndoubledata1;
      ny = gmv_data.ndoubledata2;
      nz = gmv_data.ndoubledata3;
      
      x = (double *) malloc(sizeof(double) * nx);
      y = (double *) malloc(sizeof(double) * ny);
      z = (double *) malloc(sizeof(double) * nz);
      for (i = 0; i < nx; i++)
         x[i] = gmv_data.doubledata1[i];
      for (i = 0; i < ny; i++)
         y[i] = gmv_data.doubledata2[i];
      for (i = 0; i < nz; i++)
         z[i] = gmv_data.doubledata3[i];
      gmvwrite_node_data_struct(&nx, &ny, &nz, x, y, z);
      free(x);  free(y);  free(z);
     }
   
   else if (gmv_data.datatype == AMR)
     {
      nx = gmv_data.num2;
      ny = gmv_data.nlongdata1;
      nz = gmv_data.nlongdata2;
      x0 = gmv_data.doubledata1[0];
      y0 = gmv_data.doubledata1[1];
      z0 = gmv_data.doubledata1[2];
      dx = gmv_data.doubledata2[0];
      dy = gmv_data.doubledata2[1];
      dz = gmv_data.doubledata2[2];
      gmvwrite_node_data_amr(nx, ny, nz, &x0, &y0, &z0, 
                             &dx, &dy, &dz);
     }
}

/* --------------------------------------------------------------- */

void do_nodev(void)
{
  char ffname[200];
  int nx, ny, nz, num;
  int nnodes, i;
  long ffnnodes;
  double *x, *y, *z;
  double x0, y0, z0, dx, dy, dz;

   printf("Converting nodev.\n");

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      ffnnodes = gmv_data.num;
      gmvwrite_nodev_fromfile(ffname, ffnnodes);
      nnodes = ffnnodes;
     }

   else if (gmv_data.datatype == UNSTRUCT ||
            gmv_data.datatype == LOGICALLY_STRUCT)
     {
      nnodes = gmv_data.num;
      if (nnodes > 0)
        {
         x = (double *) malloc(sizeof(double) * nnodes);
         y = (double *) malloc(sizeof(double) * nnodes);
         z = (double *) malloc(sizeof(double) * nnodes);
         for (i = 0; i < nnodes; i++)
           {
            x[i] = gmv_data.doubledata1[i];
            y[i] = gmv_data.doubledata2[i];
            z[i] = gmv_data.doubledata3[i];
           }
        }
      if (gmv_data.datatype == LOGICALLY_STRUCT)
        {
         nx = gmv_data.ndoubledata1;
         ny = gmv_data.ndoubledata2;
         nz = gmv_data.ndoubledata3;
         gmvwrite_nodev_data_lstruct(&nx, &ny, &nz, x, y, z);
        }
      else
        {
         num = nnodes;
         gmvwrite_nodev_data(&num, x, y, z);
        }
      free(x);  free(y);  free(z);
     }
}

/* --------------------------------------------------------------- */

void do_nodeids()
{
  char ffname[200];
  int num, i, *ids;

   printf("Converting nodeids.\n");

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_nodeids_fromfile(ffname);
     }

   if (gmv_data.datatype == REGULAR)
     {
      num = gmv_data.num;
      ids = (int *)malloc(num * sizeof(int));
      for (i = 0; i < num; i++)
         ids[i] = gmv_data.longdata1[i];
      gmvwrite_nodeids(ids);
     }
} 

/* --------------------------------------------------------------- */

void do_cellids()
{
  char ffname[200];
  int num, i, *ids;

   printf("Converting cellids.\n");

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_cellids_fromfile(ffname);
     }

   if (gmv_data.datatype == REGULAR)
     {
      num = gmv_data.num;
      ids = (int *)malloc(num * sizeof(int));
      for (i = 0; i < num; i++)
         ids[i] = gmv_data.longdata1[i];
      gmvwrite_cellids(ids);
     }
} 

/* --------------------------------------------------------------- */

void do_surface(void)
{
  char ffname[200];
  static int ifirst = 1;
  int numsurf, i;
  long ffnsurf;
  int nverts, *verts;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting surface.\n");
         numsurf = gmv_data.num;
         gmvwrite_surface_header(&numsurf);
        }
      nverts = gmv_data.nlongdata1;
      verts = (int *) malloc(sizeof(int) * nverts);
      for (i = 0; i < nverts; i++)
         verts[i] = gmv_data.longdata1[i];
      gmvwrite_surface_data(nverts, verts);
      free(verts);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      printf("Converting faces.\n");
      strcpy(ffname,gmv_data.chardata1);
      ffnsurf = gmv_data.num;
      gmvwrite_surface_fromfile(ffname,ffnsurf);
      numsurf = gmv_data.num;
     }

   if (gmv_data.datatype == ENDKEYWORD)
     {
      if (gmv_data.num == 0)
        {
         printf("Converting surface.\n");
         numsurf = gmv_data.num;
         gmvwrite_surface_header(&numsurf);
        }
      return;
     }
}

/* --------------------------------------------------------------- */

void do_surfmats(void)
{
  int *matids;
  int nmatdata, i;

   printf("Converting surfmats.\n");

   nmatdata = gmv_data.nlongdata1;
   matids = (int *) malloc(sizeof(int) * nmatdata);
   for (i = 0; i < nmatdata; i++)
      matids[i] = gmv_data.longdata1[i];
   gmvwrite_surfmats(matids);
   free(matids);
}

/* --------------------------------------------------------------- */

void do_surfvel(void)
{
  int nvel, i;
  double *u, *v, *w;

   printf("Converting surfvel.\n");
   nvel = gmv_data.num;
   u = (double *) malloc(sizeof(double) * nvel);
   v = (double *) malloc(sizeof(double) * nvel);
   w = (double *) malloc(sizeof(double) * nvel);
   for (i = 0; i < nvel; i++)
     {
      u[i] = gmv_data.doubledata1[i];
      v[i] = gmv_data.doubledata2[i];
      w[i] = gmv_data.doubledata2[i];
     }
   gmvwrite_surfvel(u, v, w);
   free(u);  free(v);  free(w);
}

/* --------------------------------------------------------------- */

void do_surfvars(void)
{
  char varname[40];
  int i, numdat;
  static int ifirst = 1;
  double *var_data;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting surfvars.\n");
         gmvwrite_surfvars_header();
        }
      numdat = gmv_data.num;
      strcpy(varname,gmv_data.name1);
      var_data = (double *) malloc(sizeof(double) * numdat);
      for (i = 0; i < numdat; i++)
         var_data[i] = gmv_data.doubledata1[i];
      gmvwrite_surfvars_name_data(varname, var_data);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_surfvars_endsvar();
}

/* --------------------------------------------------------------- */

void do_surfflag(void)
{
  char ffname[200], flagname[33], fnames[33];
  int numtypes, *flagdata;
  int i, numdat;
  static int ifirst = 1;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting surfflags.\n");
         gmvwrite_surfflag_header();
        }
      numdat = gmv_data.num;
      strcpy(flagname,gmv_data.name1);
      numtypes = gmv_data.num2;
      gmvwrite_surfflag_name(flagname, numtypes);
      
      for (i = 0; i < numtypes; i++)
        {
         strcpy(fnames,&gmv_data.chardata1[i*33]);
         gmvwrite_surfflag_subname(fnames);
        }

      flagdata = (int *) malloc(sizeof(int) * numdat);
      for (i = 0; i < numdat; i++)
         flagdata[i] = gmv_data.longdata1[i];
      gmvwrite_surfflag_data(flagdata);
      free(flagdata);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_surfflag_endflag();
}

/* --------------------------------------------------------------- */

void do_units(void)
{
  char ffname[200], unitname[17], fname[33];
  int d_type, i, numdat;
  static int ifirst = 1;

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_units_fromfile(ffname);
      return;
     }

    if (ifirst)
     {
      ifirst = 0;
      printf("Converting flags.\n");
      gmvwrite_units_header();
     }

   if (gmv_data.datatype == XYZ || gmv_data.datatype == VEL)
     {
      if (gmv_data.datatype == XYZ) strcpy(fname,"xyz");
      else strcpy(fname,"velocity");
      strcpy(unitname,gmv_data.chardata2);
      gmvwrite_units_name(fname,unitname);
     }

   if (gmv_data.datatype == CELL || gmv_data.datatype == NODE)
     {
      if (gmv_data.datatype == CELL) d_type = 0;
      if (gmv_data.datatype == NODE) d_type = 1;
      numdat = gmv_data.num;
      gmvwrite_units_typehdr(d_type,numdat);

      for (i = 0; i < numdat; i++)
        {
         strcpy(fname,&gmv_data.chardata1[i*33]);
         strcpy(unitname,&gmv_data.chardata2[i*33]);
         gmvwrite_units_name(fname,unitname);
        }
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_units_endunit();
}

/* --------------------------------------------------------------- */

void do_vinfo(void)
{
  char varname[40];
  int i, nelem, nlines, numdat;
  static int ifirst = 1;
  double *var_data;

   if (gmv_data.datatype == REGULAR)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting vinfo.\n");
         gmvwrite_vinfo_header();
        }
      nelem = gmv_data.num;
      nlines = gmv_data.num2;
      numdat = nelem * nlines;
      strcpy(varname,gmv_data.name1);
      var_data = (double *) malloc(sizeof(double) * numdat);
      for (i = 0; i < numdat; i++)
         var_data[i] = gmv_data.doubledata1[i];
      gmvwrite_vinfo_name_data(nelem, nlines, varname, var_data);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_vinfo_endvinfo();
}

/* --------------------------------------------------------------- */

void error_message(char *message)
{
  fprintf(stderr, "%s\n", message);
  exit(1);
}

/* --------------------------------------------------------------- */

void do_traceids()
{
  char ffname[200];
  int num, i, *ids;

   printf("Converting traceids.\n");

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_traceids_fromfile(ffname);
     }

   if (gmv_data.datatype == REGULAR)
     {
      num = gmv_data.num;
      ids = (int *)malloc(num * sizeof(int));
      for (i = 0; i < num; i++)
         ids[i] = gmv_data.longdata1[i];
      gmvwrite_traceids(num,ids);
     }
} 

/* --------------------------------------------------------------- */

void do_groups(void)
{
  char groupname[33], ffname[33];
  int d_type, numgroup, *groupdata, i;
  static int ifirst = 1;

   if (gmv_data.datatype == CELL || gmv_data.datatype == NODE ||
        gmv_data.datatype == FACE)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting groups.\n");
         gmvwrite_group_header();
        }
      if (gmv_data.datatype == CELL) d_type = 0;
      if (gmv_data.datatype == NODE) d_type = 1;
      if (gmv_data.datatype == FACE) d_type = 2;
      if (gmv_data.datatype == SURF) d_type = 3;
      numgroup = gmv_data.num;
      strcpy(groupname,gmv_data.name1);

      groupdata = (int *) malloc(sizeof(int) * numgroup);
      for (i = 0; i < numgroup; i++)
         groupdata[i] = gmv_data.longdata1[i];
      gmvwrite_group_data(groupname, d_type, numgroup, groupdata);
      free(groupdata);
     }

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_group_fromfile(ffname);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_group_endgroup();
}

/* --------------------------------------------------------------- */

void do_faceids()
{
  char ffname[200];
  int num, i, *ids;

   printf("Converting faceids.\n");

   if (gmv_data.datatype == FROMFILE)
     {
      strcpy(ffname,gmv_data.chardata1);
      gmvwrite_faceids_fromfile(ffname);
     }

   if (gmv_data.datatype == REGULAR)
     {
      num = gmv_data.num;
      ids = (int *)malloc(num * sizeof(int));
      for (i = 0; i < num; i++)
         ids[i] = gmv_data.longdata1[i];
      gmvwrite_faceids(ids);
     }
} 

/* --------------------------------------------------------------- */

void do_surfids()
{
  char ffname[200];
  int num, i, *ids;

   printf("Converting surfids.\n");

   if (gmv_data.datatype == REGULAR)
     {
      num = gmv_data.num;
      ids = (int *)malloc(num * sizeof(int));
      for (i = 0; i < num; i++)
         ids[i] = gmv_data.longdata1[i];
      gmvwrite_surfids(ids);
     }
} 

/* --------------------------------------------------------------- */

void do_subvars(void)
{
  char varname[40];
  int d_type;
  int i, numdat, *subvarids;
  static int ifirst = 1;
  double *var_data;

   if (gmv_data.datatype == CELL || gmv_data.datatype == NODE ||
       gmv_data.datatype == FACE)
     {
      if (ifirst)
        {
         ifirst = 0;
         printf("Converting subvars.\n");
         gmvwrite_subvars_header();
        }
      if (gmv_data.datatype == CELL) d_type = 0;
      if (gmv_data.datatype == NODE) d_type = 1;
      if (gmv_data.datatype == FACE) d_type = 2;
      numdat = gmv_data.num;
      strcpy(varname,gmv_data.name1);
      subvarids = (int *)malloc(sizeof(int) * numdat);
      var_data = (double *) malloc(sizeof(double) * numdat);
      for (i = 0; i < numdat; i++)
        {
         subvarids[i] = gmv_data.longdata1[i];
         var_data[i] = gmv_data.doubledata1[i];
        }
      gmvwrite_subvars_name_data(d_type, numdat, varname, 
                                 subvarids, var_data);
     }

   if (gmv_data.datatype == ENDKEYWORD)
      gmvwrite_subvars_endsubv();
}

/* --------------------------------------------------------------- */

void do_codename(void)
{
  char tmpname[9];

   printf("Converting codename.\n");
   strcpy(tmpname,gmv_data.name1);
   gmvwrite_codename(tmpname);
}

/* --------------------------------------------------------------- */

void do_codever(void)
{
  char tmpname[9];

   printf("Converting codever.\n");
   strcpy(tmpname,gmv_data.name1);
   gmvwrite_codever(tmpname);
}

/* --------------------------------------------------------------- */

void do_simdate(void)
{
  char tmpname[9];

   printf("Converting simdate.\n");
   strcpy(tmpname,gmv_data.name1);
   gmvwrite_simdate(tmpname);
}

/* --------------------------------------------------------------- */

