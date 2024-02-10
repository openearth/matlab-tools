        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRAM2__genmod
          INTERFACE 
            SUBROUTINE TRAM2(NUMREALPAR,REALPAR,WAVE,I2D3D,NPAR,PAR,KMAX&
     &,BED,DZDUU,DZDVV,RKSRS,TAUADD,TAUCR0,AKS,EPS,CAMAX,FRAC,SIG,THICK,&
     &WS,DICWW,LTUR,AKS_SS3D,IFORM,KMAXSD,TAURAT,CAKS,CAKS_SS3D,CONCIN, &
     &SEDDIF,SIGMOL,RSEDEQ,SCOUR,BEDW,SUSW,SBCU,SBCV,SBWU,SBWV,SSWU,SSWV&
     &,TETACR,CONC2D,ERROR,MESSAGE)
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              INTEGER(KIND=4), INTENT(IN) :: NUMREALPAR
              REAL(KIND=8), INTENT(INOUT) :: REALPAR(NUMREALPAR)
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              INTEGER(KIND=4), INTENT(IN) :: I2D3D
              REAL(KIND=8), INTENT(INOUT) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: BED
              REAL(KIND=8), INTENT(IN) :: DZDUU
              REAL(KIND=8), INTENT(IN) :: DZDVV
              REAL(KIND=8), INTENT(IN) :: RKSRS
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
              REAL(KIND=8), INTENT(OUT) :: AKS_SS3D
              INTEGER(KIND=4), INTENT(IN) :: IFORM
              INTEGER(KIND=4), INTENT(OUT) :: KMAXSD
              REAL(KIND=8), INTENT(OUT) :: TAURAT
              REAL(KIND=8), INTENT(OUT) :: CAKS
              REAL(KIND=8), INTENT(OUT) :: CAKS_SS3D
              REAL(KIND=8), INTENT(INOUT) :: CONCIN(KMAX)
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
              REAL(KIND=8), INTENT(IN) :: TETACR
              REAL(KIND=8), INTENT(OUT) :: CONC2D
              LOGICAL(KIND=4), INTENT(OUT) :: ERROR
              CHARACTER(*), INTENT(OUT) :: MESSAGE
            END SUBROUTINE TRAM2
          END INTERFACE 
        END MODULE TRAM2__genmod
