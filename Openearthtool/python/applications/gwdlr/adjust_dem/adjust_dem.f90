      program mod_elevation
! ===============================================
      implicit none
!
      integer                ::  iXX, iYY, jXX, jYY, kXX, kYY
      integer                ::  mXX, mYY
      parameter                 (mXX=21600)
      parameter                 (mYY=10800)
! var
      integer*2,allocatable  ::  nextx(:,:),  nexty(:,:)   !! downstream (iXX,iYY)
      integer*2,allocatable  ::  stmdem(:,:), elevtn(:,:)  !! original elevation, adjusted elevation
      real,allocatable       ::  rivwth(:,:)               !! river width (used as water mask)
      integer,allocatable    ::  length(:,:)               !! length from river mouth (for sorting)
      integer*1,allocatable  ::  check(:,:)
! length
      integer                ::  in, nmax                      !! number of river line
      integer,allocatable    ::  len_list(:,:)
      integer                ::  len_this, len_next, len_now
! sort
      integer                ::  il, jl, lmax, nl
      integer,allocatable    ::  x_list(:)
      integer,allocatable    ::  y_list(:)
      real                   ::  wgt
      integer*2              ::  stm_min
!
      real                   ::  err, err_min, diff
      integer*2              ::  hgt_h, hgt_l, hgt_mod, hgt_int
      integer*2              ::  hgt_this
! file
      character*128          ::  fnextxy, fstmdem, felevtn

! ===============================================
print *, 'ADJUST_DEM'
      call getarg(1,fnextxy)
      call getarg(2,fstmdem)
      call getarg(3,felevtn)

      allocate(nextx(mXX,mYY),nexty(mXX,mYY),stmdem(mXX,mYY),rivwth(mXX,mYY))
      allocate(elevtn(mXX,mYY))
      allocate(check(mXX,mYY),length(mXX,mYY))

      open(11,file=fnextxy,form='unformatted',access='direct',recl=2*mXX*mYY)
      read(11,rec=1) nextx
      read(11,rec=2) nexty
      close(11)

      open(12,file=fstmdem,form='unformatted',access='direct',recl=4*mXX*mYY)
      read(12,rec=1) stmdem
      close(12)

      rivwth(:,:)=0

      do iYY=1, mYY
        do iXX=1, mXX
          if( nextx(iXX,iYY)/=-30000 )then
            elevtn(iXX,iYY)=10000
          else
            elevtn(iXX,iYY)=-30000     !! -30000 for ocean pixel
          endif
        end do
      end do

      check(:,:)=1       !! check(ix,iy)=1 for topmost pixel
      do iYY=1, mYY
        do iXX=1, mXX
          if( nextx(iXX,iYY)>0 )then
            jXX=nextx(iXX,iYY)
            jYY=nexty(iXX,iYY)
            check(jXX,jYY)=0
          elseif( nextx(iXX,iYY)==-30000 )then
            check(iXX,iYY)=0
          endif
        end do
      end do

! ===
print *, 'calc river length (from topmost pixel to mouth)'
      nmax=0
      length(:,:)=0
      do iYY=1, mYY
        do iXX=1, mXX
          if( nextx(iXX,iYY)>0 .and. check(iXX,iYY)==1 )then
            nmax=nmax+1
            len_this=1
            jXX=iXX
            jYY=iYY
            kXX=nextx(jXX,jYY)
            kYY=nexty(jXX,jYY)
            do while( nextx(jXX,jYY)>0 .and. length(kXX,kYY)==0 )
              len_this=len_this+1
              jXX=kXX
              jYY=kYY
              kXX=nextx(jXX,jYY)
              kYY=nexty(jXX,jYY)
            end do
            if( nextx(jXX,jYY)>0 )then
              len_next=length(kXX,kYY)
            else
              len_next=0
            endif

            jXX=iXX
            jYY=iYY
            len_now=0
            length(jXX,jYY)=len_next+len_this-len_now
            kXX=nextx(jXX,jYY)
            kYY=nexty(jXX,jYY)
            do while( nextx(jXX,jYY)>0 .and. length(kXX,kYY)==0 )
              jXX=kXX
              jYY=kYY
              len_now=len_now+1
              length(jXX,jYY)=len_next+len_this-len_now
              kXX=nextx(jXX,jYY)
              kYY=nexty(jXX,jYY)
            end do
          endif
        end do
      end do
print *, nmax

