#include "dio_shm.h"
#include "mex.h"
#include "string.h"

/********************************************************************
 *      Check and get string
 ********************************************************************/
char * chkGetString(const mxArray * mxA, const char * StrName)
{
  const int *dimarray;
  int StrLen = -1;
  int ndims = mxGetNumberOfDimensions(mxA);
  if (mxIsChar(mxA) & (ndims == 2)) {
    dimarray = mxGetDimensions(mxA);
    if (dimarray[0]==1)
      StrLen = dimarray[1];
  }

  if (StrLen < 0) {
    char * temp = (char*)mxCalloc(128,sizeof(char));
    strcat(temp,"Invalid ");
    strcat(temp,StrName);
    strcat(temp,".");
    mexErrMsgTxt(temp);
  }
  char * Name = mxArrayToString(mxA);
  if (Name == NULL) {
    mexErrMsgTxt("Memory allocation error.");
  }

  return Name;
}

/********************************************************************
 *      Process string to be returned
 ********************************************************************/
mxArray * ReturnString(const char * StrName)
{
  int numItems = strlen(StrName);
  void * Data;
  Data = mxCalloc(numItems,2*sizeof(char));
  char * Name = (char *)Data;
  for (int i=0; i<numItems; i++)
    Name[2*i] = StrName[i];

  int * dims = (int *)mxCalloc(2,2);
  dims[0] = 1; dims[1] = numItems;
  mxArray * Export = mxCreateNumericArray(2,dims,mxCHAR_CLASS,mxREAL);
  mxSetData(Export,Data);

  return Export;
}

/********************************************************************
 *      Check and get positive integer
 ********************************************************************/
int chkGetPosInt(const mxArray * mxA)
{
  const int *dimarray;
  int Value = -1;
  int ndims = mxGetNumberOfDimensions(mxA);
  if (mxIsDouble(mxA) & !mxIsComplex(mxA) & (ndims == 2)) {
    dimarray = mxGetDimensions(mxA);
    if ((dimarray[0]==1) & (dimarray[1]==1)) {
      double rValue = mxGetScalar(mxA);
      if (rValue >= 0.0)
        Value = (int)rValue;
    }
  }
  return Value;
}

/********************************************************************
 *      Check and get DioShmPart
 ********************************************************************/
DioShmPart GetDioPart(const mxArray * mxA)
{
  const int *dimarray;
  int StrLen = -1;
  int ndims = mxGetNumberOfDimensions(mxA);
  if (mxIsChar(mxA) & (ndims == 2)) {
    dimarray = mxGetDimensions(mxA);
    if (dimarray[0]==1)
      StrLen = dimarray[1];
  }
  if (StrLen < 0)
    mexErrMsgTxt("Invalid DelftIO Shared Memory Part Identifier");

  char * Name = mxArrayToString(mxA);
  if (Name == NULL)
    mexErrMsgTxt("Memory allocation error.");

  if (strcmp(Name,"header")==0) return DioShmHeaderPart;

  if (strcmp(Name,"data")==0)   return DioShmDataPart;

  mexErrMsgTxt("Invalid DelftIO Shared Memory Part Indentification String");
}

/********************************************************************
 *      Get data share pointer
 ********************************************************************/
DioShmDs * GetDs(const mxArray * mxA)
{
  int dsh = chkGetPosInt(mxA);
  if (dsh < 0)
    mexErrMsgTxt("Invalid data share handle.");
  return (DioShmDs *) dsh;
}

