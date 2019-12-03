subroutine initsed( nmlb,   nmub,   nfrac, flufflyr, &
                 & alf1,    betam,  rksc,   pmcrit , bfluff0, bfluff1,&
                 & depeff,  depfac, eropar, parfluff0,  parfluff1, &
                 & tcrdep,  tcrero, tcrfluff)
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
!  $Id: initsed.f90 7697 2012-11-16 14:10:17Z boer_aj $
!  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/03_Fortran/example/example/source/initsed.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: Settings of morphological parameters
!
!!--declarations----------------------------------------------------------------
    
    use precision
    !
    implicit none
    !
!
! Global variables
!
    integer                                     , intent(in)   :: flufflyr      ! switch for fluff layer concept
    integer                                     , intent(in)   :: nfrac         ! number of sediment fractions
    integer                                     , intent(in)   :: nmlb          ! first cell number
    integer                                     , intent(in)   :: nmub          ! first cell number
    real(fp)                                    , intent(out)  :: alf1          ! calibration coefficient van Rijn (1984) [-]
    real(fp)                                    , intent(out)  :: betam         ! power factor for adaptation of critical bottom shear stress [-]
    real(fp)                                    , intent(out)  :: rksc          ! reference level van Rijn (1984) [m]
    real(fp)    , dimension(nmlb:nmub)          , intent(out)  :: pmcrit        ! critical mud fraction [-]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: bfluff0       ! burial coefficient 1 [kg/m2/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: bfluff1       ! burial coefficient 2 [1/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: depeff        ! deposition efficiency [-]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: depfac        ! deposition factor (flufflayer=2) [-]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: eropar        ! erosion parameter for mud [kg/m2/s]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: parfluff0     ! erosion parameter 1 [s/m]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: parfluff1     ! erosion parameter 2 [ms/kg]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: tcrdep        ! critical bed shear stress for mud sedimentation [N/m2]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: tcrero        ! critical bed shear stress for mud erosion [N/m2]
    real(fp)    , dimension(nfrac,nmlb:nmub)    , intent(out)  :: tcrfluff      ! critical bed shear stress for fluff layer erosion [N/m2]
!
!! executable statements ------------------
!
    ! ================================================================================
    !   USER INPUT
    ! ================================================================================
    !
    !   Parameters sediment
    !
    eropar      = 1.0e-2_fp     ! erosion parameter for mud [kg/m2/s]
    tcrdep      = 1000.0_fp     ! critical bed shear stress for mud sedimentation [N/m2]
    tcrero      = 1.0_fp        ! critical bed shear stress for mud erosion [N/m2]
    !
    !   Parameters fluff layer
    !   
    depeff      = 0.95_fp       ! deposition efficiency [-]
    depfac      = 0.2_fp        ! deposition factor (flufflayer=2) [-]
    parfluff0   = 2.0e-1_fp     ! erosion parameter 1 [s/m]
    parfluff1   = 1.0_fp        ! erosion parameter 2 [ms/kg]
    tcrfluff    = 0.05_fp       ! critical bed shear stress for fluff layer erosion [N/m2]
    if (flufflyr==1) then
        bfluff0     = 0.0_fp    ! burial coefficient 1 [kg/m2/s]
        bfluff1     = 0.0_fp    ! burial coefficient 2 [1/s]
    endif
    !
    !   Parameters sand-mud interaction
    !
    betam       =  1.0_fp       ! power factor for adaptation of critical bottom shear stress [-]
    pmcrit      =  0.6_fp       ! critical mud fraction [-]
    !
    !   Parameters sediment transport formulation
    !
    alf1        = 2.0_fp        ! calibration coefficient [-]
    rksc        = 0.1_fp        ! reference level [m]
    !
    ! ================================================================================
    
end subroutine initsed