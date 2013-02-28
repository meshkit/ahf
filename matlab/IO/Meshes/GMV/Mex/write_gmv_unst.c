/*
function write_gmv_unst( fname_plt, xs, elems, type, var_nodes, varlist_nodes, var_faces, varlist_faces)
Example use:
write_gmv_unst( 'fname.plt', xs, elems, 'triangle', var_nodes, 'var1, var2', var_faces, 'var3')

History: Initialized by Ying Chen, Nov. 20, 2008
         Modified by X. Jiao, Nov. 20, 2008
*/

/*mexfunction header file*/
#include "mex.h"

/* Include gmvwrite.c and change malloc and free calls */
#define malloc  mxMalloc
#define free    mxFree

#include "gmvwrite.c"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *Data;

    /*file name*/
    char *file_name;
    int name_len;

    /*x,y,z coordinates*/
    double *ps;
    int ps_num;
    double *x, *y, *z;

    /*element type*/
    char *elems_type = NULL;
    int type_length;

    /*for elems connectivity*/
    int node_num_per_elem;
    int elems_num;
    int *elems = NULL;
    double *elems_tmp = NULL;

    /*for variables data*/
    int var_node_name_len;
    char *var_node_name = NULL;
    double *var_node = NULL;
    int var_cell_name_len;
    char *var_cell_name = NULL;
    double *var_cell = NULL;

    int i,j;

    if (nrhs!=3 && nrhs!=4 && nrhs!=6 && nrhs!=8)
        mexErrMsgTxt("Incorrect number of arguments\n");

    /*get file name from prhs[0]*/
    Data = prhs[0];
    name_len = mxGetN(Data);
    file_name = mxCalloc(name_len+1, sizeof(char));
    mxGetString( Data, file_name, name_len+1);

    /*get points coordinates from prhs[1]*/
    Data = prhs[1];
    ps = mxGetPr(Data);
    ps_num = mxGetM(Data); /*by default, ps is a (ps_num * 3) matrix */
    x = mxCalloc(ps_num+1 , sizeof(double));
    y = mxCalloc(ps_num+1 , sizeof(double));
    z = mxCalloc(ps_num+1 , sizeof(double));
    for ( i=0; i<ps_num; i++)
    {
        x[i] = ps[i];
        y[i] = ps[i+ps_num];
        z[i] = ps[i+2*ps_num];
    }


    /*get elems from prhs[2]*/
    Data = prhs[2];
    elems_tmp = mxGetPr(Data);
    elems_num = mxGetM(Data);
    node_num_per_elem = mxGetN(Data);

    elems = mxCalloc(node_num_per_elem*elems_num, sizeof(int));

    for (j=0; j<node_num_per_elem; j++)
        for(i=0; i<elems_num; i++)
    {
        elems[i*node_num_per_elem + j]  = (int)elems_tmp[j*elems_num + i];
    }

    /*get elems_type from prhs[3]*/
    Data = prhs[3];
    type_length = mxGetN(Data);

    if (type_length) {
        elems_type = mxCalloc(type_length+1, sizeof(char));
        mxGetString(Data, elems_type, type_length+1);

        if (elems_type[0] != 'T' && elems_type[0] != 't' )
            mexErrMsgTxt("ERROR: Unsupported mesh type");
        mxFree(elems_type);
    }

    /*get node or cell variables*/
    if (nrhs==5 || nrhs==7)
        mexErrMsgTxt("Incorrect number of argument");

    if (nrhs >= 6)
    {
        /*get variables' names*/
        Data = prhs[5];
        var_node_name_len = mxGetN(Data);

        if (var_node_name_len && mxGetM(prhs[4])) {
            if (mxGetM(prhs[4])!=ps_num)
                mexErrMsgTxt("Incorrect dimension of nodal array");

            var_node_name = mxCalloc(var_node_name_len+1, sizeof(char));
            mxGetString( Data, var_node_name, var_node_name_len+1);

            /*get node data*/
            var_node = mxGetPr(prhs[4]);
        }
    }

    if(nrhs >= 8)
    {
        /*get variables' names*/
        Data = prhs[7];
        var_cell_name_len = mxGetN(Data);

        if (var_cell_name_len && mxGetM(prhs[6])) {
            if (mxGetM(prhs[6])!=elems_num)
                mexErrMsgTxt("Incorrect dimension for cell-centered array");

            var_cell_name = mxCalloc(var_cell_name_len+1, sizeof(char));
            mxGetString( Data, var_cell_name, var_cell_name_len+1);

            /*get cell data*/
            var_cell = mxGetPr(prhs[6]);
        }
    }

    /* open gmv file for write */
    if (file_name[name_len-1] == 'b')
        gmvwrite_openfile_ir(file_name,4,8);
    else
        gmvwrite_openfile_ir_ascii(file_name,4,8);

    /* WRITE X, Y, Z GRID POINTS TO FILE */
    gmvwrite_node_data(&ps_num, x, y, z);


    /*begin to write cell connectivity to file*/
    gmvwrite_cell_header(&elems_num); /*data and call the functions that write out  */


    /******need further notice!!!***************************************************************/
    for (i=0; i<elems_num; i++)
    {
        gmvwrite_cell_type("tri", node_num_per_elem, elems+(i*node_num_per_elem));
    }

    /*begin to write varialbes data*/
    gmvwrite_variable_header();

    if (var_cell)
    {
        gmvwrite_variable_name_data(0, var_cell_name, var_cell);
    }

    if (var_node)
    {
        gmvwrite_variable_name_data(1, var_node_name, var_node);
    }

    gmvwrite_variable_endvars();
    gmvwrite_closefile();

    /* close GMV file */
    mxFree(x);
    mxFree(y);
    mxFree(z);
    mxFree(elems);

    return;
}
