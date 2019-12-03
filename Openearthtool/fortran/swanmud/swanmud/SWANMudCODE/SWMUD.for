!
!     SWAN mud module
!
!   --|-----------------------------------------------------------|--
!     | WL | Delft Hydraulics                                     |
!     | P.O. Box 177, 2600 MH  Delft, The Netherlands             |
!     |                                                           |
!     | Programmer: Gerben J. de Boer & Wouter M. Kranenburg      |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!     $Id$ 
!     $Date$ 
!     $Author$ 
!     $Revision$ 
!     $HeadURL$ 
!     $Keywords: $. 
!     Access via https://public.deltares.nl/display/OET/SWANmud.
!
!  0. Authors
!
!     40.61mud: Gerben de Boer & Wouter Kranenburg
!
!  1. Updates
!
!     40.61mud, Oct. 15: Original.
!     40.61mud, 08/04/01: Collect all SWAN-specific routines for mud
!     40.61mud, 09/04: repaired bug in Smud=0 when Sbot > Smud
!     40.61mud, 09/05: repaired bug in refraction in SPROSDM, let neighbours (for dk/dm) depend on sweep
!
!  2. Purpose
!
!     Collect all SWAN-specific routines for mud,
!     all generic non-SWAN-specific mud routines are in
!     - Dispersion_Relations.f90 (main module) contains DMUDVARS (hidden module)
!     - EnDissTerms.f90
!
!  8. Contains subroutines
!
!     SWMUDK:   Determine complex wave number for 2L fluid mud system.   (gade or delft).
!     SWAPARM:  Computes group velocity with or without mud numerically. (~ SWAPAR).
!     SPROSDM:  Computes CAS en CAD, with general formula for mud.       (~ SPROSD).
!     SWMUDD:   Determine extra damping of waves over fluid mud banks.
!     SKWAVM:   Determine complex wave number for damping waves over mud banks De Wit (1994).
!     SWKMEAN:  Determine frequency weighted/averaged wave length.
!
!****************************************************************
!
      SUBROUTINE SWMUDK(DEP2,MUDL2,SPCSIG,ISSTOP,IX,IY,KMUDR,KMUDI)         !40.61mud
!
!****************************************************************
!
      USE SWCOMM2 ! variable VARMUD, DEPMIN
      USE SWCOMM3 ! variable MCGRD
      USE Dispersion_Relations
      USE EnDissTerms
!
      IMPLICIT NONE
!
!
!   --|-----------------------------------------------------------|--
!     | WL | Delft Hydraulics                                     |
!     | P.O. Box 177, 2600 MH  Delft, The Netherlands             |
!     |                                                           |
!     | Programmer: Gerben J. de Boer                             |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!
!  0. Authors
!
!     40.31:  Jacco Groeneweg
!     40.55:  Marcel Zijlema
!     40.61:  Marcel Zijlema
!     40.61mud: Gerben de Boer
!
!  1. Updates
!
!     40.31, Oct. 07: Originally subroutine SWMUD by J. Groeneweg: 
!                     Replaced calculation dispersion relations to SWMUDK,
!                     Replaced source term calculation to SWMUDD.
!
!  2. Purpose
!
!     Determine complex wave number for 2L fluid mud system. (Gade and DELFT)
!
!  3. Method
!
!  4. Argument variables
!
!     DEP2        water depth, interpreted as non-viscous water layer
!     MUDL2       mud layer thickness
!     KMUDR       Average wave length with mud real part for output purp.
!     KMUDI       Average wave length with mud imag part for output purp.
!     SPCSIG      relative frequencies in spectral domain
!     IX,IY       grid cell indices                                      
!     ISSTOP      maximum counter of wave component in frequency
!                 space that is propagated
!     FIRST       If this is the first time this function is called

      INTEGER ISSTOP, IX, IY, IC
      REAL     DEP2  (MCGRD),
     &         MUDL2 (MCGRD)
      REAL  :: KMUDR (MCGRD,MSC)
      REAL  :: KMUDI (MCGRD,MSC)
      REAL     SPCSIG(      MSC)
!
!  5. Parameter variables
!
      COMPLEX    CUNIT
      PARAMETER (CUNIT=(0.,1.))

!
!  6. Local variables
!
!     GD    :     factor equals gravity acceleration times depth
!     ID    :     counter of the spectral direction
!     IDDUM :     counter
!     IS    :     counter
!     KMUD  :     complex wave number to be used in computation
!                 of fluid mud-induced wave dissipation
!     THICKM:     thickness of fluid mud layer
!
      INTEGER ID, IDDUM, IS
      INTEGER disperr, disperi,source, cg
      REAL    GD, THICKM,RHOM, RHO0,XNUM
      COMPLEX KMUD(MSC)
      COMPLEX KMUD1
!
!  8. Subroutines used
!
!     GUO2002
!     GADE1958
!     ...KDELFT
!
!  9. Subroutines calling
!
!     SWOMPU
!
! 12. Structure
!
! 13. Source text
!

      RHOM    = PMUD(2) 
      RHO0    = PMUD(3) 
      XNUM    = PMUD(4) 
!     layer   = PMUD(5) 
      disperr = PMUD(6)
      disperi = PMUD(7)
      source  = PMUD(8)
      cg      = PMUD(9)

!     write(*,*) 'PMUD =', PMUD

!     Do also for ALL other grid cells in stencil, this routine is only called once.
!     We do this here because adjacent k values are already needed for spatial derivative terms.
!     so they are available after right from the start.

! First value does not seem to get a value

      DO IC = 2, MCGRD !ICMAX     
      
        IF ( DEP2(IC) .LE. DEPMIN) THEN
         KMUD = -1 + 0*CUNIT ! for all frequencies, same as done in SWAPAR, 
                             ! and done again in SWAPARM (and cg=0)
        ELSE

         GD     = GRAV * DEP2(IC) !KCGRD(IC))
!
         IF (VARMUD) THEN
            THICKM = MUDL2(IC) !KCGRD(IC))
         ELSE
            THICKM = PMUD(5)
         END IF
!
!        --- compute complex wave number
!            Remember to use a phase difference and amplitude ratio of internal 
!            and external wave that are consistent with the dispersion relation
!            Different methods are implemented
!
!           -1 = MUDFIle      load external file
!            0 = Guo(2002),   approximation of regular dispersion equation, no mud
!            1 = Gade(1958),  viscous two-layer model for shallow water only
!            2 = DeWit(1995), viscous two-layer model for 
!                             non-hydr & non-visc water layer and hydr & visc mud layer
!            3 = DELFT(2008), viscous two-layer model for 
!                             non-hydr & non-visc water layer and hydr & visc mud layer
!            4 = Dalr(1978),  viscous two-layer model for non-hydr & visc water and mud layer
!                             valid for hm > viscous boundary layer
!            5 = Ng(2000),    viscous two-layer model for non-hydr & visc water and mud layer
!                             valid for hm <= viscous boundary layer & hm << hw
!                             analytical approx. for 2nd complete model of Dalr(1978)
         KMUD = 0 + 0*CUNIT
!

        IF (THICKM < tiny(THICKM)) THEN
          DO IS = 1, MSC   ! ISSTOP is still zero here

              KMUD(IS) = GUO2002(SPCSIG(IS),GRAV,DEP2(IC)) + 0*CUNIT

          ENDDO
        ELSE

!           --- method 0: No mud : Guo(2002)
            IF     (disperr==0 .or. disperi==0) THEN
              DO IS = 1, MSC 
               KMUD(IS) = GUO2002(SPCSIG(IS),GRAV,DEP2(IC)) + 0*CUNIT
              ENDDO
            ENDIF
!
!           --- method 1: Gade(1958)!
            IF (disperr==1 .or. disperi==1) THEN
              DO IS = 1, MSC 
              KMUD(IS)    = GADE1958(SPCSIG(IS)    ,GRAV  ,
     &                               DEP2(IC)      ,THICKM,
     &                               RHO0          ,RHOM  ,
     &                               1e-6          ,XNUM  )
              ENDDO
            ENDIF
!
!           --- method 2: DeWit(1995)
            IF (disperr==2 .or. disperi==2) THEN
              DO IS = 1, MSC       
                   CALL KDEWIT1995(KMUD(IS),
     &                        SPCSIG(IS)   ,GRAV  ,
     &                        DEP2(IC)     ,THICKM,
     &                        RHO0         ,RHOM  ,
     &                        1e-6         ,XNUM  )
              ENDDO
            ENDIF
!
!           --- method 3: DELFT(2008)
            IF (disperr==3 .or. disperi==3) THEN
              DO IS = 1, MSC       
                   CALL KDELFT2008(KMUD(IS),
     &                        SPCSIG(IS)   ,GRAV  ,
     &                        DEP2(IC)     ,THICKM,
     &                        RHO0         ,RHOM  ,
     &                        1e-6         ,XNUM  )
               ENDDO
            ENDIF
!
!           --- method 4: Dalr(1978)
            IF (disperr==4 .or. disperi==4) THEN
              DO IS = 1, MSC       
                   CALL KDALR1978(KMUD(IS),
     &                        SPCSIG(IS)   ,GRAV  ,
     &                        DEP2(IC)     ,THICKM,
     &                        RHO0         ,RHOM  ,
     &                        1e-6         ,XNUM  )
               ENDDO
            ENDIF
!
!           --- method 5: Ng(2000)
            IF (disperr==5 .or. disperi==5) THEN
              DO IS = 1, MSC       
              KMUD(IS)    = NG2000(SPCSIG(IS)      ,GRAV  ,
     &                             DEP2(IC)      ,THICKM,
     &                             RHO0          ,RHOM  ,
     &                             1e-6          ,XNUM  )  
               ENDDO
            ENDIF

           !write(*,*) 'LET OP SWAPARM'
           !  DO IS = 1, MSC       
           !  KMUD(IS) = 1*real(KMUD(IS)) + imag(KMUD(IS))*CUNIT
           !  ENDDO
        ENDIF !IF (THICKM < tiny(THICKM)) THEN

!
!        --- Copy to output array
!
        DO IS = 1, MSC ! ISSTOP is still zero here

             !KMUDR (KCGRD(IC),IS) = REAL(KMUD(IS))
             !KMUDI (KCGRD(IC),IS) = IMAG(KMUD(IS))
              KMUDR (IC,IS) = REAL(KMUD(IS))
              KMUDI (IC,IS) = IMAG(KMUD(IS))

        END DO ! IS = 1, MSC ! ISSTOP is still zero here

        ENDIF ! ( DEPLOC .LE. DEPMIN) THEN

      ENDDO ! IC = 1, ICMAX

      RETURN
      END SUBROUTINE SWMUDK
!****************************************************************
!
      SUBROUTINE SWAPARM( DEP2, KWAVE, CGO, SPCSIG ,KMUDR,KMUDI)
!
!****************************************************************
!
      USE SWCOMM3                                                         40.41
      USE SWCOMM4                                                         40.41
      USE OCPCOMM4                                                        40.41
