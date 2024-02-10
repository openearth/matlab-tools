        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRAM1__genmod
          INTERFACE 
            SUBROUTINE TRAM1(NUMREALPAR,REALPAR,WAVE,NPAR,PAR,KMAX,BED, &
     &TAUADD,TAUCR0,AKS,EPS,CAMAX,FRAC,SIG,THICK,WS,DICWW,LTUR,KMAXSD,  &
     &TAURAT,CAKS,SEDDIF,SIGMOL,RSEDEQ,SCOUR,BEDW,SUSW,SBCU,SBCV,SBWU,  &
     &SBWV,SSWU,SSWV,CONC2D,ERROR,MESSAGE)
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              INTEGER(KIND=4), INTENT(IN) :: NUMREALPAR
              REAL(KIND=8), INTENT(INOUT) :: REALPAR(NUMREALPAR)
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              REAL(KIND=8), INTENT(INOUT) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: BED
              REAL(KIND=8), INTENT(IN) :: TAUADD
              REAL(KIND=8), INTENT(IN) :: TAUCR0
              REAL(KIND=8), INTENT(OUT) :: AKS
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8), INTENT(IN) :: CAMAX
              REAL(KIND=8), INTENT(IN) :: FRAC
              REAL(KIND=8), INTENT(IN) :: SIG(KMAX)
              REAL(KIND=8), INTENT(IN) :: THICK(KMAX)
              REAL(KIND=8), INTENT(IN) :: WS(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: DICWW(0:KMAX)
              INTEGER(KIND=4), INTENT(IN) :: LTUR
              INTEGER(KIND=4), INTENT(OUT) :: KMAXSD
              REAL(KIND=8), INTENT(OUT) :: TAURAT
              REAL(KIND=8), INTENT(OUT) :: CAKS
              REAL(KIND=8), INTENT(OUT) :: SEDDIF(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: SIGMOL
              REAL(KIND=8), INTENT(OUT) :: RSEDEQ(KMAX)
              LOGICAL(KIND=4), INTENT(IN) :: SCOUR
              REAL(KIND=8), INTENT(IN) :: BEDW
              REAL(KIND=8), INTENT(IN) :: SUSW
              REAL(KIND=8), INTENT(OUT) :: SBCU
              REAL(KIND=8), INTENT(OUT) :: SBCV
              REAL(KIND=8), INTENT(OUT) :: SBWU
              REAL(KIND=8), INTENT(OUT) :: SBWV
              REAL(KIND=8), INTENT(OUT) :: SSWU
              REAL(KIND=8), INTENT(OUT) :: SSWV
              REAL(KIND=8), INTENT(OUT) :: CONC2D
              LOGICAL(KIND=4), INTENT(OUT) :: ERROR
              CHARACTER(*), INTENT(OUT) :: MESSAGE
            END SUBROUTINE TRAM1
          END INTERFACE 
        END MODULE TRAM1__genmod
