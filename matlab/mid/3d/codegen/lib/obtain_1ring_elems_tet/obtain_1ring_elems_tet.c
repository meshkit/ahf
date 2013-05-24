#include "rt_nonfinite.h"
#include "obtain_1ring_elems_tet.h"
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
static define_emxInit(c_emxInit_int32_T, int32_T)

int32_T obtain_1ring_elems_tet(int32_T vid, const emxArray_int32_T *tets, const
  emxArray_int32_T *sibhfs, const emxArray_int32_T *v2hf, emxArray_int32_T
  *ngbes, emxArray_boolean_T *etags)
{
  int32_T nelems;
  int32_T eid;
  real_T u1;
  int32_T maxne;
  int32_T stack[1024];
  int32_T size_stack;
  int32_T lvid;
  int32_T ii;
  static const int8_T sibhfs_tet[12] = { 1, 1, 1, 2, 2, 2, 3, 3, 4, 3, 4, 4 };

  int32_T ngb;
  emxArray_int32_T *r0;
  emxArray_int32_T *r1;
  emxArray_int32_T *b_ngbes;
  emxArray_int32_T *c_ngbes;
  nelems = 0;
  eid = (int32_T)((uint32_T)v2hf->data[vid - 1] >> 3U);
  if (!(eid != 0)) {
  } else {
    u1 = (real_T)ngbes->size[0];
    if (1024.0 <= u1) {
      u1 = 1024.0;
    }

    maxne = (int32_T)u1;
    size_stack = 0;
    stack[0] = eid;
    while (size_stack + 1 > 0) {
      eid = stack[size_stack] - 1;
      size_stack--;
      etags->data[eid] = TRUE;
      if (nelems < maxne) {
        nelems++;
        ngbes->data[nelems - 1] = eid + 1;
      }

      lvid = -1;
      for (ii = 0; ii < 4; ii++) {
        if (tets->data[eid + tets->size[0] * ii] == vid) {
          lvid = ii;
        }
      }

      for (ii = 0; ii < 3; ii++) {
        ngb = (int32_T)((uint32_T)sibhfs->data[eid + sibhfs->size[0] *
                        (sibhfs_tet[lvid + (ii << 2)] - 1)] >> 3U);
        if ((ngb != 0) && (!etags->data[ngb - 1])) {
          size_stack++;
          stack[size_stack] = ngb;
        }
      }
    }

    if (1 > nelems) {
      size_stack = 0;
    } else {
      size_stack = nelems;
    }

    emxInit_int32_T(&r0, 1);
    eid = r0->size[0];
    r0->size[0] = size_stack;
    emxEnsureCapacity((emxArray__common *)r0, eid, (int32_T)sizeof(int32_T));
    maxne = size_stack - 1;
    for (eid = 0; eid <= maxne; eid++) {
      r0->data[eid] = 1 + eid;
    }

    emxInit_int32_T(&r1, 1);
    eid = r1->size[0];
    r1->size[0] = size_stack;
    emxEnsureCapacity((emxArray__common *)r1, eid, (int32_T)sizeof(int32_T));
    maxne = size_stack - 1;
    for (size_stack = 0; size_stack <= maxne; size_stack++) {
      r1->data[size_stack] = 1 + size_stack;
    }

    b_emxInit_int32_T(&b_ngbes, 2);
    eid = r0->size[0];
    size_stack = b_ngbes->size[0] * b_ngbes->size[1];
    b_ngbes->size[0] = 1;
    b_ngbes->size[1] = eid;
    emxEnsureCapacity((emxArray__common *)b_ngbes, size_stack, (int32_T)sizeof
                      (int32_T));
    maxne = eid - 1;
    for (size_stack = 0; size_stack <= maxne; size_stack++) {
      eid = 0;
      while (eid <= 0) {
        b_ngbes->data[b_ngbes->size[0] * size_stack] = ngbes->data[r0->
          data[size_stack] - 1] - 1;
        eid = 1;
      }
    }

    emxFree_int32_T(&r0);
    b_emxInit_int32_T(&c_ngbes, 2);
    eid = r1->size[0];
    size_stack = c_ngbes->size[0] * c_ngbes->size[1];
    c_ngbes->size[0] = 1;
    c_ngbes->size[1] = eid;
    emxEnsureCapacity((emxArray__common *)c_ngbes, size_stack, (int32_T)sizeof
                      (int32_T));
    maxne = eid - 1;
    for (size_stack = 0; size_stack <= maxne; size_stack++) {
      eid = 0;
      while (eid <= 0) {
        c_ngbes->data[c_ngbes->size[0] * size_stack] = ngbes->data[r1->
          data[size_stack] - 1];
        eid = 1;
      }
    }

    emxFree_int32_T(&r1);
    maxne = c_ngbes->size[1] - 1;
    for (size_stack = 0; size_stack <= maxne; size_stack++) {
      etags->data[b_ngbes->data[b_ngbes->size[0] * size_stack]] = FALSE;
    }

    emxFree_int32_T(&c_ngbes);
    emxFree_int32_T(&b_ngbes);
  }

  return nelems;
}

void obtain_1ring_elems_tet_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void obtain_1ring_elems_tet_terminate(void)
{
}
