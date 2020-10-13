#include "fintrf.h"
C
#if 0
C     generate with :  mex mx_subgrid_uv.f
C     
C     crvec.f
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

c     [u_zmin,u_zmax,u_dhdz,u_hrep,v_zmin,v_zmax,v_dhdz,v_hrep]=mx_subgrid_zuv(subgrd.z_zmin,subgrd.z_zmax,subgrd.z_hrep,iopt);

      integer*8 plhs(*), prhs(*)
 
      integer*8 nlhs, nrhs, ii

      integer*8 mxCreateDoubleMatrix, mxGetPr
      integer*8 mxGetM, mxGetN
 
      integer*8 :: nmax
      integer*8 :: mmax
      integer*8 :: nbin
      integer*8 :: iopt
      
c     Pointers input      
      integer*8 :: z_zmin_pr
      integer*8 :: z_zmax_pr
      integer*8 :: z_dhdz_pr
      integer*8 :: z_hrep_pr
      integer*8 :: ioptr_pr  
      
c     Pointers output      
      integer*8 :: u_zmin_pr
      integer*8 :: u_zmax_pr
      integer*8 :: u_dhdz_pr
      integer*8 :: u_hrep_pr
      integer*8 :: v_zmin_pr
      integer*8 :: v_zmax_pr
      integer*8 :: v_dhdz_pr
      integer*8 :: v_hrep_pr
      
c     Arrays input
      double precision, dimension(:,:  ), allocatable :: z_zmin
      double precision, dimension(:,:  ), allocatable :: z_zmax
      double precision, dimension(:,:  ), allocatable :: z_dhdz
      double precision, dimension(:,:,:), allocatable :: z_hrep

c     Arrays output
      double precision, dimension(:,:  ), allocatable :: u_zmin
      double precision, dimension(:,:  ), allocatable :: u_zmax
      double precision, dimension(:,:  ), allocatable :: u_dhdz
      double precision, dimension(:,:,:), allocatable :: u_hrep
      double precision, dimension(:,:  ), allocatable :: v_zmin
      double precision, dimension(:,:  ), allocatable :: v_zmax
      double precision, dimension(:,:  ), allocatable :: v_dhdz
      double precision, dimension(:,:,:), allocatable :: v_hrep

      double precision                                :: ioptr

      integer*8                        :: dims_pr
      integer*8                        :: nbin_pr
      integer*8, dimension(2)          :: dims2in
      integer*8, dimension(3)          :: dims3in
      integer*8, dimension(2)          :: dims2out
      integer*8, dimension(3)          :: dims3out
      integer*4                        :: classid
     
c      open(800,file='out01.txt')

c     Dimensions

      dims_pr = mxGetDimensions(prhs(4))
      call mxCopyPtrToReal8(dims_pr,dims3in,3)
     
      nmax = dims3in(1) - 1
      mmax = dims3in(2) - 1
      nbin = dims3in(3)
      
      dims2in(1) = nmax + 1
      dims2in(2) = mmax + 1

      dims2out(1) = nmax
      dims2out(2) = mmax

      dims3out(1) = nmax
      dims3out(2) = mmax
      dims3out(3) = nbin
      
c     Numbers of bins 
      iopt_pr    = mxGetPr(prhs(5))
      call mxCopyPtrToReal8(iopt_pr,ioptr,1)
      iopt = int(ioptr)
      
c     Allocate output
      allocate(u_zmin(1:nmax,1:mmax       ))
      allocate(u_zmax(1:nmax,1:mmax       ))
      allocate(u_dhdz(1:nmax,1:mmax       ))
      allocate(u_hrep(1:nmax,1:mmax,1:nbin))
      allocate(v_zmin(1:nmax,1:mmax       ))
      allocate(v_zmax(1:nmax,1:mmax       ))
      allocate(v_dhdz(1:nmax,1:mmax       ))
      allocate(v_hrep(1:nmax,1:mmax,1:nbin))

