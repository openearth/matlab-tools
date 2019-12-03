! DISPERSION_RELATIONS   library with dispersion relations for various 2 layer flow systems
!
! Literature:
!     1) W.M. Kranenburg, 2008. 'Wave damping by fluid mud', M.Sc. thesis TU Delft and WL | Delft hydraulics.
!        http://resolver.tudelft.nl/uuid:7644eb5b-0ec9-4190-9f72-ccd7b50cfc47 (purl)
!     2) Kranenburg, W.M., J.C. Winterwerp, G.J. de Boer, J.M. Cornelisse and M. Zijlema,
!        2010. SWAN-mud, an engineering model for mud-induced wave-damping, ASCE,
!        Journal of Hydraulic Engineering, in press.
!
! See also: DISPERSION_RELATIONS_SHELL, IMSL zanly

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

!  0. Authors
!
!     0.0: Wouter M. Kranenburg & Gerben J. de Boer
!
!  1. Updates
!
!     0.0, Jun. 07: New module (Wouter Kranenburg & Gerben de Boer)
!     0.1  Nov, 11: some numerical manipulation such that the itterative             ! 40.61SM
!      solver can converge faster (Seyed Mostafa Siadatmousavi)                          ! 40.61SM
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
!     This module Dispersion_Relations includes the next subroutines:
!
!     DISPERSION RELATION FUNCTIONS:
!
!     GUO2002:    single prec. wrapper for
!     DGUO2002:    double prec. function for wave nr. acc. Guo(2002)
!      GADE1958:   single prec. wrapper for                       
!     DGADE1958:   double prec. complex function for wave nr. acc. Gade(1958) 
!     DGADEROOTS:  double prec. subroutine for wave nr. acc. to Gade(1958)
!      SV:         single prec. wrapper for
!     DSV:         double prec. complex function for Starting Value
!      KDEWIT1995: single prec. wrapper for
!     DKDEWIT1995: double prec. subr. prepares for computation of DeWit 
!     DFDEWIT:     double prec. function for wave nr. acc. to DeWit(1995) 
!     DFDEWITder:  double prec. function for derivative of wave nr. acc. to DeWit(1995)  !40.61SM
!      KDELFT2008: single prec. wrapper for
!     DKDELFT2008: double prec. subr. prepares for computation of DELFT
!     DFKRAN:      double prec. function for wave nr. acc. to DELFT(2008)
!     DFKRANder:   double prec. function for derivative of wave nr. acc. to DELFT(2008)  !40.61SM
!      KDALR1978:  single prec. wrapper for
!     DKDALR1978:  double prec. subr. prepares for computation of Dalr(1978) 
!     DFDALR:      double prec. function for wave nr. acc. to DeWit(1995) 
!      NG2000:     single prec. wrapper for
!     DNG2000:     double prec. complex function for wave nr. acc. Ng(2000)
!     DCTANH:      auxilliary function     

!****************************************************************

MODULE DMUDVARS

implicit none

! Variables used in subroutines connected to DELFT
! values exchanged via calling and header of subroutine

! k is not in this list, because it enters the function FKRAN via the header
! while this module is used to introduce the other variables

real(8)    :: omega ! 2
real(8)    :: H, hw ! 3
real(8)    :: D, hm ! 4
real(8)    :: rhow  ! 5
real(8)    :: rhom  ! 6
real(8)    :: nuw   ! 7
real(8)    :: num   ! 8
real(8)    :: G     ! 9

integer    :: CountCorr, CountNoImpr

END MODULE DMUDVARS

!****************************************************************

MODULE Dispersion_Relations
! updates:
! Modified such that all dispersion equations are solved by laguerre method
!
implicit none 
   
real :: Dispersion_Relations_version = 1.1			!40.61SM


CONTAINS

!****************************************************************
!
      REAL(4) FUNCTION GUO2002 (sigma0,g0,hw0)
!
!****************************************************************

      !GUO2002  Wrapper to call double precision function DGUO2002
      !          with single precision input and output arguments

      REAL(4)   , intent(in) :: sigma0,g0,hw0
      REAL(8)                :: sigma ,g ,hw , realdouble

      sigma         = sigma0
      g             = g0    
      hw            = hw0   
      
      
      realdouble    = DGUO2002(sigma,g,hw)
      
      GUO2002       = real(realdouble)

      END FUNCTION GUO2002


!****************************************************************
!
      REAL(8) FUNCTION DGUO2002 (sigma,g,hw)
!
!****************************************************************

      !     Approximation of wave dispersion relation by 
      !     Guo, 2002. "Simple and explicit solution of wave 
      !     dispersion eqution.", Coastal Engineering, 45, 71--74.
      !
      ! where:
      !
      !    k      = wave number DGUO2002        [rad/m]
      !
      !    hw     = depth of top water layer    [m]
      !    g      = gravity (9.81)              [m/s2]
      !    sigma  = radial freq                 [rad/s]

      REAL(8)   , intent(in) :: sigma ,g, hw 

      if (hw < tiny(hw)) then

         DGUO2002 = 0. ! -9, exception_value

      else

         DGUO2002 = (sigma**2./g)*((1.-exp(-(sigma*sqrt(hw/g))**(5./2.)))**(-2./5.))

      endif

      END FUNCTION DGUO2002



!****************************************************************
!
      COMPLEX FUNCTION GADE1958 (sigma0,g0,hw0,hm0,rhow0,rhom0,nuw0,num0)
!
!****************************************************************

      !GADE1958  Wrapper to call double precision function DGADE1958
      !          with single precision input and output arguments

      REAL(4)   , intent(in) :: sigma0,g0,hw0,hm0,rhow0,rhom0,nuw0,num0
      REAL(8)                :: sigma, g, hw ,hm ,rhow ,rhom ,nuw ,num  
      complex(4), parameter  :: IC     = (0.,1.) ! complex unit
      complex(8)             :: complexdouble

      sigma         = sigma0
      g             = g0
      hw            = hw0   
      hm            = hm0   
      rhow          = rhow0 
      rhom          = rhom0 
      nuw           = nuw0  
      num           = num0  

      complexdouble = DGADE1958(sigma,g,hw,hm,rhow,rhom,nuw,num)

      GADE1958      = real(complexdouble) + &
                      imag(complexdouble)*IC

      !write(*,*) complexdouble, GADE1958
      
      END FUNCTION GADE1958


!****************************************************************
!
      COMPLEX(8) FUNCTION DGADE1958(sigma,g,hw,hm,rhow,rhom,nuw,num)
