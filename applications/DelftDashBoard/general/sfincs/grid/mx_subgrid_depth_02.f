#include "fintrf.h"
C
#if 0
C     generate with :  mex mx_subgrid_depth.f
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
      integer*8 plhs(*), prhs(*)
 
      integer*8 nlhs, nrhs, ii

      integer*8 mxCreateDoubleMatrix, mxGetPr
      integer*8 mxGetM, mxGetN
 
      integer*8 nmax, mmax, np, nbin

      integer*8 d_pr,zmin_pr,zmax_pr,hrep_pr,manning_avg_pr,dhdz_pr

      double precision, dimension(:,:,:), allocatable :: d
      double precision, dimension(:,:,:), allocatable :: manning
      double precision                                :: dx
      double precision                                :: nbinr

      double precision, dimension(:,:),     allocatable :: zmin
      double precision, dimension(:,:),     allocatable :: zmax
      double precision, dimension(:,:,:),   allocatable :: hrep
      double precision, dimension(:,:,:),   allocatable :: manning_avg
      double precision, dimension(:,:),     allocatable :: dhdz

      integer*8                        :: dims_pr
      integer*8                        :: dx_pr
      integer*8                        :: nbin_pr
      integer*8                        :: manning_pr
      integer*8, dimension(2)          :: dims2
      integer*8, dimension(3)          :: dims3
      integer*8, dimension(3)          :: dims3out
      integer*4                        :: classid
     
c      open(800,file='out01.txt')

c     Dimensions

      dims_pr = mxGetDimensions(prhs(1))
      call mxCopyPtrToReal8(dims_pr,dims3,3)
      
      nmax = dims3(1)
      mmax = dims3(2)
      np   = dims3(3)
      
      dims2(1) = nmax
      dims2(2) = mmax
      
c     Numbers of bins 
      nbin_pr    = mxGetPr(prhs(3))
      dx_pr      = mxGetPr(prhs(4))
      
      call mxCopyPtrToReal8(nbin_pr,nbinr,1)
      call mxCopyPtrToReal8(dx_pr,dx,1)
      
      nbin=int(nbinr)
           
      dims3out(1)=nmax
      dims3out(2)=mmax
      dims3out(3)=nbin
      
c     Allocate
      allocate(d(1:nmax,1:mmax,1:np))
      allocate(manning(1:nmax,1:mmax,1:np))
      allocate(zmin(1:nmax,1:mmax))
      allocate(zmax(1:nmax,1:mmax))
      allocate(hrep(1:nmax,1:mmax,1:nbin))      
      allocate(dhdz(1:nmax,1:mmax))      
      allocate(manning_avg(1:nmax,1:mmax,1:nbin))      

C     Create matrix for the return argument.
      classid=mxClassIDFromClassName('double')
      plhs(1) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(2) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(3) = mxCreateNumericArray(3, dims3out, classid, 0)
      plhs(4) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(5) = mxCreateNumericArray(3, dims3out, classid, 0)

      d_pr       = mxGetPr(prhs(1))
      manning_pr = mxGetPr(prhs(2))

      zmin_pr = mxGetPr(plhs(1))
      zmax_pr = mxGetPr(plhs(2))
      hrep_pr = mxGetPr(plhs(3))
      dhdz_pr = mxGetPr(plhs(4))
      manning_avg_pr = mxGetPr(plhs(5))


C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(d_pr,d,nmax*mmax*np)
      call mxCopyPtrToReal8(manning_pr,manning,nmax*mmax*np)

C     Call the computational subroutine

      call subgrid_depths(nmax,mmax,np,nbin,dx,d,
     &                    manning,zmin,zmax,hrep,dhdz,manning_avg)
          
c     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(zmin,zmin_pr,nmax*mmax)
      call mxCopyReal8ToPtr(zmax,zmax_pr,nmax*mmax)
      call mxCopyReal8ToPtr(hrep,hrep_pr,nmax*mmax*nbin)
      call mxCopyReal8ToPtr(dhdz,dhdz_pr,nmax*mmax)
      call mxCopyReal8ToPtr(manning_avg,manning_avg_pr,nmax*mmax*nbin)

      deallocate(zmin)
      deallocate(zmax)
      deallocate(d)
      deallocate(hrep)
      deallocate(manning_avg)
      deallocate(manning)
      deallocate(dhdz)

