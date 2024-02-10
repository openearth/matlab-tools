        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE EQTRAN__genmod
          INTERFACE 
            SUBROUTINE EQTRAN(SIG,THICK,KMAX,WS,LTUR,FRAC,SIGMOL,DICWW, &
     &LUNDIA,TAUCR0,RKSRS,I2D3D,LSECFL,SPIRINT,SUSPFRAC,TETACR,CONCIN,  &
     &DZDUU,DZDVV,UBOT,TAUADD,SUS,BED,SUSW,BEDW,ESPIR,WAVE,SCOUR,       &
     &UBOT_FROM_COM,CAMAX,EPS,IFORM,NPAR,PAR,NUMINTPAR,NUMREALPAR,      &
     &NUMSTRPAR,DLLFUNC,DLLHANDLE,INTPAR,REALPAR,STRPAR,AKS,CAKS,TAURAT,&
     &SEDDIF,RSEDEQ,KMAXSD,CONC2D,SBCU,SBCV,SBWU,SBWV,SSWU,SSWV,DSS,    &
     &CAKS_SS3D,AKS_SS3D,UST2,T_RELAX,ERROR)
              INTEGER(KIND=4), INTENT(IN) :: NUMSTRPAR
              INTEGER(KIND=4), INTENT(IN) :: NUMREALPAR
              INTEGER(KIND=4), INTENT(IN) :: NUMINTPAR
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              REAL(KIND=8), INTENT(IN) :: SIG(KMAX)
              REAL(KIND=8), INTENT(IN) :: THICK(KMAX)
              REAL(KIND=8), INTENT(IN) :: WS(0:KMAX)
              INTEGER(KIND=4), INTENT(IN) :: LTUR
              REAL(KIND=8), INTENT(IN) :: FRAC
              REAL(KIND=8), INTENT(IN) :: SIGMOL
              REAL(KIND=8), INTENT(IN) :: DICWW(0:KMAX)
              INTEGER(KIND=4), INTENT(IN) :: LUNDIA
              REAL(KIND=8), INTENT(IN) :: TAUCR0
              REAL(KIND=8), INTENT(IN) :: RKSRS
              INTEGER(KIND=4), INTENT(IN) :: I2D3D
              INTEGER(KIND=4), INTENT(IN) :: LSECFL
              REAL(KIND=8), INTENT(IN) :: SPIRINT
              LOGICAL(KIND=4), INTENT(IN) :: SUSPFRAC
              REAL(KIND=8), INTENT(IN) :: TETACR
              REAL(KIND=8), INTENT(INOUT) :: CONCIN(KMAX)
              REAL(KIND=8), INTENT(IN) :: DZDUU
              REAL(KIND=8), INTENT(IN) :: DZDVV
              REAL(KIND=8), INTENT(IN) :: UBOT
              REAL(KIND=8), INTENT(IN) :: TAUADD
              REAL(KIND=8), INTENT(IN) :: SUS
              REAL(KIND=8), INTENT(IN) :: BED
              REAL(KIND=8), INTENT(IN) :: SUSW
              REAL(KIND=8), INTENT(IN) :: BEDW
              REAL(KIND=8), INTENT(IN) :: ESPIR
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              LOGICAL(KIND=4), INTENT(IN) :: SCOUR
              LOGICAL(KIND=4), INTENT(IN) :: UBOT_FROM_COM
              REAL(KIND=8), INTENT(IN) :: CAMAX
              REAL(KIND=8), INTENT(IN) :: EPS
              INTEGER(KIND=4), INTENT(IN) :: IFORM
              REAL(KIND=8), INTENT(INOUT) :: PAR(NPAR)
              CHARACTER(LEN=256), INTENT(IN) :: DLLFUNC
              INTEGER(KIND=8), INTENT(IN) :: DLLHANDLE
              INTEGER(KIND=4), INTENT(INOUT) :: INTPAR(NUMINTPAR)
              REAL(KIND=8), INTENT(INOUT) :: REALPAR(NUMREALPAR)
              CHARACTER(LEN=256), INTENT(INOUT) :: STRPAR(NUMSTRPAR)
              REAL(KIND=8), INTENT(INOUT) :: AKS
              REAL(KIND=8), INTENT(OUT) :: CAKS
              REAL(KIND=8), INTENT(OUT) :: TAURAT
              REAL(KIND=8), INTENT(OUT) :: SEDDIF(0:KMAX)
              REAL(KIND=8), INTENT(OUT) :: RSEDEQ(KMAX)
              INTEGER(KIND=4), INTENT(OUT) :: KMAXSD
              REAL(KIND=8), INTENT(OUT) :: CONC2D
              REAL(KIND=8), INTENT(OUT) :: SBCU
              REAL(KIND=8), INTENT(OUT) :: SBCV
              REAL(KIND=8), INTENT(OUT) :: SBWU
              REAL(KIND=8), INTENT(OUT) :: SBWV
              REAL(KIND=8), INTENT(OUT) :: SSWU
              REAL(KIND=8), INTENT(OUT) :: SSWV
              REAL(KIND=8), INTENT(OUT) :: DSS
              REAL(KIND=8), INTENT(OUT) :: CAKS_SS3D
              REAL(KIND=8), INTENT(OUT) :: AKS_SS3D
              REAL(KIND=8), INTENT(OUT) :: UST2
              REAL(KIND=8), INTENT(OUT) :: T_RELAX
              LOGICAL(KIND=4), INTENT(OUT) :: ERROR
            END SUBROUTINE EQTRAN
          END INTERFACE 
        END MODULE EQTRAN__genmod
