      module mulnormod

      contains
      
      subroutine mulnor(a, b, sig, eps, n, inf, prob, bound, ifault)
      implicit none
c
c        algorithm as 195  appl. statist. (1984) vol.33, no.1
c
c        computes multivariate normal distribution function and computes
c        the probability that a multivariate normal vector falls in a
c        rectangle in n-space with error less than eps.
c
c     Auxiliary functions required: ANORDF, ANORIN, BNRDF, LFDRG, LFTRG
c     and LINRG from the IMSL Stat/Library.
c
      dimension
     *     a(*), b(*), sig(*), c(7), d(7), co(25), sd(2), coef(5, 3),
     *     binc(7, 5), bl(7, 5), br(7, 35, 5), r(36, 5), s(5, 27),
     *     xss(6, 6), pr2(6), prep(6), preb(6), cv(5, 15), sinv(28),
     *     condl(5), xm(5), cond(5), beta(5, 5), bh(5), fe(5), sigma(28)
     $     ,ep(5), del(3, 5), bou4(5), bou5(5), ans(6), fact(5), prod(5)
     $     ,bint(6), bcs(5), bcn(7), eo(13), do(25)
      dimension inf(7), intvl(5), ind(5), ksa(5), num(5), itype(5)
      logical simps, ipr
      data coef(1, 1), coef(2, 1), coef(3, 1), coef(4, 1), coef(5, 1),
     *  coef(1, 2), coef(2, 2), coef(3, 2), coef(4, 2), coef(5, 2),
     *     coef(1, 3), coef(2, 3), coef(3, 3), coef(4, 3), coef(5, 3)
     *     /0.311111111111111, 1.422222222222222, 0.533333333333333,
     *     1.422222222222222, 0.311111111111111, 0.333333333333333, 0.0,
     *     1.333333333333333, 0.0, 0.333333333333333, 0.5, 0.0, 0.0, 0.0
     $     ,0.5/
      data bcs(1), bcs(2), bcs(3), bcs(4), bcs(5) /1.0, 4.0, 6.0, 4.0,
     *     1.0/
      data bcn(1), bcn(2), bcn(3), bcn(4), bcn(5), bcn(6), bcn(7)
     *     /1.0, 6.0, 15.0, 20.0, 15.0, 6.0, 1.0/
      data do(1), do(2), do(3), do(4), do(5), do(6), do(7), do(8),
     *     do(9), do(10), do(11), do(12), do(13), do(14), do(15), do(16)
     $     ,do(17), do(18), do(19), do(20), do(21), do(22), do(23),
     $     do(24),do(25) / - 3.75043972,-3.3242574, -2.85697, -2
     $     .36675941,-2.3344142, -1.8891759, -1.7320508, -1.3556262,-1
     $     .15440539,-1.,-0.74196378, -0.61670659,0.0,0.61670659, 0
     $     .74196378, 1.0, 1.15440539,1.3556262,  1.7320508,1.8891759,2
     $     .3344142, 2.36675941,2.85697, 3.3242574,3.75043972/
      data eo(1), eo(2), eo(3), eo(4), eo(5), eo(6), eo(7), eo(8),
     *     eo(9), eo(10), eo(11), eo(12), eo(13) / - 2.85697, -2.3344142
     $     ,-1.7320508, -1.3556262, -1.0, -0.74196378, 0.0, 0.74196378,
     $     1.0,1.3556262, 1.7320508, 2.3344142, 2.85697/
      data cons2 /6.879833/, cons3 /4.517004/, cons4 /76.371214/,
     *     epsmin /1.0e-8/, epssim /6.0e-5/
      data zero, p05, p15, half, one, two, three, six, eight, ten,
     *     twelve, fiften, forty5, ninety, nine45 /0.0, 0.05, 0.15, 0.5,
     *     1.0, 2.0, 3.0, 6.0, 8.0, 10.0, 12.0, 15.0, 45.0, 90, 945/
c     
c        functions needed to calculate the first six derivatives of
c        the normal density
c
      f2(x, y) = abs((x * x - one) / (y * y))
      f3(x, y) = abs(-x * (x * x - three) / (y * y * y))
      f4(x, y) = abs((three + x * x * (-six + x * x)) / (y ** 4))
      f5(x, y) = abs(x * (-fiften + x * x * (ten - x * x))) / (y ** 5)
      f6(x, y) = abs(-fiften + x * x * (forty5 - x * x * (-fiften +
     *     x * x))) / (y ** 6)
