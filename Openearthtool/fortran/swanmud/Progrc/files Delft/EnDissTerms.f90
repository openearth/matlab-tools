! ENDISSTERMS   library with energy dissipation relations for various 2 layer flow systems
!
! Literature:
!     1) W.M. Kranenburg, 2008. 'Wave damping by fluid mud', M.Sc. thesis TU Delft and WL | Delft hydraulics.
!        http://resolver.tudelft.nl/uuid:7644eb5b-0ec9-4190-9f72-ccd7b50cfc47 (purl)
!     2) Kranenburg, W.M., J.C. Winterwerp, G.J. de Boer, J.M. Cornelisse and M. Zijlema,
!        2010. SWAN-mud, an engineering model for mud-induced wave-damping, ASCE,
!        Journal of Hydraulic Engineering, in press.

!   --------------------------------------------------------------------
!   Copyright (C) 2008 Delft University of Technology & WL | Delft Hydraulics > Deltares
!       Gerben J. de Boer & Wouter M. Kranenburg
!
!       g.j.deboer@tudelft.nl & W.M.Kranenburg@utwente.nl
!
!       Fluid Mechanics Section
!       Faculty of Civil Engineering and Geosciences
!       PO Box 5048
!       2600 GA Delft
!       The Netherlands
!
!   This library is free software; you can redistribute it and/or
!   modify it under the terms of the GNU Lesser General Public
!   License as published by the Free Software Foundation; either
!   version 2.1 of the License, or (at your option) any later version.
!
!   This library is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
!   Lesser General Public License for more details.
!
!   You should have received a copy of the GNU Lesser General Public
!   License along with this library; if not, write to the Free Software
!   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
!   USA or see 
!   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
!   --------------------------------------------------------------------

!     $Id: EnDissTerms.f90 4624 2011-05-31 19:01:26Z boer_g $ 
!     $Date: 2011-05-31 12:01:26 -0700 (Tue, 31 May 2011) $ 
!     $Author: boer_g $ 
!     $Revision: 4624 $ 
!     $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/fortran/swanmud/Progrc/files%20Delft/EnDissTerms.f90 $ 
!     $Keywords: $. 
!     Access via https://public.deltares.nl/display/OET/SWANmud.
!
!  0. Authors
!
!     0.0: Wouter M. Kranenburg & Gerben J. de Boer
!
!  1. Updates
!
!     0.0, Jun. 07: New module (Wouter Kranenburg & Gerben de Boer)
!
!  2. Purpose
!
!     Collect all subroutines and functions describing a relevant
!     dispersion relation for waves in a viscous two-layer system
!     as described in 
!     1) W.M. Kranenburg, 2008. 'Wave damping by fluid mud', M.Sc. thesis TU Delft and WL | Delft hydraulics.
!        http://resolver.tudelft.nl/uuid:7644eb5b-0ec9-4190-9f72-ccd7b50cfc47 (purl)
!     2) Kranenburg, W.M., J.C. Winterwerp, G.J. de Boer, J.M. Cornelisse and M. Zijlema,
!        2010. SWAN-mud, an engineering model for mud-induced wave-damping, ASCE,
!        Journal of Hydraulic Engineering, in press.
!
!  3. Method
!
!     Analytical and numerical, but always double precision inside.
!
!  8. Subroutines used
!
!     This module EnDissTerms includes the next subroutines:
!
!     ENERGY DISSIPATION FUNCTIONS:
!
!      DISSGADE:   single prec. wrapper for                       
!     DDISSGADE:   double prec. complex function for dissipation acc. Gade(1958) 
!      DISSDELFT8: single prec. wrapper for
!     DDISSDELFT8: double prec. complex function for dissipation acc. DELFT
!      DISSNG:     single prec. wrapper for
!     DDISSNG:     double prec. complex function for dissipation acc. Ng(2000)


MODULE EnDissTerms

CONTAINS

!****************************************************************
!
SUBROUTINE DISSGADE(RWS,PHIWS,SMUDWS,kmudS,omegaS,GS,hwS,rhowS)     
!
!****************************************************************

implicit none

complex(4), intent(in ) :: kmudS
real(4), intent(in)     :: omegaS,GS,hwS,rhowS
real(4), intent(out)    :: RWS, PHIWS,SMUDWS

complex(8)              :: kmudD
real(8)                 :: omegaD,GD,hwD,rhowD
real(8)                 :: RWD, PHIWD,SMUDWD


! Single precision input parameters are converted into double precision
kmudD   = kmudS
omegaD  = omegaS
GD      = GS
hwD     = hwS
rhowD   = rhowS


CALL DDISSGADE(RWD,PHIWD,SMUDWD,kmudD,omegaD,GD,hwD,rhowD)   

! Double precision output parameters are converted into single precision
RWS      = RWD
PHIWS    = PHIWD
SMUDWS   = SMUDWD