c     Allocate input
      allocate(z_zmin(1:nmax+1,1:mmax+1       ))
      allocate(z_zmax(1:nmax+1,1:mmax+1       ))
      allocate(z_dhdz(1:nmax+1,1:mmax+1       ))
      allocate(z_hrep(1:nmax+1,1:mmax+1,1:nbin))

C     Create matrix for the return argument.
      classid=mxClassIDFromClassName('double')
      plhs(1) = mxCreateNumericArray(2, dims2out, classid, 0)
      plhs(2) = mxCreateNumericArray(2, dims2out, classid, 0)
      plhs(3) = mxCreateNumericArray(2, dims2out, classid, 0)
      plhs(4) = mxCreateNumericArray(3, dims3out, classid, 0)
      plhs(5) = mxCreateNumericArray(2, dims2out, classid, 0)
      plhs(6) = mxCreateNumericArray(2, dims2out, classid, 0)
      plhs(7) = mxCreateNumericArray(2, dims2out, classid, 0)
      plhs(8) = mxCreateNumericArray(3, dims3out, classid, 0)

      u_zmin_pr = mxGetPr(plhs(1))
      u_zmax_pr = mxGetPr(plhs(2))
      u_dhdz_pr = mxGetPr(plhs(3))
      u_hrep_pr = mxGetPr(plhs(4))
      v_zmin_pr = mxGetPr(plhs(5))
      v_zmax_pr = mxGetPr(plhs(6))
      v_dhdz_pr = mxGetPr(plhs(7))
      v_hrep_pr = mxGetPr(plhs(8))

      z_zmin_pr       = mxGetPr(prhs(1))
      z_zmax_pr       = mxGetPr(prhs(2))
      z_dhdz_pr       = mxGetPr(prhs(3))
      z_hrep_pr       = mxGetPr(prhs(4))

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(z_zmin_pr,z_zmin,(nmax+1)*(mmax+1))
      call mxCopyPtrToReal8(z_zmax_pr,z_zmax,(nmax+1)*(mmax+1))
      call mxCopyPtrToReal8(z_dhdz_pr,z_dhdz,(nmax+1)*(mmax+1))
      call mxCopyPtrToReal8(z_hrep_pr,z_hrep,(nmax+1)*(mmax+1)*nbin)

C     Call the computational subroutine

      call subgrid_uv(nmax,mmax,nbin,z_zmin,z_zmax,z_dhdz,z_hrep,
     &                               u_zmin,u_zmax,u_dhdz,u_hrep, 
     &                               v_zmin,v_zmax,v_dhdz,v_hrep,
     &                iopt) 
           
c     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(u_zmin,u_zmin_pr,nmax*mmax)
      call mxCopyReal8ToPtr(u_zmax,u_zmax_pr,nmax*mmax)
      call mxCopyReal8ToPtr(u_dhdz,u_dhdz_pr,nmax*mmax)
      call mxCopyReal8ToPtr(u_hrep,u_hrep_pr,nmax*mmax*nbin)
      call mxCopyReal8ToPtr(v_zmin,v_zmin_pr,nmax*mmax)
      call mxCopyReal8ToPtr(v_zmax,v_zmax_pr,nmax*mmax)
      call mxCopyReal8ToPtr(v_dhdz,v_dhdz_pr,nmax*mmax)
      call mxCopyReal8ToPtr(v_hrep,v_hrep_pr,nmax*mmax*nbin)

      deallocate(z_zmin)
      deallocate(z_zmax)
      deallocate(z_hrep)
      deallocate(z_dhdz)
      deallocate(u_zmin)
      deallocate(u_zmax)
      deallocate(u_dhdz)
      deallocate(u_hrep)
      deallocate(v_zmin)
      deallocate(v_zmax)
      deallocate(v_dhdz)
      deallocate(v_hrep)

      close(800)
      
      return
      end

      subroutine subgrid_uv(nmax,mmax,nbin,z_zmin,z_zmax,z_dhdz,z_hrep,
     &                                     u_zmin,u_zmax,u_dhdz,u_hrep, 
     &                                     v_zmin,v_zmax,v_dhdz,v_hrep,
     &                      iopt) 

      integer nmax
      integer mmax
      integer nbin
      double precision z_zmin(nmax + 1, mmax + 1)
      double precision z_zmax(nmax + 1, mmax + 1)
      double precision z_dhdz(nmax + 1, mmax + 1)
      double precision z_hrep(nmax + 1, mmax +1, nbin)
      double precision u_zmin(nmax, mmax)
      double precision u_zmax(nmax, mmax)
      double precision u_dhdz(nmax, mmax)
      double precision u_hrep(nmax, mmax, nbin)
      double precision v_zmin(nmax, mmax)
      double precision v_zmax(nmax, mmax)
      double precision v_dhdz(nmax, mmax)
      double precision v_hrep(nmax, mmax, nbin)
      double precision zu(nbin)
      double precision z_left(nbin + 2)
      double precision h_left(nbin + 2)
      double precision z_right(nbin + 2)
      double precision h_right(nbin + 2)

      double precision zadd
      double precision hadd
      double precision zmaxmin
      double precision f
      double precision h1
      double precision h2
      integer iopt

      integer n
      integer m
      integer ibin

