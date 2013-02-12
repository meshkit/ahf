

#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * OBTAIN_NRING_TRI Collect n-ring vertices and faces of a triangle mesh.
 *
 *  [NGBVS,NVERTS,VTAGS,FTAGS,NGBFS,NFACES] = OBTAIN_NRING_TRI(VID,RING, ...
 *  MINPNTS,TRIS,OPPHES,V2HE,NGBVS,VTAGS,FTAGS,NGBFS) Collects n-ring
 *  vertices and faces of a vertex and saves them into NGBVS and NGBFS,
 *  where n is a floating point number with 0.5 increments (1, 1.5, 2, etc.)
 *  We define the n-ring verticse as follows:
 *   - 0-ring: vertex itself
 *   - k-ring vertices: vertices that share an edge with (k-1)-ring vertices
 *   - (k+0.5)-ring vertices: k-ring plus vertices that share an element
 *            with two vertices of k-ring vertices.
 *  For triangle meshes, the k-ring vertices always form some triangles.
 *
 *  Input arguments
 *    vid: vertex ID
 *    ring: the desired number of rings (it is a float as it can have halves)
 *    minpnts: the minimum number of points desired
 *    tris: element connectivity
 *    opphes: opposite half-edges
 *    v2he: vertex-to-halfedge mapping
 *    ngbvs: buffer space for neighboring vertices (not including vid itself)
 *    vtags: vertex tags (boolean, of length equal to number of vertices)
 *    ftags: face tags (boolean, of length equal to number of elements)
 *    ngbfs: buffer space for neighboring faces
 *
 *  Output arguments
 *    ngbvs: buffer space for neighboring vertices
 *    nverts: number of vertices in the neighborhood
 *    vtags: vertex tags (boolean, of length equal to number of vertices)
 *    ftags: face tags (boolean, of length equal to number of elements)
 *    ngbfs: buffer space for neighboring faces
 *    nfaces: number of elements in the neighborhood
 *
 *  Notes
 *   1. vtags and ftags must be set to false at input. They are reset to
 *      false at output.
 *   2. Since the vertex itself is always in ring, we do not include it in
 *      the output array ngbvs.
 *   3. If NGBVS or NGBFS is not enough to store the whole neighborhood,
 *      then only a subset of the neighborhood will be returned.
 *      The maximum number of points returned is numel(NGBVS) if NGBVS is
 *      given as part of the input, or 128 if not an input arguement.
 *      The maximum number of faces returned is numel(NGBFS) if NGBFS is
 *      given as part of the input, or 256 if not an input arguement.
 *
 *  See also OBTAIN_NRING_SURF, OBTAIN_NRING_QUAD, OBTAIN_NRING_CURV, OBTAIN_NRING_VOL
 */
