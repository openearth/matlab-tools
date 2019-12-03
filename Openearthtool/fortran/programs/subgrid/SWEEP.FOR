      subroutine sweep(a,b,c,d,n)
      implicit double precision(a-h,o-z)
      dimension a(n),b(n),c(n),d(n)
            c(1)=c(1)/b(1)
            d(1)=d(1)/b(1)
            do m=2,n
              b(m)=b(m)-a(m)*c(m-1)
              c(m)=c(m)/b(m)
              d(m)=(d(m)-d(m-1)*a(m))/b(m)
            enddo
            do m=n-1,1,-1
              d(m)=d(m)-c(m)*d(m+1)
            enddo
      return
      end
