#include "rt_nonfinite.h"
#include "determine_incident_halfverts.h"
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

static real_T rt_roundd_snf(real_T u);

static real_T rt_roundd_snf(real_T u)
{
  real_T y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

void determine_incident_halfverts(int32_T nv, const emxArray_int32_T *edgs,
  emxArray_int32_T *v2hv)
{
  int32_T nedgs;
  int32_T kk;
  int32_T loop_ub;
  nedgs = edgs->size[0];
  kk = v2hv->size[0];
  v2hv->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2hv, kk, (int32_T)sizeof(int32_T));
  loop_ub = nv - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2hv->data[kk] = 0;
  }

  for (kk = 0; kk + 1 <= nedgs; kk++) {
    for (loop_ub = 0; loop_ub < 2; loop_ub++) {
      if ((edgs->data[kk + edgs->size[0] * loop_ub] > 0) && (v2hv->data
           [edgs->data[kk + edgs->size[0] * loop_ub] - 1] == 0)) {
        v2hv->data[edgs->data[kk + edgs->size[0] * loop_ub] - 1] = (int32_T)
          rt_roundd_snf((real_T)((kk + 1) << 1) + (1.0 + (real_T)loop_ub)) - 1;
      }
    }
  }
}

void determine_incident_halfverts_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void determine_incident_halfverts_terminate(void)
{
}

void determine_incident_halfverts_usestruct(int32_T nv, const emxArray_int32_T
  *edgs, boolean_T usestruct, struct_T *v2hv)
{
  int32_T nedgs;
  int32_T kk;
  int32_T loop_ub;
  nedgs = edgs->size[0];
  kk = v2hv->eid->size[0];
  v2hv->eid->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2hv->eid, kk, (int32_T)sizeof(int32_T));
  loop_ub = nv - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2hv->eid->data[kk] = 0;
  }

  kk = v2hv->lvid->size[0];
  v2hv->lvid->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2hv->lvid, kk, (int32_T)sizeof(int8_T));
  loop_ub = nv - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2hv->lvid->data[kk] = 0;
  }

  for (kk = 0; kk + 1 <= nedgs; kk++) {
    for (loop_ub = 0; loop_ub < 2; loop_ub++) {
      if ((edgs->data[kk + edgs->size[0] * loop_ub] > 0) && (v2hv->eid->
           data[edgs->data[kk + edgs->size[0] * loop_ub] - 1] == 0)) {
        v2hv->eid->data[edgs->data[kk + edgs->size[0] * loop_ub] - 1] = kk + 1;
        v2hv->lvid->data[edgs->data[kk + edgs->size[0] * loop_ub] - 1] = (int8_T)
          (1 + loop_ub);
      }
    }
  }
}