!
!****************************************************************

      !GADE  Complex wave number in dispersion relation Gade(1958) for 2-layer system.
      !
      ! gade1958(hw,hm,rhow,rhom,nuw,num,g,sigma)
      !
      ! Only double precision gives accurate result!
      !
      ! Not vectorized yet!
      !
      !    Eq. (I-27) (which contains one error: (1 - Gamma*ho/H0) 
      !           should be replaced with   (1 + Gamma*ho/H0)
      ! from:
      !
      !    Herman G. Gade, 1958. "Effects of a nonrigid, 
      !    impermeable bottom on plane surface waves in shallow water",
      !    Journal of Marine Research, Vol. 16, No. 2, page 61-82.
      !
      ! where:
      !
      !    k      = complex wave number         [rad/m]
      !
      !    hw     = depth of top water layer    [m]
      !    hm     = depth of bottom mud layer   [m]
      !    rhow   = density of water layer      [kg/m3]
      !    rhom   = density of mud layer        [kg/m3]
      !    nuw    = viscosity of water (DUMMY)  [m2/s]
      !    num    = viscosity of mud layer      [m2/s]
      !    g      = gravity (9.81)              [m/s2]
      !    sigma  = radial freq                 [rad/s]
      !
      ! Note that for h0=0 [m] NaN is returned. Gade does not have a 
      ! solution, and the solution for h0 nearing 0 0 is not equal to the
      ! regular dispersion relation.
      !
      ! Note: We found the wollowing errors in the manuscript:
      !    1. Eq.  I-25: make the denominator (1-gamma*g*H0*(k/sigma)2)
      !    2. Eq.  I-27: replace (1 - Gamma*ho/H0) with (1 + Gamma*ho/H0)
      !    3. Fig.    2: the tick marks on the imaginary scale should be
      !                  [0.1 0.2] instead of [0.001 0.002]
      !    4. Eq. II- 8: multiply with sigma
      !    5. Eq. II- 9: multiply with sigma
      !    6. Eq. II-11: multiply with sigma
      !
      ! G.J. de Boer, Oct 2006 - Jan 2007
      !
      ! See also: WAVEDISPERSION, WAVELENGTH (matlab downloadcentral)
      ! this gives no solution
      ! should be calculated with limit case
      ! and gives other answer than standard wave dispersion
      ! due to different boundary condition

      complex(8), parameter  :: IC     = (0.,1.) ! complex unit
      REAL(8)   , intent(in) :: sigma,g,hw,hm,rhow,rhom,nuw,num

      real(8)    gammasmall
      complex(8) GAMMALARGE, m, Cpos, C1

        if (hm < tiny(hm)) then
        DGADE1958  = sqrt(g*hw) + 0*IC
        else
        gammasmall = 1- (rhow/rhom)
        m          = (1 - 1*ic)*sqrt(sigma/2/num)
        GAMMALARGE = 1-(dctanh(m*hm)/(m*hm))

        Cpos       = (1. + (GAMMALARGE*hm/hw))
        C1         = 2.*gammasmall*GAMMALARGE*hm/hw

        DGADE1958  = (sigma*sqrt((Cpos  - sqrt(Cpos**2 - 2*C1))/(g*hw*C1)))

            ! test: sqrt can also handxle complex numbers
            ! write(*,*) sqrt(IC)

        endif

      END FUNCTION DGADE1958



!*********************************************************************
! 
SUBROUTINE DGADEROOTS (roots,Omega,g,hw,hm,rhow,rhom,nuw,num)
!
!*********************************************************************

!     (calculates analytically the complex k's for which FGADE=0) 
!     (according to GADE(1958)) 


      real(8), intent(in)      :: Omega,g,hw,hm,rhow,rhom,nuw,num
      real(8)                  :: gammasmall
      complex(8)               :: GAMMALARGE, m, Cpos, C1, z
      complex(8), intent(out)  :: roots(4)
      complex(8), parameter    :: ic     = (0.0, 1.0)

      if (hm < tiny(hm)) then
      roots(1)  = +sqrt(g*hw) + 0*ic
      roots(2)  = -sqrt(g*hw) + 0*ic
      roots(3)  = +sqrt(g*hw) + 0*ic
      roots(4)  = -sqrt(g*hw) + 0*ic

      else
      gammasmall = 1 - (rhow/rhom)
      m          = (1-1*ic) * sqrt(Omega/2/num)
      GAMMALARGE = 1 - (dctanh(m*hm)/(m*hm))
      Cpos       = 1. + (GAMMALARGE*hm/hw)
      C1         = 2.*gammasmall*GAMMALARGE*hm/hw

      roots(1)  = + Omega * sqrt( (Cpos  - sqrt(Cpos**2 - 2*C1)) / (g*hw*C1) )
      roots(2)  = - Omega * sqrt( (Cpos  - sqrt(Cpos**2 - 2*C1)) / (g*hw*C1) )
      roots(3)  = + Omega * sqrt( (Cpos  + sqrt(Cpos**2 - 2*C1)) / (g*hw*C1) )
      roots(4)  = - Omega * sqrt( (Cpos  + sqrt(Cpos**2 - 2*C1)) / (g*hw*C1) )

      endif

!     GADE(1958):
!     k/Omega = 1/wave velocity
!     A) positive values of k/Omega: waves traveling in positive direction
!     B) negative values of k/Omega: waves traveling in the opposite direction
!     C) positive sign for second sqrt: larger amplitude at interface 
!     D) negative sing for second sqrt: larger amplitude at the surface 
!     
!     WK
!     A,C (+,+) gives the highest value --> smallest wave velocity --> internal wave
!     The one we are looking for is A,D (+,-); 


END SUBROUTINE DGADEROOTS

!****************************************************************
!
        COMPLEX FUNCTION SV (sigmaS,gS,hwS,hmS,rhowS,rhomS,nuwS,numS)
!
!****************************************************************

      REAL(4)   , intent(in) :: sigmaS,gS,hwS,hmS,rhowS,rhomS,nuwS,numS
      REAL(8)                :: sigma, g, hw ,hm ,rhow ,rhom ,nuw ,num  
      complex(4), parameter  :: IC     = (0.,1.) ! complex unit
      complex(8)             :: complexdouble

      sigma         = sigmaS
      g             = gS
      hw            = hwS   
      hm            = hmS   
      rhow          = rhowS 
      rhom          = rhomS 
      nuw           = nuwS  
      num           = numS  

      complexdouble = DSV(sigma,g,hw,hm,rhow,rhom,nuw,num)

      SV            = real(complexdouble) + &
                      imag(complexdouble)*IC

      END FUNCTION SV

