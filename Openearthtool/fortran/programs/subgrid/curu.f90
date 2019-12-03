subroutine curu

! In this subroutine are the frictionterm defined and the coefficients in momentum equation. 
use dataspace

implicit doubleprecision (a-h,o-z)

do m=0,mmax;do n=1,nmax
   umod=dsqrt(0.25d0*(v1(m,n)**2+v1(m+1,n)**2+v1(m,n-1)**2+v1(m+1,n-1)**2)+u1(m,n)**2)
	sum1=0.0d0;sum2=0.0d0
	do i=1,imax; do j=1,jmax
	  if (i.le.im) then
	    ie=im+i;me=m
	  else
	    ie=i-im+1;me=m+1
	  endif
	  humnij=dps(me,n,ie,j)+((imax-i+0.5)*s1(m,n)+(i-0.5)*s1(m+1,n))/dfloat(imax)
	  sum1=sum1+cz*humnij*dsqrt(humnij);sum2=sum2+humnij
!	  sum1=sum1+humnij*humnij;sum2=sum2+humnij
	enddo;enddo

	omega=sum1/sum2
!The if-statement determines wheter v or u is calculated implicit
	if (bla==0) then
		fac=1.0d0+theta*dt*(g*umod/omega**2)
		cu(m,n)=theta*dt*g/(dx*fac)
	else
		fac=1.0d0+(1.0d0-theta)*dt*(g*umod/omega**2)
		cu(m,n)=(1.0d0-theta)*dt*g/(dx*fac)
	endif
	ru(m,n)=u0(m,n)/fac
	

enddo; enddo




do m=1,mmax;do n=1,nmax-1

   vmod=dsqrt(0.25d0*(u1(m,n)**2+u1(m,n+1)**2+u1(m-1,n)**2+u1(m-1,n+1)**2)+v1(m,n)**2)
	sum1=0.0d0;sum2=0.0d0
	do i=1,imax; do j=1,jmax
	  if (j.le.jm) then
	    je=jm+j;ne=n
	  else
	    je=j-jm+1;ne=n+1
	  endif
	  humnij=dps(m,ne,i,je)+(jmax-j+0.5)/dfloat(jmax)*s1(m,n)+(j-0.5)/dfloat(jmax)*s1(m,n+1)
	  sum1=sum1+cz*humnij*dsqrt(humnij);sum2=sum2+humnij
	enddo;enddo
	omega=sum1/sum2
		
	if (bla==0) then
		fac=1.0d0+(1-theta)*dt*(g*vmod/omega**2)
		cv(m,n)=(1-theta)*dt*g/(dy*fac)
	else
		fac=1.0d0+theta*dt*(g*vmod/omega**2)
		cv(m,n)=theta*dt*g/(dy*fac)
	endif
	  rv(m,n)=v0(m,n)/fac

enddo; enddo
end subroutine curu