#include "rt_nonfinite.h"
#include "determine_incident_halfedges.h"
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

static void b_determine_incident_halfedges(int32_T nv, const emxArray_int32_T
  *elems, const emxArray_int32_T *sibhes_fid, emxArray_int32_T *v2he_fid,
  emxArray_int8_T *v2he_leid);
static void b_determine_incident_halfedges(int32_T nv, const emxArray_int32_T
  *elems, const emxArray_int32_T *sibhes_fid, emxArray_int32_T *v2he_fid,
  emxArray_int8_T *v2he_leid)
{
  int32_T kk;
  int32_T loop_ub;
  kk = v2he_fid->size[0];
  v2he_fid->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2he_fid, kk, (int32_T)sizeof(int32_T));
  loop_ub = nv - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2he_fid->data[kk] = 0;
  }

  kk = v2he_leid->size[0];
  v2he_leid->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2he_leid, kk, (int32_T)sizeof(int8_T));
  loop_ub = nv - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2he_leid->data[kk] = 0;
  }

  kk = 0;
  while ((kk + 1 <= elems->size[0]) && (!(elems->data[kk] == 0))) {
    for (loop_ub = 0; loop_ub + 1 <= elems->size[1]; loop_ub++) {
      if ((elems->data[kk + elems->size[0] * loop_ub] > 0) && ((v2he_fid->
            data[elems->data[kk + elems->size[0] * loop_ub] - 1] == 0) ||
           (sibhes_fid->data[kk + sibhes_fid->size[0] * loop_ub] == 0))) {
        v2he_fid->data[elems->data[kk + elems->size[0] * loop_ub] - 1] = kk + 1;
        v2he_leid->data[elems->data[kk + elems->size[0] * loop_ub] - 1] =
          (int8_T)(loop_ub + 1);
      }
    }

    kk++;
  }
}

void determine_incident_halfedges(int32_T nv, const emxArray_int32_T *elems,
  const emxArray_int32_T *sibhes, emxArray_int32_T *v2he)
{
  int32_T kk;
  int32_T loop_ub;
  kk = v2he->size[0];
  v2he->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2he, kk, (int32_T)sizeof(int32_T));
  loop_ub = nv - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2he->data[kk] = 0;
  }

  kk = 0;
  while ((kk + 1 <= elems->size[0]) && (!(elems->data[kk] == 0))) {
    for (loop_ub = 0; loop_ub + 1 <= elems->size[1]; loop_ub++) {
      if ((elems->data[kk + elems->size[0] * loop_ub] > 0) && ((v2he->data
            [elems->data[kk + elems->size[0] * loop_ub] - 1] == 0) ||
           (sibhes->data[kk + sibhes->size[0] * loop_ub] == 0) || ((sibhes->
             data[((int32_T)((uint32_T)v2he->data[elems->data[kk + elems->size[0]
               * loop_ub] - 1] >> 2U) + sibhes->size[0] * (int32_T)((uint32_T)
               v2he->data[elems->data[kk + elems->size[0] * loop_ub] - 1] & 3U))
             - 1] != 0) && (sibhes->data[kk + sibhes->size[0] * loop_ub] < 0))))
      {
        v2he->data[elems->data[kk + elems->size[0] * loop_ub] - 1] = ((kk + 1) <<
          2) + loop_ub;
      }
    }

    kk++;
  }
}

void determine_incident_halfedges_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void determine_incident_halfedges_terminate(void)
{
}

void determine_incident_halfedges_usestruct(int32_T nv, const emxArray_int32_T
  *elems, const struct_T sibhes, boolean_T usestruct, struct_T *v2he)
{
  b_determine_incident_halfedges(nv, elems, sibhes.fid, v2he->fid, v2he->leid);
}

