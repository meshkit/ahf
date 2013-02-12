CC=gcc
CFLAGS=-I.
DEPS = rtwtypes.h all_types.h all_headers.h
OBJ = util_functions.o basic_emxArray_fncs.o obtain_1ring_vol.o obtain_nring_quad.o determine_opposite_halfedge.o determine_border_vertices_surf.o call_all_functions.o determine_border_vertices_vol.o determine_incident_halfedges.o determine_incident_halffaces.o extract_border_surf_tet.o determine_opposite_halfedge_quad.o determine_opposite_halfface_tet.o obtain_nring_tri.o 

all: stuff.a try
%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)
stuff.a: $(OBJ)
	ar rc $@ $^
try: main.c stuff.a
	$(CC) -lm -o $@ $< $(CFLAGS)