/********************************************************************
 *      Main Program
 ********************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  DioShmDs * ds;

  /*
   *    Default diopart = data part of stream
   */
   DioShmPart diopart = DioShmDataPart;
  /*
   *    Obtain DelftIO command
   */
  if (nrhs<1)
    mexErrMsgTxt("Missing DelftIO command.");
  else if ( mxIsChar(prhs[0]) != 1)
    mexErrMsgTxt("Missing DelftIO command.");
  char * cmdStr = chkGetString(prhs[0],"DelftIO command");

  /******************************************************************
   *    Compare command string with implemented commands
   ******************************************************************/
  if (strcmp(cmdStr,"newput")==0) {
   /*****************************************************************
    *   NEWPUT
    *****************************************************************/
    if (nlhs != 1)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if ((nrhs != 3) & (nrhs != 4))
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      int nBytesHdr = 0;
      int nBytesData = 0;
      int idx = 1;
      if (nrhs == 3) {
       /*
        * Header size = 0
        * Data size   = user specified
        */

        nBytesData = chkGetPosInt(prhs[1]);
        if (nBytesData < 0)
          mexErrMsgTxt("Invalid data size.");

        idx = 1;
      } else {
       /*
        * Header size = user specified
        * Data size   = user specified
        */

        nBytesHdr = chkGetPosInt(prhs[1]);
        if (nBytesHdr < 0)
          mexErrMsgTxt("Invalid header size.");

        nBytesData = chkGetPosInt(prhs[2]);
        if (nBytesData < 0)
          mexErrMsgTxt("Invalid data size.");

        idx = 2;
      }

      char * DioName = chkGetString(prhs[idx+1],"DelftIO share name");

      ds = new DioShmDs(nBytesHdr, nBytesData, DioShmSharedMem, DioName);
      int dsh = (int) ds;

      plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[0])=(double)(dsh);
    }
  }
  else if (strcmp(cmdStr,"newget")==0) {
   /*****************************************************************
    *   NEWGET
    *****************************************************************/
    if (nlhs != 1)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if (nrhs != 2)
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      char * DioName = chkGetString(prhs[1],"DelftIO share name");

      ds = new DioShmDs(DioShmSharedMem, DioName);
      int dsh = (int) ds;

      plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[0])=(double)(dsh);
    }
  }
  else if (strcmp(cmdStr,"getname")==0) {
   /*****************************************************************
    *   GETNAME
    *****************************************************************/
    if (nlhs != 1)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if (nrhs != 2)
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      char * DioName = ds->GetName();

      plhs[0] = ReturnString(DioName);

    }
  }
  else if (strcmp(cmdStr,"startwrite")==0) {
   /*****************************************************************
    *   STARTWRITE
    *****************************************************************/
    if (nlhs != 1)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if ((nrhs != 2) & (nrhs != 3))
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      if (nrhs == 3)
        diopart = GetDioPart(prhs[2]);

      int okay = ds->StartWrite(diopart);

      plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[0])=(double)(okay);
    }
  }
  else if (strcmp(cmdStr,"startread")==0) {
   /*****************************************************************
    *   STARTREAD
    *****************************************************************/
    if (nlhs != 1)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if ((nrhs != 2) & (nrhs != 3))
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      if (nrhs == 3)
        diopart = GetDioPart(prhs[2]);

      int okay = ds->StartRead(diopart);

      plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[0])=(double)(okay);
    }
  }
  else if (strcmp(cmdStr,"write")==0) {
   /*****************************************************************
    *   WRITE
    *****************************************************************/
    if (nlhs != 0)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if (nrhs != 3)
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      if ((!mxIsNumeric(prhs[2])) & (!mxIsChar(prhs[2])))
        mexErrMsgTxt("Cannot transfer supplied data.");
      int numItems = 1;
      int ndims=mxGetNumberOfDimensions(prhs[2]);
      const int *dimarray;
      dimarray = mxGetDimensions(prhs[2]);
      int d;
      for (d=1; d<ndims; d++)
        numItems=numItems * dimarray[d];

     /*
      * Write Data
      */
      if (mxIsUint8(prhs[2])) {
        char * Data =(char*) mxGetData(prhs[2]);
        ds->Write(diopart, numItems, Data);
      }
      else if (mxIsInt32(prhs[2])) {
        int * Data =(int*) mxGetData(prhs[2]);
        ds->Write(diopart, numItems, Data);
      }
      else if (mxIsSingle(prhs[2])) {
        float * Data =(float*) mxGetData(prhs[2]);
        ds->Write(diopart, numItems, Data);
      }
      else
        mexErrMsgTxt("Transfer of data other than uint8,int32,single not yet implemented.");
    }
  }
  else if (strcmp(cmdStr,"read")==0) {
   /*****************************************************************
    *   READ
    *****************************************************************/
    if (nlhs != 2)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if (nrhs != 4)
      mexErrMsgTxt("Invalid number of input or output arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      int numItems = chkGetPosInt(prhs[2]);
      if (numItems < 0)
        mexErrMsgTxt("Invalid number of items.");

      char * dFormat = chkGetString(prhs[3],"data format argument");

     /*
      * Read Data
      */
      int okay = 0;
      mxClassID classid = mxUINT8_CLASS;
      void * Data;
      if (strcmp(dFormat,"uint8")==0) {
        Data = mxCalloc(numItems,sizeof(char));
        okay = ds->Read(diopart, numItems, (char *)Data);
        classid=mxUINT8_CLASS;
      }
      else if ((strcmp(dFormat,"int")==0) | (strcmp(dFormat,"int32")==0)) {
        Data = mxCalloc(numItems,sizeof(int));
        okay = ds->Read(diopart, numItems, (int *)Data);
        classid=mxINT32_CLASS;
      }
      else if ((strcmp(dFormat,"single")==0) | (strcmp(dFormat,"float32")==0)) {
        Data = mxCalloc(numItems,sizeof(float));
        okay = ds->Read(diopart, numItems, (float *)Data);
        classid=mxSINGLE_CLASS;
      }
      else
        mexErrMsgTxt("Transfer of data other than uint8,int32,single not yet implemented.");

     /*
      * Return Data
      */
      int * dims = (int *)mxCalloc(2,sizeof(int));
      dims[0] = 1; dims[1] = numItems;
      plhs[0] = mxCreateNumericArray(2,dims,classid,mxREAL);
      mxSetData(plhs[0],Data);

     /*
      * Return flag of correct reading
      */
      plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[1])=(double)(okay);
    }
  }
  else if (strcmp(cmdStr,"endwrite")==0) {
   /*****************************************************************
    *   ENDWRITE
    *****************************************************************/
    if (nlhs != 0)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if ((nrhs != 2) & (nrhs != 3))
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      if (nrhs == 3)
        diopart = GetDioPart(prhs[2]);

      ds->EndWrite(diopart);
    }
  }
  else if (strcmp(cmdStr,"endread")==0) {
   /*****************************************************************
    *   ENDREAD
    *****************************************************************/
    if (nlhs != 0)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if ((nrhs != 2) & (nrhs != 3))
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);

      if (nrhs == 3)
        diopart = GetDioPart(prhs[2]);

      ds->EndRead(diopart);
    }
  }
  else if (strcmp(cmdStr,"delete")==0) {
   /*****************************************************************
    *   DELETE
    *****************************************************************/
    if (nlhs != 0)
      mexErrMsgTxt("Invalid number of output arguments.");
    else if (nrhs != 2)
      mexErrMsgTxt("Invalid number of input arguments.");
    else {
      DioShmDs * ds = GetDs(prhs[1]);
      delete ds;
    }
  }
  else {
   /*****************************************************************
    *   Unrecognized command.
    *****************************************************************/
    mexErrMsgTxt("Unrecognized DelftIO command.");
  }
}