print *, 'sorting length list'
      allocate(len_list(nmax,3))
      in=0
      lmax=0
      do iYY=1, mYY
        do iXX=1, mXX
          if( nextx(iXX,iYY)>0 .and. check(iXX,iYY)==1 )then
            in=in+1
            lmax=max(lmax,length(iXX,iYY))
            len_list(in,1)=length(iXX,iYY)
            len_list(in,2)=iXX
            len_list(in,3)=iYY
          endif
        end do
      end do
      call heap_sort3(nmax,len_list)
print *, lmax

      allocate(x_list(lmax))
      allocate(y_list(lmax))
! ======================================


      do in=1, nmax
        if( mod(in,5000000)==0 ) print '(f5.2,a)', real(in)/real(nmax)*100, '%'

        jXX=len_list(in,2)
        jYY=len_list(in,3)
        il=1
        x_list(il)=jXX
        y_list(il)=jYY
        stm_min=9999

        if( stmdem(jXX,jYY)/=-30000 ) stm_min=min(stm_min,stmdem(jXX,jYY))
        kXX=nextx(jXX,jYY)
        kYY=nexty(jXX,jYY)
        do while( nextx(jXX,jYY)>0 .and. stm_min<elevtn(kXX,kYY) )    !! if stm_min>elevtn, no need to adjust the riverline.
          jXX=kXX                                                     !!   note: elevtn(:,:)=10000 before adjustment
          jYY=kYY
          il=il+1
          x_list(il)=jXX
          y_list(il)=jYY
          if( stmdem(jXX,jYY)/=-30000 ) stm_min=min(stm_min,stmdem(jXX,jYY))
          kXX=nextx(jXX,jYY)
          kYY=nexty(jXX,jYY)
        end do
        nl=il

        do il=1, nl-1
          jXX=x_list(il)
          jYY=y_list(il)
          kXX=x_list(il+1)
          kYY=y_list(il+1)
          if( stmdem(jXX,jYY)<stmdem(kXX,kYY) )then

            err_min=1.e20
            hgt_this=9999

            hgt_h=stmdem(kXX,kYY)
            hgt_l=stmdem(jXX,jYY)

            hgt_int=1
            if( hgt_h-hgt_l>50  ) hgt_int=10      !! if negatice slope elevation difference is large, use larger increment for faster calculation
            if( hgt_h-hgt_l>500 ) hgt_int=100

 1005       continue
            do hgt_mod=hgt_l, hgt_h, hgt_int    !! find the adjusted elevation (hgt_mod) with minimum required adjustment (err)

              err=0

! error downstream  => lower downstream
              jl=il
              jXX=x_list(il)
              jYY=y_list(il)
              kXX=x_list(il+1)
              kYY=y_list(il+1)
              do while( stmdem(kXX,kYY)>hgt_mod )
                wgt=1                                                      !! weight (small->dig, large->fill)
                if( rivwth(kXX,kYY)>0 .or. rivwth(kXX,kYY)==-1 )then
                  wgt=50                                                   !! weight 50 for water surface
                endif
                diff=stmdem(kXX,kYY)-hgt_mod
                err=err+diff*wgt
                if( err>err_min ) goto 1011
                jl=jl+1
                if( jl<1 .or. jl>nl ) goto 1001
                kXX=x_list(jl)
                kYY=y_list(jl)
              end do
 1001         continue

! error upstream  => higher upstream
              jl=il
              jXX=x_list(il+1)
              jYY=y_list(il+1)
              kXX=x_list(jl)
              kYY=y_list(jl)
              do while( stmdem(kXX,kYY)<hgt_mod )
                wgt=10                                                      !! weight (small->fill, large->dif)
                if( rivwth(kXX,kYY)>0 .or. rivwth(kXX,kYY)==-1 )then
                  wgt=50                                                   !! weight 50 for water surface
                endif
                diff=hgt_mod-stmdem(kXX,kYY)
                err=err+diff*wgt
                if( err>err_min ) goto 1011
                jl=jl-1
                if( jl<1 .or. jl>nl ) goto 1002
                kXX=x_list(jl)
                kYY=y_list(jl)
              end do
 1002       continue

            if( err < err_min )then
              hgt_this=hgt_mod
              err_min=err
            endif

 1011       continue
          end do

          if( hgt_int==10 )then
            hgt_h=hgt_this+10
            hgt_l=hgt_this-10
            hgt_int=1
            goto 1005
          elseif( hgt_int==100 )then
            hgt_h=hgt_this+100
            hgt_l=hgt_this-100
            hgt_int=10
            goto 1005
          endif

          if( hgt_this==9999 ) print *, err, hgt_h, hgt_l

