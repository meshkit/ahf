#include "rt_nonfinite.h"
#include "obtain_1ring_surf_nmanfld.h"
#include "m2c.h"
#ifndef struct_emxArray__common
#define struct_emxArray__common

typedef struct emxArray__common
{
  void *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} emxArray__common;

#endif

static define_emxInit(b_emxInit_boolean_T, boolean_T)
static define_emxInit(b_emxInit_int32_T, int32_T)
static void eml_null_assignment(emxArray_int32_T *x, int32_T idx);
static void loop_sbihes(int32_T he, const emxArray_int32_T *sibhes, int32_T
  queue[256], real_T *queue_size, const emxArray_boolean_T *ftags);

static void eml_null_assignment(emxArray_int32_T *x, int32_T idx)
{
  int32_T nrows;
  int32_T i;
  emxArray_int32_T *b_x;
  int32_T i0;
  nrows = x->size[0] - 1;
  for (i = idx; i <= nrows; i++) {
    x->data[i - 1] = x->data[i];
  }

  if (1 > nrows) {
    nrows = 0;
  }

  emxInit_int32_T(&b_x, 1);
  i0 = b_x->size[0];
  b_x->size[0] = nrows;
  emxEnsureCapacity((emxArray__common *)b_x, i0, (int32_T)sizeof(int32_T));
  i = nrows - 1;
  for (i0 = 0; i0 <= i; i0++) {
    b_x->data[i0] = x->data[i0];
  }

  i0 = x->size[0];
  x->size[0] = b_x->size[0];
  emxEnsureCapacity((emxArray__common *)x, i0, (int32_T)sizeof(int32_T));
  i = b_x->size[0] - 1;
  for (i0 = 0; i0 <= i; i0++) {
    x->data[i0] = b_x->data[i0];
  }

  emxFree_int32_T(&b_x);
}

static void loop_sbihes(int32_T he, const emxArray_int32_T *sibhes, int32_T
  queue[256], real_T *queue_size, const emxArray_boolean_T *ftags)
{
  emxArray_boolean_T *b_ftags;
  int32_T sibhe;
  boolean_T exitg1;
  int32_T fid;
  emxInit_boolean_T(&b_ftags, 1);
  sibhe = sibhes->data[((int32_T)((uint32_T)he >> 2U) + sibhes->size[0] *
                        (int32_T)((uint32_T)he & 3U)) - 1];
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (sibhe != 0)) {
    fid = (int32_T)((uint32_T)sibhe >> 2U) - 1;
    if (!ftags->data[fid]) {
      (*queue_size)++;
      queue[(int32_T)*queue_size - 1] = sibhe;
    }

    sibhe = (int32_T)((uint32_T)sibhe & 3U);
    if (sibhes->data[fid + sibhes->size[0] * sibhe] == he) {
      exitg1 = TRUE;
    } else {
      sibhe = sibhes->data[fid + sibhes->size[0] * sibhe];
    }
  }

  emxFree_boolean_T(&b_ftags);
}

