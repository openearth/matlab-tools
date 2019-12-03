subroutine comp_hu_au
! Calculation of the 'wetted' cross-sections and discarges in both directions
use dataspace

implicit doubleprecision (a-h,o-z)


do m=0,mmax;do n=1,nmax
  if (u1(m,n)>1.0d-6) then
    au(m,n)=dy*(sum(dps(m,n,im,1:jmax))/float(jmax)+s1(m,n))
  else if (u1(m,n)<-1.0d-6) then
    au(m,n)=dy*(sum(dps(m+1,n,im,1:jmax))/float(jmax)+s1(m+1,n))
  else
    au(m,n)=dy*(sum(dps(m,n,imax,1:jmax))/float(jmax)+max(s1(m,n),s1(m+1,n)))
  endif
  q0(m,n)=u1(m,n)*au(m,n)
enddo;enddo


do m=1,mmax;do n=1,nmax-1
  if (v1(m,n)>1.0d-6) then
    av(m,n)=dx*(sum(dps(m,n,1:imax,jm))/float(imax)+s1(m,n))
  else if (v1(m,n)<-1.0d-6) then
    av(m,n)=dx*(sum(dps(m,n+1,1:imax,jm))/float(imax)+s1(m,n+1))
  else
    av(m,n)=dx*(sum(dps(m,n,1:imax,jmax))/float(imax)+max(s1(m,n),s1(m,n+1)))
  endif
  r0(m,n)=v1(m,n)*av(m,n)
enddo;enddo

end subroutine comp_hu_au