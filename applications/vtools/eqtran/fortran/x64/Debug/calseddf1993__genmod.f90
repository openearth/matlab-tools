        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE CALSEDDF1993__genmod
          INTERFACE 
            SUBROUTINE CALSEDDF1993(USTARC,WS,H1,KMAX,SIG,THICK,DICWW,  &
     &TAUWAV,TAUC,LTUR,EPS,VONKAR,DIFVR,DELTAS,EPSBED,EPSMAX,EPSMXC,    &
     &SEDDIF)
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              REAL(KIND=8), INTENT(IN) :: USTARC
              REAL(KIND=8), INTENT(IN) :: WS(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(IN) :: SIG(KMAX)
              REAL(KIND=8), INTENT(IN) :: THICK(KMAX)
              REAL(KIND=8), INTENT(IN) :: DICWW(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: TAUWAV
              REAL(KIND=8), INTENT(IN) :: TAUC
              INTEGER(KIND=4), INTENT(IN) :: LTUR
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8), INTENT(IN) :: VONKAR
              LOGICAL(KIND=4), INTENT(IN) :: DIFVR
              REAL(KIND=8), INTENT(IN) :: DELTAS
              REAL(KIND=8), INTENT(IN) :: EPSBED
              REAL(KIND=8), INTENT(IN) :: EPSMAX
              REAL(KIND=8), INTENT(OUT) :: EPSMXC
              REAL(KIND=8), INTENT(OUT) :: SEDDIF(0:KMAX)
            END SUBROUTINE CALSEDDF1993
          END INTERFACE 
        END MODULE CALSEDDF1993__genmod