!write(*,*) 'In subroutine SDISSGADE: '
!write(*,*) 'kmudD       = ', kmudD
!write(*,*) 'AmplRatModD = ', AmplRatModD
!write(*,*) 'AmplRatArgD = ', AmplRatArgD
!write(*,*) 'RelDissD    = ', RelDissD
!write(*,*) ' '

END SUBROUTINE DISSGADE



!****************************************************************
!
SUBROUTINE DDISSGADE(RWD,PHIWD,SMUDWD,kmudD,omegaD,GD,hwD,rhowD)     
!
!****************************************************************

complex(8), intent(in)  :: kmudD
real(8), intent(in)     :: omegaD,GD,hwD,rhowD
real(8)                 :: omega ,G ,hw ,rhow
real(8), intent(out)    :: RWD, PHIWD,SMUDWD

! Only needed for Gade
real(8)                 :: R, FAC1, FAC2, PHIF

omega  = omegaD
G      = GD
hw     = hwD
H      = hwD
rhow   = rhowD


R      = (ABS(kmudD)/omega)**2                                ! Gade 1958 Eq. I-32
PHIF   = 2.* DATAN ( IMAG(kmudD)/REAL(kmudD) )

FAC1   = G * hw * R * COS(PHIF) - 1.                          ! Gade 1958 Eq. I-41 denominator
FAC2   = G * hw * R * SIN(PHIF)                               ! Gade 1958 Eq. I-41   nominator

RWD    = SQRT( FAC1**2 + FAC2**2 )                            ! Gade 1958 Eq. I-41
PHIWD  = DATAN2(FAC2 + TINY(FAC2), FAC1)                      ! Gade 1958 Eq. I-41
SMUDWD = G * hw * omega * R * RWD * MAX(0.,SIN(PHIWD - PHIF)) ! Gade 1958 Eq. II-11


END SUBROUTINE DDISSGADE


!****************************************************************
!
SUBROUTINE DISSDELFT(AmplRatModS,AmplRatArgS,RelDissS,kmudS,       &
		            omegaS,GS,hwS,rhowS)     
!
!****************************************************************

implicit none

complex(4), intent(in ) :: kmudS
real(4), intent(in)     :: omegaS,GS,hwS,rhowS
real(4), intent(out)    :: AmplRatModS, AmplRatArgS,RelDissS

complex(8)              :: kmudD
real(8)                 :: omegaD,GD,hwD,rhowD
real(8)                 :: AmplRatModD, AmplRatArgD,RelDissD


! Single precision input parameters are converted into double precision
kmudD   = kmudS
omegaD  = omegaS
GD      = GS
hwD     = hwS
rhowD   = rhowS


CALL DDISSDELFT(AmplRatModD,AmplRatArgD,RelDissD,kmudD,       &
		       omegaD,GD,hwD,rhowD)     

! Double precision output parameters are converted into single precision
AmplRatModS = AmplRatModD
AmplRatArgS = AmplRatArgD
RelDissS    = RelDissD

!write(*,*) 'In subroutine SDISELFT: '
!write(*,*) 'kmudD       = ', kmudD
!write(*,*) 'AmplRatModD = ', AmplRatModD
!write(*,*) 'AmplRatArgD = ', AmplRatArgD
!write(*,*) 'RelDissD    = ', RelDissD
!write(*,*) ' '

END SUBROUTINE DISSDELFT




!****************************************************************
!
SUBROUTINE DDISSDELFT(AmplRatModD,AmplRatArgD,RelDissD,kmudD,       &
		             omegaD,GD,hwD,rhowD)     
!
!****************************************************************

complex(8), intent(in)  :: kmudD
real(8), intent(in)     :: omegaD,GD,hwD,rhowD
real(8)                 :: omega ,g ,hw ,rhow
real(8), intent(out)    :: AmplRatModD, AmplRatArgD,RelDissD

complex(8)         :: rXi0a
complex*16         :: coshkh, sinhkh
real(8)            :: kmr, kmi, ARGk, MODk
real(8)            :: Real_P1_1, Real_P1_2a, Real_P1_2b, Real_P1_Sum, Real_P1_Tot
complex*16         :: P1_ampl    
real(8)            :: RelDiss_1, RelDiss_2a, RelDiss_2b, RelDiss_Sum, RelDiss_Tot 


real(8), parameter :: a = 1.0   
	! NB: here a value is given for the water level deviation
	! This parameter a is divided away in the Energy Term							
	! So the relative energy loss is indipendent of a (linear approx.)							

omega  = omegaD
G      = GD
hw     = hwD
rhow   = rhowD

! amplitude ratio
! ---------------------------------------------------------------

if (REAL(kmudD)*hw .LT. 10d0) THEN

   rXi0a        = (cdexp(kmudD*hw)+cdexp(-kmudD*hw))/2. - &
          g*kmudD*(cdexp(kmudD*hw)-cdexp(-kmudD*hw))/2./(omega**2.)
   !rXi0a        = (1-(g*kmudD/(omega**2.0)))*cdexp( kmudD*hw)/2.0 + &
   !               (1+(g*kmudD/(omega**2.0)))*cdexp(-kmudD*hw)/2.0
   !
   !!!! write(*,*) 'DDISSDELFT, rXi0a',rXi0a

