subroutine hisout
  use dataspace
implicit doubleprecision (a-h,o-z)

dimension print(1:10000)
print(1:nmax)=s0(0,1:nmax)
print(nmax+1)=sum(q0(0,1:nmax))
if (mod(nt,100)==0.and.nt>.75*ntmax) then
  write(7,'(100e12.4)') t,s0(0,1:nmax),s0(mmax+1,1:nmax),sum(q0(0,1:nmax)),sum(q0(mmax,1:nmax))
endif

end subroutine hisout