!****************************************************************
!
      COMPLEX(8) FUNCTION DSV (omega,g,hw,hm,rhow,rhom,nuw,num)
!
!****************************************************************

!     (calculates Starting Value for iterations, using DGADE1958 and DGUO2002)

      real(8), intent(in)     :: omega,g,hw,hm,rhow,rhom,nuw,num

      ! settings
      complex(8), parameter  :: IC=(0.,1.)
      real(8), parameter     :: pi = 3.141592653589793259

      complex(8)             :: kGade, SVA, SVB
      real(8)                :: kGuo
      real(8)                :: khw
      real(8)                :: lowerborder, center, factor, weightf2, weightf1


      ! A) Calculate Kgade, one of the analytical solutions of the root-equation of GADE
      ! This will function as contribution A to the Starting Value

      kGade = DGADE1958(omega,g,hw,hm,rhow,rhom,nuw,num)
      SVA   = kGade

      ! B) Calculate k_guo, the normal wave number for short waves unaffected by mud
      ! This value will be used for contribution B (small imag-value is added)
      
      kGuo  = DGUO2002  (omega, g, hw)
      SVB   = kGuo + ic*imag(kGade)/10.0
      
      ! SV) Calculate the Starting Value of the iteration out of SVA and SVB, using tanh
      ! tanh(-3) = -1, factor*(khw-center), criterium in calculation Starting Value
      
      lowerborder = -1.0
      center      = 1.5
      factor      = -3.0 / (lowerborder-center)
      khw         = kGuo*hw
      weightf2    = (tanh(factor*(khw-center))+1.0) / 2.0
      weightf1    = 1 - weightf2
      
      DSV          = weightf1*SVA + weightf2*SVB


END FUNCTION DSV


!****************************************************************
!
SUBROUTINE KDEWIT1995(kmudS,omegaS,GS,hwS,hmS,rhowS,rhomS,nuwS,numS)     
!
!****************************************************************


      implicit none

      real(4), intent(in)     :: omegaS,GS,hwS,hmS,rhowS,rhomS,nuwS,numS
      complex(4), intent(out) :: kmudS

      real(8)                 :: omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD
      complex(8)              :: kmudD

      ! Single precision input parameters are converted into double precision
      omegaD  = omegaS
      GD      = GS
      hwD     = hwS
      hmD     = hmS
      rhowD   = rhowS
      rhomD   = rhomS
      nuwD    = nuwS
      numD    = numS

      CALL DKDEWIT1995(kmudD,omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD)

      ! Double precision output parameters are converted into single precision
      kmudS       = kmudD

END SUBROUTINE KDEWIT1995



!****************************************************************
!
SUBROUTINE DKDEWIT1995(kmudD,omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD)
!
!****************************************************************

      USE DMUDVARS          !Needed to pass the variables to FDEWIT

      real(8), intent(in)     :: omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD
      complex(8), intent(out) :: kmudD

      ! settings
      complex(8), parameter  :: IC=(0.,1.)
      real(8), parameter     :: pi = 3.141592653589793259

      ! Declarations specially aimed for DZANLY:
      complex*16             :: kk                     ! Starting value of iteration
      integer                :: Info                   ! number of iteration needed to fulfill criterium
      complex*16             :: Xxi, checkDEWIT        ! final result of iteration

      omega  = omegaD
      G      = GD
      hw     = hwD
      H      = hwD
      hm     = hmD
      D      = hmD
      rhow   = rhowD
      rhom   = rhomD
      nuw    = nuwD
      num    = numD


      ! Determination of Starting Value
      kk          = DSV(omega,g,hw,hm,rhow,rhom,nuw,num)
      
      ! Iteration Procedure with DZANLY, give back kmudD
      CALL MullerNewton(DFDEWIT,DFDEWITder,0.0001,0.00001,kk,100,xxi,Info)
      kmudD = xxi
      checkDEWIT = DFDEWIT(kmudD)
!     if (real(checkDEWIT) > 1E-2 .OR. imag(checkDEWIT) > 1E-2) then
!             write(*,*) 'checkDEWIT = ', checkDEWIT
!     endif

END SUBROUTINE DKDEWIT1995



!****************************************************************
! 
COMPLEX(8) FUNCTION DFDEWIT (K)
!
!****************************************************************

!     (calculates F for combinations of kr and ki)
!     (dWIT is DR according to De Wit(1995), is FKRAN minus term3 and term1)

      USE DMUDVARS

      complex(8), intent(in) :: K
!      complex*16             :: coshkd, sinhkd, coshkh, sinhkh               !40.61SM
!      complex*16             :: coshmd, sinhmd, coshmh, sinhmh, m            !40.61SM
      complex*16             :: coshkh, tanhkh ,coshmd, tanhmd, m             !40.61SM
      complex*16             :: term4, term3, term2, term1, term0, R
!      real(8)                :: hyp2F                                        !40.61SM
      complex, parameter     :: ic     = (0.0, 1.0)

      m=(1.0-1.0*ic)*sqrt(Omega/2.0/num)

!      coshkd=(cdexp(K*D)+cdexp(-K*D))/2.0                                    !40.61SM
!      sinhkd=(cdexp(K*D)-cdexp(-K*D))/2.0                                    !40.61SM
      coshkh=(cdexp(K*H)+cdexp(-K*H))/2.0
!      sinhkh=(cdexp(K*H)-cdexp(-K*H))/2.0                                    !40.61SM
      tanhkh=0.5*(cdexp(K*H)-cdexp(-K*H))/coshkh                              !40.61SM

      coshmd=(cdexp(m*D)+cdexp(-m*D))/2.0
!      sinhmd=(cdexp(m*D)-cdexp(-m*D))/2.0                                    !40.61SM
!      coshmh=(cdexp(m*H)+cdexp(-m*H))/2.0                                    !40.61SM
!      sinhmh=(cdexp(m*H)-cdexp(-m*H))/2.0                                    !40.61SM
      tanhmd=0.5*(cdexp(m*D)+cdexp(-m*D))/coshmd                              !40.61SM

      !NB: H=waterdiepte
      !D=bodemlaagdikte
      !precies anders als in DeWit(1995)

