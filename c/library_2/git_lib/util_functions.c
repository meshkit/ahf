#ifndef INCLUDE_ALL_HEADERS_H
#define INCLUDE_ALL_HEADERS_H

#include "all_headers.h"

#endif

#include <stdio.h>
#include <stdlib.h>

int get_nrows(char *file)
{
	int i = 0;

	FILE *infile = fopen(file,"r");

	char line[200];

	while (fgets(line, sizeof line, infile) != NULL)
	{
		i++;
	}

	close(infile);

	return i;
}

emxArray_int32_T* read_emxArray(emxArray_int32_T *emxArry, int rows, int cols, char *infile)
{
	
    int i;

    int a, b, c, d;

    char line[200];


    emxArry = emxCreate_int32_T(rows, cols);

    FILE *in_file = fopen(infile,"r");

    if ( in_file != NULL )
    {

    i = 0;

    while (i < rows)
    {

    fgets(line, sizeof line, in_file);
 
	if (cols == 4)
	{
		sscanf(line, "%d,%d,%d,%d", &a,&b,&c,&d);

		emxArry->data[i + emxArry->size[0] * 0]  = (int) a;
		emxArry->data[i + emxArry->size[0] * 1]  = (int) b;
		emxArry->data[i + emxArry->size[0] * 2]  = (int) c;
  		emxArry->data[i + emxArry->size[0] * 3]  = (int) d;
	}
	else if (cols == 3)
	{
		sscanf(line, "%d,%d,%d", &a,&b,&c);

		emxArry->data[i + emxArry->size[0] * 0]  = (int) a;
		emxArry->data[i + emxArry->size[0] * 1]  = (int) b;
		emxArry->data[i + emxArry->size[0] * 2]  = (int) c;
	}
	else if (cols == 2)
	{
		sscanf(line, "%d,%d", &a,&b);

		emxArry->data[i + emxArry->size[0] * 0]  = (int) a;
		emxArry->data[i + emxArry->size[0] * 1]  = (int) b;
	}
	else
	{
		sscanf(line, "%d", &a);

		emxArry->data[i]  = (int) a;
	}


    i++;

    }

    }

   fclose(in_file);

   return emxArry;
}

void file_print_emxArry(emxArray_int32_T *emxArry, char *out_file)
{
    int rows = (int) emxArry->size[0];
    int cols = (int) emxArry->size[1];

    FILE *outfile = fopen(out_file, "w");

    int i,j;

    for (i=0; i<rows; i++)
    {
		for (j=0; j<cols; j++)
		{
			if (j == cols-1)
                        	fprintf(outfile, "%10d", emxArry->data[i + emxArry->size[0] *j]);
			else
				fprintf(outfile, "%10d,", emxArry->data[i + emxArry->size[0] *j]);
		}

        	fprintf(outfile,"\n");
		
    }

    fclose(outfile);

}


void file_print_emxArry_bool(emxArray_boolean_T *emxArry, char *out_file)
{
    int rows = (int) emxArry->size[0];
    int cols = (int) emxArry->size[1];

    FILE *outfile = fopen(out_file, "w");

    int i,j;

    for (i=0; i<rows; i++)
    {
		for (j=0; j<cols; j++)
		{
			if (j == cols-1)
                        	fprintf(outfile, "%10d", emxArry->data[i + emxArry->size[0] *j]);
			else
				fprintf(outfile, "%10d,", emxArry->data[i + emxArry->size[0] *j]);
		}

        	fprintf(outfile,"\n");
		
    }

    fclose(outfile);

}

int estimate_num_neighbor_tets(emxArray_int32_T *elems, emxArray_int32_T *opphfs, emxArray_int32_T *labels)
{
   int ngbtets = 0;
   int isbrder = 0;
   uint32_T aa;

   int j;

   int i = 0;

    while (i < elems->size[0])
    {
    	if (elems->data[i] ==0) 
		break;

    	for (j=0; j< elems->size[1]; j++)
	{
	 	
        if (opphfs->data[i + opphfs->size[0] * j] == 0)
	{
		ngbtets = ngbtets +1;

		aa = (uint32_T)opphfs->data[i + opphfs->size[0] * j];

		if (labels->data[i] != labels->data[(int32_T)(aa >> 3U) - 1])
			isbrder++;
	}
    	}

        i++;

    }

	return ngbtets;
}
