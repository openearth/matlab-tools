subroutine initialise



use dataspace
!implicit none
implicit doubleprecision (a-h,o-z)



integer ios
real u_init,v_init,s_init
character(100) inputfile
character(100)	dps_file,restart_file


  pi=4.0d0*atan(1.0)
!  g=9.81d0
!  theta=1.0d0
!  dt=2.0d0;ntmax=100000;ttide=4000.d0

!read input file
  call getarg(1,inputfile)


  namelist /grid/dx,dy,mmax,nmax,imax,jmax,dps_file
  namelist /initialconditions/u_init,v_init,s_init,restart_file
  namelist /boundaryconditions/bc_code,bc_mean,bc_amp,bc_period
  namelist /physicalconstants/g,cz
  namelist /numericalconstants/theta,dt,ntmax
  namelist /postprocess/T0map,dTmap,Tendmap

  open (unit=11,file=inputfile            ,iostat=ios,action='read')
  read (unit=11,nml=grid                  ,iostat=ios)
  read (unit=11,nml=initialconditions     ,iostat=ios)
  read (unit=11,nml=boundaryconditions    ,iostat=ios)
  read (unit=11,nml=physicalconstants     ,iostat=ios)
  read (unit=11,nml=numericalconstants    ,iostat=ios)
  read (unit=11,nml=postprocess           ,iostat=ios)
  

!read bathymetry


!allocate variables
   allocate(u1(0:mmax+1,0:nmax+1),u0(0:mmax+1,0:nmax+1),au(0:mmax,0:nmax),cu(0:mmax,0:nmax),ru(0:mmax,0:nmax))
   allocate(v1(0:mmax+1,0:nmax+1),v0(0:mmax+1,0:nmax+1),av(0:mmax,0:nmax),cv(0:mmax,0:nmax),rv(0:mmax,0:nmax))
   allocate(q1(0:mmax,0:nmax),q0(0:mmax,0:nmax),r1(0:mmax,0:nmax),r0(0:mmax,0:nmax))
   allocate(s1(0:mmax+1,0:nmax+1),s0(0:mmax+1,0:nmax+1),dps(0:mmax+1,0:nmax+1,1:imax,1:jmax),dpu(1:mmax,1:nmax,1:imax,1:jmax))
   allocate(am(max(nmax,mmax+1)),bm(max(nmax,mmax+1)),cm(max(nmax,mmax+1)),dm(max(nmax,mmax+1)))

!set initial conditions
  s0=s_init;
  u0=u_init
  v0=v_init

  s1=s0
  u1=u0
  v1=v0
    
  q0=0.0d0;r0=0.0d0;q1=0.0d0;r1=0.0d0;
  av=0.0;au=0.0;ru=0.0;rv=0.0;cu=0.0;cv=0.0;hulp=0;

!  call rdmat2real(dps_file,dps,mmax,nmax,'delta')

!  do m=0,mmax+1 ; do n=0,nmax+1
!    do i=1,imax; do j=1,jmax
!  	  if (dps(m,n,i,j)+s1(m,n)<0.1d0) s1(m,n)=0.1d0-dps(m,n,i,j)
!    enddo;enddo
!  enddo;enddo
!  s0=maxval(s1)
!  s1=s0

end subroutine initialise