!       term4 = + coshmd*Rhom*coshkh/K               &                        !40.61SM
!               - Rhow*sinhkh*sinhmd/m               &                        !40.61SM
!               + Rhow*sinhkh*coshmd*D                                        !40.61SM
!       term2 = + Rhom*G*K*coshkh*sinhmd/m           &                        !40.61SM
!               - Rhom*G*K*coshkh*coshmd*D           &                        !40.61SM
!               - Rhom*G*coshmd*sinhkh                                        !40.61SM
!       term0 = - K**2.0*G**2.0*sinhkh*coshmd*Rhow*D &                        !40.61SM
!               - K**2.0*G**2.0*sinhkh*sinhmd*Rhom/m &                        !40.61SM
!               + K**2.0*G**2.0*sinhkh*coshmd*Rhom*D &                        !40.61SM
!               + K**2.0*G**2.0*sinhkh*sinhmd*Rhow/m                          !40.61SM
        term4 = Rhom/K - Rhow*tanhkh*(tanhmd/m - D )                          !40.61SM
        term2 = + Rhom*G*K*(tanhmd/m -D) - Rhom*G*tanhkh                      !40.61SM
        term0 = K**2.0*G**2.0*tanhkh*(Rhom-Rhow)*( D- tanhmd/m )              !40.61SM

      ! De daadwerkelijke determinant
      R       = + term4*Omega**4          &
                + term2*Omega**2  &
                + term0*Omega**0
!      hyp2F   = real(R)**2.0 + imag(R)**2.0                                  !40.61SM

      DFDEWIT = R

END FUNCTION DFDEWIT

!****************************************************************             !40.61SM
!                                                                             !40.61SM
COMPLEX(8) FUNCTION DFDEWITder (K)                                            !40.61SM
!                                                                             !40.61SM
!****************************************************************             !40.61SM

