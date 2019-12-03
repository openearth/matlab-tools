subroutine erosand(umod     , chezy    , ws    , rsedeq    , &
                 & sour     , sink                 )
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
!  $Id: erosand.f90 7697 2012-11-16 14:10:17Z boer_aj $
!  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/03_Fortran/example/example/source/erosand.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: Computes the sour and sink terms for the 2D case
!              (Gallappatti aproach)
!
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
    use precision
    !
    implicit none
    !
    ! The following list of pointer parameters is used to point inside the gdp structure
    !
!
! Global variables
!
    real(fp), intent(in)  :: chezy      ! Chezy coefficient for hydraulic roughness [m(1/2)/s] 
    real(fp), intent(in)  :: umod       ! velocity magnitude (in bottom cell) [m/s]
    real(fp), intent(in)  :: ws         ! sediment settling velocity (hindered) [m/s]
    real(fp), intent(in)  :: rsedeq     ! equilibrium concentration [kg/m3]
    real(fp), intent(out) :: sour       ! sediment source flux [m/s]
    real(fp), intent(out) :: sink       ! sediment sink flux [m/s]
!
! Local variables
!
    real(fp) :: b
    real(fp) :: eps      
    real(fp) :: hots
    real(fp) :: sg
    real(fp) :: tsd
    real(fp) :: u
    real(fp) :: ulog
    real(fp) :: ustarc
    real(fp) :: w
    real(fp) :: wsl
    real(fp) :: x
    real(fp) :: x2
    real(fp) :: x3
!
!! executable statements -------------------------------------------------------
!
    eps     = 1.0e-6
    sg      = sqrt(9.81_fp)
    !
    sour    = 0.0_fp
    sink    = 0.0_fp
    !
    ! local bed shear stress due to currents
    !
    ustarc  = umod*sg/chezy
    !
    wsl = max(1.0e-3_fp,ws)
    if (umod > eps .and. ustarc > eps) then
        !
        ! compute relaxation time using the Gallappatti formulations
        !
        u = ustarc/umod
        !
        ! limit u to prevent overflow in tsd below
        !
        u = min(u, 0.15_fp)
        if (ustarc > wsl) then
            w = wsl/ustarc
        else
            w = 1.0
        endif
        b    = 1.0
        x    = w/b
        x2   = x*x
        x3   = x2*x
        ulog = log(u)
        tsd  = x*exp((  1.547           - 20.12*u )*x3 &
           &     + (326.832 *u**2.2047 -  0.2   )*x2 &
           &     + (  0.1385*ulog      -  6.4061)*x  &
           &     + (  0.5467*u         +  2.1963) )
        !
        hots = wsl/tsd
        sour = rsedeq*hots
        sink = hots
    else
        sink = wsl
    endif
end subroutine erosand