c      open(801,file='out05.txt')

      do n = 1, nmax
         do m = 1, mmax
        
c           U points

            u_zmin(n, m) = max(z_zmin(n, m), z_zmin(n, m + 1))
            u_zmax(n, m) = max(z_zmax(n, m), z_zmax(n, m + 1))
            u_dhdz(n, m) = 0.5*(z_dhdz(n,m) + z_dhdz(n,m + 1))

            zadd = u_zmax(n, m) + 10.0
                    
            do ibin = 1, nbin
               zu(ibin) = u_zmin(n, m) + ibin*(u_zmax(n, m) - 
     &                    u_zmin(n, m))/nbin
            enddo
        
c           Left
            hadd = zadd - z_zmax(n, m)
            zmaxmin = max(z_zmax(n, m) - z_zmin(n, m), 1.0e-4)
            do ibin = 1, nbin + 1
               z_left(ibin) = z_zmin(n, m) + (ibin-1)*zmaxmin/nbin
            enddo
            h_left(1) = 0.0
            do ibin = 1, nbin
               h_left(ibin + 1) = z_hrep(n, m, ibin)
            enddo            
c           Add extra point
            z_left(nbin + 2) = zadd
            h_left(nbin + 2) = h_left(nbin + 1) + hadd*z_dhdz(n, m)
            
c           Right
            hadd = zadd - z_zmax(n, m + 1)
            zmaxmin = max(z_zmax(n, m + 1) - z_zmin(n, m + 1), 1.0e-4)
            do ibin = 1, nbin + 1
               z_right(ibin) = z_zmin(n, m + 1) + (ibin-1)*zmaxmin/nbin
            enddo
            h_right(1) = 0.0
            do ibin = 1, nbin
               h_right(ibin + 1) = z_hrep(n, m + 1, ibin)
            enddo            
c           Add extra point
            z_right(nbin + 2) = zadd
            h_right(nbin + 2) = h_right(nbin+1) + hadd*z_dhdz(n,m+1)


            do ibin = 1, nbin
               
               call interp1(z_left,  h_left,  zu(ibin), h1, nbin + 2)
               call interp1(z_right, h_right, zu(ibin), h2, nbin + 2)
               
               f = 0.5*(ibin*1.0/nbin)
               
               if (z_left(1)>z_right(1)) then
                  f = 1.0 - f
               endif
               
               u_hrep(n, m, ibin) = f*h1 + (1.0 - f)*h2

            enddo   


c           V points

            v_zmin(n, m) = max(z_zmin(n, m), z_zmin(n + 1, m))
            v_zmax(n, m) = max(z_zmax(n, m), z_zmax(n + 1, m))
            v_dhdz(n, m) = 0.5*(z_dhdz(n,m) + z_dhdz(n + 1, m))            

            zadd = v_zmax(n, m) + 10.0
        
            do ibin = 1, nbin
               zu(ibin) = v_zmin(n, m) + ibin*(v_zmax(n, m) - 
     &                    v_zmin(n, m))/nbin
            enddo
        