void obtain_1ring_surf_nmanfld(int32_T vid, const emxArray_int32_T *tris, const
  emxArray_int32_T *sibhes, const emxArray_int32_T *v2he, emxArray_boolean_T
  *vtags, emxArray_boolean_T *ftags, emxArray_int32_T *ngbvs, int32_T *nverts,
  emxArray_int32_T *ngbfs, int32_T *nfaces)
{
  int32_T lid;
  int32_T fid;
  static const int8_T iv0[3] = { 3, 1, 2 };

  static const int8_T iv1[3] = { 2, 3, 1 };

  int32_T queue[256];
  real_T queue_size;
  int32_T b_nfaces;
  int32_T queue_top;
  int32_T b_nverts;
  emxArray_int32_T *b_ngbvs;
  emxArray_int32_T *r0;
  *nverts = 0;
  *nfaces = 0;
  lid = ngbvs->size[0];
  ngbvs->size[0] = 128;
  emxEnsureCapacity((emxArray__common *)ngbvs, lid, (int32_T)sizeof(int32_T));
  for (lid = 0; lid < 128; lid++) {
    ngbvs->data[lid] = 0;
  }

  lid = ngbfs->size[0];
  ngbfs->size[0] = 256;
  emxEnsureCapacity((emxArray__common *)ngbfs, lid, (int32_T)sizeof(int32_T));
  for (lid = 0; lid < 256; lid++) {
    ngbfs->data[lid] = 0;
  }

  if (!((int32_T)((uint32_T)v2he->data[vid - 1] >> 2U) != 0)) {
  } else {
    lid = ngbfs->size[0];
    ngbfs->size[0] = 256;
    emxEnsureCapacity((emxArray__common *)ngbfs, lid, (int32_T)sizeof(int32_T));
    for (lid = 0; lid < 256; lid++) {
      ngbfs->data[lid] = 0;
    }

    fid = (int32_T)((uint32_T)v2he->data[vid - 1] >> 2U);
    lid = (int32_T)((uint32_T)v2he->data[vid - 1] & 3U);
    if (tris->data[(fid + tris->size[0] * lid) - 1] == vid) {
      lid = iv0[lid];
    } else {
      lid = iv1[lid];
    }

    ftags->data[(int32_T)((uint32_T)v2he->data[vid - 1] >> 2U) - 1] = TRUE;
    ngbfs->data[0] = (int32_T)((uint32_T)v2he->data[vid - 1] >> 2U);
    memset(&queue[0], 0, sizeof(int32_T) << 8);
    queue_size = 0.0;
    loop_sbihes(v2he->data[vid - 1], sibhes, queue, &queue_size, ftags);
    loop_sbihes(((fid << 2) + lid) - 1, sibhes, queue, &queue_size, ftags);
    b_nfaces = 1;
    if (queue_size < 1.0) {
    } else {
      queue_top = 0;
      while ((real_T)(queue_top + 1) <= queue_size) {
        lid = queue[queue_top];
        queue_top++;
        fid = (int32_T)((uint32_T)lid >> 2U);
        lid = (int32_T)((uint32_T)lid & 3U);
        if (tris->data[(fid + tris->size[0] * lid) - 1] == vid) {
          lid = iv0[lid];
        } else {
          lid = iv1[lid];
        }

        if (ftags->data[fid - 1]) {
        } else {
          ftags->data[fid - 1] = TRUE;
          loop_sbihes(((fid << 2) + lid) - 1, sibhes, queue, &queue_size, ftags);
          b_nfaces++;
          ngbfs->data[b_nfaces - 1] = fid;
        }
      }
    }

    *nfaces = b_nfaces;
    lid = ngbvs->size[0];
    ngbvs->size[0] = 128;
    emxEnsureCapacity((emxArray__common *)ngbvs, lid, (int32_T)sizeof(int32_T));
    for (lid = 0; lid < 128; lid++) {
      ngbvs->data[lid] = 0;
    }

    b_nverts = 0;
    vtags->data[vid - 1] = TRUE;
    for (lid = 0; lid + 1 <= b_nfaces; lid++) {
      for (fid = 0; fid < 3; fid++) {
        if (!vtags->data[tris->data[(ngbfs->data[lid] + tris->size[0] * fid) - 1]
            - 1]) {
          b_nverts++;
          ngbvs->data[b_nverts - 1] = tris->data[(ngbfs->data[lid] + tris->size
            [0] * fid) - 1];
          vtags->data[tris->data[(ngbfs->data[lid] + tris->size[0] * fid) - 1] -
            1] = TRUE;
        }

        ftags->data[ngbfs->data[lid] - 1] = FALSE;
      }
    }

    vtags->data[vid - 1] = FALSE;
    if (1 > b_nverts) {
      lid = 0;
    } else {
      lid = b_nverts;
    }

    emxInit_int32_T(&b_ngbvs, 1);
    fid = b_ngbvs->size[0];
    b_ngbvs->size[0] = lid;
    emxEnsureCapacity((emxArray__common *)b_ngbvs, fid, (int32_T)sizeof(int32_T));
    queue_top = lid - 1;
    for (fid = 0; fid <= queue_top; fid++) {
      b_ngbvs->data[fid] = ngbvs->data[fid] - 1;
    }

    emxInit_int32_T(&r0, 1);
    fid = r0->size[0];
    r0->size[0] = lid;
    emxEnsureCapacity((emxArray__common *)r0, fid, (int32_T)sizeof(int32_T));
    queue_top = lid - 1;
    for (lid = 0; lid <= queue_top; lid++) {
      r0->data[lid] = 1 + lid;
    }

    lid = r0->size[0];
    emxFree_int32_T(&r0);
    queue_top = lid - 1;
    for (lid = 0; lid <= queue_top; lid++) {
      vtags->data[b_ngbvs->data[lid]] = FALSE;
    }

    emxFree_int32_T(&b_ngbvs);
    *nverts = b_nverts;
    eml_null_assignment(ngbfs, b_nfaces + 1);
    eml_null_assignment(ngbvs, b_nverts + 1);
  }
}

void obtain_1ring_surf_nmanfld_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void obtain_1ring_surf_nmanfld_terminate(void)
{
}
