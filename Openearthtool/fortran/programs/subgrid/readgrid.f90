subroutine allocate_read_grid

use dataspace
implicit doubleprecision (a-h,o-z)

open( 7,file='historyfile.out')
open( 8,file='check.out')
open( 9,file='openboundary.dat')
open(10,file='u.map')
open(12,file='umodmax.his')

!mmax= 100; nmax=1; imax=10; jmax=10; dx=100.0d0; dy=100.0d0 ; cz=36.0d0
slope=-1.0d-4; 
im=nint(0.5*imax+0.45);jm=nint(0.5*jmax+0.45); slope2=0.05d0

! Wat is dps<o ???
do m=0,mmax+1 ; do n=0,nmax+1
   x0=(m-1)*dx;y0=(n-1)*dy
   do i=1,imax; do j=1,jmax
     xc=x0+(i-0.5d0)*dx/dfloat(imax); yc=y0+(j-0.5d0)*dy/dfloat(jmax)
	 dps(m,n,i,j)=0.5d0+slope2*yc+slope*xc
	 if (yc<0.8d0*dx) then
	   dps(m,n,i,j)=0.4d0+slope*xc
	 else
	   dps(m,n,i,j)=5.0d0+slope*xc
	 endif
!print*,dps(m,n,i,j),slope
	 write(8,'('' dps'',4i4,f12.4)') m,n,i,j,dps(m,n,i,j)
   enddo; enddo;
enddo; enddo;

dps(:,:,:,:)=4.+dps

end subroutine allocate_read_grid