c           Left
            hadd = zadd - z_zmax(n, m)
            zmaxmin = max(z_zmax(n, m) - z_zmin(n, m), 1.0e-4)
            do ibin = 1, nbin + 1
               z_left(ibin) = z_zmin(n, m) + (ibin-1)*zmaxmin/nbin
            enddo
            h_left(1) = 0.0
            do ibin = 1, nbin
               h_left(ibin + 1) = z_hrep(n, m, ibin)
            enddo            
c           Add extra point
            z_left(nbin + 2) = zadd
            h_left(nbin + 2) = h_left(nbin + 1) + hadd*z_dhdz(n, m)
            
c           Right
            hadd = zadd - z_zmax(n + 1, m)
            zmaxmin = max(z_zmax(n + 1, m) - z_zmin(n + 1, m), 1.0e-4)
            do ibin = 1, nbin + 1
               z_right(ibin) = z_zmin(n + 1, m) + (ibin-1)*zmaxmin/nbin
            enddo
            h_right(1) = 0.0
            do ibin = 1, nbin
               h_right(ibin + 1) = z_hrep(n + 1, m, ibin)
            enddo            
c           Add extra point
            z_right(nbin + 2) = zadd
            h_right(nbin + 2) = h_right(nbin + 1) + 
     &                          hadd*z_dhdz(n + 1, m)

            do ibin = 1, nbin
               
               call interp1(z_left,  h_left,  zu(ibin), h1, nbin + 2)
               call interp1(z_right, h_right, zu(ibin), h2, nbin + 2)

               f = 0.5*(ibin*1.0/nbin)
               
               if (z_left(1)>z_right(1)) then
                  f = 1.0 - f
               endif
               
               v_hrep(n, m, ibin) = f*h1 + (1.0 - f)*h2

            enddo   

         enddo
      enddo
      
c      close(801)

      return

      end


      Subroutine interp1(x1,y1,x2,y2,n)

      integer*8         j,n
      double precision  x1(n),y1(n)
      double precision  x2,y2,eps

      eps = 1.0e-6
      
      do j = 1, n - 1
         if (x1(j + 1) + eps >= x2) then
            y2 = y1(j) + (y1(j + 1) - y1(j))*(x2 - x1(j))/ 
     &           (x1(j + 1) - x1(j))
            exit
         endif
      enddo

      end

      Subroutine SORT (n,ra,wksp,iwksp)
c
      Integer*8         j,n,iwksp(n)
      double precision          ra(n),wksp(n)
c
      Call INDEXX (n,ra,iwksp)
      Do 120 j=1,n
             wksp(j) = ra(iwksp(j))
  120 Continue
      End
      

      Subroutine INDEXX (n,arrin,indx)
c
      Integer*8         i,indxt,ir,l,n,j,indx(n)
      double precision q,arrin(n)
c
      Do 11 j=1,n
            indx(j)=j
   11 Continue
      l  = n/2+1
      ir = n
   10 Continue
        If (l.GT.1) Then
           l       = l-1
           indxt   = indx(l)
           q       = arrin(indxt)
        Else
           indxt   = indx(ir)
           q       = arrin(indxt)
           indx(ir)= indx(1)
           ir      = ir-1
           If (ir.EQ.1) Then
              indx(1) = indxt
              Return
           Endif
        Endif
        i = l
        j = l+l
   20   Continue
        If (j.LE.ir) Then
           If (j.LT.ir) Then
              If (arrin(indx(j)).LT.arrin(indx(j+1))) j = j+1
           Endif
           If (q.LT.arrin(indx(j))) Then
              indx(i) = indx(j)
              i       = j
              j       = j+j
           Else
              j       = ir+1
           Endif
           Goto 20
        Endif
        indx(i) = indxt
      Goto 10
      End
