function fcn_enloss(d1,bup,vbov,hunoweir,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,testfixedweirs,VillemonteCD3) result(dte)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'fcn_enloss' :: fcn_enloss
    
    use precision
    
    implicit none
    
    real(fp)    , parameter    :: ag = 9.81_fp     !  Description and declaration in esm_alloc_real.f90
    
    real(fp)                   :: dte    !!  Subgrid energy loss due to weir
    character(4)               :: toest  !!  State weir:
                                          !!  volk = perfect weir
                                          !!  onvo = imperfect weir
    
    real(fp)    , intent(in)    :: d1     !!  Distance between crest and downstream depth
    real(fp)    , intent(in)    :: bup    !!  Crest height (downward negative).  
    real(fp)    , intent(in)    :: vbov    !!  velocity upstream
    real(fp)    , intent(in)    :: hunoweir    !!  flow depth upstream. Note it is used to compute `qunit` only
    real(fp)    , intent(in)    :: wsben  !!  Downstream water level
    real(fp)    , intent(in)    :: wsbov  !!  Upstream water level
    integer    , intent(in)     :: iflagweir  !!  Flag to switch between Tabellenboek and Villemonte
    real(fp)   , intent(in)     :: crestl !!  crest length of weir
    real(fp)   , intent(in)     :: rmpben !!  ramp (talud) downstream of weir
    real(fp)   , intent(in)     :: rmpbov !!  ramp (talud) upstream of weir
    real(fp)   , intent(in)     :: veg    !!  Vegetation on weir
    real(fp)   , intent(in)     :: VillemonteCD1    !!  
    real(fp)   , intent(in)     :: VillemonteCD2    !!  
    real(fp)   , intent(in)     :: VillemonteCD3    !!  
    integer    , intent(in)     :: iflagcriteriumvol  
    integer    , intent(in)     :: iflaglossvol  
    integer    , intent(in)     :: testfixedweirs !< Flag for fixed weir options; 0 = original D-Flow FM approach, 1 = Simona approach
    
    call enloss_wrap(d1,bup,vbov,hunoweir,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,dte,toest,testfixedweirs,VillemonteCD3)
    
end function fcn_enloss
    
function fcn_volkomen(d1,bup,vbov,hunoweir,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,testfixedweirs,VillemonteCD3) result(volk)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'fcn_volkomen' :: fcn_volkomen
    
    use precision
    
    implicit none
    
    real(fp)    , parameter    :: ag = 9.81_fp     !  Description and declaration in esm_alloc_real.f90
    
    real(fp)                   :: dte    !!  Subgrid energy loss due to weir
    character(4)               :: toest  !!  State weir:
                                          !!  volk = perfect weir
                                          !!  onvo = imperfect weir
    integer                     :: volk !1: volkomen (free-flow), 0: onvolkomen (submerged)
    
    real(fp)    , intent(in)    :: d1     !!  Distance between crest and downstream depth
    real(fp)    , intent(in)    :: bup    !!  Crest height (downward negative).  
    real(fp)    , intent(in)    :: vbov    !!  velocity upstream
    real(fp)    , intent(in)    :: hunoweir    !!  flow depth upstream. Note it is used to compute `qunit` only
    real(fp)    , intent(in)    :: wsben  !!  Downstream water level
    real(fp)    , intent(in)    :: wsbov  !!  Upstream water level
    integer    , intent(in)     :: iflagweir  !!  Flag to switch between Tabellenboek and Villemonte
    real(fp)   , intent(in)     :: crestl !!  crest length of weir
    real(fp)   , intent(in)     :: rmpben !!  ramp (talud) downstream of weir
    real(fp)   , intent(in)     :: rmpbov !!  ramp (talud) upstream of weir
    real(fp)   , intent(in)     :: veg    !!  Vegetation on weir
    real(fp)   , intent(in)     :: VillemonteCD1    !!  
    real(fp)   , intent(in)     :: VillemonteCD2    !!  
    real(fp)   , intent(in)     :: VillemonteCD3    !!  
    integer    , intent(in)     :: iflagcriteriumvol  
    integer    , intent(in)     :: iflaglossvol  
    integer    , intent(in)     :: testfixedweirs !< Flag for fixed weir options; 0 = original D-Flow FM approach, 1 = Simona approach
    
    call enloss_wrap(d1,bup,vbov,hunoweir,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,dte,toest,testfixedweirs,VillemonteCD3)
    
    if (toest=='volk') then
       !
       ! It is a free weir flow
       !
       volk = 1
    elseif (toest=='onvo') then
       !
       ! It is a submerged weir flow
       !
       volk = 0
    endif
        
    end function fcn_volkomen
    
