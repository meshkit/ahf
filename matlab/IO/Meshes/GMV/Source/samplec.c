
/*
    Copyright, 1991, The Regents of the University of
    California.  This software was produced under a U. S.
    Government contract (W-7405-ENG-36) by the Los Alamos
    National Laboratory, which is operated by the
    University of California for the U. S. Department of
    Energy.  The U. S. Government is licensed to use,
    reproduce, and distribute this software.  Permission
    is granted to the public to copy and use this software
    without charge, provided that this Notice and any statement
    of authorship are reproduced on all copies.  Neither the
    Government nor the University makes any warranty, express
    or implied, or assumes any liability or responsibility for
    the use of this software.


     Software Author:  John D. Fowler, Jr., X-7 (505) 667-3413

*/

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#define s 1
#define b 2
#define nnodes 37 * 2 * 30
#include "gmvwrite.c"
#include <sys/types.h>
#include <malloc.h>
float x[nnodes];
float y[nnodes];
float z[nnodes];
float step;
float i;
float l;
float small = s;
float big = b;
int NXV = 37, NYV = 2, NZV = 30;
int numats = 2;
int dattype = 1;
int j,k,p,m,n;
long long n_cells = 0;
long long n_nodes = nnodes;

void main(void)
 {
  gmvwrite_openall();           /*This section is the main function that calls*/
  generate_cylender();          /*that calls subroutines that generate the gmv*/
  gmvwrite_cell_header(&n_cells);/*data and call the functions that write out  */
  generate_material_data();     /*data.*/
  generate_velocities();
  generate_variables();
  generate_flags();
  generate_polygons();
  generate_tracers();
  gmvwrite_closeall();
  
}

/*Folowing code generates a cylender*/
/*and then uses functions from the gmvwriter*/
/*library to write it out*/
generate_cylender()
 {
  step = (360.000/(NXV - 1));

  j = 0;
 
  for(k = 0;k<NZV;k++)
  {
   for(l=0;l<=(360);l+=step)
    {
     i=((l/180)*3.14159265359);
     x[j] = fcos(i)*small;
     y[j] = fsin(i)*small;
    j++;
    } 

   for(l=0;l<=(360);l+=step)
    {
     i=((l/180)*3.14159265359);
     x[j] = fcos(i)*big;
     y[j] = fsin(i)*big;
    j++;
    }
  }


   k=0;  

   for(p=0;p<(NZV);p++)
    {
     for(n=0;n<NYV;n++)
      {
       for(j=0;j<NXV;j++)
        {
         z[k]=p;
         k++;
     
        }
      }
    }
/*The following statement uses the function gmvwrite_node_data_lstruct*/
/*to write out information for a cylender using the nodes -2 option*/
  gmvwrite_node_data_lstruct(&NXV, &NYV, &NZV,x,y,z);
 }


/*following code generates two materials and their data*/
/*and writes it to a gmv file using functions from the gmvwrtite libraries*/
generate_material_data()
 {
  int mids[nnodes];
  char matnam1[] = "gold    ";
  char matnam2[] = "silver  ";
  gmvwrite_material_header(numats,dattype);
  gmvwrite_material_name(matnam1);
  gmvwrite_material_name(matnam2);
  for(j = 0;j<((n_nodes)/2);j++)
   {
    mids[j] = 1;
    mids[(j+((n_nodes)/2))] = 2;
   }
  gmvwrite_material_ids(mids,dattype);
 }

/*generates the velocities of the nodes and uses the function*/
/*gmvwrite_velocity_datafrom the gmvwrite library to write it to the gmvfile*/
generate_velocities()
 {
  float u[nnodes];
  float v[nnodes];
  float w[nnodes];
  for(j = 0;j<nnodes;j++)
   {
    u[j] = 0;
    v[j] = 0;
    w[j] = 1;
   }
  gmvwrite_velocity_data(dattype,u,v,w);
 }
  
/*generates the variable data and writes to a gmvfile using functions from*/
/*the gmvwrite library*/
generate_variables()
 {
  float varids[nnodes];
  char varname[] = "density ";
  gmvwrite_variable_header();
  i = 0;
  for(j = 0;j<(nnodes);j++)
   {
    varids[j] = i;
    i+=.1;
   }
  gmvwrite_variable_name_data(dattype,varname,varids);
  gmvwrite_variable_endvars();
 }