!
!
!   --|-----------------------------------------------------------|--
!     | Delft University of Technology                            |
!     | Faculty of Civil Engineering                              |
!     | Environmental Fluid Mechanics Section                     |
!     | P.O. Box 5048, 2600 GA  Delft, The Netherlands            |
!     |                                                           |
!     | Programmers: R.C. Ris, N. Booij,                          |
!     |              IJ.G. Haagsma, A.T.M.M. Kieftenburg,         |
!     |              M. Zijlema, E.E. Kriezi,                     |
!     |              R. Padilla-Hernandez, L.H. Holthuijsen       |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!
!  0. Authors
!
!     30.72:  IJsbrand Haagsma
!     30.81:  Annette Kieftenburg
!     30.82:  IJsbrand Haagsma
!     40.13:  Nico Booij
!     40.41:  Marcel Zijlema
!     40.41G: Gerben J. de Boer
!
!  1. Updates
!
!     20.96,  Jan. 96: Computation of CGO etc. taken out of ID loop
!     30.72,  Feb. 98: Introduced generic names XCGRID, YCGRID and SPCSIG for SWAN
!     30.81,  Dec. 98: Argument list KSCIP1 adjusted
!     30.82,  July 99: Corrected argumentlist KSCIP1
!     40.13,  Oct. 01: single call to KSCIP1 instead of loop over call
!                      N and ND declared as arrays
!                      loop over IC now inside routine SWAPAR
!     40.41,  Aug. 04: CG moved to DSPHER and code optimized
!     40.41,  Oct. 04: common blocks replaced by modules, include files removed
!     40.41G, Oct 07: Rewritten for mud layer:
!                     - Select relevant k values from k(x,y,msc) array
!                     - Calculate CGO numerically
!
!  2. Purpose
!
!     computes the wave parameters K and CGO in the nearby
!     points, depending of the sweep direction.
!     The nearby points are indicated with the index IC (see
!     FUNCTION ICODE(_,_)
!
!  3. Method
!
!     The wave number K(IS,iC) has been determined previously for mud in SWMUDK.
!
!     The group velocity CGO in the case without current is equal to the numerical
!     approximation domega/dk.
!
!  4. Argument variables
!
!     SPCSIG: Relative frequencies in computational domain in sigma-space 30.72
!
      REAL    SPCSIG(MSC)                                                 30.72
!
!        INTEGERS:
!        ---------
!
!        IX          Counter of gridpoints in x-direction
!        IY          Counter of gridpoints in y-direction
!        IS          Counter of relative frequency band
!        ID          Counter of directional distribution
!        ICMAX       Maximum array size for the points of the molecule
!        MXC         Maximum counter of gridppoints in x-direction
!        MYC         Maximum counter of gridppoints in y-direction
!        MSC         Maximum counter of relative frequency
!        MDC         Maximum counter of directional distribution
!
!        REALS:
!        ---------
!
!        GRAV        Gravitational acceleration
!
!        one and more dimensional arrays:
!        ---------------------------------
!
!        CGO       2D    Group velocity as function of X and Y and S in the
!                        direction of wave propagation in absence of currents
!        DEP2      2D    Depth as function of X and Y at time T
!        KWAVE     2D    wavenumber as function of the relative frequency S
!
!     5. SUBROUTINES CALLING
!
!        SWOMPU
!
!     6. SUBROUTINES USED
!
!        ---
!
!     7. Common blocks used
!
!OMP      INCLUDE 'tpcomm.inc'                                                40.41
!
!     8. REMARKS
!
!     9. STRUCTURE
!
!   -------------------------------------------------------------
!   If depth is negative ( D(IX,IY) <= 0), then,
!     For every point in S and D-direction do,
!       Give wave parameters default values :
!       CGO(IS,IC)  =  0.    ,  {group velocity in absence of a current}
!       K(IS,IC)    = -1.    ,                             {wave number}
!     ---------------------------------------------------------
!   Else
!         Then for every IS do
!           call KSCIP1 to compute wave number and group velocity
!         ------------------------------------------------------
!   end if
!   ------------------------------------------------------------
!   End of SWAPAR
!   ------------------------------------------------------------
!
!     10. SOURCE
!
!************************************************************************
!
!        IC          Dummy variable: ICode gridpoint:
!                      IC = 1  Top or Bottom gridpoint
!                      IC = 2  Left or Right gridpoint
!                      IC = 3  Central gridpoint
!                    Whether which value IC has, depends of the sweep
!                    If necessary IC can be enlarged by increasing
!                    the array size of ICMAX
! !! GJdB: NOT CORRECT: THE SWEEP DIRECTION IS NOT TAKEMN INTO ACCOUNT UNTILL SPROSD ROUTINE
      INTEGER      IC    ,IS    ,ID
      REAL      :: N(1:MSC), ND(1:MSC)                                    40.13
      INTEGER disperr, disperi,source, cg                                !40.61mud
!
      REAL         DEP2  (    MCGRD),
     &             KWAVE (MSC,ICMAX),
     &             KWAVEM(MSC,ICMAX),
     &             CGO   (MSC,ICMAX),
     &             CGO2  (MSC,ICMAX),
     &             CGOM  (MSC,ICMAX)
      REAL      :: KMUDR (MCGRD,MSC)                                     !40.61mud
      REAL      :: KMUDI (MCGRD,MSC)                                     !40.61mud

!FIRST2 indicates whether something is called for 1st time               !40.61mud
      LOGICAL, SAVE :: FIRST2  = .true. 

!
!
      INTEGER, SAVE :: IENT=0
      IF (LTRACE) CALL STRACE (IENT,'SWAPARM')
!
      DO IC = 1, ICMAX                                                    40.13
        INDX   = KCGRD(IC)
        DEPLOC = DEP2(INDX)
        IF ( DEPLOC .LE. DEPMIN) THEN
!         *** depth is negative ***
          DO 50 IS = 1, MSC
             KWAVE (IS,IC) = -1.                                          40.41
             KWAVEM(IS,IC) = -1.                                         !40.61mud
             CGO   (IS,IC) = 0.                                           40.41
             CGOM  (IS,IC) = 0.                                          !40.61mud
 50       CONTINUE
        ELSE
!       *** Replaced call to KSCIP1 with code below***

          CALL KSCIP1 (MSC, SPCSIG, DEPLOC, KWAVE(1,IC) ,                 40.41
     &                 CGO(1,IC), N, ND)                                  40.41

          KWAVEM(1:MSC,IC) = KMUDR(INDX,1:MSC)
        ! KWAVEM is the real part of kGuo,kGade,kDW,kDelft,kDalr or kNg 
        ! KWAVE  is the real wave number as normally used in SWAN


        ! cgroup = domega / dk. Take central derivative,
        ! except at edges of frequency array, where we take upwind.
        ! Apply this to KWAVE as well and compare with CGO to test the central scheme.
        !
        !if (IC==1) THEN
        !write(*,*) 'IS,K,Km,Cg,Cg discr.,Cgm discr.'
        !ENDIF

        DO IS = 1, MSC

          IF     (IS==1)  THEN                                           !40.61mud
          CGO2(IS,IC)= (SPCSIG(IS+1   ) - SPCSIG(IS     ))/              !40.61mud
     &                 (KWAVE (IS+1,IC) - KWAVE (IS  ,IC))               !40.61mud
          ELSEIF (IS==MSC)  THEN                                         !40.61mud
          CGO2(IS,IC)= (SPCSIG(IS     ) - SPCSIG(IS-1   ))/              !40.61mud
     &                 (KWAVE (IS  ,IC) - KWAVE (IS-1,IC))               !40.61mud
          ELSE                                                           !40.61mud
          CGO2(IS,IC)= (SPCSIG(IS+1   ) - SPCSIG(IS-1   ))/              !40.61mud
     &                 (KWAVE (IS+1,IC) - KWAVE (IS-1,IC))               !40.61mud
          ENDIF

          IF     (IS==1)  THEN                                           !40.61mud
          CGOM(IS,IC)= (SPCSIG(IS+1   ) - SPCSIG(IS     ))/              !40.61mud
     &                 (KWAVEM(IS+1,IC) - KWAVEM(IS  ,IC))               !40.61mud
          ELSEIF (IS==MSC)  THEN                                         !40.61mud
          CGOM(IS,IC)= (SPCSIG(IS     ) - SPCSIG(IS-1   ))/              !40.61mud
     &                 (KWAVEM(IS  ,IC) - KWAVEM(IS-1,IC))               !40.61mud
          ELSE                                                           !40.61mud
          CGOM(IS,IC)= (SPCSIG(IS+1   ) - SPCSIG(IS-1   ))/              !40.61mud
     &                 (KWAVEM(IS+1,IC) - KWAVEM(IS-1,IC))               !40.61mud
          ENDIF

          if (IC==-1) THEN
          write(*,'(i3,5(f7.4,a),f7.5,a)') IS,KWAVE (IS,1),' ',
     &                                        KWAVEM(IS,1),'|',
     &                                        CGO   (IS,1),' ',
     &                                        CGO2  (IS,1),' ',
     &                                        CGOM  (IS,1),'|',
     &                                        KMUDI (INDX,IS)
          endif

        ENDDO ! IS = 1, MSC

        disperr = PMUD(6)                                               !40.61mud
        disperi = PMUD(7)                                               !40.61mud
        source  = PMUD(8)                                               !40.61mud
        cg      = PMUD(9)                                               !40.61mud

!         IF (first2) THEN
!            write(*,*) 'In SWAPARM, cg = ', cg
!            first = .false.
!         ENDIF

        IF (cg==0) THEN
          CGO   = CGO
          KWAVE = KWAVE  
        ELSE
          CGO   = CGOM
          KWAVE = KWAVEM    
        ENDIF
 
!       IF (cg =/0) adjust KWAVE to make sure that also the other kinematics are 
!       influenced by mud-adjusted wave number

        ENDIF

!       IS = 50
!          write(*,'(2i3,5(f7.4,a),f7.5,a)') IS,cg,KWAVE (IS,1),' ',
!     &                                            KWAVEM(IS,1),'|',
!     &                                            CGO   (IS,1),' ',
!     &                                            CGO2  (IS,1),' ',
!     &                                            CGOM  (IS,1),'|',
!     &                                            KMUDI (INDX,IS)
!
!
        IF ( TESTFL .AND. IC .EQ. 1 .AND. ITEST.GE. 100 ) THEN
          WRITE(PRINTF,6021) DEP2(KCGRD(IC))
 6021     FORMAT(' SWAPARM:                   DEP :',E12.4, /,
     &           '   IS          K           CGO                 :')      40.00
          DO 105 IS = 1, MSC
            WRITE(PRINTF,6019) IS, KWAVE(IS,IC), CGO(IS,IC)               40.41 40.00
 6019       FORMAT(I4, 2E12.4)                                            40.41 40.00
 105      CONTINUE
        END IF
      ENDDO                                                               40.13
!
!     end of subroutine SWAPARM
      RETURN
      END SUBROUTINE SWAPARM
!****************************************************************
!
      SUBROUTINE SPROSDM(SPCSIG     ,KWAVE      ,CAS        ,             40.03
     &                   CAD        ,CGO        ,                         30.80
     &                   DEP2       ,DEP1       ,ECOS       ,
     &                   ESIN       ,UX2        ,UY2        ,
     &                   SWPDIR     ,IDCMIN     ,IDCMAX     ,
     &                   COSCOS     ,SINSIN     ,SINCOS     ,             30.80
     &                   RDX        ,RDY        ,                         30.80
     &                   CAX        ,CAY        ,ANYBIN     ,             30.80
     &                   KGRPNT     ,XCGRID     ,YCGRID     ,             30.80
     &                   KSX        ,KSY        ,KMUDR      )
!
!****************************************************************
!
      USE SWCOMM2                                                         40.41
      USE SWCOMM3                                                         40.41
      USE SWCOMM4                                                         40.41
      USE TIMECOMM                                                        40.41
      USE OCPCOMM4                                                        40.41
      USE M_PARALL                                                        40.31
      USE M_DIFFR                                                         40.21
!
      IMPLICIT NONE
!
!OMP      INCLUDE 'tpcomm.inc'                                                40.41
!
!
!   --|-----------------------------------------------------------|--
!     | Delft University of Technology                            |
!     | Faculty of Civil Engineering                              |
!     | Environmental Fluid Mechanics Section                     |
!     | P.O. Box 5048, 2600 GA  Delft, The Netherlands            |
!     |                                                           |
!     | Programmers: R.C. Ris, N. Booij,                          |
!     |              IJ.G. Haagsma, A.T.M.M. Kieftenburg,         |
!     |              M. Zijlema, E.E. Kriezi,                     |
!     |              R. Padilla-Hernandez, L.H. Holthuijsen       |
!     |              W.M.Kranenburg                               |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!
!  0. Authors
!
!     30.72: IJsbrand Haagsma
!     30.80: Nico Booij
!     40.03: Nico Booij
!     40.02: IJsbrand Haagsma
!     40.14: Annette Kieftenburg
!     40.21: Agnieszka Herman
!     40.30: Marcel Zijlema
!     40.41: Marcel Zijlema
!     40.61: Wouter Kranenburg
!
!  1. Updates
!
!     30.72, Feb. 98: Introduced generic names XCGRID, YCGRID and SPCSIG for SWAN
!     30.80, Nov. 98: Provision for limitation on Ctheta (refraction)
!     30.80, Aug. 99: SWCOMM3.INC included
!     30.80, Sep. 99: SWCOMM2.INC included, limitation modified
!     40.03, Dec. 99: for directions outside the current sweep the depth and
!                     current gradients are computed using the gradient at the
!                     proper side of the grid point.
!                     argument KGRPNT added.
!                     argument IC removed (is always 1)
!                     argument DT removed, TIMECOMM.INC included
!                     code completely revised
!     40.02, Jan. 00: Introduction limiter dependent on Cx, Cy, Dx and Dy
!     40.02, Sep. 00: Corrected order of handling sweeps
!     40.02, Sep. 00: Limiter on refraction only activated when IREFR=-1
!     40.14, Nov. 00: Land points excluded (bug fix)
!     40.21, Aug. 01: adaption of velocities in case of diffraction
!     40.30, Mar. 03: correcting indices of test point with offsets MXF, MYF
!     40.41, Oct. 04: common blocks replaced by modules, include files removed
!     40.61, Mar. 08: more general formulation of refraction to allow for mud-induced refr.
!
!  2. Purpose
!
!     computes the propagation velocities of energy in S- and
!     D-space, i.e., CAS, CAD, in the presence or absence of
!     currents, for the action balance equation. Adapted for change
!     in CAD in case of mud.
!     NOTE: influence of mud on CAS not yet investigated(08/03/08)
!
!  3. Method
!
!     The next equation are solved numerically
!
!           @S   @S   @D   _     @D   @D          _   @U
!     CAS = -- = -- [ -- + U . ( -- + --) ] - CGO K . --
!           @T   @D   @T         @X   @Y              @s
!
!           with:   @S       KS
!                   -- =  ---------
!                   @D    sinh(2KD)
!
!           @D      S      @D         @D           @Ux   @Uy
!     CAD = -- = ------- [ --sin(D) - --cos(D)] + [--- - ---] *
!           @T  sinh(2KD)  @X         @Y            @X   @Y
!
!                        @Uy               @Ux
!     * sin(D)cos(D) +   ---sin(D)sin(D) - ---cos(D)cos(D)
!                        @X                @Y
!
!     @D/@x appr by:   RDX(1) * (DEP(KCGRD(1)) - DEP(KCGRD(2)))
!                    + RDX(2) * (DEP(KCGRD(1)) - DEP(KCGRD(3)))
!     @D/@y appr by:   RDY(1) * (DEP(KCGRD(1)) - DEP(KCGRD(2)))
!                    + RDY(2) * (DEP(KCGRD(1)) - DEP(KCGRD(3)))
!     etc.
!
!     the limitation procedure is described in the system documentation.
!
!     In case of mud a more general formulation is needed:
!
!           @D      S      @D         @D           @Ux   @Uy
!     CAD = -- = ------- [ --sin(D) - --cos(D)] + [--- - ---] *
!           @T  sinh(2KD)  @X         @Y            @X   @Y
!
!
!  4. Argument variables
!
!     IDCMAX: upper theta-boundary of current sweep
!     IDCMIN: lower theta-boundary of current sweep (function of Sigma)
!     KGRPNT: grid point addresses                                        40.03
!     SWPDIR: current sweep direction
!
      INTEGER, INTENT(IN) :: IDCMIN(MSC), IDCMAX(MSC)
      INTEGER, INTENT(IN) :: KGRPNT(MXC,MYC)                              40.03
      INTEGER, INTENT(IN) :: SWPDIR,KSX,KSY
!
!     CAS   : Wave transport velocity in S-direction, function of (ID,IS,IC)
!     CAD   : Wave transport velocity in D-dirctiion, function of (ID,IS,IC)
!     CAX   : Wave transport velocity in X-direction, function of (ID,IS,IC)
!     CAY   : Wave transport velocity in Y-direction, function of (ID,IS,IC)
!     CGO   : Group velocity as function of X and Y and sigma in the
!             direction of wave propagation in absence of currents
!     DEP1  : Depth as function of X and Y at time T
!     DEP2  : (Nonstationary case) depth as function of X and Y at time T+1
!     ECOS  : Represent the values of cos(d) of each spectral direction
!     ESIN  : Represent the values of sin(d) of each spectral direction
!     KWAVE : wavenumber as function of the relative frequency sigma
!     SPCSIG: Relative frequencies in computational domain in sigma-space
!     UX2   : X-component of current velocity of X and Y at time T+1
!     UY2   : Y-component of current velocity of X and Y at time T+1
!     XCGRID: x-coordinate of comput. grid points
!     YCGRID: y-coordinate of comput. grid points
!
      REAL  :: SPCSIG(MSC)                                                30.72
      REAL  :: XCGRID(MXC,MYC), YCGRID(MXC,MYC)                           30.80
!     Changed ICMAX to MICMAX, since MICMAX doesn't vary over gridpoint   40.22
      REAL  :: CAS   (MDC,MSC,MICMAX)                                     40.22
      REAL  :: CAD   (MDC,MSC,MICMAX)                                     40.22
      REAL  :: CAX   (MDC,MSC,MICMAX)                                     30.80 40.22
      REAL  :: CAY   (MDC,MSC,MICMAX)                                     30.80 40.22
      REAL  :: CGO   (MSC,MICMAX)                                         40.22
      REAL  :: DEP2  (MCGRD)               ,
     &         KMUDR (MCGRD,MSC)           ,
     &         DEP1  (MCGRD)               ,
     &         ECOS  (MDC)                 ,
     &         ESIN  (MDC)                 ,
     &         COSCOS(MDC)                 ,
     &         SINSIN(MDC)                 ,
     &         SINCOS(MDC)
!     Changed ICMAX to MICMAX, since MICMAX doesn't vary over gridpoint   40.22
      REAL  :: KWAVE (MSC,MICMAX)                                         40.22
      REAL  :: UX2   (MCGRD)               ,
     &         UY2   (MCGRD)               ,
     &         RDX   (10)                  ,                              40.08
     &         RDY   (10)                                                 40.08
!
!        logical:
!
!        ANYBIN    i  if True component (ID,IS) is updated                30.80
!
      LOGICAL ANYBIN(MDC,MSC)                                             30.80
!
!
!     variables from common
!
!        ICUR    Indicator for current
!        ICMAX   Maximum array size for the points of the molecule
!        NSTATC  Indicator if computation is stationair
!        MXC     Maximum counter of gridppoints in x-direction
!        MYC     Maximum counter of gridppoints in y-direction
!        MSC     Maximum counter of relative frequency
!        MDC     Maximum counter of spectral directions
!
!        DYNDEP  if True depths vary with time
!
!        DT      Time step
!        RDTIM   1/DT                                                     30.80
!        PNUMS   array of numerical coefficients; used here:              30.80
!                PNUMS(17), coeff. for limitation of Ctheta               30.80
!
!     local variables
!
!        IX1,IX2,IX3   Counter of gridpoints in x-direction
!        IY1,IY2,IY3   Counter of gridpoints in y-direction
!        IS            Counter of relative frequency band
!        ID, ID1, ID2  Counter of directions
!        IDDUM         aux. counter of directions
!        II            counter
!        ISWEEP        sweep index: 2=current sweep, 1 and 3=neighbouring sweeps
!        ISWP          counter for sweeps                                 40.02
!        KCG1          grid address of the active grid point
!        KCG2, KCG3    grid addresses of two neighbouring grid points
!        SWPNGB        neighbouring sweep direction
!
      INTEGER  IENT  ,IS    ,ID    ,II    ,                               30.80
     &         SWPNGB,IDDUM ,ID1   ,ID2   ,                               30.80
     &         KCG1  ,KCG2  ,KCG3  ,ISWEEP                                30.80
      INTEGER  IX1, IY1, IX2, IY2, IX3, IY3                               40.03
      INTEGER :: ISWP                                                     40.02
      INTEGER IC, KCGI                                                    40.21
!
!     logical local variables
!
!        VALSWP        if true this sweep is valid (all corner points exist)
!
      LOGICAL    VALSWP                                                   40.03
!
!     real local variables
!
!        KD1           wavenumber * depth
!        COEF          aux. quantity
!        VLSINH        sinh of KD1
!        RDXL, RDYL    interpolation factors (see RDX and RDY in common)
!        CAST..        aux. quantities to compute Csigma
!        CADT..        aux. quantities to compute Ctheta
!        DPDX, DPDY    depth gradient
!        DUXDX,DUXDY,DUYDX,DUYDY  current velocity gradients
!
      REAL     VLSINH ,KD1   ,COEF   ,COEF2
      REAL     RDXL(2),RDYL(2),XC1   ,YC1    ,DET    ,
     &         DX2    ,DY2    ,DX3   ,DY3
      REAL     DPDX   ,DPDY   ,DUXDX ,DUXDY ,DUYDX ,DUYDY
      REAL     DKDX(MSC), DKDY(MSC)
      REAL     CAST1    ,CAST2    ,CAST3(3) ,CAST4(3) ,                   40.03
     &         CAST5    ,CAST6(3) ,CAST7(3) ,CAST8(3) ,CAST9(3) ,
     &         CADT1    ,CADT4(3) ,CADT5(3) ,CADT6(3) ,CADT7(3) ,
     &         CADT2(MSC,3)       ,CADT3(MSC,3)
      REAL  :: DLOC1, DLOC2, DLOC3
!     local depths corrected in view of stability                         40.02
      REAL  :: KLOC1(MSC), KLOC2(MSC), KLOC3(MSC)                        !40.61mud
!
!  5. Parameter variables
!
!     SWP_ARRAY: Array containing the order of sweep handling
!
      INTEGER, PARAMETER :: SWP_ARRAY(1:3) = (/2,1,3/)
!
!  8. Remarks
!
!       propagation velocity in sigma-direction:
!
!                              K(IS,IC)S            DEP2(IX,IY)-DEP1(IX,IY)
!       CAS(ID,IS,IC) = ------------------------- [ ----------------------- +
!                       sinh 2K(IS,IC)DEP2(IX,IY)            DT
!
!                           (DEP2(IX,IY) - DEP2(IX+KSX,IY)
!              + UX2(IX,IY) ------------------------------ +
!                                        DDX
!
!                           (DEP2(IX,IY) - DEP2(IX,IY+KSY)
!              + UY2(IX,IY) ------------------------------ ] - CGO(IS,IC) *
!                                        DDY
!
!                          UX2(IX,IY)-UX2(IX+KSX,IY)
!         *  [   K(IS,IC) --------------------------- cos**2(D) +
!                                    DDX
!
!                          UX2(IX,IY)-UX2(IX,IY+KSY)
!              + K(IS,IC) -------------------------- cos(D)sin(D) +
!                                    DDY
!
!                          UY2(IX,IY)-UY2(IX+KSX,IY)
!              + K(IS,IC) -------------------------- sin(D)cos(D) +
!                                    DDX
!
!                          UY2(IX,IY)-UY2(IX,IY+KSY)
!              + K(IS,IC) -------------------------- sin**2(D)        ]
!                                    DDY
!
!       -----------------------------------------------------
!       propagation velocity in theta-direction:
!
!       CAD(ID,IS,IC) =
!
!                     S                   DEP2(IX,IY)-DEP2(IX+KSX,IY)
!           ------------------------- * [ --------------------------sin(D) -
!           sinh 2K(IS,IC)DEP2(IX,IY)               DDX
!
!            (DEP2(IX,IY) - DEP2(IX,IY+KSY)
!           ------------------------------- cos(D) ]  +
!                        DDY
!
!        UX2(IX,IY)-UX2(IX+KSX,IY)   UY2(IX,IY)-UY2(IX,IY+KSY)
!    [  -------------------------- - ------------------------- ] sin(D)cos(D)+
!                 DDX                         DDY
!
!          UY2(IX,IY)-UY2(IX+KSX,IY)
!       + --------------------------- sin**2(D) -
!                   DDX
!
!          UX2(IX,IY)-UX2(IX,IY+KSY)
!         --------------------------- cos**2(D)
!                   DDY
!
!
!
!     9. STRUCTURE
!
!   ------------------------------------------------------------
!   For current sweep and two adjacent sweeps do
!       determine interpolation factors RDXL and RDYL
!       determine depth and current gradients
!   ------------------------------------------------------------
!   For each frequency do
!       determine auxiliary quantities depending on sigma
!       For each direction in the sweep and two neighbouring
!           directions do
!           If IREFR=-1
!           Then compute reduction factor for contribution due
!                to depth gradient
!           ----------------------------------------------------
!           determine sweep in which this direction is located
!           using gradients of the proper sweep determine
!           Csigma (CAS) and Ctheta (CAD)
!   ------------------------------------------------------------
!   If ITFRE=0
!   Then make values of CAS=0
!   ------------------------------------------------------------
!   If IREFR=0
!   Then make values of CAD=0
!   ------------------------------------------------------------
!
!     10. SOURCE
!
!************************************************************************
!
      SAVE IENT
      DATA IENT/0/
      IF (LTRACE) CALL STRACE (IENT,'SPROSDM')
!
      CAST1 = 0.
      CAST2 = 0.
      CAST5 = 0.
      CADT1 = 0.
      IX1   = IXCGRD(1)
      IY1   = IYCGRD(1)
      KCG1  = KCGRD (1)
      XC1   = XCGRID(IX1,IY1)
      YC1   = YCGRID(IX1,IY1)
!     NOTE that we do not use the pointers KCG2 and KCG3 here,
!     as we first have to redetermine them depending on the sweep.
      DLOC1 = DEP2  (KCG1)
      KLOC1 = KMUDR (KCG1,:) ! KWAVE(:,1)
!
!     *** test output ***
!
      IF (TESTFL .AND. ITEST .GE. 100 ) THEN
        WRITE(PRINTF, 211) IX1+MXF-2, IY1+MYF-2, XC1+XOFFS, YC1+YOFFS,    40.30
     &                     DLOC1                                          40.30
 211    FORMAT(' test SPROSDM, location:',2I5,2e12.4,', depth:',F9.2)
      ENDIF
!
      DO ISWP = 1, 3                                                      40.02
        ISWEEP = SWP_ARRAY(ISWP)                                          40.02
!
!       *** prepare depth and current gradient for current sweep and ***
!       *** two adjacent sweeps                                      ***
!
        CAST3(ISWEEP)  = 0.
        CAST4(ISWEEP)  = 0.
        CAST6(ISWEEP)  = 0.
        CAST7(ISWEEP)  = 0.
        CAST8(ISWEEP)  = 0.
        CAST9(ISWEEP)  = 0.
!
!       *** set the propagation dummy terms CADT 0 ***
!
        CADT2(:,ISWEEP) = 0.
        CADT3(:,ISWEEP) = 0.
        CADT4  (ISWEEP) = 0.
        CADT5  (ISWEEP) = 0.
        CADT6  (ISWEEP) = 0.
        CADT7  (ISWEEP) = 0.
        VALSWP = .TRUE.
!
        IF (ISWEEP.EQ.2) THEN
          KCG2 = KCGRD(2)
          KCG3 = KCGRD(3)
          IX2  = IXCGRD(2)
          IY2  = IYCGRD(2)
          IX3  = IXCGRD(3)
          IY3  = IYCGRD(3)
          SWPNGB = SWPDIR
          DO II = 1, 2
            RDXL(II) = RDX(II)
            RDYL(II) = RDY(II)
          ENDDO
!         Refraction and frequency shift are not defined for points
!         neighbouring to landpoints
          IF ( (KCG1.EQ.1).OR.(DEP2(KCG1).LE.DEPMIN).OR.                  30.82
     &         (KCG2.EQ.1).OR.(DEP2(KCG2).LE.DEPMIN).OR.                  30.82
     &         (KCG3.EQ.1).OR.(DEP2(KCG3).LE.DEPMIN) ) THEN               30.82
            DO IS = 1, MSC
              DO ID = 1, MDC
                CAS(ID,IS,1) = 0.
                CAD(ID,IS,1) = 0.
              ENDDO
            ENDDO
            GOTO 900
          ENDIF
        ELSE ! IF (ISWEEP.EQ.2) THEN
!         determine neighbouring sweep
          IF (ISWEEP.EQ.1) THEN
            SWPNGB = SWPDIR-1
            IF (SWPNGB.EQ.0) SWPNGB = 4
          ELSE
            SWPNGB = SWPDIR+1
            IF (SWPNGB.EQ.5) SWPNGB = 1
          ENDIF
!
!         determine neighbouring grid points according to sweep
!
          IF (SWPNGB.EQ.1) THEN
            IF (KREPTX.EQ.0) THEN                                         33.09
              IF (IX1.EQ.1) VALSWP = .FALSE.
            ENDIF                                                         33.09
            IF (.NOT.ONED .AND. IY1.EQ.1) VALSWP = .FALSE.
            IX2 = IX1 - 1
            IY2 = IY1
            IX3 = IX1
            IY3 = IY1 - 1
          ELSE IF (SWPNGB.EQ.2) THEN
            IF (KREPTX.EQ.0) THEN                                         33.09
              IF (IX1.EQ.MXC) VALSWP = .FALSE.
            ENDIF                                                         33.09
            IF (.NOT.ONED .AND. IY1.EQ.1) VALSWP = .FALSE.
            IX2 = IX1 + 1
            IY2 = IY1
            IX3 = IX1
            IY3 = IY1 - 1
          ELSE IF (SWPNGB.EQ.3) THEN
            IF (KREPTX.EQ.0) THEN                                         33.09
              IF (IX1.EQ.MXC) VALSWP = .FALSE.
            ENDIF                                                         33.09
            IF (.NOT.ONED .AND. IY1.EQ.MYC) VALSWP = .FALSE.
            IX2 = IX1 + 1
            IY2 = IY1
            IX3 = IX1
            IY3 = IY1 + 1
          ELSE IF (SWPNGB.EQ.4) THEN
            IF (KREPTX.EQ.0) THEN                                         33.09
              IF (IX1.EQ.1) VALSWP = .FALSE.
            ENDIF                                                         33.09
            IF (.NOT.ONED .AND. IY1.EQ.MYC) VALSWP = .FALSE.
            IX2 = IX1 - 1
            IY2 = IY1
            IX3 = IX1
            IY3 = IY1 + 1
          ENDIF
          IF (KREPTX.GT.0) THEN                                           33.09
            IF (IX2.LE.0)   IX2 = IX2 + MXC                               33.09
            IF (IX2.GT.MXC) IX2 = IX2 - MXC                               33.09
          ENDIF ! IF (SWPNGB.EQ.1) THEN
!
!         determine interpolation coeffcients (RDXL, RDYL)
!
          IF (VALSWP) THEN
            KCG2 = KGRPNT(IX2,IY2)
            IF (KCG2.LE.1 .OR. DEP2(KCG2).LE.DEPMIN) VALSWP = .FALSE.         40.14
            IF (KREPTX.GT.0) THEN                                         33.09
              DX2 =  DX * COSPC                                            33.09
              DY2 = -DX * SINPC                                           33.09
            ELSE
              DX2 = XC1 - XCGRID(IX2,IY2)
              DY2 = YC1 - YCGRID(IX2,IY2)
            ENDIF
            IF (KSPHER.GT.0) THEN
              DX2 = DX2 * LENDEG * COSLAT(1)
              DY2 = DY2 * LENDEG
            ENDIF
            IF (ONED) THEN
              KCG3 = KCG1
              DET     =  DX2**2 + DY2**2
              RDXL(1) =  DX2/DET
              RDYL(1) =  DY2/DET
              RDXL(2) =  0.
              RDYL(2) =  0.
            ELSE
              KCG3 = KGRPNT(IX3,IY3)
              IF (KCG3.LE.1 .OR. DEP2(KCG3).LE.DEPMIN) VALSWP = .FALSE.   40.14
              DX3 = XC1 - XCGRID(IX3,IY3)
              DY3 = YC1 - YCGRID(IX3,IY3)
              IF (KSPHER.GT.0) THEN
                DX3 = DX3 * LENDEG * COSLAT(1)
                DY3 = DY3 * LENDEG
              ENDIF
              DET     =  DY3*DX2 - DY2*DX3
              RDXL(1) =  DY3/DET
              RDYL(1) = -DX3/DET
              RDXL(2) = -DY2/DET
              RDYL(2) =  DX2/DET
            ENDIF
          ENDIF ! IF (VALSWP) THEN
        ENDIF ! IF (ISWEEP.EQ.2) THEN
!
!       *** compute the derivatives of the depth and the current velocity ***
!
        IF (VALSWP) THEN

          IF (IREFR.EQ.-1) THEN                                           40.02

!           limitation of depths in neighbouring grid points

            DLOC2 = MIN (DEP2(KCG2), PNUMS(17)*DLOC1)
            DLOC3 = MIN (DEP2(KCG3), PNUMS(17)*DLOC1)
          ELSE                                                            40.02

!           no limitation                                                 40.02

            DLOC2 = DEP2(KCG2)                                            40.02
            DLOC3 = DEP2(KCG3)                                            40.02
          END IF                                                          40.02

          KLOC2 = KMUDR(KCG2,:) ! KWAVE(:,2)                             !40.61mud
          KLOC3 = KMUDR(KCG3,:) ! KWAVE(:,3)                             !40.61mud

!         *** @D/@X ***
          DPDX = RDXL(1) * (DLOC1-DLOC2) + RDXL(2) * (DLOC1-DLOC3)       !40.61mud

!         *** @D/@Y ***
          DPDY = RDYL(1) * (DLOC1-DLOC2) + RDYL(2) * (DLOC1-DLOC3)
!
!         *** @K/@X ***
          DKDX = RDXL(1) * (KLOC1-KLOC2) + RDXL(2) * (KLOC1-KLOC3)

!         *** @K/@Y ***
          DKDY = RDYL(1) * (KLOC1-KLOC2) + RDYL(2) * (KLOC1-KLOC3)

!         DKDX = DKDX * KSX*KSY
!         DKDY = DKDY * KSX*KSY

          CADT2(:,ISWEEP) = DKDX                                          30.21
          CADT3(:,ISWEEP) = DKDY                                          30.21
!

          IF ( ICUR .EQ. 1 ) THEN
!           *** current is on ***
!
!           *** @Ux/@X ***
            DUXDX =  RDXL(1) * (UX2(KCG1) - UX2(KCG2))
     &             + RDXL(2) * (UX2(KCG1) - UX2(KCG3))
!
!           *** @Ux/@Y ***
            DUXDY =  RDYL(1) * (UX2(KCG1) - UX2(KCG2))
     &             + RDYL(2) * (UX2(KCG1) - UX2(KCG3))
!
!           *** @Uy/@X ***
            DUYDX =  RDXL(1) * (UY2(KCG1) - UY2(KCG2))
     &             + RDXL(2) * (UY2(KCG1) - UY2(KCG3))
!
!           *** @Uy/@Y ***
            DUYDY =  RDYL(1) * (UY2(KCG1) - UY2(KCG2))
     &             + RDYL(2) * (UY2(KCG1) - UY2(KCG3))

            CAST3(ISWEEP) = UX2(KCG1) * DPDX
            CAST4(ISWEEP) = UY2(KCG1) * DPDY
          ELSE
            DUXDX = 0.
            DUXDY = 0.
            DUYDX = 0.
            DUYDY = 0.
            CAST3(ISWEEP) = 0.
            CAST4(ISWEEP) = 0.
          ENDIF
!
          CAST6(ISWEEP) = DUXDX
          CAST7(ISWEEP) = DUXDY
          CAST8(ISWEEP) = DUYDX
          CAST9(ISWEEP) = DUYDY
!
!         *** coefficients for CAD -> function of IX and IY only ***
!
          CADT2(:,ISWEEP) = DKDX
          CADT3(:,ISWEEP) = DKDY
          CADT4(ISWEEP) = DUXDX
          CADT5(ISWEEP) = DUYDY
          CADT6(ISWEEP) = DUYDX
          CADT7(ISWEEP) = DUXDY
!
        ELSE ! IF (VALSWP) THEN
!         if gradients cannot be determined because one grid point is missing,
!         use gradient computed for the central sweep
         !write(*,*) 'gradients not determined, 1 grid point missing:'
          CAST3(ISWEEP) = CAST3(2)
          CAST4(ISWEEP) = CAST4(2)
          CAST6(ISWEEP) = CAST6(2)
          CAST7(ISWEEP) = CAST7(2)
          CAST8(ISWEEP) = CAST8(2)
          CAST9(ISWEEP) = CAST9(2)
          CADT2(:,ISWEEP) = CADT2(:,2)
          CADT3(:,ISWEEP) = CADT3(:,2)
          CADT4(ISWEEP) = CADT4(2)
          CADT5(ISWEEP) = CADT5(2)
          CADT6(ISWEEP) = CADT6(2)
          CADT7(ISWEEP) = CADT7(2)
        ENDIF ! IF (VALSWP) THEN
!
!       *** test output ***
!
        IF (TESTFL .AND. ITEST .GE. 100 ) THEN
          WRITE(PRINTF, 411) SWPNGB, IX2+MXF-2, IY2+MYF-2, DLOC2,
     &                               IX3+MXF-2, IY3+MYF-2, DLOC3
 411      FORMAT(' sweep, depths:', I2, 2(I6,I4,F9.2))
          IF (ICUR .EQ. 1) THEN
            WRITE(PRINTF, 412) UX2(KCG1),UX2(KCG2),UX2(KCG3),
     &                         UY2(KCG1),UY2(KCG2),UY2(KCG3)
 412        FORMAT(10X, 'UX:',3(1X,F8.3),/, 10X, 'UY:',3(1X,F8.3))
          ENDIF
          WRITE(PRINTF, 413) RDXL(1),RDXL(2),RDYL(1),RDYL(2)
 413      FORMAT(10X, 'RDX etc.:',4(1X,E12.4))
          WRITE(PRINTF, 414) DPDX,  DPDY
 414      FORMAT(10x, 'DPDX,DPDY:',2(1X,E12.4))
        ENDIF
      ENDDO
!
!     *** coefficients for CAS -> function of IX and IY only ***
!
      IF ( NSTATC.EQ.0 .OR. .NOT.DYNDEP) THEN                             40.00
!       *** stationary calculation ***
        CAST2 = 0.
      ELSE
!       nonstationary depth, CAST2 is @D/@t
        CAST2 = ( DLOC1 - DEP1(KCG1) ) * RDTIM
      END IF
!
      DO 70 IS = 1, MSC
        KD1 = KWAVE(IS,1) * DLOC1
        IF ( KD1 .GT. 30.0 ) KD1 = 30.
        VLSINH = SINH (2.* KD1 )
        COEF   = SPCSIG(IS) / VLSINH                                      30.72
        COEF2  = CGO(IS,1) / KWAVE(IS,1)                                 !40.61mud
!
!       *** coefficients for CAS -> function of IS only ***
!
        CAST1 = KWAVE(IS,1) * COEF
        CAST5 = CGO(IS,1) * KWAVE(IS,1)
!
!       *** coefficients for CAD -> function of IS only ***
!
        CADT1 =  COEF
!
!       loop over spectral directions
!
        DO 60 IDDUM = IDCMIN(IS)-1, IDCMAX(IS)+1                          40.03
          ID = MOD ( IDDUM - 1 + MDC , MDC ) + 1
          IF (IDDUM.EQ.IDCMIN(IS)-1) THEN
!           direction is in the lower adjacent sweep
            ISWEEP = 1
          ELSE IF (IDDUM.EQ.IDCMAX(IS)+1) THEN
!           direction is in the upper adjacent sweep
            ISWEEP = 3
          ELSE
!           direction is in the current sweep
            ISWEEP = 2
          ENDIF
!
!         *** computation of CAS and CAD ***
!
          IF (ICUR .EQ. 0) THEN
            CAS(ID,IS,1) = CAST1 * CAST2
!
            CAD(ID,IS,1) = -COEF2 * ( ESIN(ID) * CADT2(IS,ISWEEP) -
     &                               ECOS(ID) * CADT3(IS,ISWEEP) )

!           --- adapt the velocity in case of diffraction                 40.21
            IF (IDIFFR.EQ.1) THEN                                         40.21
               CAD(ID,IS,1) = DIFPARAM(KCG1)*CAD(ID,IS,1)
     &                      - DIFPARDX(KCG1)*CGO(IS,1)*ESIN(ID)           40.21
     &                      + DIFPARDY(KCG1)*CGO(IS,1)*ECOS(ID)           40.21
            END IF

          ELSE
            IF (IDIFFR.EQ.0) THEN                                         40.21
               CAS(ID,IS,1)= CAST1 *
     &              (CAST2 + CAST3(ISWEEP) + CAST4(ISWEEP)) -
     &               CAST5 *
     &              (COSCOS(ID) * CAST6(ISWEEP) +
     &               SINCOS(ID) * (CAST7(ISWEEP) + CAST8(ISWEEP)) +
     &               SINSIN(ID) * CAST9(ISWEEP) )

               CAD(ID,IS,1) =
     &            -COEF2 * ( ESIN(ID) * CADT2(IS,ISWEEP) -
     &                       ECOS(ID) * CADT3(IS,ISWEEP)) +
     &             SINCOS(ID) * (CADT4(ISWEEP) - CADT5(ISWEEP)) +
     &             SINSIN(ID) *  CADT6(ISWEEP) -
     &             COSCOS(ID) *  CADT7(ISWEEP)
            ELSE IF (IDIFFR.EQ.1) THEN                                    40.21
               CAS(ID,IS,1)= CAST1 *                                      40.21
     &              (CAST2 + CAST3(ISWEEP) + CAST4(ISWEEP)) -             40.21
     &               DIFPARAM(KCG1)*CAST5 *                               40.21
     &              (COSCOS(ID) * CAST6(ISWEEP) +                         40.21
     &               SINCOS(ID) * (CAST7(ISWEEP) + CAST8(ISWEEP)) +       40.21
     &               SINSIN(ID) * CAST9(ISWEEP) )                         40.21

               CAD(ID,IS,1) = DIFPARAM(KCG1)*                             40.21
     &            -COEF2 * (ESIN(ID) * CADT2(IS,ISWEEP) -                 40.61mud
     &                      ECOS(ID) * CADT3(IS,ISWEEP))                  40.61mud
     &                      - DIFPARDX(KCG1)*CGO(IS,1)*ESIN(ID)           40.21
     &                      + DIFPARDY(KCG1)*CGO(IS,1)*ECOS(ID) +         40.21
     &             SINCOS(ID) * (CADT4(ISWEEP) - CADT5(ISWEEP)) +         40.21
     &             SINSIN(ID) *  CADT6(ISWEEP) -                          40.21
     &             COSCOS(ID) *  CADT7(ISWEEP)                            40.21
            END IF                                                        40.21
          ENDIF
!
 60     CONTINUE
 70   CONTINUE
!
!     *** for most cases CAS and CAD will be activated. Therefore ***
!     *** for IREFR is set 0 (no refraction) or ITFRE = 0 (no     ***
!     *** frequency shift) we have put the IF statement outside   ***
!     *** the internal loop above                                 ***
!
 10   IF (ITFRE .EQ. 0) THEN
        DO IS = 1, MSC
          DO ID = 1, MDC
            CAS(ID,IS,1) = 0.0
          ENDDO
        ENDDO
      ENDIF
!
      IF (IREFR .EQ. 0) THEN
        DO IS = 1, MSC
          DO ID = 1, MDC
            CAD(ID,IS,1) = 0.0
          ENDDO
        ENDDO
      ENDIF
!
!     *** test output ***
!
      IF (TESTFL .AND. ITEST.GE.140) THEN                                 40.00
        IF (DYNDEP .OR. ICUR.GT.0) THEN
          WRITE(PRINTF, *) ' IS ID1 ID2        values of CAS'             40.00
          DO 602 IS = 1, MSC
            ID1 = IDCMIN(IS)-1
            ID2 = IDCMAX(IS)+1
            WRITE(PRINTF, 619) IS, ID1, ID2,                              40.00
     &            (CAS(MOD(IDDUM-1+MDC,MDC)+1, IS, 1), IDDUM=ID1,ID2)     40.00
 619        FORMAT(3I4, 2X, 600E12.4)                                     40.00
 602      CONTINUE
        ENDIF
        WRITE(PRINTF, *) ' IS ID1 ID2        values of CAD'               40.00
        DO 604 IS = 1, MSC
          ID1 = IDCMIN(IS)-1
          ID2 = IDCMAX(IS)+1
          WRITE(PRINTF,619) IS, ID1, ID2,                                 40.00
     &          (CAD(MOD(IDDUM-1+MDC,MDC)+1, IS, 1), IDDUM=ID1,ID2)       40.00
 604   CONTINUE
      ENDIF                                                               40.00
!     write(*,*) 'We are in subroutine SPROSDM'
!
!     end of the subroutine SPROSDM
 900  RETURN
      END SUBROUTINE SPROSDM
!
!****************************************************************
!
      SUBROUTINE SWMUDD( DEP2  , MUDL2 , IMATDA, SPCSIG,
     &                   IDCMIN, IDCMAX, PLMUD , ISSTOP,
     &                   DISSC1, DISMUD, IX    , IY    ,                 !40.61mud
     &                   KMUDR , KMUDI , PLBTFR,DISBOT,CGO)              !40.61mud
!
!****************************************************************
!
      USE OCPCOMM4
      USE SWCOMM2
      USE SWCOMM3 ! PMUD
      USE SWCOMM4
      USE EnDissTerms
!
      IMPLICIT NONE
!
!
!   --|-----------------------------------------------------------|--
!     | WL | Delft Hydraulics                                     |
!     | P.O. Box 177, 2600 MH  Delft, The Netherlands             |
!     |                                                           |
!     | Programmer: J. Groeneweg                                  |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!
!  0. Authors
!
!     40.31:  Jacco Groeneweg
!     40.55:  Marcel Zijlema
!     40.61:  Marcel Zijlema
!     40.61mud: Gerben de Boer & Wouter Kranenburg
!
!  1. Updates
!
!     40.31, Oct. 07: Originally subroutine SWMUD by J. Groeneweg: 
!     40.61, Apr. 08: Replaced calculation dispersion relations to SWMUDK,
!                     Replaced source term calculation to SWMUDD.
!                     Added diss term acc. to Kranenburg
!                     Replaced diss terms to subroutines
!
!  2. Purpose
!
!     Determine extra damping of waves over fluid mud banks.
!
!  3. Method
!
!     Compute sink term accounting for viscous dissipation
!     in the mud layer. Note that the derivation of the pressure
!     gradient in this equations needs to be consistent with
!     the dispersion relations. We use Gade (158) for both. Note that 
!     his equation contains one type (missing sigma).
!
!  4. Argument variables
!
!     DEP2        water depth, interpreted as non-viscous water layer
!     DISMUD      total fluid mud dissipation for output purposes         40.61
!     KMUDR       Average wave length with mud real part                  40.61mud
!     KMUDI       Average wave length with mud imag part                  40.61mud
!     DISSC1      dissipation coefficient
!     IDCMIN      frequency dependent counter in directional space
!     IDCMAX      frequency dependent counter in directional space
!     IMATDA      coefficients of diagonal of matrix
!     ISSTOP      maximum counter of wave component in frequency
!                 space that is propagated
!     MUDL2       mud layer thickness
!     PLMUD       array containing the fluid mud source term for test-output
!     SPCSIG      relative frequencies in spectral domain
!     IX,IY       grid cell indices                                       40.61mud
!
      INTEGER  ISSTOP, IDCMIN(MSC), IDCMAX(MSC), IX, IY                  !40.61mud
      REAL     DEP2  (MCGRD)             ,
     &         SPCSIG(MSC)               ,
     &         IMATDA(MDC,MSC)           ,
     &         DISMUD(MDC,MSC)           ,
     &         DISBOT(MDC,MSC)           ,                                40.61
     &         DISSC1(MDC,MSC)           ,
     &         MUDL2 (MCGRD)             ,
     &         PLMUD (MDC,MSC,NPTST)     ,
     &         PLBTFR(MDC,MSC,NPTST)                                     !40.00
      REAL  :: KMUDR (MCGRD,MSC)                                         !40.61mud
      REAL  :: KMUDI (MCGRD,MSC)                                         !40.61mud
      REAL  :: CGO   (MSC,MICMAX)                                        !40.61mud
!
!  5. Parameter variables
!
      COMPLEX    CUNIT
      PARAMETER (CUNIT=(0.,1.))
!
!  6. Local variables
!
!     AMUD  :     calibration coefficient for accounting possible
!                 nonlinear effects
!     FAC1  :     auxiliary factor
!     FAC2  :     auxiliary factor
!     GD    :     factor equals gravity acceleration times depth
!     ID    :     counter of the spectral direction
!     IDDUM :     counter
!     IENT  :     number of entries
!     IS    :     counter
!     KMUD  :     complex wave number to be used in computation
!                 of fluid mud-induced wave dissipation
!     PHIF  :     phase angle between water elevation and flow velocity
!     PHIW  :     phase angle between surface and internal waves
!     R     :     inverse complex wave celerity
!     RW    :     ratio of amplitudes of surface and internal waves
!     SMUDWD:     source term containing fluid mud-induced wave
!                 dissipation
!     THICKM:     thickness of fluid mud layer
!
      INTEGER ID, IDDUM, IENT, IS
      INTEGER disperr, disperi,source, cg                                !40.61mud
      REAL    AMUD, FAC1, FAC2, GD, PHIF, PHIW, R, RW, SMUDWD, THICKM,
     &        RHOM, RHO0,XNUM
      COMPLEX KMUD(MSC)
 !    FIRST3 indicates whether something is called for 1st time           40.61mud
      LOGICAL, SAVE :: FIRST3  = .true. 

!
!  8. Subroutines used
!
!     STRACE           Tracing routine for debugging
!     DISSGADE         Diss term acc. to Gade(1958)
!     DISSDELFT        Diss term acc. to Kranenburg, consistent with DELFT(2008)
!
!  9. Subroutines calling
!
!     SOURCE
!
! 12. Structure
!
!     First, compute complex wave number according to formula (9) of
!     the abovementioned paper and then the source term accounting
!     for fluid mud-induced wave dissipation according to formula (8)
!
! 13. Source text
!
      SAVE IENT
      DATA IENT/0/
      IF (LTRACE) CALL STRACE (IENT,'SWMUD')

      AMUD    = PMUD(1) ! PMUD defined in module SWCOMM3 in swmod1.for
      RHOM    = PMUD(2) 
      RHO0    = PMUD(3) 
      XNUM    = PMUD(4) 
!     layer   = PMUD(5) 
      disperr = PMUD(6)
      disperi = PMUD(7)
      source  = PMUD(8)
      cg      = PMUD(9)

      IF (source.NE.disperr) THEN
        IF (FIRST3) THEN

          WRITE(*,*) 'The fluid mud dissipation term is on, refer to:'   !40.55
          WRITE(*,*) '  * Kranenburg et al. (2010)'
          WRITE(*,*) '    Journal of Hydraulic Engineering, 2010'
          WRITE(*,*) '  * Kranenburg (2008)'
          WRITE(*,*) '    http://repository.tudelft.nl/view/ir/'
          WRITE(*,*) '     uuid%3A7644eb5b-0ec9-4190-9f72-ccd7b50cfc47/'
          WRITE(*,*) '    with default parameter settings:'
          WRITE(*,*) 'ALPHA          ',PMUD( 1)
          WRITE(*,*) 'RHOM           ',PMUD( 2)
          WRITE(*,*) 'RHO0           ',PMUD( 3)
          WRITE(*,*) 'NU             ',PMUD( 4)
          WRITE(*,*) 'layer==f(x,y)  ',PMUD( 5)
          WRITE(*,*) 'disperr        ',PMUD( 6)
          WRITE(*,*) 'disperi        ',PMUD( 7)
          WRITE(*,*) 'source         ',PMUD( 8)
          WRITE(*,*) 'cg             ',PMUD( 9)
          WRITE(*,*) 'power          ',PMUD(10)
          write(*,*) ' '
          write(*,*) 'NOTE:' 
          write(*,*) '  disperr = ', disperr 
          write(*,*) '  source  = ', source 
          write(*,*) '  Possibly introduction of inconsistency!'
          write(*,*) ' '
          FIRST3 = .false.
        ENDIF
      ENDIF  

      GD         = GRAV * DEP2(KCGRD(1))
!
      IF (VARMUD) THEN
         THICKM = MUDL2(KCGRD(1))
      ELSE
         THICKM = PMUD(5)
      END IF

      DO IS = 1, ISSTOP
      KMUD(IS)     = KMUDR (KCGRD(1),IS) + CUNIT*KMUDI (KCGRD(1),IS)
      ENDDO

!
!     *** test output ***
!
      IF (TESTFL .AND. ITEST.GE.60) THEN
        WRITE (PRTEST, 110) IMUD, KCGRD(1), DEP2(KCGRD(1)), THICKM, AMUD
 110    FORMAT (' SWMUD :IMUD INDX DEP MUDLAY ALPHA:', 2I5, 3E12.4)
      END IF

      DO IS = 1, ISSTOP
!
!        --- method 0: No effect ki
        IF (source==0) THEN
            SMUDWD = 0.      
		  
!        --- method x: Impossible solution for k [GJdB 2009 june] 
        ELSEIF (imag(KMUD(IS))<0 .or. real(KMUD(IS))<0) THEN

        write(*,*) 'neg kreal,imag in (IX,IY,IS)',IX,IY,IS,' set Smud=0'
	                      
!
!        --- method 1: Gade (1958)
        ELSEIF     (source==1) THEN
          CALL DISSGADE (RW             ,PHIW    ,
     &                   SMUDWD         ,KMUD(IS),
     &                   SPCSIG(IS)     ,GRAV    ,
     &                   DEP2(KCGRD(1)) ,
     &                   RHO0           )
        !write(*,*) 'Gade', SMUDWD, CGO(IS,1), KMUD(IS)

!        --- method 3: Dissipation term according to KRANENBURG, consistent with DELFT(2008)
        ELSEIF     (source==3) THEN
          CALL DISSDELFT(RW             ,PHIW    ,
     &                   SMUDWD         ,KMUD(IS),
     &                   SPCSIG(IS)     ,GRAV    ,
     &                   DEP2(KCGRD(1)) ,
     &                   RHO0           )
        !write(*,*) 'Delft', SMUDWD, CGO(IS,1), KMUD(IS)

!
!        --- method 5: Ng (2000)
        ELSEIF     (source==5) THEN
          CALL DISSNG   (RW             ,PHIW    ,
     &                   SMUDWD         ,KMUD(IS),
     &                   SPCSIG(IS)     ,GRAV    ,
     &                   DEP2(KCGRD(1)) ,
     &                   RHO0           ,CGO(IS,1)) ! Cg
        !write(*,*) 'Ng', SMUDWD, CGO(IS,1), KMUD(IS)

        ELSE
        
        write(*,*) 'source term not implemented (only 1 or 3): ',source

        ENDIF

!      write(*,'(3(I3,X),E12.7,X,F8.6,X,E15.9,2(F8.6),X,F4.2,X,3(F8.6,X))') 
!     write(*,*) 
!    &         IX,IY,IS,RW             ,PHIW    ,
!    &                  SMUDWD         ,KMUD(IS),
!    &                  SPCSIG(IS)     ,GRAV    ,
!    &                  DEP2(KCGRD(1)) ,RHO0           


!        *** store the results in the array IMATDA ***
!        *** if testfl store results in array for isoline plot ***
!
!        only directions that are in current sweep
         DO IDDUM = IDCMIN(IS), IDCMAX(IS)
          ID = MOD ( IDDUM - 1 + MDC , MDC ) + 1

          ! store mud source term for regular output
          DISMUD(ID,IS) = SMUDWD                       ! only for output purposes

          ! store mud source term for spectral test output
          IF (TESTFL) PLMUD(ID,IS,IPTST) = -1.* SMUDWD ! only for output purposes (TEST command)

          ! add mud source term to total source term
          ! when it is bigger then the bottom friction term
          ! but only that part that exceeds then the bottom friction, because
          ! that part was already added before we do the mud source term here, and
          ! before we set it to zero here (See sketch below).

          IF (ABS(DISMUD(ID,IS)) .GE. ABS(DISBOT(ID,IS))) THEN

            IMATDA(ID,IS)       = IMATDA(ID,IS) + SMUDWD - DISBOT(ID,IS) ! for actual computation with mud dissipation
            DISSC1(ID,IS)       = DISSC1(ID,IS) + SMUDWD - DISBOT(ID,IS) ! only for output purposes

            DISBOT(ID,IS)       = 0. ! only for output purposes
            IF (TESTFL)  THEN
            PLBTFR(ID,IS,IPTST) = 0. ! only for output purposes
            ENDIF

          ELSE

            DISMUD(ID,IS)       = 0.                                        ! OPTION A ABOVE (result)
!!!!!       DISMUD(ID,IS)       = DISMUD(ID,IS)       - DISMUD(ID,IS        ! OPTION A ABOVE (in symbols)
!!!!!       DISBOT(ID,IS)       = DISBOT(ID,IS)       - DISMUD(ID,IS)       ! OPTION B ABOVE

            IF (TESTFL)  THEN
            PLMUD (ID,IS,IPTST) = 0.                                        ! OPTION A (result)
!!!!!       PLMUD (ID,IS,IPTST) = PLMUD (ID,IS,IPTST) - PLMUD (ID,IS,IPTST) ! OPTION A (in symbols)
!!!!!       PLBTFR(ID,IS,IPTST) = PLBTFR(ID,IS,IPTST) - PLMUD (ID,IS,IPTST) ! OPTION B
            ENDIF

          ENDIF

         END DO

      END DO ! IS = 1, ISSTOP

! start of ACCOUNTING FOR SMUD OVERTAKING SBOT
!---------------------------------------------------------------------------
!
! dissipation ^                  @
!             |                @ dismud                                    40.61mud
!             | disbot       @                                             40.61mud
!             |************@..............disbot                           40.61mud
!             |         .  @                                               40.61mud
!             |       .    *                                               40.61mud
!             |     .      @                                               40.61mud
!             |   .        *                                               40.61mud
!             | .          @                                               40.61mud
!             |.dismud=0   *   disbot=0                                    40.61mud
!            +@@@@@@@@@@@@@@***********--------------> (MDC,MSC)           40.61mud
!      A) Set bottom dissipation to zero where mud dissipation is bigger   40.61mud
!         Set mud dissipation to zero where bottom dissipation is bigger   40.61mud
!
! 
! dissipation ^                  @
!             |                @ dismud                                    40.61mud
!             | disbot       @                                             40.61mud
!             |............@..............disbot                           40.61mud
!             |*         @ .                                               40.61mud
!             |  *     @   .                                               40.61mud
!             |     *@     .                                               40.61mud
!             |    @  *    .                                               40.61mud
!             |  @      *  .                                               40.61mud
!             |@ dismud=0 *  disbot=0                                      40.61mud
!             +------------*************--------------> (MDC,MSC)          40.61mud
!      B) Subtract any value of mud dissipatio from bottom dissipation     40.61mud
!
! So Dismud and Disbot can occur at the same spatial point,                40.61mud
! in different 2D-spectral bins.
!
! * As we don't know whether the bottom dissipation is defined as negative 
!   or positive, we do a comparison on the abs values.
!   The bottom friction and fluid mud dissipation have the same sign.
!   Option: smooth transition, where Smud grows while Sbot decreases, 
!   until they are equal.
! * Note that this approach has to be repeated for the test output in subroutine PLTSRC
! * Undo addition made in subroutine SMUDDD
! * DISSC1 is copied to SWMATR(1,1,JDIS1) in call of subroutine source
!---------------------------------------------------------------------------

      RETURN
      END SUBROUTINE SWMUDD
!

!
!****************************************************************
!
      SUBROUTINE SWKMEAN (KWAVE, SPCSIG, AC2, LMEAN,NODATAVALUE) !40.61mud
!
!****************************************************************
!
!
      USE SWCOMM3  ! for KCGRD,MSC,MDC, PWTAIL, FRINTF, PMUD in SWMOD3.for
      USE SWCOMM1  ! for OUTPAR                              in SWMOD1.for
      USE OCPCOMM4 ! for LTRACE

      IMPLICIT NONE
!
!
!   --|-----------------------------------------------------------|--
!     | WL | Delft Hydraulics                                     |
!     | P.O. Box 177, 2600 MH  Delft, The Netherlands             |
!     |                                                           |
!     | Programmer: G.J. de Boer                                  |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!  0. Authors
!
!     40.61mud: Gerben de Boer
!
!  1. Updates
!
!     40.61mud, Dec. 07:
!
!  2. Purpose
!
!     Calculate spectrum-averaged real and imag wavelength k(x,y) from wave length k(x,y,sigma)
!
!  3. Method
!
!      Numerical integration
!
!  4. Argument variables
!
!     KWAVE       real arr input  wave length in all computational points and sigma space
!     SPCSIG      Relative frequencies in computational domain in sigma-space in [rad/s]
!     AC2         real arr input  action density in all computational points
!     LMEAN       real arr input  wave length in all computational points integrated over sigma space (ith AC as weight)
!     MSC         Maximum counter of relative frequency
!     MDC         Maximum counter of directional distribution
!     ISSTOP      maximum counter of wave component in frequency
!                 space that is propagated
!
      REAL   , INTENT(IN) :: AC2   (MDC  ,MSC,MCGRD)  
      REAL   , INTENT(IN) :: KWAVE (MCGRD,MSC      ) ! subarray of COMPDA
      REAL   , INTENT(IN) :: SPCSIG(      MSC      )
      REAL                :: LMEAN (          MCGRD) ! subarray of COMPSPC
      REAL   , INTENT(IN) :: NODATAVALUE
!
!  5. Parameter variables
!
!  6. Local variables
!
!     IENT   : Number of entries into this subroutine
      INTEGER             :: IENT
      REAL                :: ETOT, EKTOT, PPTAIL,CKTAIL
      REAL                :: SIG2, SKK,   CETAIL
      INTEGER             :: IS  , ID,   INDX, power
!
!  8. Subroutines used
!
!  9. Subroutines calling
!
!     SWOUTP
!
! 13. Source text
!

      SAVE IENT
      DATA  IENT /0/
      IF (LTRACE) CALL STRACE (IENT,'SWKMEAN')

         if (int(PMUD(10)).eq.0) THEN
            power = OUTPAR(3)
         ELSE
            power = PMUD(10)
         ENDIF

         IF (power > 0) THEN
         
            write(*,*) 'Frequency-averaged WLENMR + KI'
            write(*,*) '   calculated with power: ', power

            DO INDX  = 1, MCGRD
               ETOT  = 0.
               EKTOT = 0.
!              new integration method involving FRINTF                        20.59
               DO IS   = 1, MSC
                  SIG2 = (SPCSIG(IS))**2                                      30.72
                  SKK  = SIG2 * (KWAVE(INDX,IS))**power                       40.00
                  DO ID=1,MDC
                    ETOT  = ETOT  + FRINTF *  SIG2 * AC2(ID,IS,INDX)         !40.61mud
                    EKTOT = EKTOT + FRINTF *  SKK  * AC2(ID,IS,INDX)         !40.61mud
                   !ETOT  = ETOT  + SIG2 * ACLOC(ID,IS)                       20.59
                   !EKTOT = EKTOT + SKK * ACLOC(ID,IS)                        20.59
                  ENDDO
               ENDDO
               !ETOT  = FRINTF * ETOT                                         40.61mud
               !EKTOT = FRINTF * EKTOT                                        40.61mud
               IF (MSC .GT. 3) THEN                                           10.20
!                 contribution of tail to total energy density
                  PPTAIL = PWTAIL(1) - 1.                                     20.59
                  CETAIL = 1. / (PPTAIL * (1. + PPTAIL * (FRINTH-1.)))        20.59
                  PPTAIL = PWTAIL(1) - 1. - 2.*power                          40.00
                  IF (PPTAIL.LE.0.) THEN
                    CALL MSGERR (2,'error tail computation')
                    GOTO 480
                  ENDIF
                  CKTAIL = 1. / (PPTAIL * (1. + PPTAIL * (FRINTH-1.)))        20.59
                  DO ID=1,MDC
                    ETOT   = ETOT  + CETAIL * SIG2 * AC2(ID,MSC,INDX)         20.59
                    EKTOT  = EKTOT + CKTAIL * SKK  * AC2(ID,MSC,INDX)         20.59
                  ENDDO
 480              CONTINUE
               ENDIF
!              IF (ITEST.GE.80) WRITE (PRTEST, 482) ETOT, EKTOT, power,       40.00
!    &                          CETAIL, CKTAIL, 4.*SQRT(ETOT*DDIR)
!482           FORMAT (' computation average k ', 6(1X,F8.3))
               IF (ETOT.LE.0.) THEN
                 LMEAN (INDX) = NODATAVALUE
               ELSE
                 LMEAN (INDX) = PI2 * (ETOT / EKTOT) ** (1./power)            40.00
               ENDIF

                  !write(*,*) INDX, ETOT, EKTOT, LMEAN (INDX)

            ENDDO ! DO INDX =1, MCGRD

         ELSEIF (power < 0) THEN
         
            write(*,*) 'WLENMR & KI selected at frequency: ',abs(power)

            DO INDX  = 1, MCGRD

             IF (abs(power)> MSC) THEN
             write(*,*) ('MUD: frequency larger then defined in CGRID')
             STOP
             ELSE
             LMEAN (INDX) = 2*PI/KWAVE(INDX,int(abs(power)))
             ENDIF
         
            ENDDO ! DO INDX =1, MCGRD

         ENDIF
      
      END SUBROUTINE SWKMEAN


!****************************************************************
!
      SUBROUTINE SKWAVM ( KMUD, DEP, THICKM, SPCSIG, ISSTOP,KWAVE,IX,IY) !40.61mud
!
!****************************************************************
!
      USE OCPCOMM4
      USE SWCOMM3
!
      IMPLICIT NONE
!
!
!   --|-----------------------------------------------------------|--
!     | WL | Delft Hydraulics                                     |
!     | P.O. Box 177, 2600 MH  Delft, The Netherlands             |
!     |                                                           |
!     | Programmer: J. Groeneweg                                  |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!
!  0. Authors
!
!     40.31:  Jacco Groeneweg
!     40.55:  Marcel Zijlema
!     40.61mud: Gerben de Boer
!
!  1. Updates
!
!     40.31,  Sep. 04: original
!     40.55,  Jan. 06: New subroutine
!     40.61mud, Oct. 07: Cut-off for kh > 2
!                      Cut-off ctanh(z) for large z
!
!  2. Purpose
!
!     Determine complex wave number for damping waves over mud banks De Wit (1994)
!
!  3. Method
!
!     Compute complex wave number according formula (9) in the paper
!     "Modelling of wave damping at Guyana mud coast" of
!     Winterwerp et al. (2006) in Coastal Engng.
!
!     Newton-Raphson iteration to determine solution of complex-valued
!     function F(z) = f(x+iy) + i g(x+iy) = 0
!
!     Iterative solution for f(x,y)=0 and g(x,y)=0:
!
!        ( f )   ( fx  fy ) ( dx )
!        (   ) + (        ) (    ) = 0
!        ( g )   ( gx  gy ) ( dy )
!
!     with
!
!        (dx,dy) = z^n+1 - z^n
!
!     Hence,
!
!        f+i*g + (fx*dx + fy*dy) + i*(gx*dx + gy*dy) = 0
!
!     or
!
!        f+i*g + (fx + i*gx)*dx + (gy - i*fy) * i*dy = 0
!
!     Mulitplication with complex conjugated of fx+i*gx and
!     considering only imaginary part provides dy, while
!     dx is obtained by multiplying with gy+i*fy and
!     considering real part of the result
!
!     Consequently,
!
!              - real{   (f+i*g) * conj(gy-i*fy) }
!        dx  = -----------------------------------
!                real{ (fx+i*gx) * conj(gy-i*fy) }
!
!              - imag{   (f+i*g) * conj(fx+i*gx) }
!        dy  = -----------------------------------
!                real{ (gy-i*fy) * conj(fx+i*gx) }
!
!     The derivatives fx, gx, fy, gy are determined approximately
!
!     With dk a complex-valued increment, we have
!
!                  F(k+real(dk)) - F(k-real(dk))
!       fx+i*gx =  -----------------------------
!                            2*real(dk)
!
!                  F(k+i*imag(dk)) - F(k-i*imag(dk))
!       gy-i*fy =  ---------------------------------
!                           i * 2*imag(dk)
!
!  4. Argument variables
!
!     DEP         water depth, interpreted as non-viscous water layer
!     ISSTOP      maximum counter of wave component in frequency
!                 space that is propagated
!     KMUD        complex wave number to be used in computation
!                 of fluid mud-induced wave dissipation
!     SPCSIG      relative frequencies in spectral domain in [rad/s]
!     THICKM      thickness of fluid mud layer
!     KWAVE       wave number without mud (always real !)                40.61mud
!     IX,IY       grid cell indices                                      40.61mud
!
      INTEGER ISSTOP
      REAL    DEP, THICKM
      REAL    SPCSIG(MSC)
      COMPLEX KMUD(MSC)
      REAL, INTENT(IN) :: KWAVE(MSC,MICMAX)
      INTEGER :: IX, IY
!
!  5. Parameter variables
!
!     EPS   :     tolerance value
!     IC    :     complex unity
!     MAXIT :     maximum number of iterations
!
      INTEGER MAXIT
      PARAMETER (MAXIT=50)
      REAL    EPS
      PARAMETER (EPS=1.0D-4)
      COMPLEX IC
      PARAMETER (IC=(0.,1.))
!
!  6. Local variables
!
!     DFI   :     difference quotient corresponding to gy-i*fy
!     DFR   :     difference quotient corresponding to fx+i*gx
!     DK    :     increment of complex wave number
!     F0    :     complex-valued function (cf. formula (9)) with
!                 argument the previous wave number
!     FM    :     complex-valued function (cf. formula (9)) with
!                 argument the previous wave number minus increment
!     FP    :     complex-valued function (cf. formula (9)) with
!                 argument the previous wave number plus increment
!     GAMMA :     a parameter for Gade's solution
!     IENT  :     number of entries
!     IS    :     counter
!     IT    :     iteration counter
!     KGADE :     complex wave number based on Gade's harmonic solution
!     KOLD  :     complex wave number from previous iteration
!     LG    :     complex boundary layer thickness
!     RES   :     complex residual
!     RESI  :     imaginary part of residual
!     RESR  :     real part of residual
!     RHO0  :     water density
!     RHOM  :     density of fluid mud layer
!     XNUM  :     fluid mud viscosity
!
      INTEGER IENT, IS, IT
      REAL    RHO0, RHOM, XNUM
      COMPLEX DFI, DFR, DK, F0, FM, FP, GAMMA, KGADE, KOLD, LG,
     &        RES, RESI, RESR
!
!  8. Subroutines used
!
!     EVALCF           Evaluation of complex-valued function F
!                      (cf. formula (9)) in Newton-Raphson iteration
!     CTANH            tanh-function of complex number
!     STRACE           Tracing routine for debugging
!
!  9. Subroutines calling
!
!     SWMUD
!
! 13. Source text
!
      SAVE IENT
      DATA IENT/0/
      IF (LTRACE) CALL STRACE (IENT,'SKWAVM')
!
!     --- determine some constants
!
      RHOM = PMUD(2)
      RHO0 = PMUD(3)
      XNUM = PMUD(4)

      NS: DO IS = 1, ISSTOP                                              !40.61mud
!
!        --- calculate Gade's harmonic solution of complex wave number
!
         LG  = (1.-IC)*SQRT(SPCSIG(IS)/2./XNUM)
         IF (THICKM.EQ.0.) THEN
            GAMMA = 0.
         ELSE
            GAMMA = 1. - CTANH(LG*THICKM)/(LG*THICKM)
         END IF
         KGADE = SPCSIG(IS)/SQRT(GRAV*DEP) / SQRT(1.+GAMMA*THICKM/DEP)
!
!        --- initialisations
!
         KMUD(IS) = KGADE
         KOLD     = KGADE
         DK       = KGADE/50.
!
!        --- Newton-Raphson iteration
!
         NR : DO IT = 1, MAXIT

            CALL EVALCF( F0, KOLD )
            IF (ABS(F0).LT.1.E-6) EXIT NR
!
!           --- estimate derivative of F
!
            CALL EVALCF( FP, KOLD+REAL(DK) )
            CALL EVALCF( FM, KOLD-REAL(DK) )
            DFR = (FP-FM)/(2.*REAL(DK))
!
!           --- determine the residual
!
            IF (THICKM < tiny(THICKM)) THEN                              !40.61mud
               RES = -F0/DFR
            ELSE
               CALL EVALCF( FP, KOLD+IC*IMAG(DK) )
               CALL EVALCF( FM, KOLD-IC*IMAG(DK) )
               DFI = (FP-FM)/(2.*IC*IMAG(DK))

               RESR = -REAL( F0 * CONJG(DFI) )/REAL( DFR * CONJG(DFI) )
               RESI = -IMAG( F0 * CONJG(DFR) )/REAL( DFI * CONJG(DFR) )
               RES  = RESR + IC*RESI
            END IF
!
!           --- update the wave number
!
            KMUD(IS) = KOLD + RES
!
!           --- check convergence
!
            IF ( REAL(KMUD(IS)).LT.0. .OR.
     &           ABS(KMUD(IS)).GT.10.*ABS(KGADE) ) THEN
!              no convergence, set to Gade's solution
               KMUD(IS) = KGADE
               EXIT NR
            END IF
            IF ( ABS(RES)/ABS(KOLD).LT.EPS ) EXIT NR
            KOLD = KMUD(IS)

         END DO NR

      END DO NS

      RETURN

      CONTAINS
!
      SUBROUTINE EVALCF ( F, K )
!
      IMPLICIT NONE
!
!     Argument variables
!
!     F           complex-valued function to be computed
!     K           complex wave number as argument
!
      COMPLEX F, K
!
!     Local variables
!
!     KDAMP :     auxiliary factor in formula (9)
!     QRHO  :     quotient of water density and mud density
!     RDSP  :     ratio between gravity times wave number and
!                 squared frequency (followed from dispersion relation)
!     TKH   :     tanh of wave number times depth
!
      REAL    QRHO
      COMPLEX KDAMP, RDSP, TKH
!
!     Subroutines used
!
!     CTANH       tanh-function of complex number
!
      KDAMP = K*THICKM - K/LG * CTANH(LG*THICKM)
      QRHO  = RHO0/RHOM
      RDSP  = GRAV*K/(SPCSIG(IS))**2
      TKH   = CTANH(K*DEP)

      F = ( -1. + (1.-QRHO) * RDSP * KDAMP ) * ( RDSP * TKH - 1.)
     &          -     QRHO         * KDAMP   * ( RDSP - TKH     )

      RETURN
      END SUBROUTINE EVALCF
!
      COMPLEX FUNCTION CTANH(Z)
      COMPLEX Z
         if     (EXP(real(Z)) >  0.1*huge(real(Z))) then                 !40.61mud
            CTANH             = +1.0000000000000000000d0                 !40.61mud
         elseif (EXP(real(Z)) < -0.1*huge(real(Z))) then                 !40.61mud
            CTANH             = -1.0000000000000000000d0                 !40.61mud
         else                                                            !40.61mud
            ! the evaluation below becomes nan for too large Z           !40.61mud
            CTANH = (EXP(Z)-EXP(-Z)) / (EXP(Z)+EXP(-Z))                  !40.61mud
         endif
      END FUNCTION CTANH
!
      END SUBROUTINE SKWAVM
!
!