subroutine enloss_wrap(d1,bup,vbov,hunoweir,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,dte,toest,testfixedweirs,VillemonteCD3)    
    
    use precision
    
    implicit none
    
    real(fp)    , parameter    :: ag = 9.81_fp     !  Description and declaration in esm_alloc_real.f90
    
    real(fp)                   :: dte    !!  Subgrid energy loss due to weir
    character(4)               :: toest  !!  State weir:
                                          !!  volk = perfect weir
                                          !!  onvo = imperfect weir
    
    real(fp)    , intent(in)    :: d1     !!  Distance between crest and downstream depth
    real(fp)    , intent(in)    :: bup    !!  Crest height (downward negative).  
    real(fp)    , intent(in)    :: vbov    !!  velocity upstream
    real(fp)    , intent(in)    :: hunoweir    !!  flow depth upstream. Note it is used to compute `qunit` only
    real(fp)    , intent(in)    :: wsben  !!  Downstream water level
    real(fp)    , intent(in)    :: wsbov  !!  Upstream water level
    integer    , intent(in)     :: iflagweir  !!  Flag to switch between Tabellenboek and Villemonte
    real(fp)   , intent(in)     :: crestl !!  crest length of weir
    real(fp)   , intent(in)     :: rmpben !!  ramp (talud) downstream of weir
    real(fp)   , intent(in)     :: rmpbov !!  ramp (talud) upstream of weir
    real(fp)   , intent(in)     :: veg    !!  Vegetation on weir
    real(fp)   , intent(in)     :: VillemonteCD1    !!  
    real(fp)   , intent(in)     :: VillemonteCD2    !!  
    real(fp)   , intent(in)     :: VillemonteCD3    !!  
    integer    , intent(in)     :: iflagcriteriumvol  
    integer    , intent(in)     :: iflaglossvol  
    integer    , intent(in)     :: testfixedweirs !< Flag for fixed weir options; 0 = original D-Flow FM approach, 1 = Simona approach
    
    !local
    
    double precision  :: avolk, hkruin, ewben, eweir, qvolk, hov, vov, hvolk, qov, tol, vhei, qunit, vben, bl_ds, dtefri
    !character(4) :: toest
    double precision  :: twot = 2d0/3d0
    integer :: itel
    

    avolk = twot*sqrt(twot*ag)
    hkruin = -bup
    
    !vbov   =  abs(uin)
    vhei   =  0.5d0*vbov*vbov / ag
    eweir  =  max (0.000001d0, wsbov + hkruin) + vhei
    qvolk  =  avolk*eweir**1.5d0
    qunit  =  vbov*hunoweir

    ! Compute energy height downstream (EWBEN)
    
    !IMPORTANT. In the original code the bed level at cell centre of the d/s cell is used while
    !here we use the "subgrid" d/s bed level as the difference between crest height and distance 
    !between crest and d/s bed level.
    
    !vben   = qunit / max (0.000001d0,wsben - bl(kd)) !original
    bl_ds = -hkruin-d1 
    vben   = qunit / max (0.000001d0,wsben - bl_ds)
    vhei   =  0.5d0*vben*vben / ag
    ewben  =  max (0.000001d0, wsben + hkruin) + vhei
    ! limit downstream energy height EWBEN by upstream enegy height EWEIR
    ewben = min(ewben, eweir)

    ! Qunit  = abs(q1(L)) / wu(L)

    hov    =  wsbov + hkruin
    vov    =  qunit/hov
    if (vov < 0.5d0 ) then
       itel  = 0
       hvolk = twot*eweir
       tol   = 0.001d0 *max(0.0001d0, qunit)
       qov   = 0d0
       do while (itel < 100 .and. (abs(qunit - qov)) > tol )
          itel = itel + 1
          vov  = qunit / hov
          hov  = max(hvolk, eweir - (vov**2)/(2d0*ag) )
          qov  = vov*hov
       enddo
    endif

    dtefri = 0.0d0
                 
    call enloss(ag        ,d1        ,eweir     ,hkruin    ,hov       , &
                & qunit     ,qvolk     ,toest     ,vov       , &
                & ewben     ,wsbov     ,wsben     ,dte       , &
                & dtefri    ,iflagweir , &
                & crestl    ,rmpbov    ,rmpben    ,veg       ,testfixedweirs, &
                & VillemonteCD1, VillemonteCD2, iflagcriteriumvol, iflaglossvol,VillemonteCD3)
    
end subroutine enloss_wrap    
    
!This is 