c     checking for faulty data
c
      ifault = 0
      if (eps .le. epsmin) ifault = 2
      if (n .le. 0 .or. n .gt. 7) ifault = 3
      if (ifault .ne. 0) return
      do  i = 1, n
         if (inf(i) .eq. 2 .and. a(i) .lt. b(i)) ifault = 100 + i
      enddo
      if (ifault .ne. 0) return
      bound = eps
c     finding z such that p(n(0,1).gt.z).lt. 0.15*eps/n
c     co will contain the roots of the first 5 or 7 hermite
c     polynomials
      ifault=0.
      ept = eps * p15 / float(n)
      z = -anorin(ept) + epsmin
      cup=1-anordf(z)
c     
c     inverting sig and the n-2 lower right hand principal minors
c     
      ik = 0
      ij = 0
      do  i = 1, n
         do  j = 1, i
            ik = ik + 1
            if (i .eq. j) goto 2
            ij = ij + 1
            sigma(ik) = sig(ij)
            goto 3
 2          sigma(ik) = one
         enddo
 3       continue
      enddo
      if (n .le. 2) goto 4
      call invert(sigma, sinv, cv, n, det, ifault)
      if (ifault .ne. 0) return
      simps = .true.
      if (det .lt. p05 .or. eps .le. epssim) simps = .false.
      prob = zero
      det = sinv(1) * sinv(3) - sinv(2) * sinv(2)
      sd(1) = sqrt(sinv(3) / det)
      sd(2) = sqrt(sinv(1) / det)
      rho = -sinv(2) / (sd(1) * sd(2) * det)
      if (abs(rho) .gt. one) goto 400
 4    nm2 = n - 2
      nm1 = n - 1
c     
c     checking whether upper and lower endpoints are too big
c     
      eplos = zero
      do  l = 1, n
         c(l) = max(b(l), -z)
         d(l) = min(a(l), z)
         if (inf(l) .eq. 0) d(l) = z
         if (inf(l) .eq. 1) c(l) = -z
         if (a(l) .gt. z .or. inf(l) .eq. 0) eplos = eplos + cup
         if (b(l) .lt. -z .or. inf(l) .eq. 1) eplos = eplos + cup
         if (c(l) .ge. d(l)) return
      enddo
      if (n .eq. 1) goto 350
      fac = one
      ipr = .false.
      if (inf(1) .ne. 1 .or. inf(2) .ne. 1) goto 7
      ipr = .true.
      eplos = eplos - two * cup
      goto 8
 7    if (inf(1) .ne. 0 .or. inf(2) .ne. 0) goto 8
      fac = -one
      ipr = .true.
      d(1) = c(1)
      d(2) = c(2)
      eplos = eplos - two * cup
 8    if (n .eq. 2) goto 360
      ifault = 5
      epsi = (eps - eplos) / float(nm2)
c     finding regression coefficients (beta,bh) and bounds on the
c     conditional integrals (binc)
c     cond(l)=conditional variance of variable n-l+1 given later
c     variables
c     
      do  l = 1, nm2            ! 15
         cond(l) = one / sqrt(cv(l, 1))
         condl(l) = log(cond(l))
         do  i = 1, l
            beta(l, i) = zero
            do  j = 1, l
               jk = (l - i + 1) * (l - i) / 2 + j
               if (j .gt. l - i + 1) jk = j * (j - 1) / 2 + l - i
     $              + 1
               jn = (n - l + j) * (n - l + j - 1) / 2 + n - l
               beta(l, i) = beta(l, i) + sigma(jn) * cv(l, jk)
            enddo
         enddo
         k = n - l - 1
         bh(k + 1) = beta(l, l)
         do  i = 1, k
            bh(i) = zero
            do  j = 1, l
               jn = (j + n - l) * (j + n - l - 1) / 2 + n - l
               ijk = 1 + j * (j - 1) / 2
               bh(i) = bh(i) + sigma(jn) * cv(l, ijk)
            enddo
         enddo
         k = 0
         sigc = zero
         do j = 1, l
            do i = 1, j
               k = k + 1
               sigc = sigc + bh(i) * bh(j) * sinv(k)
            enddo
         enddo                  !12continue
         binc(1, l) = one
         binc(2, l) = sqrt(sigc)
         binc(3, l) = two * sigc
         binc(4, l) = cons2 * sigc * binc(2, l)
         binc(5, l) = twelve * sigc * sigc
         if (simps) goto 13
         binc(6, l) = sigc * sigc * binc(1, l) * cons3
         binc(7, l) = (sigc ** 3) * cons4
 13      if (l .lt. nm2) goto 15
         do  i = 1, nm2
            bh(i) = zero
            do  j = 1, nm2
               jk = (l - i + 1) * (l - i) / 2 + j
               if (j .gt. l - i + 1) jk = j * (j - 1) / 2
     $              + l - i + 1
               jn = (2 + j) * (1 + j) / 2 + 1
               bh(i) = bh(i) + sigma(jn) * cv(l, jk)
            enddo
         enddo                  !14         continue
 15      continue
      enddo
      l = 1
