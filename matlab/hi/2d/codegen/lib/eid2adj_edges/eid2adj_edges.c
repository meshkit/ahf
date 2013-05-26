#include "rt_nonfinite.h"
#include "eid2adj_edges.h"
#include "m2c.h"

static define_emxInit(b_emxInit_int32_T, int32_T)
static void vid2adj_edges_local(int32_T vid, const emxArray_int32_T *v2hv, const
  emxArray_int32_T *sibhvs, real_T *nedges, emxArray_int32_T *edge_list);

static void vid2adj_edges_local(int32_T vid, const emxArray_int32_T *v2hv, const
  emxArray_int32_T *sibhvs, real_T *nedges, emxArray_int32_T *edge_list)
{
  emxArray_int32_T *b_edge_list;
  int32_T hvid;
  boolean_T exitg1;
  int32_T eid;
  int32_T lvid;
  emxInit_int32_T(&b_edge_list, 1);
  hvid = v2hv->data[vid - 1];
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
      edge_list->data[(int32_T)*nedges - 1] = (int32_T)((uint32_T)hvid >> 1U);
    }
  }

  emxFree_int32_T(&b_edge_list);
}

real_T eid2adj_edges(int32_T eid, const emxArray_int32_T *edges, const
                     emxArray_int32_T *v2hv, const emxArray_int32_T *sibhvs,
                     emxArray_int32_T *edge_list)
{
  real_T nedges;
  nedges = 0.0;
  vid2adj_edges_local(edges->data[eid - 1], v2hv, sibhvs, &nedges, edge_list);
  vid2adj_edges_local(edges->data[(eid + edges->size[0]) - 1], v2hv, sibhvs,
                      &nedges, edge_list);
  return nedges;
}

void eid2adj_edges_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void eid2adj_edges_terminate(void)
{
}

