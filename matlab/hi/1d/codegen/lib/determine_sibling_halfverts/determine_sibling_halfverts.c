#include "rt_nonfinite.h"
#include "determine_sibling_halfverts.h"
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

static define_emxInit(b_emxInit_int32_T, int32_T)
static define_emxInit(b_emxInit_int8_T, int8_T)

void determine_sibling_halfverts(int32_T nv, const emxArray_int32_T *edges,
  emxArray_int32_T *sibhvs, boolean_T *manifold, boolean_T *oriented)
{
  emxArray_int32_T *is_index;
  int32_T last;
  int32_T nedgs;
  int32_T ii;
  boolean_T exitg1;
  emxArray_int32_T *v2hv;
  int32_T edges_idx_0;
  emxInit_int32_T(&is_index, 1);
  last = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, last, (int32_T)sizeof(int32_T));
  for (last = 0; last <= nv; last++) {
    is_index->data[last] = 0;
  }

  nedgs = edges->size[0];
  ii = 0;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii + 1 <= nedgs)) {
    if (edges->data[ii] == 0) {
      nedgs = ii;
      exitg1 = TRUE;
    } else {
      is_index->data[edges->data[ii]]++;
      is_index->data[edges->data[ii + edges->size[0]]]++;
      ii++;
    }
  }

  is_index->data[0] = 1;
  for (ii = 1; ii <= nv; ii++) {
    is_index->data[ii] += is_index->data[ii - 1];
  }

  emxInit_int32_T(&v2hv, 1);
  last = v2hv->size[0];
  v2hv->size[0] = nedgs << 1;
  emxEnsureCapacity((emxArray__common *)v2hv, last, (int32_T)sizeof(int32_T));
  for (ii = 0; ii + 1 <= nedgs; ii++) {
    for (edges_idx_0 = 0; edges_idx_0 < 2; edges_idx_0++) {
      v2hv->data[is_index->data[edges->data[ii + edges->size[0] * edges_idx_0] -
        1] - 1] = ((ii + 1) << 1) + edges_idx_0;
      is_index->data[edges->data[ii + edges->size[0] * edges_idx_0] - 1]++;
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;
  edges_idx_0 = edges->size[0];
  last = sibhvs->size[0] * sibhvs->size[1];
  sibhvs->size[0] = edges_idx_0;
  sibhvs->size[1] = 2;
  emxEnsureCapacity((emxArray__common *)sibhvs, last, (int32_T)sizeof(int32_T));
  edges_idx_0 = (edges->size[0] << 1) - 1;
  for (last = 0; last <= edges_idx_0; last++) {
    sibhvs->data[last] = 0;
  }

  *manifold = TRUE;
  *oriented = TRUE;
  for (edges_idx_0 = 0; edges_idx_0 + 1 <= nv; edges_idx_0++) {
    last = is_index->data[edges_idx_0 + 1] - 1;
    if (last > is_index->data[edges_idx_0]) {
      nedgs = v2hv->data[last - 1];
      for (ii = is_index->data[edges_idx_0]; ii <= last; ii++) {
        sibhvs->data[((int32_T)((uint32_T)nedgs >> 1U) + sibhvs->size[0] *
                      (int32_T)((uint32_T)nedgs & 1U)) - 1] = v2hv->data[ii - 1];
        nedgs = v2hv->data[ii - 1];
      }

      if (*manifold) {
        if (is_index->data[edges_idx_0 + 1] - is_index->data[edges_idx_0] > 2) {
          *manifold = FALSE;
          *oriented = FALSE;
        } else {
          if (*oriented) {
            *oriented = ((int32_T)((uint32_T)v2hv->data[is_index->
              data[edges_idx_0] - 1] & 1U) + 1 != (int32_T)((uint32_T)nedgs & 1U)
                         + 1);
          }
        }
      }
    }
  }

  emxFree_int32_T(&v2hv);
  emxFree_int32_T(&is_index);
}

void determine_sibling_halfverts_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void determine_sibling_halfverts_terminate(void)
{
}

void determine_sibling_halfverts_usestruct(int32_T nv, const emxArray_int32_T
  *edges, boolean_T usestruct, struct_T *sibhvs, boolean_T *manifold, boolean_T *
  oriented)
{
  emxArray_int32_T *is_index;
  int32_T last;
  int32_T nedgs;
  int32_T ii;
  boolean_T exitg1;
  emxArray_int32_T *v2hv_eid;
  emxArray_int8_T *v2hv_lvid;
  int32_T nhv;
  boolean_T b_manifold;
  boolean_T b_oriented;
  int8_T lvid_prev;
  emxInit_int32_T(&is_index, 1);
  last = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, last, (int32_T)sizeof(int32_T));
  for (last = 0; last <= nv; last++) {
    is_index->data[last] = 0;
  }

  nedgs = edges->size[0];
  ii = 0;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii + 1 <= nedgs)) {
    if (edges->data[ii] == 0) {
      nedgs = ii;
      exitg1 = TRUE;
    } else {
      is_index->data[edges->data[ii]]++;
      is_index->data[edges->data[ii + edges->size[0]]]++;
      ii++;
    }
  }

  is_index->data[0] = 1;
  for (ii = 1; ii <= nv; ii++) {
    is_index->data[ii] += is_index->data[ii - 1];
  }

  emxInit_int32_T(&v2hv_eid, 1);
  emxInit_int8_T(&v2hv_lvid, 1);
  nhv = nedgs << 1;
  last = v2hv_eid->size[0];
  v2hv_eid->size[0] = nhv;
  emxEnsureCapacity((emxArray__common *)v2hv_eid, last, (int32_T)sizeof(int32_T));
  last = v2hv_lvid->size[0];
  v2hv_lvid->size[0] = nhv;
  emxEnsureCapacity((emxArray__common *)v2hv_lvid, last, (int32_T)sizeof(int8_T));
  for (ii = 0; ii + 1 <= nedgs; ii++) {
    for (nhv = 0; nhv < 2; nhv++) {
      v2hv_eid->data[is_index->data[edges->data[ii + edges->size[0] * nhv] - 1]
        - 1] = ii + 1;
      v2hv_lvid->data[is_index->data[edges->data[ii + edges->size[0] * nhv] - 1]
        - 1] = (int8_T)(nhv + 1);
      is_index->data[edges->data[ii + edges->size[0] * nhv] - 1]++;
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;
  nhv = edges->size[0];
  last = sibhvs->eid->size[0] * sibhvs->eid->size[1];
  sibhvs->eid->size[0] = nhv;
  sibhvs->eid->size[1] = 2;
  emxEnsureCapacity((emxArray__common *)sibhvs->eid, last, (int32_T)sizeof
                    (int32_T));
  nhv = (edges->size[0] << 1) - 1;
  for (last = 0; last <= nhv; last++) {
    sibhvs->eid->data[last] = 0;
  }

  nhv = edges->size[0];
  last = sibhvs->lvid->size[0] * sibhvs->lvid->size[1];
  sibhvs->lvid->size[0] = nhv;
  sibhvs->lvid->size[1] = 2;
  emxEnsureCapacity((emxArray__common *)sibhvs->lvid, last, (int32_T)sizeof
                    (int8_T));
  nhv = (edges->size[0] << 1) - 1;
  for (last = 0; last <= nhv; last++) {
    sibhvs->lvid->data[last] = 0;
  }

  b_manifold = TRUE;
  b_oriented = TRUE;
  for (nhv = 0; nhv + 1 <= nv; nhv++) {
    last = is_index->data[nhv + 1] - 1;
    if (last > is_index->data[nhv]) {
      nedgs = v2hv_eid->data[last - 1];
      lvid_prev = v2hv_lvid->data[last - 1];
      for (ii = is_index->data[nhv] - 1; ii + 1 <= last; ii++) {
        sibhvs->eid->data[(nedgs + sibhvs->eid->size[0] * (lvid_prev - 1)) - 1] =
          v2hv_eid->data[ii];
        sibhvs->lvid->data[(nedgs + sibhvs->lvid->size[0] * (lvid_prev - 1)) - 1]
          = v2hv_lvid->data[ii];
        nedgs = v2hv_eid->data[ii];
        lvid_prev = v2hv_lvid->data[ii];
      }

      if (b_manifold) {
        if (is_index->data[nhv + 1] - is_index->data[nhv] > 2) {
          b_manifold = FALSE;
          b_oriented = FALSE;
        } else {
          if (b_oriented) {
            if ((v2hv_eid->data[is_index->data[nhv] - 1] == nedgs) &&
                (v2hv_lvid->data[is_index->data[nhv] - 1] == lvid_prev)) {
              b_oriented = TRUE;
            } else {
              b_oriented = FALSE;
            }
          }
        }
      }
    }
  }

  emxFree_int8_T(&v2hv_lvid);
  emxFree_int32_T(&v2hv_eid);
  emxFree_int32_T(&is_index);
  *manifold = b_manifold;
  *oriented = b_oriented;
}

