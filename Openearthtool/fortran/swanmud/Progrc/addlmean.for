      SUBROUTINE ADDLMEAN  (AC2        ,ANYBIN     , 
     &                      KWAVE      ,EKTOTGRID  , SPCSIG     )           40.62
!
!*******************************************************************
!
      USE SWCOMM3 ! for KCGRD,MSC,MDC
!
!  0. Authors
!
!     40.62 Gerben de Boer
!
!  1. Updates
!
!     ---
!
!  2. Purpose
!
!     Adds all dependent terms in computation of average wave lenght (p=1).
!     for one grid point.
!
!  3. Method
!
!     ---
!
!  4. Argument variables
!
!     SPCSIG: Relative frequencies in computational domain in sigma-space 30.72
!
      REAL    SPCSIG(MSC)                                                 30.72
!     MSC         Maximum counter of relative frequency
!     MDC         Maximum counter of directional distribution
!
!     one and more dimensional arrays:
!     ---------------------------------
!     AC2       4D     Action density as function of D,S,X,Y and T
!     PI2    [CALCUL]  =2*PI;
!     FRINTF [CALCUL]  =ALOG(SHIG/SLOW)/(MSC-1); frequency integration factor (df/f)
!                       (integral over frequency of G(f) = SUM_j (sigma_j*Gj*FRINTF) )
!     FRINTH [CALCUL]  =SQRT(SFAC); frequency mesh boundary factor
!                       (mesh in frequency space runs from sigma/FRINTH to sigma*FRINTH)
!     PWTAIL(1)        coefficient to calculate tail of the spectrum
!                      tail power of energy density spectrum as function of freq.
!                      =5.; for command GEN3 JANS ...
!                      =5.; for command WCAP JANS ...,
!                           not documented in manual
!                      =5.; for command GROWTH G3 JANS ...,
!                           not documented in manual
!                      =pwtail; set by command SET ... [pwtail]
!
!  8. Subroutines used
!
!     ---
!
!  9. Subroutines calling
!
!     SWOMPU
!
! 11. Remarks
!
!     ---
!
! 12. Structure
!
!     ---
!
! 13. Source text
!
      REAL     KWAVE (MSC      )  ,EKTOTGRID(MCGRD),                    40.62
     &         AC2   (MDC,MSC,MCGRD)  
!
      LOGICAL  ANYBIN(MDC,MSC)
      INTEGER, SAVE :: IENT=0
      CALL STRACE (IENT, 'ADDLMEAN')

!	write(*,*) 'addlmean: ', kwave

      EKTOT = 0

!     new integration method involving FRINTF                           20.59
      DO IS=1, MSC
         SIG2 = (SPCSIG(IS))**2                                         30.72
         ID   = 1 ! same for all wave lenghts, in future make KWAVE (MSC)
         DO ID=1,MDC
            SKK  = SIG2 * (KWAVE(IS))                                   40.62
           IF (ANYBIN(ID,IS)) THEN
           !DO ONLY FOR CURRENT SWEEP
           EKTOT = EKTOT + FRINTF * SKK  * AC2(ID,IS,KCGRD(1))          40.62
           !write(*,*) '>',ID,IS,(ANYBIN(ID,IS)),EKTOT,SKK,AC2(ID,IS,KCGRD(1))
           ENDIF
         ENDDO
      ENDDO

! ==================================
! ALSO TAIL FOR IMAGINARY PART ????? DOES NOT SEEM TO MAKW A DIFFERENCE
! BUT WHY THEN ADD TAIL IN THE FIRST PLACE
! ==================================

!      IF (MSC .GT. 3) THEN                                              10.20
!!        contribution of tail to total energy density
!         PPTAIL = PWTAIL(1) - 1.                                        20.59
!         CETAIL = 1. / (PPTAIL * (1. + PPTAIL * (FRINTH-1.)))           20.59
!         PPTAIL = PWTAIL(1) - 1. - 2.                                   40.00
!!         IF (PPTAIL.LE.0.) THEN
!!           CALL MSGERR (2,'error tail computation')
!!           GOTO 480
!!         ENDIF
!         CKTAIL = 1. / (PPTAIL * (1. + PPTAIL * (FRINTH-1.)))           20.59
!         DO ID=1,MDC
!           !DO FOR ALL DIRECTIONS (ALL 4 SWEEPS)
!           EKTOT  = EKTOT + CKTAIL * SKK  * AC2(ID,MSC,KCGRD(1))        40.62
!         ENDDO
!      ENDIF

      EKTOTGRID(KCGRD(1)) = EKTOTGRID(KCGRD(1)) + EKTOT

      RETURN
      END SUBROUTINE ADDLMEAN

