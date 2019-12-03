
! data space

 module dataspace

 implicit doubleprecision (a-h,o-z)


 double precision, allocatable, save :: s1(:,:),s0(:,:)                            ! waterlevels
 double precision, allocatable, save :: am(:),bm(:),cm(:),dm(:)                    ! waterlevels
 double precision, allocatable, save :: u1(:,:),u0(:,:),v1(:,:),v0(:,:)            ! velocities
 double precision, allocatable, save :: ru(:,:),rv(:,:),cu(:,:),cv(:,:)            ! coefficients of momentum equations
 double precision, allocatable, save :: q1(:,:),q0(:,:),r1(:,:),r0(:,:)            ! discharges in x and y direction
 double precision, allocatable, save :: au(:,:),hu(:,:,:,:),av(:,:),hv(:,:,:,:)    ! wetsurface and total depth at velocities
 double precision, allocatable, save :: as(:),hs(:),ds(:),dps(:,:,:,:),dpu(:,:,:,:)! wetsurface and total depth at waterlevels
 integer, save :: mmax,nmax,imax,jmax,im,jm, ntmax, nt,bla						   ! administrative integers

 double precision, save :: g,pi,t,dt,dx,dy,slope,cz,ttide,theta                             ! parameters
 
 real, dimension(4)     ::			bc_mean,bc_amp,bc_period
 integer, dimension(4) :: bc_code


 integer         T0map,dTmap,Tendmap



 end module dataspace
 
