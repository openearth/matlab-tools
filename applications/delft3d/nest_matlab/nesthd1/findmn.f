cfindmn
      subroutine findmn (xp    , yp    , x     , y     , mmax  , nmax  ,
     *                   mc    , nc    , mp    , np    , rmp   , rnp   ,
     *                   inside, spher                                 )
c***********************************************************************
c delft hydraulics                         marine and coastal management
c
c subroutine         : findmn
c version            : v0.1
c date               : 6 October 1995
c specs last update  : derived from findnm subroutine of Herman Kernkamp
c                      changes with other versions of findnm:
c                      - subroutine name changed to findmn
c                      - depth points instead of zeta points
c                      - search starts at the grid cell determined by the
c                        relative M,N co-ordinates of the next boundary
c                        point with respect to the last found grid cell
c programmer         : Lamber Hulsen
c
c function           : given a pair of X,Y co-ordinates, find the
c                      M,N co-ordinates of the grid cell containing
c                      this specified location
c method             : 1. initialisation
c                      2. identify candidate grid cell starting from
c                         last found grid cell by relative M,N indices
c                         of specified location in last found cell
c                      3. check grid cell when first shot else search
c                         for grid cell
c limitations        :
c error messages     : see subroutine pinpol
c subroutines called : pinpol
c
c global variables
c
c name     type      length   description
c ------   -------   ------   -----------
c inside   logical   1        true if found
c lundia   integer   1        lun diagnostics
c mc       integer   1        overall grid dimension in M-direction
c mmax     integer   1        maximum grid dimension in M-direction
c mp       integer   1        M co-ordinate grid cell with location inside
c nc       integer   1        overall grid dimension in N-direction
c nerror   integer   1        number of error messages
c nmax     integer   1        maximum grid dimension in N-direction
c np       integer   1        N co-ordinate grid cell with location inside
c rmp      real      1        relative M co-ordinate of spec location
c rnp      real      1        relative N co-ordinate of spec location
c x        real      mmax,    X co-ordinates depth points overall model
c                    nmax
c xp       real      1        X co-ordinate of specified location
c y        real      mmax,    Y co-ordinates depth points overall model
c                    nmax
c yp       real      1        Y co-ordinate of specified location
c***********************************************************************
c
      integer       mmax  , nmax  , mc    , nc    ,
     *              mp    , np    , mb    , me    , nb    , ne    ,
     *              i     , j
c
      real          x     ( mmax  , nmax  )       ,
     *              y     ( mmax  , nmax  )
c
      real          xx    ( 5     )       , yy    ( 5     )
c
      real          xp    , yp    , rmp   , rnp   , xymiss,
     *              a     , b     , c
c
      logical       inside, spher
c
c-----------------------------------------------------------------------
c---- 1. initialisation
c-----------------------------------------------------------------------
c
      xymiss = 0.0
      mb = 1
      me = mc - 1
      nb = 1
      ne = nc - 1
c
c-----------------------------------------------------------------------
c---- 3. check all grid cells
c-----------------------------------------------------------------------
c
      do 30 i = mb, me
c
         do 20 j = nb, ne
c
c---------- set corner points
c
            xx (1) = x (i  ,j  )
            yy (1) = y (i  ,j  )
c
            xx (2) = x (i+1,j  )
            yy (2) = y (i+1,j  )
c
            xx (3) = x (i+1,j+1)
            yy (3) = y (i+1,j+1)
c
            xx (4) = x (i  ,j+1)
            yy (4) = y (i  ,j+1)
c
            xx (5) = x (i  ,j  )
            yy (5) = y (i  ,j  )
c
c---------- continue only if all corners are active
c
            if (( xx(1) /= xymiss .or. yy(1) /= xymiss ) .and.
     *          ( xx(2) /= xymiss .or. yy(2) /= xymiss ) .and.
     *          ( xx(3) /= xymiss .or. yy(3) /= xymiss ) .and.
     *          ( xx(4) /= xymiss .or. yy(4) /= xymiss )      ) then
c
c------------- specified location in grid cell ?
c
               call pinpol (xp    , yp    , 5    , xx   , yy   , inside)
c
c------------- if inside set M,N co-ordinates and compute relative M,N
c
               if( inside )then
c
                  mp  = i
                  np  = j
c
c                 xb1 = xx (2) - xx (1)
c                 xb2 = yy (2) - yy (1)
c                 xbl = sqrt (xb1 * xb1 + xb2 * xb2)
c                 yb1 = xx (4) - xx (1)
c                 yb2 = yy (4) - yy (1)
c                 ybl = sqrt (yb1 * yb1 + yb2 * yb2)
c                 r1  = xp - xx (1)
c                 r2  = yp - yy (1)
c                 rmp = (xb1 * r1 + xb2 * r2) / (xbl * xbl)
c                 rnp = (yb1 * r1 + yb2 * r2) / (ybl * ybl)

                  call  distance(spher ,xx(1),yy(1),xx(2),yy(2),a)
                  call  distance(spher ,xx(1),yy(1),xp   ,yp   ,b)
                  call  distance(spher ,xx(2),yy(2),xp   ,yp   ,c)
                  rmp = 0.5 + (b*b - c*c)/(2*a*a)

                  call  distance(spher ,xx(1),yy(1),xx(4),yy(4),a)
                  call  distance(spher ,xx(4),yy(4),xp   ,yp   ,c)
                  rnp = 0.5 + (b*b - c*c)/(2*a*a)
c
                  goto 999
c
               endif
c
            endif
c
   20    continue
c
   30 continue
c
c-----------------------------------------------------------------------
c---- return to calling module
c-----------------------------------------------------------------------
c
  999 continue
c
      return
      end