c
c     co will contain the roots of the first 5 or 7 hermite
c     polynomials
c     
      if (simps) goto 50
      do i = 1, 25
         co(i) = do(i)
      enddo
      iend = 25
      ien = 7
      goto 60
 50   do 55 i = 1, 13
         co(i) = eo(i)
      enddo
      iend = 13
      ien = 5
c     
c     initialising values.   xss contains partial sums used for
c     calculating conditional means.
c     
 60   do  i = 1, nm1 ! 70
         xss(i, 1) = zero
      enddo
      xm(1) = zero
      prod(1) = one
      pr2(1) = one
      do i = 1, nm2
         ni = n - i + 1
         pr2(i + 1) = pr2(i) * (d(ni) - c(ni))
      enddo ! 80   continue
c     
c     bint(l) is a bound on the error accumulated at levels l and
c     deeper.
c     ans(l)  is the accumulated integral at level l.
c     prep(l) contains the integrand at level l.
c     preb(l) bounds the error accumulated at levels deeper than l.
c     
      bint(nm1) = zero
 90   intvl(l) = 2
      ans(l) = zero
      bou4(l) = zero
      bint(l) = zero
      prep(l) = zero
      preb(l) = zero
      k = 1
c     
c     finding which of the co are in the current interval.
c     s(l,.) are the endpoints of intervals on which the integrand
c     at level l and its derivatives are monotone.
c     num(l) is the number of such intervals.
c     
      nl = n - l + 1
      s(l, 1) = c(nl) - xm(l)
      s(l, iend + 2) = d(nl) - xm(l)
      num(l) = iend + 2
      do  i = 1, iend
         njs = i
         if (s(l, 1) .lt. co(i) * cond(l))
     $        goto 92
         num(l) = num(l) - 1
      enddo                     !91   continue
 92   if (num(l) .eq. 2) goto 99
      do  i = njs, iend
         mjs = iend - i + njs
         if (s(l, iend + 2) .ge. co(mjs)* cond(l)) goto 96
         num(l) = num(l) - 1
      enddo ! 94   continue
 96   if (num(l) .eq. 2) goto 99
      do  i = njs, mjs
         inj = i - njs + 2
         s(l, inj) = co(i) * cond(l)
      enddo                     !98   continue
 99   numl = num(l)
      s(l, numl) = s(l, iend + 2)
c     
c        ep(l)  is an upper limit on the allowable error at level l.
c        r(k,l) is the right end-point of the current sub-interval.
c        fe(l)  is the left end-point of the current sub-interval.
c        ind(l)-1  indicates which point of the newton-cotes formula
c        we are dealing with.
c
      ep(l) = epsi / pr2(l + 1)
      r(1, l) = s(l, 2)
      ind(l) = 6
c
c        bounding derivatives at left end-point of current interval.
c        bl(i,l) is a bound on the ith derivative of the normal
c        density at level l at the left end-point.
c
      fe(l) = s(l, 1)
      t = fe(l) / cond(l)
      bl(1, l) = phi(t, condl(l))
      bl(2, l) = bl(1, l) * abs(t / cond(l))
      bl(3, l) = bl(1, l) * f2(t, cond(l))
      bl(4, l) = bl(1, l) * f3(t, cond(l))
      bl(5, l) = bl(1, l) * f4(t, cond(l))
      if (simps) goto 100
      bl(6, l) = bl(1, l) * f5(t, cond(l))
      bl(7, l) = bl(1, l) * f6(t, cond(l))
c        bounding derivatives at right end-point of sub-interval.
c        br(i,l) is a bound on the ith derivative of the normal
c        density at level l at the right end-point.
c
 100  t = r(k, l) / cond(l)
      br(1, k, l) = phi(t, condl(l))
      br(2, k, l) = br(1, k, l) * abs(t / cond(l))
      br(3, k, l) = br(1, k, l) * f2(t, cond(l))
      br(4, k, l) = br(1, k, l) * f3(t, cond(l))
      br(5, k, l) = br(1, k, l) * f4(t, cond(l))
      if (simps) goto 104
      br(6, k, l) = br(1, k, l) * f5(t, cond(l))
      br(7, k, l) = br(1, k, l) * f6(t, cond(l))
 104  r(k + 1, l) = (fe(l) + r(k, l)) * half
      bou5(l) = ep(l) * (r(k, l) - s(l, 1))
      del(2, l) = r(k + 1, l) - fe(l)
