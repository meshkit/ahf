C******************************************************************
C    Copyright, 1991, The Regents of the University of            *
C    California.  This software was produced under a U. S.        *
C    Government contract (W-7405-ENG-36) by the Los Alamos        *
C    National Laboratory, which is operated by the                *
C    University of California for the U. S. Department of         *
C    Energy.  The U. S. Government is licensed to use,            *
C    reproduce, and distribute this software.  Permission         *
C    is granted to the public to copy and use this software       *
C    without charge, provided that this Notice and any statement  *
C    of authorship are reproduced on all copies.  Neither the     *
C    Government nor the University makes any warranty, express    *
C    or implied, or assumes any liability or responsibility for   *
C    the use of this software.                                    *
C								  *
C								  *
C     Software Author:  Kevin L. Bolling 			  *
C*************************************************************************
C    This program writes a gmv ieei4r8 file using the functions in the 	 *
C    gmvwrite library.  This should serve as an example of how to	 *
C    use these functions in a fortran routine.  To use these functions	 *
C    you first need to compile the file gmvwritef.c using the -c 	 *
C    option of the c compiler.  This will give you a .o file that	 *
C    that you need to include when you compile your fortran routine.	 *
C    These different compilations look like:				 *
C       SGI:  cc -c gmvwritef.c              f77 sampfile2.f gmvwritef.o *
C       SUN:  acc -c gmvwritef.c             f77 sampfile2.f gmvwritef.o *
C       CRAY: cc -c -Dunicos gmvwritef.c     cf77 sampfile2.f gmvwritef.o*
C       HP:   gcc -c -Dhp gmvwritef.c        f77 sampfile2.f gmvwritef.o *
C*************************************************************************

 	CHARACTER C(1)*80
	CHARACTER CTYPE(1)*9
	CHARACTER MATNAM(1)*9
	CHARACTER varnam(1)*9
	CHARACTER tracername(1)*8
        INTEGER nodids1(8)
        INTEGER nodids2(8)
        INTEGER nodids3(8)
        INTEGER nodids4(8)
        INTEGER nodids5(8)
        INTEGER nodids6(8)
        INTEGER nodids7(8)
        INTEGER nodids8(8)
	INTEGER matids(8)
	INTEGER flagids(27)
        INTEGER nnodes, ncells, nverts, nmats, dattyp, matnum, ntracers
	INTEGER cyclno
        REAL*8 X(27)
        REAL*8 Y(27)
        REAL*8 Z(27)
	REAL*8 M(4)
	REAL*8 N(4)
	REAL*8 O(4)
	REAL*8 tracex(2)
	REAL*8 tracey(2)
	REAL*8 tracez(2)
	REAL*8 ptime
	ptime = 13.5
	cyclno = 15
	nmats = 1
	dattyp = 0
        nnodes = 27
	nverts = 8
        ncells = 8
	ntracers = 2
        X(1) = 00.5
        X(2) = 10.5
        X(3) = 20.5
        X(4) = 00.5
        X(5) = 10.5
        X(6) = 20.5
        X(7) = 00.5
        X(8) = 10.5
        X(9) = 20.5
        X(10) = 00.5
        X(11) = 10.5
        X(12) = 20.5
        X(13) = 00.5
        X(14) = 10.5
        X(15) = 20.5
        X(16) = 00.5
        X(17) = 10.5
        X(18) = 20.5
        X(19) = 00.5
        X(20) = 10.5
        X(21) = 20.5
        X(22) = 00.5
        X(23) = 10.5
        X(24) = 20.5
        X(25) = 00.5
        X(26) = 10.5
        X(27) = 20.5
        Y(1) = 00.5
        Y(2) = 00.5
        Y(3) = 00.5
        Y(4) = 10.5
        Y(5) = 10.5
        Y(6) = 10.5
        Y(7) = 20.5
        Y(8) = 20.5
        Y(9) = 20.5
        Y(10) = 00.5
        Y(11) = 00.5
        Y(12) = 00.5
        Y(13) = 10.5
        Y(14) = 10.5
        Y(15) = 10.5
        Y(16) = 20.5
        Y(17) = 20.5
        Y(18) = 20.5
        Y(19) = 00.5
        Y(20) = 00.5
        Y(21) = 00.5
        Y(22) = 10.5
        Y(23) = 10.5
        Y(24) = 10.5
        Y(25) = 20.5
        Y(26) = 20.5
        Y(27) = 20.5
        Z(1) = 00.5
        Z(2) = 00.5
        Z(3) = 00.5
        Z(4) = 00.5
        Z(5) = 00.5
        Z(6) = 00.5
        Z(7) = 00.5
        Z(8) = 00.5
        Z(9) = 00.5
        Z(10) = 10.5
        Z(11) = 10.5
        Z(12) = 10.5
        Z(13) = 10.5
        Z(14) = 10.5
        Z(15) = 10.5
        Z(16) = 10.5
        Z(17) = 10.5
        Z(18) = 10.5
        Z(19) = 20.5
        Z(20) = 20.5
        Z(21) = 20.5
        Z(22) = 20.5
        Z(23) = 20.5
        Z(24) = 20.5
        Z(25) = 20.5
        Z(26) = 20.5
        Z(27) = 20.5
        nodids1(1) = 1
        nodids1(2) = 2
   	nodids1(3) = 5
	nodids1(4) = 4
	nodids1(5) = 10
	nodids1(6) = 11
	nodids1(7) = 14
	nodids1(8) = 13
        nodids2(1) = 2
        nodids2(2) = 3
   	nodids2(3) = 6
	nodids2(4) = 5
	nodids2(5) = 11
	nodids2(6) = 12
	nodids2(7) = 15
	nodids2(8) = 14	
        nodids3(1) = 4
        nodids3(2) = 5
   	nodids3(3) = 8
	nodids3(4) = 7
	nodids3(5) = 13
	nodids3(6) = 14
	nodids3(7) = 17
	nodids3(8) = 16
        nodids4(1) = 5
        nodids4(2) = 6
   	nodids4(3) = 9
	nodids4(4) = 8
	nodids4(5) = 14
	nodids4(6) = 15
	nodids4(7) = 18
	nodids4(8) = 17

        nodids5(1) = 10
        nodids5(2) = 11
   	nodids5(3) = 14
	nodids5(4) = 13
	nodids5(5) = 19
	nodids5(6) = 20
	nodids5(7) = 23
	nodids5(8) = 22
        nodids6(1) = 11
        nodids6(2) = 12
   	nodids6(3) = 15
	nodids6(4) = 14
	nodids6(5) = 20
	nodids6(6) = 21
	nodids6(7) = 24
	nodids6(8) = 23	
        nodids7(1) = 13
        nodids7(2) = 14
   	nodids7(3) = 17
	nodids7(4) = 16
	nodids7(5) = 22
	nodids7(6) = 23
	nodids7(7) = 26
	nodids7(8) = 25
        nodids8(1) = 14
        nodids8(2) = 15
   	nodids8(3) = 18
	nodids8(4) = 17
	nodids8(5) = 23
	nodids8(6) = 24
	nodids8(7) = 27
	nodids8(8) = 26
	M(1) = 0
	M(2) = 2
	M(3) = 2
	M(4) = 0
	N(1) = 0
	N(2) = 0
	N(3) = 4
	N(4) = 4
	O(1) = 1
	O(2) = 1
	O(3) = 1
	O(4) = 1

	tracex(1) = 15.5
	tracex(2) = 9.34
	tracey(1) = 15.5
	tracey(2) = 9.34
	tracez(1) = 15.5
	tracez(2) = 9.34

	matids(1) = 1
	matids(2) = 1
	matids(3) = 1
	matids(4) = 1
	matids(5) = 1
	matids(6) = 1
	matids(7) = 1
	matids(8) = 1

	flagids(1) = 1
	flagids(2) = 1
	flagids(3) = 1
	flagids(4) = 1
	flagids(5) = 1
	flagids(6) = 1
	flagids(7) = 1
	flagids(8) = 1
	flagids(9) = 1
	flagids(10) = 1
	flagids(11) = 1
	flagids(12) = 1
	flagids(13) = 1
	flagids(14) = 1
	flagids(15) = 1
	flagids(16) = 1
	flagids(17) = 1
	flagids(18) = 1
	flagids(19) = 1
	flagids(20) = 1
	flagids(21) = 1
	flagids(22) = 1
	flagids(23) = 1
	flagids(24) = 1
	flagids(25) = 1
	flagids(26) = 1
	flagids(27) = 1

	C(1) = 'testfile2'
	CTYPE(1) = 'hex     '
	MATNAM(1) = 'gold    '
	varnam(1) = 'pressure'
	tracername(1) = 'pressure'
     	call fgmvwrite_openfile_ir(C(1),4,8)
        call fgmvwrite_node_data(nnodes, X, Y, Z)
	call fgmvwrite_cell_header(ncells)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids1)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids2)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids3)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids4)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids5)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids6)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids7)
	call fgmvwrite_cell_type(CTYPE(1), nverts, nodids8)
	call fgmvwrite_material_header(nmats, dattyp)
	call fgmvwrite_material_name(MATNAM(1))
	call fgmvwrite_material_ids(matids, dattyp)
	dattyp = 1
	call fgmvwrite_velocity_data(dattyp, X, Y, Z)
	call fgmvwrite_variable_header()
	call fgmvwrite_variable_name_data(dattyp, varnam(1), Z)
	call fgmvwrite_variable_endvars()
	call fgmvwrite_polygons_header()
	nverts = 4
	matnum = 1
	call fgmvwrite_polygons_data(nverts, matnum, M, N, O) 
	call fgmvwrite_polygons_endpoly() 
	call fgmvwrite_tracers_header(ntracers, tracex, tracey, tracez)
	call fgmvwrite_tracers_name_data(ntracers, tracername(1), tracex)
	call fgmvwrite_tracers_endtrace()
	call fgmvwrite_flag_header()
	call fgmvwrite_flag_name(varnam(1), dattyp, dattyp)
	call fgmvwrite_flag_subname(MATNAM(1))
	call fgmvwrite_flag_data(dattyp, flagids)
	call fgmvwrite_flag_endflag()
	call fgmvwrite_probtime(ptime)
	call fgmvwrite_cycleno(cyclno)
        call fgmvwrite_closefile()
	END