void obtain_nring_tri(int32_T vid, real_T ring, int32_T minpnts, const
                      emxArray_int32_T *tris, const emxArray_int32_T *opphes,
                      const emxArray_int32_T *v2he, emxArray_int32_T *ngbvs,
                      emxArray_boolean_T *vtags, emxArray_boolean_T *ftags,
                      emxArray_int32_T *ngbfs, int32_T *nverts, int32_T *nfaces)
{
  

  emxArray_int32_T *b_ngbvs;
  emxArray_boolean_T *b_vtags;
  emxArray_boolean_T *b_ftags;
  emxArray_int32_T *b_ngbfs;
  int32_T fid;
  int32_T lid;
  boolean_T overflow;
  int32_T maxnv;
  int32_T B[128];
  int32_T fid_in;
  int32_T maxnf;
  int32_T b_B[256];
  emxArray_int32_T *hebuf;
  static const int8_T iv0[3] = { 2, 3, 1 };


  int32_T exitg4;
  static const int8_T iv1[3] = { 3, 1, 2 };

  int32_T opp;
  int32_T nverts_pre;
  int32_T nfaces_pre;
  real_T ring_full;
  real_T cur_ring;
  int32_T exitg1;
  boolean_T guard1 = FALSE;
  int32_T nverts_last;
  boolean_T exitg2;
  boolean_T b0;
  boolean_T isfirst;
  int32_T exitg3;
  boolean_T guard2 = FALSE;
  emxInit_int32_T(&b_ngbvs, 1);
  emxInit_boolean_T(&b_vtags, 1);
  emxInit_boolean_T(&b_ftags, 1);
  emxInit_int32_T(&b_ngbfs, 1);



  /*  HEID2FID   Obtains face ID from half-edge ID. */
  fid = (int32_T)((uint32_T)v2he->data[vid - 1] >> 2U);



  /*  HEID2LEID   Obtains local edge ID within a face from half-edge ID. */
  lid = (int32_T)((uint32_T)v2he->data[vid - 1] & 3U);
  *nverts = 0;
  *nfaces = 0;
  overflow = FALSE;


  if (!(fid != 0)) {
  } else {
    if (!(ngbvs->size[0] == 0)) {
      maxnv = ngbvs->size[0];
    } else {
      maxnv = 128;
      fid_in = ngbvs->size[0];
      ngbvs->size[0] = 128;
      emxEnsureCapacity((emxArray__common *)ngbvs, fid_in, (int32_T)sizeof
                        (int32_T));
      for (fid_in = 0; fid_in < 128; fid_in++) {
        ngbvs->data[fid_in] = B[fid_in];
      }
    }

	

    if (!(ngbfs->size[0] == 0)) {
      maxnf = ngbfs->size[0];
    } else {
      maxnf = 256;
      fid_in = ngbfs->size[0];
      ngbfs->size[0] = 256;
      emxEnsureCapacity((emxArray__common *)ngbfs, fid_in, (int32_T)sizeof
                        (int32_T));
      for (fid_in = 0; fid_in < 256; fid_in++) {
        ngbfs->data[fid_in] = b_B[fid_in];
      }
    }

	

    emxInit_int32_T(&hebuf, 1);
    fid_in = hebuf->size[0];
    hebuf->size[0] = maxnv;
    emxEnsureCapacity((emxArray__common *)hebuf, fid_in, (int32_T)sizeof(int32_T));

    /*  Optimized version for collecting one-ring vertices */
    if (opphes->data[(fid + opphes->size[0] * lid) - 1] != 0) {
      fid_in = fid;
    } else {
      fid_in = 0;
      *nverts = 1;
      ngbvs->data[0] = tris->data[(fid + tris->size[0] * (iv0[lid] - 1)) - 1];
      hebuf->data[0] = 0;
    }

    /*  Rotate counterclockwise order around vertex and insert vertices */
    do {
      exitg4 = 0;

      /*  Insert vertx into list */
      if ((*nverts < maxnv) && (*nfaces < maxnf)) {
        (*nverts)++;
        ngbvs->data[*nverts - 1] = tris->data[(fid + tris->size[0] * (iv1[lid] -
          1)) - 1];

        /*  Save starting position for next vertex */
        hebuf->data[*nverts - 1] = opphes->data[(fid + opphes->size[0] *
          (iv1[iv1[lid] - 1] - 1)) - 1];
        (*nfaces)++;
        ngbfs->data[*nfaces - 1] = fid;
      } else {
        overflow = TRUE;
      }

      opp = opphes->data[(fid + opphes->size[0] * (iv1[lid] - 1)) - 1];

      /*  HEID2FID   Obtains face ID from half-edge ID. */
      fid = (int32_T)((uint32_T)opphes->data[(fid + opphes->size[0] * (iv1[lid]
        - 1)) - 1] >> 2U);
      if (fid == fid_in) {
        exitg4 = 1;
      } else {
        /*  HEID2LEID   Obtains local edge ID within a face from half-edge ID. */
        lid = (int32_T)((uint32_T)opp & 3U);
      }
    } while (exitg4 == 0U);

    /*  Finished cycle */
    if ((ring == 1.0) && ((*nverts >= minpnts) || (*nverts >= maxnv) || (*nfaces
          >= maxnf))) {
    } else {
      vtags->data[vid - 1] = TRUE;
      for (fid_in = 1; fid_in <= *nverts; fid_in++) {
        vtags->data[ngbvs->data[fid_in - 1] - 1] = TRUE;
      }

      for (fid_in = 1; fid_in <= *nfaces; fid_in++) {
        ftags->data[ngbfs->data[fid_in - 1] - 1] = TRUE;
      }

      /*  Define buffers and prepare tags for further processing */
      nverts_pre = 0;
      nfaces_pre = 0;

      /*  Second, build full-size ring */
      if (ring < 0.0) {
        ring_full = ceil(ring);
      } else {
        ring_full = floor(ring);
      }

      if (minpnts <= maxnv) {
      } else {
        minpnts = maxnv;
      }

      cur_ring = 1.0;
      do {
        exitg1 = 0;
        guard1 = FALSE;
        if ((cur_ring > ring_full) || ((cur_ring == ring_full) && (ring_full !=
              ring))) {
          /*  Collect halfring */
          opp = *nfaces;
          nverts_last = *nverts;
          while (nfaces_pre + 1 <= opp) {
            /*  take opposite vertex in opposite face */
            fid_in = 0;
            exitg2 = FALSE;
            while ((exitg2 == 0U) && (fid_in + 1 < 4)) {
              /*  HEID2FID   Obtains face ID from half-edge ID. */
              fid = (int32_T)((uint32_T)opphes->data[(ngbfs->data[nfaces_pre] +
                opphes->size[0] * fid_in) - 1] >> 2U) - 1;
              if ((opphes->data[(ngbfs->data[nfaces_pre] + opphes->size[0] *
                                 fid_in) - 1] != 0) && (!ftags->data[fid])) {
                /*  HEID2LEID   Obtains local edge ID within a face from half-edge ID. */
                lid = (int32_T)((uint32_T)opphes->data[(ngbfs->data[nfaces_pre]
                  + opphes->size[0] * fid_in) - 1] & 3U);
                if (overflow || ((!vtags->data[tris->data[fid + tris->size[0] *
                                  (iv1[lid] - 1)] - 1]) && (*nverts >=
                      ngbvs->size[0])) || ((!ftags->data[fid]) && (*nfaces >=
                      ngbfs->size[0]))) {
                  overflow = TRUE;
                } else {
                  overflow = FALSE;
                }

                if ((!ftags->data[fid]) && (!overflow)) {
                  (*nfaces)++;
                  ngbfs->data[*nfaces - 1] = fid + 1;
                  ftags->data[fid] = TRUE;
                }

                if ((!vtags->data[tris->data[fid + tris->size[0] * (iv1[lid] - 1)]
                     - 1]) && (!overflow)) {
                  (*nverts)++;
                  ngbvs->data[*nverts - 1] = tris->data[fid + tris->size[0] *
                    (iv1[lid] - 1)];
                  vtags->data[tris->data[fid + tris->size[0] * (iv1[lid] - 1)] -
                    1] = TRUE;
                }

                exitg2 = TRUE;
              } else {
                fid_in++;
              }
            }

            nfaces_pre++;
          }

          if ((*nverts >= minpnts) || (*nverts >= maxnv) || (*nfaces >= maxnf) ||
              (*nfaces == opp)) {
            exitg1 = 1;
          } else {
            /*  If needs to expand, then undo the last half ring */
            for (fid_in = nverts_last; fid_in + 1 <= *nverts; fid_in++) {
              vtags->data[ngbvs->data[fid_in] - 1] = FALSE;
            }

            *nverts = nverts_last;
            for (fid_in = opp; fid_in + 1 <= *nfaces; fid_in++) {
              ftags->data[ngbfs->data[fid_in] - 1] = FALSE;
            }

            *nfaces = opp;
            guard1 = TRUE;
          }
        } else {
          guard1 = TRUE;
        }

        if (guard1 == TRUE) {
          /*  Collect next full level of ring */
          nverts_last = *nverts;
          nfaces_pre = *nfaces;
          while (nverts_pre + 1 <= nverts_last) {
            /*  HEID2FID   Obtains face ID from half-edge ID. */
            fid = (int32_T)((uint32_T)v2he->data[ngbvs->data[nverts_pre] - 1] >>
                            2U) - 1;

            /*  HEID2LEID   Obtains local edge ID within a face from half-edge ID. */
            lid = (int32_T)((uint32_T)v2he->data[ngbvs->data[nverts_pre] - 1] &
                            3U);

            /*  Allow early termination of the loop if an incident halfedge */
            /*  was recorded and the vertex is not incident on a border halfedge */
            if ((hebuf->data[nverts_pre] != 0) && (opphes->data[fid +
                 opphes->size[0] * lid] != 0)) {
              b0 = TRUE;
            } else {
              b0 = FALSE;
            }

            if (b0) {
              /*  HEID2FID   Obtains face ID from half-edge ID. */
              fid = (int32_T)((uint32_T)hebuf->data[nverts_pre] >> 2U) - 1;

              /*  HEID2LEID   Obtains local edge ID within a face from half-edge ID. */
              lid = (int32_T)((uint32_T)hebuf->data[nverts_pre] & 3U);
            }

            /*  */
            if (opphes->data[fid + opphes->size[0] * lid] != 0) {
              fid_in = fid;
            } else {
              fid_in = -1;
              if (overflow || ((!vtags->data[tris->data[fid + tris->size[0] *
                                (iv0[lid] - 1)] - 1]) && (*nverts >= ngbvs->
                    size[0]))) {
                overflow = TRUE;
              } else {
                overflow = FALSE;
              }

              if (!overflow) {
                (*nverts)++;
                ngbvs->data[*nverts - 1] = tris->data[fid + tris->size[0] *
                  (iv0[lid] - 1)];
                vtags->data[tris->data[fid + tris->size[0] * (iv0[lid] - 1)] - 1]
                  = TRUE;

                /*  Save starting position for next vertex */
                hebuf->data[*nverts - 1] = 0;
              }
            }

            /*  Rotate counterclockwise around the vertex. */
            isfirst = TRUE;
            do {
              exitg3 = 0;

              /*  Insert vertx into list */
              /*  Insert face into list */
              guard2 = FALSE;
              if (ftags->data[fid]) {
                if (b0 && (!isfirst)) {
                  exitg3 = 1;
                } else {
                  guard2 = TRUE;
                }
              } else {
                /*  If the face has already been inserted, then the vertex */
                /*  must be inserted already. */
                if (overflow || ((!vtags->data[tris->data[fid + tris->size[0] *
                                  (iv1[lid] - 1)] - 1]) && (*nverts >=
                      ngbvs->size[0])) || ((!ftags->data[fid]) && (*nfaces >=
                      ngbfs->size[0]))) {
                  overflow = TRUE;
                } else {
                  overflow = FALSE;
                }

                if ((!vtags->data[tris->data[fid + tris->size[0] * (iv1[lid] - 1)]
                     - 1]) && (!overflow)) {
                  (*nverts)++;
                  ngbvs->data[*nverts - 1] = tris->data[fid + tris->size[0] *
                    (iv1[lid] - 1)];
                  vtags->data[tris->data[fid + tris->size[0] * (iv1[lid] - 1)] -
                    1] = TRUE;

                  /*  Save starting position for next ring */
                  hebuf->data[*nverts - 1] = opphes->data[fid + opphes->size[0] *
                    (iv1[iv1[lid] - 1] - 1)];
                }

                if ((!ftags->data[fid]) && (!overflow)) {
                  (*nfaces)++;
                  ngbfs->data[*nfaces - 1] = fid + 1;
                  ftags->data[fid] = TRUE;
                }

                isfirst = FALSE;
                guard2 = TRUE;
              }

              if (guard2 == TRUE) {
                opp = opphes->data[fid + opphes->size[0] * (iv1[lid] - 1)];

                /*  HEID2FID   Obtains face ID from half-edge ID. */
                fid = (int32_T)((uint32_T)opphes->data[fid + opphes->size[0] *
                                (iv1[lid] - 1)] >> 2U) - 1;
                if (fid + 1 == fid_in + 1) {
                  /*  Finished cycle */
                  exitg3 = 1;
                } else {
                  /*  HEID2LEID   Obtains local edge ID within a face from half-edge ID. */
                  lid = (int32_T)((uint32_T)opp & 3U);
                }
              }
            } while (exitg3 == 0U);

            nverts_pre++;
          }

          cur_ring++;
          if (((*nverts >= minpnts) && (cur_ring >= ring)) || (*nfaces ==
               nfaces_pre) || overflow) {
            exitg1 = 1;
          } else {
            nverts_pre = nverts_last;
          }
        }
      } while (exitg1 == 0U);

      /*  Reset flags */
      vtags->data[vid - 1] = FALSE;
      for (fid_in = 1; fid_in <= *nverts; fid_in++) {
        vtags->data[ngbvs->data[fid_in - 1] - 1] = FALSE;
      }

      for (fid_in = 1; fid_in <= *nfaces; fid_in++) {
        ftags->data[ngbfs->data[fid_in - 1] - 1] = FALSE;
      }
    }

    emxFree_int32_T(&hebuf);
  }

  emxFree_int32_T(&b_ngbfs);
  emxFree_boolean_T(&b_ftags);
  emxFree_boolean_T(&b_vtags);
  emxFree_int32_T(&b_ngbvs);
}

void obtain_nring_tri_initialize(void)
{
}

void obtain_nring_tri_terminate(void)
{
  /* (no terminate code required) */
}

/* End of code generation (obtain_nring_tri.c) */
