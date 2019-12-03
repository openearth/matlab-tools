subroutine erosed(morlyr    , nmlb      , nmub  , dt    , morfac        , &
                & ws        , umod      , h     , chezy , taub          , &
                & nfrac     , rhosol    , sedd50, sedd90, sedtyp        , &
                & sink      , sinkf     , sour  , sourf , messages    )
!----- GPL ---------------------------------------------------------------------
!                                                                               
!  Copyright (C)  Stichting Deltares, 2012.                                     
!                                                                               
!  This program is free software: you can redistribute it and/or modify         
!  it under the terms of the GNU General Public License as published by         
!  the Free Software Foundation version 3.                                      
!                                                                               
!  This program is distributed in the hope that it will be useful,              
!  but WITHOUT ANY WARRANTY; without even the implied warranty of               
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                
!  GNU General Public License for more details.                                 
!                                                                               
!  You should have received a copy of the GNU General Public License            
!  along with this program.  If not, see <http://www.gnu.org/licenses/>.        
!                                                                               
!  contact: delft3d.support@deltares.nl                                         
!  Stichting Deltares                                                           
!  P.O. Box 177                                                                 
!  2600 MH Delft, The Netherlands                                               
!                                                                               
!  All indications and logos of, and references to, "Delft3D" and "Deltares"    
!  are registered trademarks of Stichting Deltares, and remain the property of  
!  Stichting Deltares. All rights reserved.                                     
!                                                                               
!-------------------------------------------------------------------------------
!  $Id: erosed.f90 7697 2012-11-16 14:10:17Z boer_aj $
!  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/03_Fortran/example/example/source/erosed.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: Computes sedimentation and erosion fluxes
!
!!--declarations----------------------------------------------------------------
    
    use precision
    use bedcomposition_module
    use message_module
    !
    implicit none
    !
    include 'sedparams.inc'
    !
    integer                         , pointer :: flufflyr                       ! switch for fluff layer concept
    real(fp)    , dimension(:,:)    , pointer :: bfluff0                        ! burial coefficient 1 [kg/m2/s]
    real(fp)    , dimension(:,:)    , pointer :: bfluff1                        ! burial coefficient 2 [1/s]
    real(fp)    , dimension(:,:)    , pointer :: mfluff                         ! composition of fluff layer: mass of mud fractions [kg/m2]
    !
    type(bedcomp_data)                          , intent(in)   :: morlyr        ! bed composition data
    integer                                     , intent(in)   :: nfrac         ! number of sediment fractions
    integer                                     , intent(in)   :: nmlb          ! first cell number
    integer                                     , intent(in)   :: nmub          ! last cell number
    integer     , dimension(nfrac)              , intent(in)   :: sedtyp        ! sediment type
    real(fp)                                    , intent(in)   :: dt            ! time step [s]
    real(fp)                                    , intent(in)   :: morfac        ! morphological accelaration factor 
    real(fp)    , dimension(nmlb:nmub)          , intent(in)   :: chezy         ! Chezy coefficient for hydraulic roughness [m(1/2)/s] 
    real(fp)    , dimension(nmlb:nmub)          , intent(in)   :: h             ! water depth [m]
    real(fp)    , dimension(nfrac)              , intent(in)   :: rhosol        ! specific sediment density [kg/m3]
    real(fp)    , dimension(nmlb:nmub)          , intent(in)   :: sedd50        ! 50% diameter sediment fraction [m]
    real(fp)    , dimension(nmlb:nmub)          , intent(in)   :: sedd90        ! 90% diameter sediment fraction [m]
    real(fp)    , dimension(nmlb:nmub)          , intent(in)   :: taub          ! bottom shear stress [N/m2]
    real(fp)    , dimension(nmlb:nmub)          , intent(in)   :: umod          ! velocity magnitude (in bottom cell) [m/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(in)   :: ws            ! sediment settling velocity (hindered) [m/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: sink          ! sediment sink flux [m/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: sinkf         ! sediment sink flux fluff layer [m/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: sour          ! sediment source flux [kg/m2/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: sourf         ! sediment source flux fluff layer [kg/m2/s]
    type(message_stack)                                        :: messages      ! message stack
!
! Local variables
!
    character(message_len)                      :: message      ! message
    logical                                     :: anymud
    integer                                     :: istat
    integer                                     :: l            ! sediment counter
    integer                                     :: nm           ! cell counter
    real(fp)                                    :: alf1         ! calibration coefficient van Rijn (1984) [-]
    real(fp)                                    :: betam        ! power factor for adaptation of critical bottom shear stress [-]
    real(fp)                                    :: fracf
    real(fp)                                    :: mfltot
    real(fp)                                    :: rksc         ! reference level van Rijn (1984) [m]
    real(fp)                                    :: sbot
    real(fp)                                    :: smfac        ! correction factor for critical bottom shear stress
    real(fp)                                    :: ssus 
    real(fp)    , dimension(nmlb:nmub)          :: mudcnt 
    real(fp)    , dimension(nmlb:nmub)          :: mudfrac      ! mud fraction [-]
    real(fp)    , dimension(nmlb:nmub)          :: pmcrit       ! critical mud fraction [-]
    real(fp)    , dimension(nmlb:nmub)          :: seddep 
    real(fp)    , dimension(nfrac          )    :: E            ! erosion velocity [m/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: depeff       ! deposition efficiency [-]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: depfac       ! deposition factor (flufflayer=2) [-]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: eropar       ! erosion parameter for mud [kg/m2/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: fixfac       ! reduction factor in case of limited sediment availability [-] 
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: frac         ! sediment (mass) fraction [-]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: parfluff0    ! erosion parameter 1 [s/m]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: parfluff1    ! erosion parameter 2 [ms/kg]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: rsedeq       ! equilibrium concentration [kg/m3]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: tcrdep       ! critical bed shear stress for mud sedimentation [N/m2]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: tcrero       ! critical bed shear stress for mud erosion [N/m2]
    real(fp)    , dimension(nfrac,nmlb:nmub)    :: tcrfluff     ! critical bed shear stress for fluff layer erosion [N/m2]
!
!! executable statements ------------------
!
    !
    istat   = 0
    ! 
    !   User defined parameters
    !
    message = 'initializing fluff layer'
    if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'Flufflyr' , flufflyr)
    if (flufflyr>0 .and. istat == 0) istat = bedcomp_getpointer_realfp (morlyr, 'mfluff'   , mfluff)
    if (flufflyr==1) then
        if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'Bfluff0'            , bfluff0)
        if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'Bfluff1'            , bfluff1)
    endif
    if (istat /= 0) call adderror(messages, message)
    !
    call initsed(nmlb,   nmub,   nfrac, flufflyr, &
                 & alf1,    betam,  rksc,   pmcrit, bfluff0, bfluff1, &
                 & depeff,  depfac, eropar, parfluff0,  parfluff1, &
                 & tcrdep,  tcrero, tcrfluff)
    !
    !
    mudcnt      = 0.0_fp
    anymud      = .true.
    !
    !   Determine fractions of all sediments in the top layer and compute the mud fraction. 
    !
    call getfrac(morlyr, frac, anymud, mudcnt, mudfrac, nmlb, nmub)
    !
    !   Determine thickness of sediment
    !
    call getsedthick(morlyr, seddep)
    !
    !   Initialization
    !
    fixfac      = 1.0_fp 
    rsedeq      = 0.0_fp
    ssus        = 0.0_fp 
    sour        = 0.0_fp
    sink        = 0.0_fp
    sinkf       = 0.0_fp
    sourf       = 0.0_fp
    !
    !   Compute change in sediment composition (e.g. based on available fractions and sediment availability)
    !   
    do nm = nmlb, nmub
        mfltot = 0.0_fp
        if (flufflyr>0) then
            do l = 1, nfrac
                mfltot = mfltot + mfluff(l,nm)
            enddo
        endif
        do l = 1, nfrac
            if (sedtyp(l)==SEDTYP_COHESIVE) then
                !
                !   Compute source and sink fluxes for cohesive sediment (mud)
                !
                fracf   = 0.0_fp
                if (mfltot>0.0_fp) fracf   = mfluff(l,nm)/mfltot
                !
                call eromud(ws(l,nm)      , fixfac(l,nm)  , taub(nm)      , frac(l,nm)     , fracf  , &
                          & tcrdep(l,nm)  , tcrero(l,nm)  , eropar(l,nm)  , flufflyr       , mfltot , &
                          & tcrfluff(l,nm), depeff(l,nm)  , depfac(l,nm)  , parfluff0(l,nm), parfluff1(l,nm) , &
                          & sink(l,nm)    , sour(l,nm)    , sinkf(l,nm)   , sourf(l,nm)               )
                 !              
            else
                !
                ! Compute correction factor for critical bottom shear stress with sand-mud interaction
                !
                if ( pmcrit(nm) > 0.0_fp ) then
                    smfac = ( 1.0_fp + mudfrac(nm) ) ** betam
                else
                    smfac = 1.0_fp
                endif
                !
                !   Apply sediment transport formula ( in this case vanRijn (1984) )
                !

                call vanRijn84(umod(nm)  ,sedd50(nm),sedd90(nm),h(nm)     ,ws(l,nm)   , &
                             & rhosol(l) ,alf1      ,rksc      , &
                             & sbot      ,ssus      ,smfac     )
                !
                ssus =  ssus * rhosol(l)
                !
                !   Compute reference concentration
                !
                if (umod(nm)*h(nm)>0.0_fp) then
                    rsedeq(l,nm) = frac(l,nm) * ssus / (umod(nm)*h(nm))
                endif
                !
                !   Compute suspended sediment fluxes for non-cohesive sediment (sand)
                !
                call erosand(umod(nm)    ,chezy(nm)     ,ws(l,nm)  ,rsedeq(l,nm),  &
                           & sour(l,nm)  ,sink(l,nm)                 )
            endif
        enddo      
    enddo
    !
    ! Recompute fluxes due to sand-mud interaction
    !
    do nm = nmlb, nmub
        ! Compute erosion velocities
        E = 0.0_fp
        do l = 1, nfrac
            if (frac(l,nm)>0.0_fp)  E(l) = sour(l,nm)/(rhosol(l)*frac(l,nm))
        enddo
        !
        ! Recompute erosion velocities
        !
        call sand_mud(nfrac, E, frac(:,nm), mudfrac(nm), sedtyp, pmcrit(nm))
        !
        ! Recompute erosion fluxes
        ! 
        do l = 1, nfrac
            sour(l,nm) = frac(l,nm)*rhosol(l)*E(l)
        enddo
    enddo
    !
    ! Add implicit part of source term to sink
    !
    do l = 1, nfrac
        do nm = nmlb, nmub
            sink(l,nm) = sink(l,nm)
        enddo
    enddo
    !
    !
end subroutine erosed