!     (calculates derivative of DFDEWIT with respect to K                     !40.61SM

      USE DMUDVARS

      complex(8), intent(in) :: K                                             !40.61SM
      complex*16             :: coshkh, tanhkh ,coshmd, tanhmd, m             !40.61SM
      complex*16             :: term4, term3, term2, term1, term0, R          !40.61SM
      complex(8), parameter  :: ic     = (0.0, 1.0)                           !40.61SM

      m=(1.0-1.0*ic)*sqrt(Omega/2.0/num)                                      !40.61SM
      coshkh=(cdexp(K*H)+cdexp(-K*H))/2.0                                     !40.61SM
      tanhkh=0.5*(cdexp(K*H)-cdexp(-K*H))/coshkh                              !40.61SM

      coshmd=(cdexp(m*D)+cdexp(-m*D))/2.0                                     !40.61SM
      tanhmd=0.5*(cdexp(m*D)+cdexp(-m*D))/coshmd                              !40.61SM

        term4 = - Rhom/K**2.0 - Rhow*H*(1.0/coshkh**2.0)*(tanhmd/m - D )      !40.61SM
        term2 = + Rhom*G*(tanhmd/m -D) - Rhom*G*H*(1.0/coshkh**2.0)           !40.61SM
        term0 = G**2.0*(Rhom-Rhow)*( D- tanhmd/m )* &                         !40.61SM
             (tanhkh * K* 2.0 + H * K**2.0 /coshkh**2.0 )                     !40.61SM

      R       = + term4*Omega**4. &                                           !40.61SM
                + term2*Omega**2. &                                           !40.61SM 
                + term0*Omega**0.                                             !40.61SM
      DFDEWITder = R                                                          !40.61SM

END FUNCTION DFDEWITder                                                       !40.61SM


!****************************************************************
!
SUBROUTINE KDELFT2008(kmudS,omegaS,GS,hwS,hmS,rhowS,rhomS,nuwS,numS)     
!
!****************************************************************


      implicit none

      real(4), intent(in)     :: omegaS,GS,hwS,hmS,rhowS,rhomS,nuwS,numS
      complex(4), intent(out) :: kmudS

      real(8)                 :: omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD
      complex(8)              :: kmudD

      ! Single precision input parameters are converted into double precision
      omegaD  = omegaS
      GD      = GS
      hwD     = hwS
      hmD     = hmS
      rhowD   = rhowS
      rhomD   = rhomS
      nuwD    = nuwS
      numD    = numS

      CALL DKDELFT2008(kmudD,omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD)

      ! Double precision output parameters are converted into single precision
      kmudS       = kmudD

END SUBROUTINE KDELFT2008



!****************************************************************
!
SUBROUTINE DKDELFT2008(kmudD,omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD)
!
!****************************************************************

      USE DMUDVARS          !Needed to pass the variables to FKRAN

      real(8), intent(in)     :: omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD
      real(8)                 :: kGuo
      complex(8), intent(out) :: kmudD
      complex(8)              :: kmudcor

      ! settings
      complex(8), parameter   :: IC=(0.,1.)
      real(8), parameter      :: pi = 3.141592653589793259

      ! Declarations specially aimed for DZANLY:
      complex*16              :: kk                          ! Starting value of iteration
      integer                 :: Info                        ! number of iteration needed to fulfill criterium
      complex*16              :: Xxi, checkKRAN1, checkKRAN2 ! final result of iteration

!      LOGICAL, SAVE           :: condition1          = .false.                    !40.61SM
!      LOGICAL, SAVE           :: condition2          = .false.                    !40.61SM
!      logical                 :: improve_with_argand = .true.                     !40.61SM

      omega  = omegaD
      G      = GD
      hw     = hwD
      H      = hwD
      hm     = hmD
      D      = hmD
      rhow   = rhowD
      rhom   = rhomD
      nuw    = nuwD
      num    = numD


      ! Determination of Starting Value
!      condition1  = .false.                                                       !40.61SM
!      condition2  = .false.                                                       !40.61SM
      kk          = DSV(omega,g,hw,hm,rhow,rhom,nuw,num)

      ! Iteration Procedure with DZANLY, give back kmudD

      kGuo  = DGUO2002  (omega, g, hw)

      ! For deep water (kh >3) set dispersion relation to regular one
      if (kGuo*hw> 5) THEN ! make option in *.swn input file

        kmudD      = kGuo + IC*0

      ELSE

!        CALL DZANLY(DFKRAN,0.01,0.01,0,1,1,kk,400,xxi,Info)                       !40.61SM    
        CALL MullerNewton(DFKRAN,DFKRANder,0.0001,0.00001,kk,100,xxi,Info)         !40.61SM 
!        write(*,*) Info

        if ( Info .lt. 1) then                                                     !40.61SM 
!            Usually it needs only one more itteration to have enough accuracy
            if ( Info .gt. -99) then  
               kk= DNG2000 (Omega,g,hw,hm,rhow,rhom,nuw,num)
               CALL NewtonRoot(DFKRAN,DFKRANder,0.0001,0.00001,kk,100,xxi,Info)    !40.61SM 
            else
! Changing the starting point is usually enough, but maybe needs to switch to NewtonRoot !40.61SM
              kk= DNG2000 (Omega,g,hw,hm,rhow,rhom,nuw,num)                        !40.61SM
              CALL MullerNewton(DFKRAN,DFKRANder,0.0001,0.00001,kk,100,xxi,Info)   !40.61SM
!              CALL NewtonRoot(DFKRAN,DFKRANder,0.0001,0.00001,kk,100,xxi,Info)    !40.61SM  
             endif                                                                 !40.61SM  
        endif                                                                      !40.61SM                                                                 
        kmudD      = xxi    
!         if (improve_with_argand) then                                            !40.61SM 
! 
!           checkKRAN1 = DFKRAN(kmudD)                                             !40.61SM 
! 
!           IF (abs(real(checkKRAN1)) > 1E-2 .OR. abs(imag(checkKRAN1)) > 1E-2) THEN  !40.61SM 
! !            write(*,*) ' '
! !            write(*,'(A15,2E14.4)') 'kmudD = ',      real(kmudD),     imag(kmudD)  !40.61SM 
! !            write(*,'(A15,2E14.4)') 'checkKRAN1 = ', real(checkKRAN2), imag(checkKRAN1) !40.61SM 
! 
!                 CALL DARGAND(kmudcor)                                            !40.61SM 
! 
!                 checkKRAN2 = DFKRAN(kmudcor)                                     !40.61SM 
! !                write(*,'(A15,2E14.4)') 'kmudcor = ',      real(kmudcor),     imag(kmudcor) !40.61SM 
! !                write(*,'(A15,2E14.4)') 'checkKRAN2 = ', real(checkKRAN2), imag(checkKRAN2) !40.61SM 
! 
! 
!                 IF (abs(real(checkKRAN2)) <= abs(real(checkKRAN1)) .AND. abs(imag(checkKRAN2)) <= abs(imag(checkKRAN1))) THEN !40.61SM 
!                      condition1 = .true.                                         !40.61SM 
!                 ENDIF                                                            !40.61SM 
!                 IF (abs(real(checkKRAN2)) <= 1E-2 .AND. abs(imag(checkKRAN2)) <= 1E-2) THEN !40.61SM 
!                      condition2 = .true.                                         !40.61SM 
!                 ENDIF                                                            !40.61SM 
! 
!                 IF (condition1 .OR. condition2) THEN                             !40.61SM 
!                      kmudD       = kmudcor                                       !40.61SM 
!                      CountCorr   = CountCorr + 1                                 !40.61SM 
!                 ELSE                                                             !40.61SM 
!                      CountNoImpr = CountNoImpr + 1                               !40.61SM 
!                 ENDIF                                                            !40.61SM 
!                 write(*,*) 'Improvements:   ', Countcorr, ' of which no improvement: ', CountNoImpr !40.61SM 
! 
!           ! sign change cg                                                       !40.61SM 
!           ! IF (real(checkKRAN2) <= 0) THEN                                      !40.61SM 
!           !          kmudD = 0.                                                  !40.61SM 
!           ! write(*,*) 'kreal < 0'                                               !40.61SM 
!           ! ENDIF                                                                !40.61SM 
!  
!           ENDIF                                                                  !40.61SM 
!  
!         endif ! if (improve_with_argand) then                                    !40.61SM 
! 
       ENDIF ! hk > ...                                                           

END SUBROUTINE DKDELFT2008

!****************************************************************
! 
COMPLEX(8) FUNCTION DFKRAN (K)
!
!****************************************************************

!     (calculates F for combinations of kr and ki)
!     (KRAN is DR according to KRAN, corrected version of DR DeWit(1995))

      USE DMUDVARS

      complex(8), intent(in) :: K
!      complex*16             :: coshkd, sinhkd, coshkh, sinhkh               !40.61SM
!      complex*16             :: coshmd, sinhmd, coshmh, sinhmh, m            !40.61SM
      complex*16             :: coshkh, tanhkh ,coshmd, tanhmd, m             !40.61SM
      complex*16             :: term4, term3, term2, term1, term0, R
!      real(8)                :: hyp2F                                        !40.61SM
      complex(8), parameter  :: ic     = (0.0, 1.0)

      m=(1.0-1.0*ic)*sqrt(Omega/2.0/num)

!      coshkd=(cdexp(K*D)+cdexp(-K*D))/2.0                                    !40.61SM
!      sinhkd=(cdexp(K*D)-cdexp(-K*D))/2.0                                    !40.61SM
      coshkh=(cdexp(K*H)+cdexp(-K*H))/2.0
!      sinhkh=(cdexp(K*H)-cdexp(-K*H))/2.0                                    !40.61SM
      tanhkh=0.5*(cdexp(K*H)-cdexp(-K*H))/coshkh                              !40.61SM

      coshmd=(cdexp(m*D)+cdexp(-m*D))/2.0
!      sinhmd=(cdexp(m*D)-cdexp(-m*D))/2.0                                    !40.61SM
!      coshmh=(cdexp(m*H)+cdexp(-m*H))/2.0                                    !40.61SM
!      sinhmh=(cdexp(m*H)-cdexp(-m*H))/2.0                                    !40.61SM
      tanhmd=0.5*(cdexp(m*D)+cdexp(-m*D))/coshmd                              !40.61SM



      !NB: H=waterdiepte
      !D=bodemlaagdikte
      !precies anders als in DeWit(1995)
      
!       term4 = + coshmd*Rhom*coshkh/K &                                      !40.61SM
!               - Rhow*sinhkh*sinhmd/m &                                      !40.61SM
!               + Rhow*sinhkh*coshmd*D                                        !40.61SM
!       term3 = - 2.0*ic*K*Rhom*num*coshmd**2.0*coshkh &                      !40.61SM
!               + 2.0*ic*K*Rhom*num*coshmd*coshkh &                           !40.61SM
!               + 2.0*ic*K*num*Rhom*sinhmd**2.0*coshkh                        !40.61SM
!       term2 = + Rhom*G*K*coshkh*sinhmd/m &                                  !40.61SM
!               - Rhom*G*K*coshkh*coshmd*D &                                  !40.61SM
!               - Rhom*G*coshmd*sinhkh                                        !40.61SM
!       term1 = + 2.0*ic*K**2.0*G*Rhom*num*sinhkh*coshmd**2.0 &               !40.61SM
!               - 2.0*ic*K**2.0*G*Rhom*num*sinhkh*coshmd &                    !40.61SM
!               - 2.0*ic*K**2.0*G*Rhom*num*sinhkh*sinhmd**2.0                 !40.61SM
!       term0 = - K**2.0*G**2.0*sinhkh*Rhow*coshmd*D &                        !40.61SM
!               - K**2.0*G**2.0*sinhkh*sinhmd*Rhom/m &                        !40.61SM
!               + K**2.0*G**2.0*sinhkh*coshmd*D*Rhom &                        !40.61SM
!               + K**2.0*G**2.0*sinhkh*sinhmd*Rhow/m                          !40.61SM
        term4 = Rhom/K - Rhow*tanhkh*(tanhmd/m - D )                          !40.61SM
        term3 = 2.0*ic*K*Rhom*num*( 1.0 -1.0/coshmd )                         !40.61SM
        term2 = + Rhom*G*K*(tanhmd/m -D) - Rhom*G*tanhkh                      !40.61SM
        term1 = + 2.0*ic*K**2.0*G*Rhom*num*tanhkh* (1.0/coshmd-1.0)           !40.61SM
        term0 = K**2.0*G**2.0*tanhkh*(Rhom-Rhow)*( D- tanhmd/m )              !40.61SM

      ! De daadwerkelijke determinant
      R       = + term4*Omega**4. &
                + term3*Omega**3. &
                + term2*Omega**2. &
                + term1*Omega**1. &
                + term0*Omega**0.
!      hyp2F   = real(R)**2.0 + imag(R)**2.0                                  !40.61SM

      ! write (40,'(10E11.2)') real(K),imag(K),real(R),imag(R),hyp2F,    &
      ! real(term4),real(term3),real(term2),real(term1),real(term0)
      ! This write-statement is added here to reach hyp2F and termN.
      ! This makes it possible to control the terms. 
      ! It is about the 40-file of <070602

      DFKRAN = R

END FUNCTION DFKRAN

!****************************************************************             !40.61SM
!                                                                             !40.61SM
COMPLEX(8) FUNCTION DFKRANder (K)                                             !40.61SM
!                                                                             !40.61SM
!****************************************************************             !40.61SM

!     (calculates derivative of DFKRAN with respect to K                      !40.61SM

      USE DMUDVARS

      complex(8), intent(in) :: K                                             !40.61SM
      complex*16             :: coshkh, tanhkh ,coshmd, tanhmd, m             !40.61SM
      complex*16             :: term4, term3, term2, term1, term0, R          !40.61SM
      complex(8), parameter  :: ic     = (0.0, 1.0)                           !40.61SM

      m=(1.0-1.0*ic)*sqrt(Omega/2.0/num)                                      !40.61SM
      coshkh=(cdexp(K*H)+cdexp(-K*H))/2.0                                     !40.61SM
      tanhkh=0.5*(cdexp(K*H)-cdexp(-K*H))/coshkh                              !40.61SM

      coshmd=(cdexp(m*D)+cdexp(-m*D))/2.0                                     !40.61SM
      tanhmd=0.5*(cdexp(m*D)+cdexp(-m*D))/coshmd                              !40.61SM

        term4 = - Rhom/K**2.0 - Rhow*H*(1.0/coshkh**2.0)*(tanhmd/m - D )      !40.61SM
        term3 = 2.0*ic*Rhom*num*( 1.0 -1.0/coshmd )                           !40.61SM
        term2 = + Rhom*G*(tanhmd/m -D) - Rhom*G*H*(1.0/coshkh**2.0)           !40.61SM
        term1 = + 2.0*ic*G*Rhom*num* (1.0/coshmd-1.0)* &                      !40.61SM
             (tanhkh * K* 2.0 + H * K**2.0 /coshkh**2.0 )                     !40.61SM
        term0 = G**2.0*(Rhom-Rhow)*( D- tanhmd/m )* &                         !40.61SM
             (tanhkh * K* 2.0 + H * K**2.0 /coshkh**2.0 )                     !40.61SM

      R       = + term4*Omega**4. &                                           !40.61SM
                + term3*Omega**3. &                                           !40.61SM
                + term2*Omega**2. &                                           !40.61SM 
                + term1*Omega**1. &                                           !40.61SM
                + term0*Omega**0.                                             !40.61SM
      DFKRANder = R                                                           !40.61SM

END FUNCTION DFKRANder                                                        !40.61SM

! !****************************************************************
! ! 
! SUBROUTINE DARGAND(kmudD)
! !
! !****************************************************************
! 
! !     (calculates k with method of increasing viscosity, only valid for KRAN)
! !     (Alternative method to compute the wave number, used as corrector)
! 
!       USE DMUDVARS
! 
!       complex(8), intent(out)      :: kmudD
! 
!       real(8) :: realSV, kstap, kr(2000), FKRANnum0(2000), Kgood
!       integer :: countmax, count
! 
!       LOGICAL, SAVE :: noresult  = .true.
! 
!       integer     :: j, jmax
!       real        :: numstap
! 
!       ! Declarations specially aimed for DZANLY:
!       complex*16             :: kk   ! Starting value of iteration
!       integer                :: Info ! number of iteration needed to fulfill criterium
!       complex*16             :: xxi  ! final result of iteration
!       complex(8), parameter  :: ic     = (0.0, 1.0)
! 
! !     write(*,'(A6,F11.4,A6,F11.4,A6,2F11.6)') 'T =',(2.0*3.1415/omega) , 'hm =', hm, 'k  =', real(kmudD), imag(kmudD)
!     
! 
! ! Determination of Starting Value for iterations of increasing viscosity
! 
!       realSV   = real(DSV(omega,g,hw,hm,rhow,rhom,nuw,num))
!       countmax = 100
!       kstap    = realSV / countmax
! 
!       noresult          = .true.
!       count             = 1
!       kr(count)         = 0.5*realSV + count * kstap 
!       FKRANnum0(count)  = DFKRANnu0(kr(count))
!       
!       DO count = 2,countmax,1
!           IF (noresult) THEN
!           kr(count)  = 0.5*realSV + count * kstap
!           FKRANnum0(count) = DFKRANnu0(kr(count))
!               IF (FKRANnum0(count)*FKRANnum0(count-1) < 0 ) THEN
!                   Kgood    = (kr(count) + kr(count-1)) / 2.
!                   noresult = .false.
!               END IF
!           ENDIF
!       END DO    
! 
! 
! 
! ! Procedure of increasing viscosity
! 
!       IF (num <= 0.1 ) THEN
!           jmax = 50
!       ELSE
!           jmax = 100
!       END IF
!       numstap = num / jmax
!       jmax = jmax + 1
! 
!       j        = 1
!       kk       = 0 + 0*ic    
!       xxi      = Kgood + 0*ic
!       Info     = 0
! 
!       DO j = 2, jmax, 1
!           num = (j-1) * numstap
!           kk  = xxi
!           IF (j < (jmax-4)) THEN
!           Call DZANLY(DFKRAN,0.01,0.01,0,1,1,kk,100,xxi,Info)
!           ELSE
!           Call DZANLY(DFKRAN,0.01,0.01,0,1,1,kk,400,xxi,Info)
!           ENDIF
!       END DO
! 
!       kmudD = xxi
! 
! 
! END SUBROUTINE DARGAND



! !****************************************************************
! ! 
! REAL(8) FUNCTION DFKRANnu0(kr)
! 
! !****************************************************************
! 
! !     (calculates F for kr)
! !     (DFKRANnu0 is reduction of DFKRAN for the case num = 0)
! 
!       USE DMUDVARS
! 
!       real(8), intent(in)    :: kr
!       real(8)                :: K
!       real(8)                :: coshkd, sinhkd, coshkh, sinhkh
!       real(8)                :: term4, term3, term2, term1, term0, R
! 
! !     m=(1-1*ic)*sqrt(Omega/2/num)
! 
!       K = kr
! 
!       coshkd=(exp(K*D)+exp(-K*D))/2
!       sinhkd=(exp(K*D)-exp(-K*D))/2
!       coshkh=(exp(K*H)+exp(-K*H))/2
!       sinhkh=(exp(K*H)-exp(-K*H))/2
! 
! !     coshmd=(cdexp(m*D)+cdexp(-m*D))/2
! !     sinhmd=(cdexp(m*D)-cdexp(-m*D))/2
! !     coshmh=(cdexp(m*H)+cdexp(-m*H))/2
! !     sinhmh=(cdexp(m*H)-cdexp(-m*H))/2
! 
!       !NB: H=waterdiepte
!       !D=bodemlaagdikte
!       !precies anders als in DeWit(1995)
! 
!       term4 = + Rhom     *coshkh/K &
!               + Rhow     *sinhkh*D
!       term2 = - Rhom*G*K *coshkh*D &
!               - Rhom*G   *sinhkh
!       term0 = - K**2*G**2*sinhkh*Rhow*D &
!               + K**2*G**2*sinhkh*D*Rhom 
!                
!       ! De daadwerkelijke determinant
!       R       = + term4*Omega**4 &
!                 + term2*Omega**2 &
!                 + term0*Omega**0
! 
! 
!       DFKRANnu0 = R
!  
! END FUNCTION DFKRANnu0



!****************************************************************
!
SUBROUTINE KDALR1978(kmudS,omegaS,GS,hwS,hmS,rhowS,rhomS,nuwS,numS)     
!
!****************************************************************


      implicit none
      
      real(4), intent(in)     :: omegaS,GS,hwS,hmS,rhowS,rhomS,nuwS,numS
      complex(4), intent(out) :: kmudS
      
      real(8)                 :: omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD
      complex(8)              :: kmudD
      
      ! Single precision input parameters are converted into double precision
      omegaD  = omegaS
      GD      = GS
      hwD     = hwS
      hmD     = hmS
      rhowD   = rhowS
      rhomD   = rhomS
      nuwD    = nuwS
      numD    = numS
      
      CALL DKDALR1978(kmudD,omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD)
      
      ! Double precision output parameters are converted into single precision
      kmudS       = kmudD

END SUBROUTINE KDALR1978



!****************************************************************
!
SUBROUTINE DKDALR1978(kmudD,omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD)
!
!****************************************************************


      USE DMUDVARS         !Needed to pass the variables to DFDALR

      real(8), intent(in)     :: omegaD,GD,hwD,hmD,rhowD,rhomD,nuwD,numD
      complex(8), intent(out) :: kmudD
      
      ! settings
      complex(8), parameter  :: IC=(0.,1.)
      real(8), parameter     :: pi = 3.141592653589793259
      
      ! Declarations specially aimed for DZANLY:
      complex*16             :: kk                ! Starting value of iteration
      integer                :: Info              ! number of iteration needed to fulfill criterium
      complex*16             :: Xxi, checkDALR    ! final result of iteration
      
      omega  = omegaD
      G      = GD    
      hw     = hwD
      H      = hwD
      hm     = hmD
      D      = hmD
      rhow   = rhowD
      rhom   = rhomD
      nuw    = nuwD
      num    = numD
      
      
      ! Determination of Starting Value
      kk          = DSV(omega,g,hw,hm,rhow,rhom,nuw,num)
      
      ! Iteration Procedure with DZANLY, give back kmudD
      CALL Muller(DFDALR,0.01,0.01,0,1,1,kk,400,xxi,Info)
      kmudD     = xxi
      checkDALR = DFDALR(kmudD)
!      if (real(checkDALR) > 1E-2 .OR. imag(checkDALR) > 1E-2) then
!          write(*,*) 'checkDALR  = ', checkDALR
!      endif

END SUBROUTINE DKDALR1978



!*******************************************************************
! 
    COMPLEX*16 FUNCTION DFDALR (K)
!
!*******************************************************************

!    (calculates F for combinations of kr and ki)
!    (FDALR has been taken from J.Cornelisse(94))
!    (NB: This function has not been checked seperatedly)


      USE DMUDVARS

      complex*16          :: A(4), B(4), L(2), M(2), Xi
!     real(8)             :: G 
      complex*16          :: I, K, P, Q, R, Ex1, Ex2 
      complex*16          :: coshkd, sinhkd, coshkh, sinhkh 
      complex*16          :: C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, CC0

      
      ! Declarations connected only to FDALR
      real, parameter :: Zeta   = 0.1 ! Probably needed to calculate the constants, 
                                      ! but in my opinion not needed for a DR!

 
      I = cdsqrt(dcmplx(-1.0D00,0D00)) 
      G = 9.81231 
 
      coshkd = (cdexp(K*D)+cdexp(-K*D))/2 
      sinhkd = (cdexp(K*D)-cdexp(-K*D))/2 
      coshkh = (cdexp(K*H)+cdexp(-K*H))/2 
      sinhkh = (cdexp(K*H)-cdexp(-K*H))/2 
 
      L(1) = cdsqrt(K**2-I*Omega/nuw) 
      L(2) = cdsqrt(K**2-I*Omega/num) 
 
      M(1) = I*Omega*rhow/K-2*rhow*nuw*K 
      M(2) = I*Omega*rhom/K-2*rhom*num*K 
 
      P    = sinhkd-L(2)/K*coshkd 
      Q    = coshkd-L(2)/K*sinhkd 
 
      C0   = -I*Omega*rhow*L(1)/(K*K) 
      C1   = G*(rhom-rhow)/(I*Omega)-2*L(2)*(rhom*num-   &
             rhow*nuw)-I*Omega*rhow*L(2)/(K*K) 
      C2   = P*(M(1)-M(2))-Q*(rhom-rhow)*G/(I*Omega) 
      C3   = -I*Omega*rhow/(K*K) 
      C4   = 2*rhow*nuw-rhom*num*(1+L(2)*L(2)/(K*K)) 
      C5   = 2*Q*(rhom*num-rhow*nuw) 
      C6   = L(1)/K*sinhkh-coshkh 
      C7   = L(2)/K*sinhkh+coshkh 
      C8   = -P*sinhkh-Q*coshkh 
      C9   = 2*nuw*K*K-I*Omega 
 
      CC0  = (L(1)*C5-C2)/(C1-L(1)*C4) 
 
      B(4) = C9/(-C6*(C1*CC0+C2)/C0+C7*CC0+C8)*Zeta 
      B(3) = CC0*B(4) 
      A(4) = (-C1*CC0-C2)/C0*B(4) 
 
      Xi   = (B(3)-Q*B(4))/(-I*Omega) 
 
      A(1) = L(1)/K*A(4)+L(2)/K*B(3)-P*B(4) 
      A(2) = -A(4)+B(3)-Q*B(4) 
      A(3) = -2*nuw*K*K*Zeta 
 
      B(1) = L(2)/K*B(4) 
      B(2) = -B(4) 
 
      R    = (L(1)/K*coshkh-sinhkh)*A(4)+(L(2)/K*coshkh+sinhkh)*B(3)- &
             (P*coshkh+Q*sinhkh)*B(4)+(4*rhow*nuw*nuw*K*K*L(1)-       &
             rhow*G)/M(1)*Zeta 
 
      Ex1  = cdexp(-L(1)*H) 
      Ex2  = cdexp(-L(2)*D) 
 
      DFDALR = R 
 END FUNCTION DFDALR



!****************************************************************
!
COMPLEX FUNCTION NG2000 (OmegaS,gS,hwS,hmS,rhowS,rhomS,nuwS,numS)
!
!****************************************************************

      !Wrapper to call double precision function DNG2000
      !with single precision input and output arguments
      
      REAL(4)   , intent(in) :: OmegaS,gS,hwS,hmS,rhowS,rhomS,nuwS,numS
      REAL(8)                :: Omega, g, hw ,hm ,rhow ,rhom ,nuw ,num  
      complex(4), parameter  :: IC     = (0.,1.) ! complex unit
      complex(8)             :: complexdouble
      
      Omega         = OmegaS
      g             = gS
      hw            = hwS   
      hm            = hmS   
      rhow          = rhowS 
      rhom          = rhomS 
      nuw           = nuwS  
      num           = numS  
      
      
      complexdouble = DNG2000(Omega,g,hw,hm,rhow,rhom,nuw,num)
      
      NG2000        = real(complexdouble) + &
                      imag(complexdouble)*IC
      
      !write(*,*) complexdouble, NG2000
        
END FUNCTION NG2000



!*********************************************************************
! 
    COMPLEX(8) FUNCTION DNG2000(Omega,g,hw,hm,rhow,rhom,nuw,num)
! 
!*********************************************************************

! (calculates analytically the complex k's according to Ng(2000)) 

      real(8), intent(in)      :: Omega,g,hw,hm,rhow,rhom,nuw,num
      real(8)                  :: dBLm, dBLw, eps, zdeta
      real(8)                  :: B1, B2, B3, ReB, ImB
      real(8)                  :: k1
      complex(8)               :: B, k2
      complex(8), parameter    :: ic     = (0.0, 1.0)


      eps        = rhow/rhom
      dBLm       = sqrt(2*num/Omega)
      dBLw       = sqrt(2*nuw/Omega)
      zdeta      = sqrt(num/nuw)   
      k1         = DGUO2002  (Omega, g, hw)
      

      B1      = +eps*(-2.0*eps**2.0+2.0*eps-1.0-zdeta**2.0)*sinh(hm/dBLm)*cosh(hm/dBLm)                          &
                -eps**2.0*zdeta*(cosh(hm/dBLm)**2.0+sinh(hm/dBLm)**2.0)                                          &
                -(eps**2.-1.0)**2.*zdeta*(cosh(hm/dBLm)**2.*cos(hm/dBLm)**2.+sinh(hm/dBLm)**2.*sin(hm/dBLm)**2.) &
                -2.*eps*(1.-eps)*(zdeta*cosh(hm/dBLm)+eps*sinh(hm/dBLm))*cos(hm/dBLm)
      B2      = +eps*(-2.*eps**2.+2.*eps-1.+zdeta**2)*sin(hm/dBLm)*cos(hm/dBLm)                                  &
                -2.*eps*(1.-eps)*(zdeta*sinh(hm/dBLm)+eps*cosh(hm/dBLm))*sin(hm/dBLm)
      B3      = +(zdeta*cosh(hm/dBLm)+eps*sinh(hm/dBLm))**2.*cos(hm/dBLm)**2.                                    &
                +(zdeta*sinh(hm/dBLm)+eps*cosh(hm/dBLm))**2.*sin(hm/dBLm)**2.

      ReB     = k1*dBLm*(B1-B2)/(2.*B3)+eps*k1*hm
      ImB     = k1*dBLm*(B1+B2)/(2.*B3)
      B       = ReB + ic*ImB

      k2      = -B*k1/(sinh(k1*hw)*cosh(k1*hw)+k1*hw)
      DNG2000 = k1+k2

END FUNCTION DNG2000



!****************************************************************
! 
    COMPLEX FUNCTION DCTANH(z)
!
!****************************************************************

      ! (auxilliary function)

      COMPLEX(8), INTENT(IN) :: z

      ! does > hold for IEEE +/-Inf ?

      if     (EXP(real(Z)) >  0.1*huge(real(Z))) then
        DCTANH             = +1.0000000000000000000d0
      elseif (EXP(real(Z)) < -0.1*huge(real(Z))) then
        DCTANH             = -1.0000000000000000000d0
      else
        ! the evaluation below becomes nan for too large Z
        DCTANH = (EXP(Z)-EXP(-Z)) / (EXP(Z)+EXP(-Z))
      endif


END FUNCTION DCTANH

END MODULE Dispersion_Relations

