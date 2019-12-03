program test_flowmodel

use dataspace
use matlab_io


implicit doubleprecision (a-h,o-z)
!  implicit none
  integer i,j,k,l,m,n,nod,nodl,nodr,n1,n2,jv1,jv2,li
  integer outputno
  character(20) fmatname,test
  real*8 cpu0,cpu1
  open(60,file='reduce.log')
  call initialise

  call allocate_read_grid
  call wrreal2matf('flow_00000.mat',s0(1:mmax,1:nmax),mmax,nmax,'s')
  call wrreal2matf('flow_00000.mat',u0(1:mmax,1:nmax),mmax,nmax,'U')
  call wrreal2matf('flow_00000.mat',v0(1:mmax,1:nmax),mmax,nmax,'V')
  call wrreal2matf('flow_00000.mat',dps(1:mmax,1:nmax,1,1),mmax,nmax,'d')



  call comp_hu_au

  t=0.0d0
  outputno=0

  do nt=1,ntmax     
     call timestep
	 t=t+dt
!     if (mod(nt,100)==0) write(*,'(2i10,3e14.4,e12.4)') nt,ntmax-nt,maxval(abs(u1-u0)),maxval(abs(s1-s0))
!     if (mod(nt,100)==0) write(8,'(2i10,3e14.4,e12.4)') nt,ntmax-nt,maxval(abs(u1-u0)),maxval(abs(s1-s0))
!     if (maxval(abs(u1-u0))<0.5d-10.and.maxval(abs(s0-s1))<0.5d-10) exit

! reset
     u0=u1;s0=s1;v0=v1
  
! postprocessing
  if (mod((nt-T0map),dTmap)==0) then
     outputno=outputno+1

     write(fmatname,105) 'flow_',outputno,'.mat' 
105          format(a,i5.5,a,i5.5,a) 

     call wrreal2matf(fmatname,u1(1:mmax,1:nmax),mmax,nmax,'U')
     call wrreal2matf(fmatname,v1(1:mmax,1:nmax),mmax,nmax,'V')
	 call wrreal2matf(fmatname,s1(1:mmax,1:nmax),mmax,nmax,'s')
  endif

  enddo

!  do m=0,mmax
!    write(8,'('' steady state at nt='', i9,i3,'' discharge, wet area=''4e12.4)') nt,m,sum(q0(m,1:nmax)),sum(au(m,1:nmax))&
!	,maxval(u1(m,1:nmax))
!  enddo

 
 end program test_flowmodel
     