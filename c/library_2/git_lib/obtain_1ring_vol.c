#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * OBTAIN_1RING_VOL Collects 1-ring neighbor vertices and elements.
 *  [NGBVS,NVERTS,VTAGS,ETAGS,NGBES,NELEMS] = OBTAIN_1RING_VOL(VID,TETS, ...
 *  OPPHFS,V2HF,NGBVS,VTAGS,ETAGS,NGBES) Collects 1-ring neighbor vertices
 *  and elements of vertex VID and saves them into NGBVS and NGBES.  Note
 *  that NGBVS does not contain VID itself.  At input, VTAGS and ETAGS must
 *  be set to zeros. They will be reset to zeros at output.
 *
 *  See also OBTAIN_1RING_SURF, OBTAIN_1RING_CURV
 */

void obtain_1ring_vol(int32_T vid, const emxArray_int32_T *tets, const
                      emxArray_int32_T *opphfs, const emxArray_int32_T *v2hf,
                      emxArray_int32_T *ngbvs, emxArray_boolean_T *vtags,
                      emxArray_boolean_T *etags, emxArray_int32_T *ngbes,
                      int32_T *nverts, int32_T *nelems)
{
  int32_T eid;
  int32_T stack[1024];
  int32_T size_stack;
  int32_T lvid;
  int32_T ii;
  static const int8_T opphfs_tet[12] = { 1, 1, 1, 2, 2, 2, 3, 3, 4, 3, 4, 4 };

  int32_T ngb;
  emxArray_int32_T *r0;
  emxArray_int32_T *r1;
  emxArray_int32_T *b_ngbvs;
  emxArray_int32_T *c_ngbvs;
  emxArray_int32_T *r2;
  emxArray_int32_T *r3;
  emxArray_int32_T *b_ngbes;
  emxArray_int32_T *c_ngbes;

  /* assert( numel(ngbvs) <= MAXNPNTS); */
  /* assert( numel(ngbes) <= MAXNPNTS); */
  *nverts = 0;
  *nelems = 0;

  /*  Obtain incident tetrahedron of vid. */
  /*  HFID2CID   Obtains cell ID from half-face ID. */
  eid = (int32_T)((uint32_T)v2hf->data[vid - 1] >> 3U);
  if (!(eid != 0)) {
  } else {
    /*  If no incident tets, then return. */
    /*  Initialize array */
    vtags->data[vid - 1] = TRUE;

    /*  Create a stack for storing tets */
    size_stack = 0;
    stack[0] = eid;

    /*  Insert element itself into queue. */
    while (size_stack + 1 > 0) {
      /*  Pop the element from top of stack */
      eid = stack[size_stack] - 1;
      size_stack--;
      etags->data[eid] = TRUE;

      /*  Append element */
      (*nelems)++;
      ngbes->data[*nelems - 1] = eid + 1;
      lvid = -1;

      /*  Stores which vertex vid is within the tetrahedron. */
      /*  Append vertices */
      for (ii = 0; ii < 4; ii++) {
        if (tets->data[eid + tets->size[0] * ii] == vid) {
          lvid = ii;
        }

        if (!vtags->data[tets->data[eid + tets->size[0] * ii] - 1]) {
          vtags->data[tets->data[eid + tets->size[0] * ii] - 1] = TRUE;
          (*nverts)++;
          ngbvs->data[*nverts - 1] = tets->data[eid + tets->size[0] * ii];
        }
      }

      /*  Push unvisited neighbor tets onto stack */
      for (ii = 0; ii < 3; ii++) {
        /*  HFID2CID   Obtains cell ID from half-face ID. */
        ngb = (int32_T)((uint32_T)opphfs->data[eid + opphfs->size[0] *
                        (opphfs_tet[lvid + (ii << 2)] - 1)] >> 3U);
        if ((ngb != 0) && (!etags->data[ngb - 1])) {
          size_stack++;
          stack[size_stack] = ngb;
        }
      }
    }

    /*  Reset flags */
    vtags->data[vid - 1] = FALSE;
    if (1 > *nverts) {
      lvid = 0;
    } else {
      lvid = *nverts;
    }

    emxInit_int32_T(&r0, 1);
    eid = r0->size[0];
    r0->size[0] = lvid;
    emxEnsureCapacity((emxArray__common *)r0, eid, (int32_T)sizeof(int32_T));
    size_stack = lvid - 1;
    for (eid = 0; eid <= size_stack; eid++) {
      r0->data[eid] = 1 + eid;
    }

    emxInit_int32_T(&r1, 1);
    eid = r1->size[0];
    r1->size[0] = lvid;
    emxEnsureCapacity((emxArray__common *)r1, eid, (int32_T)sizeof(int32_T));
    size_stack = lvid - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      r1->data[lvid] = 1 + lvid;
    }

    b_emxInit_int32_T(&b_ngbvs, 2);
    eid = r0->size[0];
    lvid = b_ngbvs->size[0] * b_ngbvs->size[1];
    b_ngbvs->size[0] = 1;
    b_ngbvs->size[1] = eid;
    emxEnsureCapacity((emxArray__common *)b_ngbvs, lvid, (int32_T)sizeof(int32_T));
    size_stack = eid - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      eid = 0;
      while (eid <= 0) {
        b_ngbvs->data[b_ngbvs->size[0] * lvid] = ngbvs->data[r0->data[lvid] - 1]
          - 1;
        eid = 1;
      }
    }

    emxFree_int32_T(&r0);
    b_emxInit_int32_T(&c_ngbvs, 2);
    eid = r1->size[0];
    lvid = c_ngbvs->size[0] * c_ngbvs->size[1];
    c_ngbvs->size[0] = 1;
    c_ngbvs->size[1] = eid;
    emxEnsureCapacity((emxArray__common *)c_ngbvs, lvid, (int32_T)sizeof(int32_T));
    size_stack = eid - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      eid = 0;
      while (eid <= 0) {
        c_ngbvs->data[c_ngbvs->size[0] * lvid] = ngbvs->data[r1->data[lvid] - 1];
        eid = 1;
      }
    }

    emxFree_int32_T(&r1);
    size_stack = c_ngbvs->size[1] - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      vtags->data[b_ngbvs->data[b_ngbvs->size[0] * lvid]] = FALSE;
    }

    emxFree_int32_T(&c_ngbvs);
    emxFree_int32_T(&b_ngbvs);
    if (1 > *nelems) {
      lvid = 0;
    } else {
      lvid = *nelems;
    }

    emxInit_int32_T(&r2, 1);
    eid = r2->size[0];
    r2->size[0] = lvid;
    emxEnsureCapacity((emxArray__common *)r2, eid, (int32_T)sizeof(int32_T));
    size_stack = lvid - 1;
    for (eid = 0; eid <= size_stack; eid++) {
      r2->data[eid] = 1 + eid;
    }

    emxInit_int32_T(&r3, 1);
    eid = r3->size[0];
    r3->size[0] = lvid;
    emxEnsureCapacity((emxArray__common *)r3, eid, (int32_T)sizeof(int32_T));
    size_stack = lvid - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      r3->data[lvid] = 1 + lvid;
    }

    b_emxInit_int32_T(&b_ngbes, 2);
    eid = r2->size[0];
    lvid = b_ngbes->size[0] * b_ngbes->size[1];
    b_ngbes->size[0] = 1;
    b_ngbes->size[1] = eid;
    emxEnsureCapacity((emxArray__common *)b_ngbes, lvid, (int32_T)sizeof(int32_T));
    size_stack = eid - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      eid = 0;
      while (eid <= 0) {
        b_ngbes->data[b_ngbes->size[0] * lvid] = ngbes->data[r2->data[lvid] - 1]
          - 1;
        eid = 1;
      }
    }

    emxFree_int32_T(&r2);
    b_emxInit_int32_T(&c_ngbes, 2);
    eid = r3->size[0];
    lvid = c_ngbes->size[0] * c_ngbes->size[1];
    c_ngbes->size[0] = 1;
    c_ngbes->size[1] = eid;
    emxEnsureCapacity((emxArray__common *)c_ngbes, lvid, (int32_T)sizeof(int32_T));
    size_stack = eid - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      eid = 0;
      while (eid <= 0) {
        c_ngbes->data[c_ngbes->size[0] * lvid] = ngbes->data[r3->data[lvid] - 1];
        eid = 1;
      }
    }

    emxFree_int32_T(&r3);
    size_stack = c_ngbes->size[1] - 1;
    for (lvid = 0; lvid <= size_stack; lvid++) {
      etags->data[b_ngbes->data[b_ngbes->size[0] * lvid]] = FALSE;
    }

    emxFree_int32_T(&c_ngbes);
    emxFree_int32_T(&b_ngbes);
  }
}

void obtain_1ring_vol_initialize(void)
{
}

void obtain_1ring_vol_terminate(void)
{
  /* (no terminate code required) */
}

/* End of code generation (obtain_1ring_vol.c) */