c     
c     checking the bound for the trapezoidal rule
c     
      del(3, l) = two * del(2, l)
      bou1 = max(br(1, k, l), bl(1, l)) * binc(3, l) +
     *     two * max(br(2, k, l), bl(2, l)) * binc(2, l) +
     *     max(br(3, k, l), bl(3, l)) * binc(1, l)
      bou3 = bou4(l) + bou1 * (del(3, l) ** 3) * prod(l) / twelve
      itype(l) = 3
      if (bou3 .le. bou5(l)) goto 200
c     
c     checking the bound for simpsons rule.
c     
      bou1 = zero
      do  ij = 1, 5
         jk = 6 - ij
         bou2 = max(br(ij, k, l), bl(ij, l))
         bou1 = bou1 + bou2 * binc(jk, l) * bcs(ij)
      enddo                     !  110 continue
      bou3 = bou4(l) + bou1 * (del(2, l) ** 5) * prod(l) / ninety
      itype(l) = 2
      if (bou3 .le. bou5(l)) goto 200
      if (simps) goto 130
c
c        checking the bound for boules rule, if necessary.
c
      del(1, l) = half * del(2, l)
      bou1 = zero
      itype(l) = 1
      do  ij = 1, 7
         jk = 8 - ij
         bou2 = max(br(ij, k, l), bl(ij, l))
         bou1 = bou1 + bou2 * binc(jk, l) * bcn(ij)
      enddo  !120 continue
      bou3 = bou4(l) + bou1 * (del(1, l) ** 7) * prod(l) * eight /
     *     nine45
      if (bou3 .le. bou5(l)) goto 200
c
c        sub-dividing further at level l when the bound is too big.
c
 130  k = k + 1
      if (k .gt. 35) return
      goto 100
  200 bint(l) = bint(l) + bou3 - bou4(l)
      bou4(l) = bou3
      ksa(l) = k
      if (ind(l) .eq. 6) goto 202
      if (itype(l) - 2) 205, 206, 210
c
c        the next 30 lines condition on the value xs and go to level l+1
c
 202  ind(l) = 5
      xs = fe(l)
      fact(l) = bl(1, l)
 203  xss(nm1, l + 1) = xss(nm1, l) + bh(l) * (xs + xm(l))
      do  ll = l, nm2
         xss(ll, l + 1) = xss(ll, l) + beta(ll, l) * (xs + xm(l))
      enddo
      if (l .eq. nm2) goto 300
c
c        xm is the mean of the next variable given those fixed so far.
c
      xm(l + 1) = xss(l, l + 1)
      prod(l + 1) = prod(l) * fact(l)
      l = l + 1
      goto 90
  205 ind(l) = 4
      k = ksa(l)
      xs = half * (fe(l) + r(k + 1, l))
      goto 207
  206 ind(l) = 3
      k = ksa(l)
      xs = r(k + 1, l)
  207 t = xs / cond(l)
      fact(l) = phi(t,condl(l))
      goto 203
  208 ind(l) = 2
      k = ksa(l)
      xs = half * (r(k, l) + r(k + 1, l))
      goto 207
  210 ind(l) = 1
      k = ksa(l)
      xs = r(k, l)
      fact(l) = br(1, k, l)
      goto 203
c
c        evaluate conditional bivariate probabilities at deepest level
c
  300 x1 = fac * (xss(nm1, nm1) - d(1)) / sd(1)
      x2 = fac * (xss(nm2, nm1) - d(2)) / sd(2)
      l = nm1
      ans(l) = bivnor(x1, x2, rho)
      if (ipr) goto 310
      y1 = (xss(nm1, nm1) - c(1)) / sd(1)
      y2 = (xss(nm2, nm1) - c(2)) / sd(2)
      wu = bivnor(y1, y2, rho)
      wt = bivnor(x1, y2, rho)
      wb = bivnor(y1, x2, rho)
      ans(l) = ans(l) + wu - wt - wb
310   if (l .eq. 1) goto 340
      l = l - 1
