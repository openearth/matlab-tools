#include "fintrf.h"
C
#if 0
C     generate with :  mex mkcurvec.f curvec.f
C     
C     curvec.f
C     .F file needs to be preprocessed to generate .for equivalent
C     
#endif
C     
C     curvec.f
C
C     multiple the first input by the second input
      
C     This is a MEX file for MATLAB.
C     Copyright 1984-2004 The MathWorks, Inc. 
C     $Revision: 1.12.2.1 $
      
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C

C      mwpointer plhs(*), prhs(*)
C      mwpointer mxCreateDoubleMatrix
C      mwpointer mxGetPr
C      mwpointer x2_pr,y2_pr,x1_pr,y1_pr,u_pr,v_pr
C      mwpointer dt_pr,nt_pr,hdtck_pr,arthck_pr,xp_pr,yp_pr

C-----------------------------------------------------------------------
C
      integer plhs(*), prhs(*)
 
      integer nlhs, nrhs

      integer mxCreateDoubleMatrix, mxGetPr
      integer mxGetM, mxGetN
 
      integer m1, n1, n2, nt, size, nmax, np2, np3, nhead, nt0

      integer x2_pr,y2_pr,x1_pr,y1_pr,u_pr,v_pr
      integer dt_pr,nt_pr,hdthck_pr,arthck_pr,xp_pr,yp_pr
      integer xax_pr,yax_pr
      integer relwdt_pr

      real*8 x1(1000000)
      real*8 y1(1000000)
      real*8 u(1000000)
      real*8 v(1000000)
      real*8 relwdt(100000)
      real*8 x2(100000)
      real*8 y2(100000)
      real*8 xp(1000000)
      real*8 yp(1000000)
      real*8 xax(1000000)
      real*8 yax(1000000)
      real*8 dt,hdthck,arthck

      n2 = mxGetM(prhs(1))

      nt0=20
      nhead=5      

      m1 = mxGetM(prhs(3))
      n1 = mxGetN(prhs(3))
      size = m1*n1

      np2 = n2*((nt0-nhead)*2+5)
      np3 = n2*(nt0+1)

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(np2,1,0)
      plhs(2) = mxCreateDoubleMatrix(np2,1,0)
      plhs(3) = mxCreateDoubleMatrix(np3,1,0)
      plhs(4) = mxCreateDoubleMatrix(np3,1,0)

      x2_pr = mxGetPr(prhs(1))
      y2_pr = mxGetPr(prhs(2))
      x1_pr = mxGetPr(prhs(3))
      y1_pr = mxGetPr(prhs(4))
      u_pr  = mxGetPr(prhs(5))
      v_pr  = mxGetPr(prhs(6))
      dt_pr = mxGetPr(prhs(7))
      nt_pr = mxGetPr(prhs(8))
      hdthck_pr = mxGetPr(prhs(9))
      arthck_pr = mxGetPr(prhs(10))
      relwdt_pr = mxGetPr(prhs(11))

      xp_pr = mxGetPr(plhs(1))
      yp_pr = mxGetPr(plhs(2))
      xax_pr = mxGetPr(plhs(3))
      yax_pr = mxGetPr(plhs(4))

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(x2_pr,x2,n2)
      call mxCopyPtrToReal8(y2_pr,y2,n2)
      call mxCopyPtrToReal8(x1_pr,x1,size)
      call mxCopyPtrToReal8(y1_pr,y1,size)
      call mxCopyPtrToReal8(u_pr,u,size)
      call mxCopyPtrToReal8(v_pr,v,size)
      call mxCopyPtrToReal8(dt_pr,dt,1)
      call mxCopyPtrToReal8(nt_pr,nt,1)
      call mxCopyPtrToReal8(hdthck_pr,hdthck,1)
      call mxCopyPtrToReal8(arthck_pr,arthck,1)
      call mxCopyPtrToReal8(relwdt_pr,relwdt,n2)

      nt=20

C     Call the computational subroutine
       call mkcurvec(x2,y2,n2,relwdt,x1,y1,u,v,m1,n1,
     &              dt,nt,nhead,hdthck,arthck,xp,yp,
     &              xax,yax)

C     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(xp,xp_pr,np2)
      call mxCopyReal8ToPtr(yp,yp_pr,np2)
      call mxCopyReal8ToPtr(yax,yax_pr,np3)
      call mxCopyReal8ToPtr(xax,xax_pr,np3)

      return
      end


