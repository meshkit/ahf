#include "rt_nonfinite.h"
#include "vid2adj_edges.h"
#include "m2c.h"

void vid2adj_edges(int32_T vid, const emxArray_int32_T *v2hv, const
                   emxArray_int32_T *sibhvs, int32_T edge_list[50], real_T
                   *nedges)
{
  int32_T hvid;
  boolean_T exitg1;
  int32_T eid;
  int32_T lvid;
  memset(&edge_list[0], 0, 50U * sizeof(int32_T));
  *nedges = 1.0;
  hvid = v2hv->data[vid - 1];
  edge_list[0] = (int32_T)((uint32_T)v2hv->data[vid - 1] >> 1U);
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (hvid != 0)) {
    eid = (int32_T)((uint32_T)hvid >> 1U) - 1;
    lvid = (int32_T)((uint32_T)hvid & 1U);
    hvid = sibhvs->data[((int32_T)((uint32_T)hvid >> 1U) + sibhvs->size[0] *
                         (int32_T)((uint32_T)hvid & 1U)) - 1];
    if ((!(sibhvs->data[eid + sibhvs->size[0] * lvid] != 0)) || (sibhvs->
         data[eid + sibhvs->size[0] * lvid] == v2hv->data[vid - 1])) {
      exitg1 = TRUE;
    } else {
      (*nedges)++;
      edge_list[(int32_T)*nedges - 1] = (int32_T)((uint32_T)hvid >> 1U);
    }
  }
}

void vid2adj_edges_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void vid2adj_edges_terminate(void)
{
}