! correct downstream
            jl=il+1
            jXX=x_list(il)
            jYY=y_list(il)
            kXX=x_list(jl)
            kYY=y_list(jl)
            do while( stmdem(kXX,kYY)>hgt_this )
              stmdem(kXX,kYY)=hgt_this
              jl=jl+1
              if( jl<1 .or. jl>nl ) goto 1003
              kXX=x_list(jl)
              kYY=y_list(jl)
            end do
 1003       continue

! correct upstream
            jl=il
            jXX=x_list(il+1)
            jYY=y_list(il+1)
            kXX=x_list(jl)
            kYY=y_list(jl)
            do while( stmdem(kXX,kYY)<hgt_this )
              stmdem(kXX,kYY)=hgt_this
              jl=jl-1
              if( jl<1 .or. jl>nl ) goto 1004
              kXX=x_list(jl)
              kYY=y_list(jl)
            end do
 1004       continue

          endif
        end do

        do il=1, nl
          jXX=x_list(il)
          jYY=y_list(il)
          elevtn(jXX,jYY)=stmdem(jXX,jYY)
        end do

      end do

      deallocate(x_list,y_list)

! ====================
! river mouth

      do iYY=1, mYY
        do iXX=1, mXX
          if( check(iXX,iYY)==1 .and. nextx(iXX,iYY)<0 )then
            elevtn(iXX,iYY) = stmdem(iXX,iYY)
          endif
        end do
      end do

! ====================
! check error

      do iYY=1, mYY
        do iXX=1, mXX
          if( nextx(iXX,iYY)>0 )then
            jXX=nextx(iXX,iYY)
            jYY=nexty(iXX,iYY)
            if( elevtn(jXX,jYY)>elevtn(iXX,iYY) )then
              print *, 'error', iXX, iYY, elevtn(iXX,iYY), elevtn(jXX,jYY), check(iXX,iYY), nextx(jXX,jYY)
            endif
          endif
        end do
      end do

! ===============================================
      open(21, file=felevtn, form='unformatted', access='direct', recl=2*mXX*mYY)
      write(21,rec=1) elevtn
      close(21)

      deallocate(nextx,nexty,stmdem,elevtn,check,length)

      end program mod_elevation







      subroutine heap_sort3(nmax,a)
! ===============================================
! to sort array by heap (large first => small later)
! ===============================================
      implicit none
!
      integer            ::  nmax
      integer            ::  a(nmax,3)   !! it=1: length, it=2: iXX, it=3; iYY
!
      integer            ::  i, n
      integer            ::  c(3)
      integer            ::  mod
! ===============================================
      i=int(nmax/2)
      n=i
 1000 continue
      if( n.eq.0 )goto 9900
      if( 2*n > nmax )then
        i=i-1
        n=i
        goto 1000
      else
        if( 2*n+1 > nmax )then
          if( a(2*n,1) < a(n,1) )then
            c(:)=a(n,:)
            a(n,:)=a(2*n,:)
            a(2*n,:)=c(:)
            n=2*n
            goto 1000
          else
            i=i-1
            n=i
            goto 1000
          endif
        else
          if( a(n,1) <= a(2*n,1) .and. a(n,1) <= a(2*n+1,1) )then
            i=i-1
            n=i
            goto 1000
          elseif( a(2*n,1) < a(2*n+1,1) )then
            c(:)=a(n,:)
            a(n,:)=a(2*n,:)
            a(2*n,:)=c(:)
            n=2*n
            goto 1000
          else
            c(:)=a(n,:)
            a(n,:)=a(2*n+1,:)
            a(2*n+1,:)=c(:)
            n=2*n+1
            goto 1000
          endif
        endif
      endif
 9900 continue
!
      do n=1, nmax
        c(:)=a(1,:)
        a(1,:)=a(nmax-n+1,:)
        a(nmax-n+1,:)=c(:)
        i=1
        mod=1
        do while (mod==1)
          mod=0
          if( 2*i <= nmax-n )then
            if( 2*i+1 <= nmax-n )then
              if( a(2*i,1)<a(i,1) .and. a(2*i,1)<=a(2*i+1,1) )then
                c(:)=a(i,:)
                a(i,:)=a(2*i,:)
                a(2*i,:)=c(:)
                i=2*i
                mod=1
              elseif( a(2*i+1,1)<a(i,1) .and. a(2*i+1,1)<a(2*i,1) )then
                c(:)=a(i,:)
                a(i,:)=a(2*i+1,:)
                a(2*i+1,:)=c(:)
                i=2*i+1
                mod=1
              endif
            else
              if( a(2*i,1)<a(i,1) )then
                c(:)=a(i,:)
                a(i,:)=a(2*i,:)
                a(2*i,:)=c(:)
                i=2*i
                mod=1
              endif
            endif
          endif
        end do
      end do


      return
      end subroutine heap_sort3