c
c        advancing the integration at the current level
c
      indl = ind(l)
      numl = num(l)
      ity = itype(l)
      temp = fact(l) * ans(l + 1)
      temb = bint(l + 1)
      fsa = one
      if (indl .ne. 1) goto 315
      tem = temp
      temp = temp + prep(l)
      temb = temb + preb(l)
      prep(l) = tem
      preb(l) = bint(l + 1)
      fsa = two
  315 ans(l) = ans(l) + coef(indl, ity) * temp * del(ity, l)
      bint(l) = bint(l) + coef(indl, ity) * temb * del(ity, l)
c
c        making use of the error which did not accumulate at level l+1
c
      ep(l) = ep(l) + del(ity, l) * coef(indl, ity) * (fsa * float(nm2 -
     *  l) * epsi / pr2(l + 1) - temb) / (s(l, numl) - s(l, 1))
      if (indl .eq. 1) goto 320
      igo = indl - (1 + (itype(l) * (itype(l) - 1)) / 2)
      goto (210, 208, 206, 205), igo
c
c        un-subdividing at level l.
  320 k = ksa(l)
      do 322 i = 1, ien
  322 bl(i, l) = br(i, k, l)
      ind(l) = 5
      fe(l) = r(k, l)
      if (k .eq. 1) goto 326
      k = k - 1
      goto 104
  326 if (intvl(l) .eq. num(l)) goto 310
      intvl(l) = intvl(l) + 1
      intl = intvl(l)
      r(1, l) = s(l, intl)
      goto 100
c
c        completion of integration and bounding.
c
 340  ifault = 0
      prob = ans(1)
      bound = bint(1) + eplos
      return
c
c        special cases --
c        label 350 - n=1
c        label 360 - n=2
c
350   prob = anordf(d(1))-anordf(c(1))
      return
  360 rho = sigma(2)
      if (abs(rho) .gt. one) goto 400
      y1 = -d(1) * fac
      y2 = -d(2) * fac
      prob = bivnor(y1, y2, rho)
      if (ipr) return
      x1 = -c(1)
      x2 = -c(2)
      wl = bivnor(x1, x2, rho)
      wt = bivnor(x1, y2, rho)
      wb = bivnor(y1, x2, rho)
      prob = wl - wt - wb + prob
      return
c
c        error return for covariance not positive definite.
c
  400 ifault = 4
      return
      end subroutine mulnor
c
c
c
      function phi(x, y)
      implicit none
c
c        algorithm as 195.1  appl. statist. (1984) vol.33, no.1
c
c        computes univariate normal density
c        xlow=log(smallest floating point number)
c        sq2p=log(sqrt(two*pi))
c
      real arg, half, sq2p, x, xlow, y, zero
c
      real exp
c
      data xlow /-87.0/, sq2p /0.91893853320467274/, zero /0.0/,
     *  half /0.5/
      phi = zero
      arg = -half * x * x - sq2p - y
      if (arg .gt. xlow) phi = exp(arg)
      return
      end function phi
c
c
c
      real function bivnor(x,y,r)
      implicit none
      data range/25.0/
c     
      xx=max(-range,min(range,x))
      yy=max(-range,min(range,y))
      bivnor=1+bnrdf(xx,yy,r)-anordf(xx)-anordf(yy)
      return
      end function bivnor
c
c
c
      subroutine invert(a,ai,c,n,det,ier)
      implicit none
      dimension a(*),ai(*),c(5,1),s(5,5),ipiv(20),aa(5,5)
c     
      l=0
      do  i=1,n
         do  j=1,i
            l=l+1
            aa(i,j)=a(l)
            aa(j,i)=aa(i,j)     ! 3
         enddo
      enddo
      call linrg(n,aa,5,s,5)
      l=0
      do i=1,n
         do  j=1,i
            l=l+1
 4          ai(l)=s(i,j)
         enddo
      enddo
      do  nm=1,(n-2)
         ii=n+1-nm
         l1=0
         do  i=ii,n
            l1=l1+1
            l2=0
            do  j=ii,n
               l2=l2+1
 2             s(l1,l2)=aa(i,j)
            enddo
         enddo
         call linrg(nm,s,5,s,5)
         l=0
         do  i=1,l1
            do  j=1,i
               l=l+1
 1             c(nm,l)=s(i,j)
            enddo
         enddo
      enddo
      call lftrg(n,aa,5,aa,5,ipiv)
      call lfdrg(n,aa,5,ipiv,det1,det2)
      det=det1*10.0**det2
      ier=0
      return
      end subroutine invert
c     
c     
c     
      subroutine matinv(a,nd,n,ifault)
      implicit none
      dimension a(nd,1)
c     
      ifault=0
      call linrg(n,a,nd,a,nd)
      return
      end subroutine matinv
      end module mulnormod
 
