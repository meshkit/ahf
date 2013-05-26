#include "rt_nonfinite.h"
#include "eid2adj_faces.h"
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
static void loop_sbihes(int32_T he, const emxArray_int32_T *sibhes, int32_T
  queue[100], real_T *queue_size, const emxArray_boolean_T *ftags);
static int32_T obtain_1ring_surf_he(int32_T vid, int32_T second_vid, const
  emxArray_int32_T *tris, const emxArray_int32_T *sibhes, const emxArray_int32_T
  *v2he, emxArray_boolean_T *ftags);
static real_T rt_roundd_snf(real_T u);

static void loop_sbihes(int32_T he, const emxArray_int32_T *sibhes, int32_T
  queue[100], real_T *queue_size, const emxArray_boolean_T *ftags)
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

static int32_T obtain_1ring_surf_he(int32_T vid, int32_T second_vid, const
  emxArray_int32_T *tris, const emxArray_int32_T *sibhes, const emxArray_int32_T
  *v2he, emxArray_boolean_T *ftags)
{
  int32_T heid;
  int32_T queue[100];
  int32_T fid;
  int32_T lid;
  static const int8_T iv0[3] = { 3, 1, 2 };

  static const int8_T iv1[3] = { 2, 3, 1 };

  real_T queue_size;
  int32_T b_queue[100];
  real_T b_queue_size;
  int32_T queue_top;
  int32_T counter;
  boolean_T exitg1;
  boolean_T guard1 = FALSE;
  heid = 0;
  if (!((int32_T)((uint32_T)v2he->data[vid - 1] >> 2U) != 0)) {
  } else {
    memset(&queue[0], 0, 100U * sizeof(int32_T));
    fid = (int32_T)((uint32_T)v2he->data[vid - 1] >> 2U);
    lid = (int32_T)((uint32_T)v2he->data[vid - 1] & 3U);
    if (tris->data[(fid + tris->size[0] * lid) - 1] == vid) {
      lid = iv0[lid];
    } else {
      lid = iv1[lid];
    }

    lid = ((fid << 2) + lid) - 1;
    queue[0] = v2he->data[vid - 1];
    queue[1] = lid;
    ftags->data[(int32_T)((uint32_T)v2he->data[vid - 1] >> 2U) - 1] = TRUE;
    queue_size = 2.0;
    loop_sbihes(v2he->data[vid - 1], sibhes, queue, &queue_size, ftags);
    loop_sbihes(lid, sibhes, queue, &queue_size, ftags);
    memcpy(&b_queue[0], &queue[0], 100U * sizeof(int32_T));
    b_queue_size = queue_size;
    heid = 0;
    if (queue_size < 1.0) {
    } else {
      queue_top = 0;
      counter = 0;
      exitg1 = FALSE;
      while ((exitg1 == 0U) && (((real_T)(queue_top + 1) <= b_queue_size) &&
              (counter < 500))) {
        heid = b_queue[queue_top];
        guard1 = FALSE;
        if (tris->data[((int32_T)((uint32_T)b_queue[queue_top] >> 2U) +
                        tris->size[0] * (int32_T)((uint32_T)b_queue[queue_top] &
              3U)) - 1] == vid) {
          if (tris->data[((int32_T)((uint32_T)b_queue[queue_top] >> 2U) +
                          tris->size[0] * (iv1[(int32_T)((uint32_T)
                 b_queue[queue_top] & 3U)] - 1)) - 1] == second_vid) {
            exitg1 = TRUE;
          } else {
            guard1 = TRUE;
          }
        } else if (tris->data[((int32_T)((uint32_T)b_queue[queue_top] >> 2U) +
                               tris->size[0] * (int32_T)((uint32_T)
                     b_queue[queue_top] & 3U)) - 1] == second_vid) {
          exitg1 = TRUE;
        } else {
          guard1 = TRUE;
        }

        if (guard1 == TRUE) {
          queue_top++;
          fid = (int32_T)((uint32_T)heid >> 2U) - 1;
          lid = (int32_T)((uint32_T)heid & 3U);
          if (tris->data[fid + tris->size[0] * lid] == vid) {
            lid = iv0[lid];
          } else {
            lid = iv1[lid];
          }

          if (ftags->data[fid]) {
          } else {
            ftags->data[fid] = TRUE;
            loop_sbihes((((fid + 1) << 2) + lid) - 1, sibhes, b_queue,
                        &b_queue_size, ftags);
            counter++;
          }
        }
      }
    }

    for (lid = 0; lid <= (int32_T)queue_size - 1; lid++) {
      ftags->data[(int32_T)((uint32_T)queue[(int32_T)(1.0 + (real_T)lid) - 1] >>
                            2U) - 1] = FALSE;
    }
  }

  return heid;
}

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

real_T eid2adj_faces(int32_T eid, const emxArray_int32_T *edges, const
                     emxArray_int32_T *tris, const emxArray_int32_T *v2he, const
                     emxArray_int32_T *sibhes, emxArray_int32_T *flist,
                     emxArray_boolean_T *ftags)
{
  real_T nfaces;
  emxArray_int32_T *b_flist;
  emxArray_boolean_T *b_ftags;
  int32_T heid;
  int32_T sibhe;
  int32_T nhes;
  int32_T helist[150];
  int32_T fid;
  boolean_T exitg1;
  emxInit_int32_T(&b_flist, 1);
  emxInit_boolean_T(&b_ftags, 1);
  nfaces = 0.0;
  heid = obtain_1ring_surf_he(edges->data[eid - 1], edges->data[(eid +
    edges->size[0]) - 1], tris, sibhes, v2he, ftags);
  if (heid == 0) {
    sibhe = flist->size[0];
    flist->size[0] = 1;
    emxEnsureCapacity((emxArray__common *)flist, sibhe, (int32_T)sizeof(int32_T));
    flist->data[0] = 0;
  } else {
    flist->data[0] = (int32_T)((uint32_T)heid >> 2U);
    nfaces = 1.0;
    nhes = -1;
    memset(&helist[0], 0, 150U * sizeof(int32_T));
    fid = (int32_T)((uint32_T)heid >> 2U);
    if (fid == 0) {
    } else {
      sibhe = sibhes->data[(fid + sibhes->size[0] * (int32_T)((uint32_T)heid &
        3U)) - 1];
      exitg1 = FALSE;
      while ((exitg1 == 0U) && (sibhe != 0)) {
        fid = (int32_T)((uint32_T)sibhe >> 2U) - 1;
        if (!ftags->data[fid]) {
          nhes++;
          helist[nhes] = sibhe;
        }

        sibhe = (int32_T)((uint32_T)sibhe & 3U);
        if (sibhes->data[fid + sibhes->size[0] * sibhe] == heid) {
          exitg1 = TRUE;
        } else {
          sibhe = sibhes->data[fid + sibhes->size[0] * sibhe];
        }
      }
    }

    for (sibhe = 0; sibhe <= nhes; sibhe++) {
      nfaces++;
      flist->data[(int32_T)nfaces - 1] = (int32_T)((uint32_T)rt_roundd_snf
        ((real_T)helist[sibhe]) >> 2U);
    }
  }

  emxFree_boolean_T(&b_ftags);
  emxFree_int32_T(&b_flist);
  return nfaces;
}

void eid2adj_faces_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void eid2adj_faces_terminate(void)
{
}

