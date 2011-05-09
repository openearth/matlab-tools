#include <stdio.h>
#include <stdarg.h>
#include "mex.h"

FILE *fid;
int afopen=0;

void CloseFile(void)
{
  fclose(fid);
}

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

  mexAtExit(CloseFile);

  if (nlhs==0) {
    if (nrhs!=1)
      mexErrMsgTxt("One input argument expected.");

    /* Argument must be a filename. */
    if ( mxIsChar(prhs[0]) != 1)
      mexErrMsgTxt("Argument must be a filename.");

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
  
    if (afopen) {
      fclose(fid);
      afopen=0;
    }

    /* Open the file ... */
    if (!(fid=fopen(filename,"r")))
      mexErrMsgTxt("Cannot open the file.");

    afopen=1;

    return;
  }

  /* Check for proper number of arguments. */
  if (nrhs<1)
    mexErrMsgTxt("At least one input argument expected.");
  else if ((nlhs!=1) & (nlhs!=2))
    mexErrMsgTxt("One or two output arguments expected.");

  for (i=0; i<nrhs; i++)
    if ( mxIsChar(prhs[i]) != 1)
      mexErrMsgTxt("Arguments must be strings.");

  Str = mxCalloc(nrhs,sizeof(char*));
  for (i=0; i<nrhs; i++) {
    buflen=1;
    ndims=mxGetNumberOfDimensions(prhs[i]);
    dimarray=mxGetDimensions(prhs[i]);
    for (d=0; d<ndims; d++)
      buflen=buflen*dimarray[d];
    buflen++; /* add one for \0 character */
    Str[i] = mxCalloc(buflen,sizeof(char));
    if (mxGetString(prhs[i],Str[i], buflen) != 0)
      mexWarnMsgTxt("Not enough space. String is truncated.");
  }

  /* Create output matrix. */
  plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
  ntim = mxGetPr(plhs[0]);

  while (!feof(fid) & (ntim[0]<0.5)) {
    if (readline(fid,oneline,sizeof(oneline)) != 0)
      mexWarnMsgTxt("Line too long. Line is truncated.");
    for (i=0; i<nrhs; i++)
      if (strstr(oneline,Str[i])) {
        ntim[0]=(double)(i+1);
        if (nlhs==2) plhs[1]=mxCreateString(oneline);
      }
  }
  if (ntim[0]<0.5) {
    ntim[0]=-1.0;
    if (nlhs==2) plhs[1]=mxCreateString("");
  }
}
