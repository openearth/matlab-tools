subroutine s1uexpvimp
! Solving the equiation; the momentum equation is substituted into the continuity equation
use dataspace
implicit doubleprecision (a-h,o-z)

do m=1,mmax
  if (nmax==1) then
    s1(m,n)=s0(m,n)+0.5*dt*(q0(m-1,n)-q0(m,n))/(dx*dy)
  else
    do n=1,nmax
      dm(n)=s0(m,n)+0.5*dt*(q0(m-1,n)-q0(m,n)+av(m,n-1)*rv(m,n-1)-av(m,n)*rv(m,n))/(dx*dy)
      am(n)=-0.5*dt*av(m,n-1)*cv(m,n-1)/(dx*dy)
      cm(n)=-0.5*dt*av(m,n)*cv(m,n)/(dx*dy)
      bm(n)=1.0d0-am(n)-cm(n)
    enddo
    call sweep(am,bm,cm,dm,nmax)
    s1(m,1:nmax)=dm(1:nmax)
  endif 
enddo





do i=2,2,4
   do n=1,nmax
   select case (bc_code(i))
      case(1)  ! waterlevel
         if (i==2) then		 
            s1(0     ,n)=bc_mean(i)-bc_amp(i)*dcos(t*2.0*pi/bc_period(i))
         else
		    s1(mmax+1,n)=bc_mean(i)-bc_amp(i)*dcos(t*2.0*pi/bc_period(i))
         endif

      case(3)   ! Riemann with slope effects
         if (i==2) then		 
		    s1(0     ,n)=s0(0     ,n)+0.5*dt*sqrt(g*(dps(0   ,n,im,jm)+s0(0   ,n)))*( dx*slope+s0(1     ,n)-s0(0   ,n))/dx
         else	
            s1(mmax+1,n)=s0(mmax+1,n)-0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))*( dx*slope+s0(mmax+1,n)-s0(mmax,n))/dx
         endif

    end select

    enddo
enddo



do m=1,mmax;do n=1,nmax-1

  v1(m,n)=rv(m,n)-cv(m,n)*(s1(m,n+1)-s1(m,n))
  u1(m,n)=ru(m,n)-cu(m,n)*(s0(m+1,n)-s0(m,n))

enddo;enddo


end subroutine s1uexpvimp