else

! Prevent numerical numerical incaccuracies leading to
! unrealisticallyt large values of rXi0a
! See note G.J. de Boer, TU Delft, May 16th 2008
! ---------------------------------------------------------------

   !!! write(*,*) 'DDISSDELFT, rXi0a',rXi0a,' =>',0
   rXi0a = 0.

endif


AmplRatModD  = sqrt (real(rXi0a)**2.0 + imag(rXi0a)**2.0)        
AmplRatArgD  = datan2 (imag(rXi0a) + TINY(imag(rXi0a)),real(rXi0a)) ! make sure not to end up in quadrant IV, so add tiny to IMAG part


! preparation for pressure and dissipation
! ---------------------------------------------------------------
coshkh       = (cdexp(kmudD*hw)+cdexp(-kmudD*hw))/2.0					
sinhkh       = (cdexp(kmudD*hw)-cdexp(-kmudD*hw))/2.0					
kmr          = real(kmudD)
kmi          = imag(kmudD)
MODk         = sqrt (kmr**2.0 + kmi**2.0)
ARGk         = datan2(kmi + TINY(kmi),kmr)

! pressure
Real_P1_1    = rhow*a*g*cosh(kmr*hw)*cos(kmi*hw)    
Real_P1_2a   = -rhow*a*omega**2*sinh(kmr*hw)*cos(kmi*hw)*cos(ARGk)/MODk
Real_P1_2b   = -rhow*a*omega**2*cosh(kmr*hw)*sin(kmi*hw)*sin(ARGk)/MODk
Real_P1_Sum  = Real_P1_1 + Real_P1_2a + Real_P1_2b
P1_ampl      = rhow*a*g*coshkh - rhow*a*(omega**2.0)*sinhkh / kmudD
Real_P1_Tot  = real(P1_ampl)

! dissipation
RelDiss_1    = -omega*dsin(AmplRatArgD)*dcosh(kmr*hw)*dcos(kmi*hw)*AmplRatModD
RelDiss_2a   = omega**3.0*dsinh(kmr*hw)*dcos(kmi*hw)*dcos(ARGk)*dsin(AmplRatArgD)*AmplRatModD/MODk/g
RelDiss_2b   = omega**3.0*dcosh(kmr*hw)*dsin(kmi*hw)*dsin(ARGk)*dsin(AmplRatArgD)*AmplRatModD/MODk/g
RelDiss_Sum  = RelDiss_1 + RelDiss_2a + RelDiss_2b
RelDiss_Tot  = -omega*dsin(AmplRatArgD)*Real_P1_Tot*AmplRatModD / (rhow*g*a)

RelDissD     = RelDiss_Tot

END SUBROUTINE DDISSDELFT

!****************************************************************
!
SUBROUTINE DISSNG(RWS,PHIWS,SMUDWS,kmudS,omegaS,GS,hwS,rhowS,CgS)
!
!****************************************************************

implicit none

complex(4), intent(in ) :: kmudS
real(4), intent(in)     :: omegaS,GS,hwS,rhowS,CgS,RWS,PHIWS
real(4), intent(out)    :: SMUDWS

complex(8)              :: kmudD
real(8)                 :: omegaD,GD,hwD,rhowD,CgD
real(8)                 :: RWD, PHIWD,SMUDWD


! Single precision input parameters are converted into double precision
kmudD   = kmudS
omegaD  = omegaS
GD      = GS
hwD     = hwS
rhowD   = rhowS
CgD     = CgS


CALL DDISSNG(RWD,PHIWD,SMUDWD,kmudD,omegaD,GD,hwD,rhowD,CgD)

! Double precision output parameters are converted into single precision
SMUDWS   = SMUDWD

!write(*,*) 'In subroutine SDISSNG: '
!write(*,*) 'kmudD       = ', kmudD
!write(*,*) 'AmplRatModD = ', AmplRatModD
!write(*,*) 'AmplRatArgD = ', AmplRatArgD
!write(*,*) 'RelDissD    = ', RelDissD
!write(*,*) ' '

END SUBROUTINE DISSNG



!****************************************************************
!
SUBROUTINE DDISSNG(RWD,PHIWD,SMUDWD,kmudD,omegaD,GD,hwD,rhowD,CgD)
!
!****************************************************************

complex(8), intent(in)  :: kmudD
real(8), intent(in)     :: omegaD,GD,hwD,rhowD,CgD,RWD,PHIWD
real(8), intent(out)    :: SMUDWD

SMUDWD = 2*CgD*imag(kmudD) ! Kranenburg(2008) Eq. 143

SMUDWS  = SMUDWD

END SUBROUTINE DDISSNG


END MODULE EnDissTerms




