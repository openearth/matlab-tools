subroutine eromud(ws       , fixfac    , taub      , frac      , fracf     , &
                & tcrdep   , tcrero    , eropar    , flufflyr  , mflufftot , &
                & tcrfluff , depeff    , depfac    , parfluff0 , parfluff1 , &
                & sink     , sour      , sinkf     , sourf                    )
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
!  $Id: eromud.f90 7697 2012-11-16 14:10:17Z boer_aj $
!  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/03_Fortran/example/example/source/eromud.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: Computes sediment fluxes at the bed using
!              the Partheniades-Krone formulations.
!
!!--declarations----------------------------------------------------------------
    use precision
    !
    implicit none
    !
    include 'sedparams.inc'
    !
    integer                                     , intent(in)   :: flufflyr      ! switch for fluff layer concept
    real(fp)                                    , intent(in)   :: eropar        ! erosion parameter for mud [kg/m2/s]
    real(fp)                                    , intent(in)   :: depeff        ! deposition efficiency [-]
    real(fp)                                    , intent(in)   :: depfac        ! deposition factor (flufflayer=2) [-]
    real(fp)                                    , intent(in)   :: fixfac        ! reduction factor in case of limited sediment availability [-] 
    real(fp)                                    , intent(in)   :: frac          ! sediment (mass) fraction [-]
    real(fp)                                    , intent(in)   :: fracf         ! sediment (mass) fraction fluff layer [-]
    real(fp)                                    , intent(in)   :: mflufftot     ! total mass of fluff layer
    real(fp)                                    , intent(in)   :: parfluff0     ! erosion parameter 1 [s/m]
    real(fp)                                    , intent(in)   :: parfluff1     ! erosion parameter 2 [s/m]
    real(fp)                                    , intent(in)   :: taub          ! bottom shear stress [N/m2]
    real(fp)                                    , intent(in)   :: tcrdep        ! critical bed shear stress for mud sedimentation [N/m2]
    real(fp)                                    , intent(in)   :: tcrero        ! critical bed shear stress for mud erosion [N/m2]
    real(fp)                                    , intent(in)   :: tcrfluff      ! critical bed shear stress for fluff layer erosion [N/m2]
    real(fp)                                    , intent(in)   :: ws            ! settling velocity [m/s]
    real(fp)                                    , intent(out)  :: sink          ! sediment sink flux [m/s]
    real(fp)                                    , intent(out)  :: sinkf         ! sediment sink flux [m/s]
    real(fp)                                    , intent(out)  :: sour          ! sediment source flux [kg/m2/s]
    real(fp)                                    , intent(out)  :: sourf         ! sediment source flux fluff layer [kg/m2/s]
!
! Local variables
!
    real(fp) :: taum
!
!! executable statements ------------------
!
    sour    = 0.0_fp
    sourf   = 0.0_fp
    sink    = 0.0_fp
    sinkf   = 0.0_fp
    !
    ! Default Partheniades-Krone formula
    !
    taum = 0.0_fp
    if (tcrero>0.0_fp) then
        taum = max(0.0_fp, taub/tcrero - 1.0_fp)
    endif
    sour = eropar * taum
    if (tcrdep > 0.0) then
        sink = max(0.0_fp , 1.0_fp-taub/tcrdep)
    endif
    !
    ! Erosion and deposition to fluff layer
    !
    if (flufflyr>0) then
        taum    = max(0.0_fp, taub - tcrfluff)
        sourf   = min(mflufftot*parfluff1,parfluff0)*taum
        sinkf   = depeff
        sink    = 0.0_fp
    endif
    if (flufflyr==2) then
        sinkf   = (1.0_fp - depfac)*sinkf
        sink    = depeff*depfac
    endif
    !
    !   Sediment source and sink fluxes
    !
    sink    = ws * sink
    sinkf   = ws * sinkf
    sour    = fixfac * frac  * sour
    sourf   =          fracf * sourf          
    !
end subroutine eromud