/*generates flag data and uses functions from the gmvwrite library*/
/*write it to a file*/
generate_flags()
 {
  int n_types = 2;
  char fname[] = "cheese  ";
  char ftype1[] = "swiss   ";
  char ftype2[] = "american";
  int flagids[nnodes];
  
  gmvwrite_flag_header();
  gmvwrite_flag_name(fname,n_types,dattype);
  gmvwrite_flag_subname(ftype1);
  gmvwrite_flag_subname(ftype2);
  j = 1;
  for(k = 0; k<500;k++)
   {
    flagids[k] = j;
   }
  j = 2;
  for(k = 500;k<(nnodes);k++)
   {
    flagids[k] = j;
   }
  gmvwrite_flag_data(dattype,flagids);
  gmvwrite_flag_endflag();
 }

/*generates polygons and uses functions from the gmvwrite library*/
/*to write it to a gmv file*/
generate_polygons()
 {
  int n_verts = 4;
  int matno = 1;
  float c[4];
  float d[4];
  float e[4];
  gmvwrite_polygons_header();
  c[0] = -5;
  c[1] = 5;
  c[2] = 5;
  c[3] = -5;
  d[0] = -5;
  d[1] = -5;
  d[2] =5;
  d[3] = 5;
  e[0] = 0;
  e[1] = 0;
  e[2] = 0;
  e[3] = 0;
  gmvwrite_polygons_data(n_verts,matno,c,d,e);

  matno = 2;
  c[0] = -5;
  c[1] = 5;
  c[2] = 5;
  c[3] = -5;
  d[0] = -5;
  d[1] = -5;
  d[2] =5;
  d[3] = 5;
  e[0] = 29;
  e[1] = 29;
  e[2] = 29;
  e[3] = 29;
  gmvwrite_polygons_data(n_verts,matno,c,d,e);

  matno = 1;
  c[0] = -5;
  c[1] = 5;
  c[2] = 5;
  c[3] = -5;
  d[0] = -5;
  d[1] = -5;
  d[2] =-5;
  d[3] = -5;
  e[0] = 29;
  e[1] = 29;
  e[2] = 0;
  e[3] = 0;
  gmvwrite_polygons_data(n_verts,matno,c,d,e);

  matno = 2;
  c[0] = 5;
  c[1] = 5;
  c[2] = 5;
  c[3] = 5;
  d[0] = -5;
  d[1] = 5;
  d[2] = 5;
  d[3] = -5;
  e[0] = 29;
  e[1] = 29;
  e[2] = 0;
  e[3] = 0;
  gmvwrite_polygons_data(n_verts,matno,c,d,e);

  matno = 2;
  c[0] = -5;
  c[1] = -5;
  c[2] = -5;
  c[3] = -5;
  d[0] = 5;
  d[1] = -5;
  d[2] = -5;
  d[3] = 5;
  e[0] = 29;
  e[1] = 29;
  e[2] = 0;
  e[3] = 0;
  gmvwrite_polygons_data(n_verts,matno,c,d,e);

  gmvwrite_polygons_endpoly();
 }  

/*generates tracer data and writes it out to a gmv file using funcions*/
/*from the gmvwrite library*/
generate_tracers() 
 {
  int n_tracers = 30;
  float c[30];
  float d[30];
  float e[30];
  char trname[8] = "middle  ";
  float dat[30];
  for(j = 0;j<30;j++)
   {
    c[j] = 0;  
    d[j] = 0;
    e[j] = j;
    dat[j] = j;
   }
  gmvwrite_tracers_header(n_tracers, c, d, e);
  gmvwrite_tracers_name_data(n_tracers, trname, dat);
  gmvwrite_tracers_endtrace();
 }

/*opens the file and writes the gmv header using functions*/
/*from the gmvwrite library*/
gmvwrite_openall()
 {
  char file[80] = "testfile";  
  gmvwrite_openfile(file);
 }
 
/*writes the gmv closure and closes the file*/
/*using functions from the gmvwrite library*/
gmvwrite_closeall()
 {
  gmvwrite_closefile();
 }  
