#include "rt_nonfinite.h"
#include "obtain_neighbor_faces.h"
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

void obtain_neighbor_faces(int32_T fid, const emxArray_int32_T *sibhes,
  emxArray_boolean_T *ftags, real_T ngbfaces[100], real_T *nfaces)
{
  real_T queue_size;
  int32_T queue[100];
  int32_T i;
  int32_T leid;
  int32_T b_fid;
  boolean_T exitg1;
  queue_size = 0.0;
  ftags->data[fid - 1] = TRUE;
  *nfaces = 0.0;
  for (i = 0; i < 100; i++) {
    queue[i] = 0;
    ngbfaces[i] = 0.0;
  }

  for (leid = 0; leid < 3; leid++) {
    if (sibhes->data[(fid + sibhes->size[0] * leid) - 1] != 0) {
      (*nfaces)++;
      ngbfaces[(int32_T)*nfaces - 1] = (real_T)((uint32_T)sibhes->data[(fid +
        sibhes->size[0] * leid) - 1] >> 2U);
      b_fid = (int32_T)((uint32_T)sibhes->data[(fid + sibhes->size[0] * leid) -
                        1] >> 2U);
      i = (int32_T)((uint32_T)sibhes->data[(fid + sibhes->size[0] * leid) - 1] &
                    3U);
      if (b_fid == 0) {
      } else {
        i = sibhes->data[(b_fid + sibhes->size[0] * i) - 1];
        exitg1 = FALSE;
        while ((exitg1 == 0U) && (i != 0)) {
          b_fid = (int32_T)((uint32_T)i >> 2U) - 1;
          if (!ftags->data[b_fid]) {
            queue_size++;
            queue[(int32_T)queue_size - 1] = i;
          }

          i = (int32_T)((uint32_T)i & 3U);
          if (sibhes->data[b_fid + sibhes->size[0] * i] == sibhes->data[(fid +
               sibhes->size[0] * leid) - 1]) {
            exitg1 = TRUE;
          } else {
            i = sibhes->data[b_fid + sibhes->size[0] * i];
          }
        }
      }
    }
  }

  for (i = 0; i <= (int32_T)queue_size - 1; i++) {
    (*nfaces)++;
    ngbfaces[(int32_T)*nfaces - 1] = (real_T)((uint32_T)rt_roundd_snf((real_T)
      queue[(int32_T)(1.0 + (real_T)i) - 1]) >> 2U);
  }

  ftags->data[fid - 1] = FALSE;
  for (i = 0; i <= (int32_T)queue_size - 1; i++) {
    ftags->data[(int32_T)((uint32_T)rt_roundd_snf((real_T)queue[(int32_T)(1.0 +
                            (real_T)i) - 1]) >> 2U) - 1] = FALSE;
  }
}

void obtain_neighbor_faces_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void obtain_neighbor_faces_terminate(void)
{
}

void obtain_neighbor_faces_usestruct(int32_T fid, const b_struct_T sibhes,
  emxArray_boolean_T *ftags, boolean_T usestruct, real_T ngbfaces[100], real_T
  *nfaces)
{
  real_T queue_size;
  int32_T b_nfaces;
  int32_T queue_fid[100];
  int32_T i;
  int32_T heid_fid;
  int8_T heid_leid;
  int32_T sibhe_fid;
  int8_T sibhe_leid;
  boolean_T exitg1;
  int32_T b_fid;
  emxArray_int32_T *r0;
  emxArray_int32_T *r1;
  queue_size = 0.0;
  ftags->data[fid - 1] = TRUE;
  b_nfaces = -1;
  for (i = 0; i < 100; i++) {
    queue_fid[i] = 0;
    ngbfaces[i] = 0.0;
  }

  for (i = 0; i < 3; i++) {
    heid_fid = sibhes.fid->data[(fid + sibhes.fid->size[0] * i) - 1];
    heid_leid = sibhes.leid->data[(fid + sibhes.leid->size[0] * i) - 1];
    if (heid_fid != 0) {
      b_nfaces++;
      ngbfaces[b_nfaces] = (real_T)heid_fid;
      if ((heid_fid == 0) || (heid_leid == 0)) {
      } else {
        sibhe_fid = sibhes.fid->data[(heid_fid + sibhes.fid->size[0] *
          (heid_leid - 1)) - 1];
        sibhe_leid = sibhes.leid->data[(heid_fid + sibhes.leid->size[0] *
          (heid_leid - 1)) - 1];
        exitg1 = FALSE;
        while ((exitg1 == 0U) && (sibhe_fid != 0)) {
          b_fid = sibhe_fid;
          if (!ftags->data[sibhe_fid - 1]) {
            queue_size++;
            queue_fid[(int32_T)queue_size - 1] = sibhe_fid;
          }

          if ((sibhes.fid->data[(sibhe_fid + sibhes.fid->size[0] * (sibhe_leid -
                 1)) - 1] == heid_fid) && (sibhes.leid->data[(sibhe_fid +
                sibhes.leid->size[0] * (sibhe_leid - 1)) - 1] == heid_leid)) {
            exitg1 = TRUE;
          } else {
            sibhe_fid = sibhes.fid->data[(sibhe_fid + sibhes.fid->size[0] *
              (sibhe_leid - 1)) - 1];
            sibhe_leid = sibhes.leid->data[(b_fid + sibhes.leid->size[0] *
              (sibhe_leid - 1)) - 1];
          }
        }
      }
    }
  }

  for (i = 0; i <= (int32_T)queue_size - 1; i++) {
    b_nfaces++;
    ngbfaces[b_nfaces] = (real_T)queue_fid[i];
  }

  ftags->data[fid - 1] = FALSE;
  if (1.0 > queue_size) {
    heid_fid = 0;
  } else {
    heid_fid = (int32_T)queue_size;
  }

  emxInit_int32_T(&r0, 1);
  i = r0->size[0];
  r0->size[0] = heid_fid;
  emxEnsureCapacity((emxArray__common *)r0, i, (int32_T)sizeof(int32_T));
  i = heid_fid - 1;
  for (heid_fid = 0; heid_fid <= i; heid_fid++) {
    r0->data[heid_fid] = queue_fid[heid_fid];
  }

  emxInit_int32_T(&r1, 1);
  heid_fid = r1->size[0];
  r1->size[0] = r0->size[0];
  emxEnsureCapacity((emxArray__common *)r1, heid_fid, (int32_T)sizeof(int32_T));
  i = r0->size[0] - 1;
  for (heid_fid = 0; heid_fid <= i; heid_fid++) {
    r1->data[heid_fid] = r0->data[heid_fid] - 1;
  }

  i = r0->size[0];
  emxFree_int32_T(&r0);
  i--;
  for (heid_fid = 0; heid_fid <= i; heid_fid++) {
    ftags->data[r1->data[heid_fid]] = FALSE;
  }

  emxFree_int32_T(&r1);
  *nfaces = (real_T)(b_nfaces + 1);
}