c      close(800)
      
      return
      end


      subroutine subgrid_depths(nmax,mmax,np,nbin,dx,d,
     &                    manning,zmin,zmax,hrep,dhdz,manning_avg)

      integer nmax
      integer mmax
      integer np
      integer nbin
      double precision dx
      double precision d(nmax,mmax,np)
      double precision manning(nmax,mmax,np)
      double precision manning_avg(nmax,mmax,nbin)
      double precision zmin(nmax,mmax)
      double precision zmax(nmax,mmax)
      double precision hrep(nmax,mmax,nbin)
      double precision dhdz(nmax,mmax)
      double precision dd0(np)
      double precision dd(np)
      integer indx(np)
      double precision dbin
      double precision dw
      double precision q
      double precision h
      double precision zb
      double precision manning0
      double precision h10
      double precision zadd
      double precision dsum
      double precision dsum2
      double precision hrepsum
      double precision manning_sum

      double precision zz(nbin+1)
      double precision hh(nbin+1)


      integer n
      integer m
      integer ibin
      integer j1
      integer j2
      integer nsum

      integer mmx
      
      manning0 = 0.02

c      if (dx<100.0) then
c      open(801,file='out050.txt')
c      mmx=5
c      else
c      open(801,file='out200.txt')
c      mmx=2
c      endif

c      open(801,file='mx_subgrid_depth.txt')

c     write(801,*)nmax,mmax,nbin,np
      
      dsum2 = 0.0
      hrepsum = 0.0
      
      do n=1,nmax
         do m=1,mmax
         
c               write(801,*)n,m

            do ip=1,np
               dd0(ip)=d(n,m,ip)
c               write(801,*)n,m,ip,manning(n,m,ip)
            enddo
            
            call sort(np,dd0,dd,indx)

            zmin(n,m) = dd(1)
            zmax(n,m) = dd(np)

            if (zmax(n,m)<zmin(n,m)+0.01) then
               zmax(n,m)=zmax(n,m)+0.01
            endif

            dbin = (zmax(n,m)-zmin(n,m))/nbin
            dbin = max(dbin, 1.0e-9)

            dw = dx/np

c           Next bins
            zz(1) = zmin(n,m)
            hh(1) = 0.0
            do ibin = 1, nbin    
               manning_sum = 0.0
               nsum        = 0
               zb = zmin(n,m) + ibin*dbin
               q = 0.0
               do j1 = 1, np
                  h = max(zb - d(n,m,j1), 0.0)
                  q = q + h**(5.0/3.0)/manning(n,m,j1)
c                  write(801,'(4i8,20e14.4)')n,m,ibin,j1,zb,d(n,m,j1)
                  if (zb>d(n,m,j1)) then
                     nsum = nsum + 1
                     manning_sum = manning_sum + manning(n,m,j1)
c      write(801,'(3i5,20e14.4)')ibin,j1,nsum,manning_sum,manning(n,m,j1)
                  endif   
               enddo

               manning_avg(n,m,ibin) = manning_sum/nsum
c               write(801,'(4i8,20e14.4)')n,m,ibin,nsum,manning_sum,manning_avg(n,m,ibin)

               q = dx*q/np

c               hrep(n,m,ibin) = (q*manning0/dx)**(3.0/5.0)
               hrep(n,m,ibin) = (q*manning_avg(n,m,ibin)/dx)**(3.0/5.0)
               
               zz(ibin+1)=zb
               hh(ibin+1)=hrep(n,m,ibin)
               
            enddo
            
c           Now compute slope above zmax      
            zadd = 5.0
            zb = zmax(n,m) + zadd
            q = 0.0
            do j1 = 1, np
               h = max(zb - d(n,m,j1), 0.0)
               q = q + h**(5.0/3.0)/manning(n,m,j1)
            enddo
            q         = dx*q/np
c            h10       = (q*manning0/dx)**(3.0/5.0)
            h10       = (q*manning_avg(n,m,nbin)/dx)**(3.0/5.0)
            dhdz(n,m) = (h10 - hrep(n,m,nbin)) / zadd
                        
         enddo
      enddo
      
c      if (dx<100) then
c          write(801,'(a,20e14.4)')'averaged',dsum2/(16*np)
c          write(801,'(a,20e14.4)')'averaged',hrepsum/(16)
c          write(801,'(a,20e14.4)')'averaged',dsum2/(100*np)
c          write(801,'(a,20e14.4)')'averaged',hrepsum/(100)
c      else
c          write(801,'(a,20e14.4)')'averaged',dsum2/(1*np)
c          write(801,'(a,20e14.4)')'averaged',hrepsum
c      endif
      
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
