#include "rt_nonfinite.h"
#include "obtain_1ring_curv_NM.h"
#include "m2c.h"

void obtain_1ring_curv_NM(int32_T vid, const emxArray_int32_T *edges, const
  emxArray_int32_T *sibhvs, const emxArray_int32_T *v2hv, int32_T ngbvs[10],
  int32_T *nverts)
{
  int32_T eid;
  int32_T lid;
  int32_T i;
  eid = (int32_T)((uint32_T)v2hv->data[vid - 1] >> 1U);
  lid = (int32_T)((uint32_T)v2hv->data[vid - 1] & 1U);
  for (i = 0; i < 10; i++) {
    ngbvs[i] = 0;
  }

  *nverts = 0;
  if (!(eid != 0)) {
  } else {
    *nverts = 1;
    ngbvs[0] = edges->data[(eid + edges->size[0] * (1 - lid)) - 1];
    i = sibhvs->data[(eid + sibhvs->size[0] * lid) - 1];
    while ((i != 0) && (i != v2hv->data[vid - 1])) {
      eid = (int32_T)((uint32_T)i >> 1U) - 1;
      lid = (int32_T)((uint32_T)i & 1U);
      (*nverts)++;
      ngbvs[*nverts - 1] = edges->data[eid + edges->size[0] * (1 - lid)];
      i = sibhvs->data[eid + sibhvs->size[0] * lid];
    }
  }
}

void obtain_1ring_curv_NM_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void obtain_1ring_curv_NM_terminate(void)
{
}

void obtain_1ring_curv_NM_usestruct(int32_T vid, const emxArray_int32_T *edges,
  const struct_T sibhvs, const struct_T v2hv, boolean_T usestruct, int32_T
  ngbvs[10], int32_T *nverts)
{
  int32_T i;
  int8_T opp_lvid;
  for (i = 0; i < 10; i++) {
    ngbvs[i] = 0;
  }

  *nverts = 0;
  if (!(v2hv.eid->data[vid - 1] != 0)) {
  } else {
    *nverts = 1;
    ngbvs[0] = edges->data[(v2hv.eid->data[vid - 1] + edges->size[0] * ((int8_T)
                             (3 - v2hv.lvid->data[vid - 1]) - 1)) - 1];
    i = sibhvs.eid->data[(v2hv.eid->data[vid - 1] + sibhvs.eid->size[0] *
                          (v2hv.lvid->data[vid - 1] - 1)) - 1];
    opp_lvid = sibhvs.lvid->data[(v2hv.eid->data[vid - 1] + sibhvs.lvid->size[0]
      * (v2hv.lvid->data[vid - 1] - 1)) - 1];
    while ((i != 0) && ((i != v2hv.eid->data[vid - 1]) || (opp_lvid !=
             v2hv.lvid->data[vid - 1]))) {
      (*nverts)++;
      ngbvs[*nverts - 1] = edges->data[(i + edges->size[0] * ((int8_T)(3 -
        opp_lvid) - 1)) - 1];
      i = sibhvs.eid->data[(i + sibhvs.eid->size[0] * (opp_lvid - 1)) - 1];
      opp_lvid = sibhvs.lvid->data[(i + sibhvs.lvid->size[0] * (opp_lvid - 1)) -
        1];
    }
  }
}
