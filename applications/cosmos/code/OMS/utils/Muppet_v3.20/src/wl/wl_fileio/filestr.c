#include <stdio.h>
#include <stdarg.h>
#include "mex.h"

int readline(FILE *fid, char *Line, int Len) {
  char Char[2];
  int i, TooLong;
  TooLong=0;
  fscanf(fid,"%c",Char);
  i=0;
  while ((Char[0]!='\n') & (i<(Len-1))) {
    if (i<(Len-1)) {
      Line[i]=Char[0];
      i=i+1;
    }
    else {
      TooLong=1;
    }
    fscanf(fid,"%c",Char);
  }
  Line[i]='\0';
  return TooLong;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  char *filename;
  char oneline[256];
  char **Str;
  int i, buflen;
  int ndims, d;
  const int *dimarray;
  double *ntim;
  int k, n;
  FILE *fid;

/*  printf("%i input argument(s) and %i output argument(s).\n",nrhs,nlhs);
  for (i=0; i<nrhs; i++) {
    printf("arg%2.2i: ",i);
    ndims=mxGetNumberOfDimensions(prhs[i]);
    dimarray=mxGetDimensions(prhs[i]);
    printf("%i",dimarray[0]);
    for (d=1; d<ndims; d++) {
      printf("x%i",dimarray[d]);
    }
    printf(" %s\n",mxGetClassName(prhs[i]));
  } */

  /* Check for proper number of arguments. */
  if (nrhs<2)
    mexErrMsgTxt("At least two input arguments expected.");
  else if (nlhs!=1)
    mexErrMsgTxt("One output argument expected.");

  /* First argument must be a filename. */
  if ( mxIsChar(prhs[0]) != 1)
    mexErrMsgTxt("First argument must be a filename.");
  for (i=1; i<nrhs; i++) {
    if ( mxIsChar(prhs[i]) != 1)
      mexErrMsgTxt("Arguments must be strings.");
  }

  /* Get the length of the input string. */
  buflen=1;
  ndims=mxGetNumberOfDimensions(prhs[0]);
  dimarray=mxGetDimensions(prhs[0]);
  for (d=0; d<ndims; d++) {
    buflen=buflen*dimarray[d];
  }
  buflen++; /* add one for \0 character */
  filename = mxCalloc(buflen,sizeof(char));
  
  if (mxGetString(prhs[0],filename, buflen) != 0)
    mexWarnMsgTxt("Not enough space. String is truncated.");

  /* Open the file ... */
  if (!(fid=fopen(filename,"r"))) {
    mexErrMsgTxt("Cannot open the file.");
  }

  Str = mxCalloc(nrhs,sizeof(char*));
  for (i=1; i<nrhs; i++) {
    buflen=1;
    ndims=mxGetNumberOfDimensions(prhs[i]);
    dimarray=mxGetDimensions(prhs[i]);
    for (d=0; d<ndims; d++) {
      buflen=buflen*dimarray[d];
    }
    buflen++; /* add one for \0 character */
    Str[i-1] = mxCalloc(buflen,sizeof(char));
    if (mxGetString(prhs[i],Str[i-1], buflen) != 0)
      mexWarnMsgTxt("Not enough space. String is truncated.");
  }

  /* Create output matrix. */
  plhs[0]=mxCreateDoubleMatrix(1,nrhs-1,mxREAL);
  ntim = mxGetPr(plhs[0]);

  while (!feof(fid)) {
    if (readline(fid,oneline,sizeof(oneline)) != 0)
      mexWarnMsgTxt("Line too long. Line is truncated.");
    for (i=0; i<(nrhs-1); i++) {
      n= strstr(oneline,Str[i]);
      if (n) {
        ntim[i]++;
      }
    }
  }

/*  for (i=0; i<(nrhs-1); i++) {
    printf("String %i (%s) occurs in %i lines.\n",i+1,Str[i],(int) (ntim[i]));
  } */

  /* Close the file. */
  fclose(fid);

}
