subroutine s1uimpvexp

use dataspace
implicit doubleprecision (a-h,o-z)
! Solving the equiation; the momentum equation is substituted into the continuity equation


do n=1,nmax
  do m=1,mmax
    dm(m)=s0(m,n)+0.5*dt*(r0(m,n-1)-r0(m,n)+au(m-1,n)*ru(m-1,n)-au(m,n)*ru(m,n))/(dx*dy)
    am(m)=-0.5*dt*au(m-1,n)*cu(m-1,n)/(dx*dy)
	cm(m)=-0.5*dt*au(m,n)*cu(m,n)/(dx*dy)
    bm(m)=1.0d0-am(m)-cm(m)
    if (m==1) dm(m)=dm(m)+am(m)*s1(0,n)
!    if (m==mmax) dm(m)=dm(m)-cm(m)*s1(mmax+1,n)
  enddo
                          

!!boundaries
   do i=2,2,4
   select case (bc_code(i))
      case(1)  ! waterlevel
         if (i==2) then		 
            s1(0     ,n)=bc_mean(i)-bc_amp(i)*dcos(t*2.0*pi/bc_period(i))
         else
		    s1(mmax+1,n)=bc_mean(i)-bc_amp(i)*dcos(t*2.0*pi/bc_period(i))
         endif

      case(3)   ! Riemann with slope effects
         if (i==2) then		 
            dm(0     )=s0(mmax+1,n)+0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))*slope
            am(0     )=+0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))/dx
            bm(0     )=1.0d0-0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))/dx
            cm(0     )=0.0d0
         else	
            dm(mmax+1)=s0(mmax+1,n)-0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))*slope
            am(mmax+1)=-0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))/dx
            bm(mmax+1)=1.0d0+0.5*dt*sqrt(g*(dps(mmax,n,im,jm)+s0(mmax,n)))/dx
            cm(mmax+1)=0.0d0
         endif

   end select
   enddo
!!! end boundaries


!solve matrix
  call sweep(am,bm,cm,dm,mmax+1)
  s1(1:mmax+1,n)=dm(1:mmax+1)
enddo 



do m=0,mmax;do n=1,nmax

  v1(m,n)=rv(m,n)-cv(m,n)*(s0(m,n+1)-s0(m,n))
  u1(m,n)=ru(m,n)-cu(m,n)*(s1(m+1,n)-s1(m,n))

enddo;enddo


end subroutine s1uimpvexp
