        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE BEDTR2004__genmod
          INTERFACE 
            SUBROUTINE BEDTR2004(U2DH,D50,D90,H1,RHOSOL,TP,TETA,UON,UOFF&
     &,UWB,TAUCR,DELM,RA,Z0CUR,FC1,FW1,DSTAR,DRHO,PHICUR,QBCU,QBCV,QBWU,&
     &QBWV,QSWU,QSWV,TETACR,AKS,FSILT,SIG,THICK,CONCIN,KMAX,DELTAS,WS,  &
     &RKSRS,DZDUU,DZDVV,RHOWAT,AG,BEDW,PANGLE,FPCO,SUSW,WAVE,EPS,SUBIW, &
     &VCR,ERROR,MESSAGE,WFORM,R,PHI_PHASE,UWBIH)
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              REAL(KIND=8), INTENT(IN) :: U2DH
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(IN) :: RHOSOL
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: TETA
              REAL(KIND=8), INTENT(INOUT) :: UON
              REAL(KIND=8), INTENT(INOUT) :: UOFF
              REAL(KIND=8), INTENT(IN) :: UWB
              REAL(KIND=8), INTENT(IN) :: TAUCR
              REAL(KIND=8), INTENT(IN) :: DELM
              REAL(KIND=8), INTENT(IN) :: RA
              REAL(KIND=8), INTENT(IN) :: Z0CUR
              REAL(KIND=8), INTENT(IN) :: FC1
              REAL(KIND=8), INTENT(IN) :: FW1
              REAL(KIND=8), INTENT(IN) :: DSTAR
              REAL(KIND=8), INTENT(IN) :: DRHO
              REAL(KIND=8), INTENT(IN) :: PHICUR
              REAL(KIND=8), INTENT(OUT) :: QBCU
              REAL(KIND=8), INTENT(OUT) :: QBCV
              REAL(KIND=8), INTENT(OUT) :: QBWU
              REAL(KIND=8), INTENT(OUT) :: QBWV
              REAL(KIND=8), INTENT(OUT) :: QSWU
              REAL(KIND=8), INTENT(OUT) :: QSWV
              REAL(KIND=8), INTENT(IN) :: TETACR
              REAL(KIND=8), INTENT(IN) :: AKS
              REAL(KIND=8), INTENT(IN) :: FSILT
              REAL(KIND=8), INTENT(IN) :: SIG(KMAX)
              REAL(KIND=8), INTENT(IN) :: THICK(KMAX)
              REAL(KIND=8), INTENT(IN) :: CONCIN(KMAX)
              REAL(KIND=8), INTENT(IN) :: DELTAS
              REAL(KIND=8), INTENT(IN) :: WS
              REAL(KIND=8), INTENT(IN) :: RKSRS
              REAL(KIND=8), INTENT(IN) :: DZDUU
              REAL(KIND=8), INTENT(IN) :: DZDVV
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              REAL(KIND=8), INTENT(IN) :: AG
              REAL(KIND=8), INTENT(IN) :: BEDW
              REAL(KIND=8), INTENT(IN) :: PANGLE
              REAL(KIND=8), INTENT(IN) :: FPCO
              REAL(KIND=8), INTENT(IN) :: SUSW
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              REAL(KIND=8), INTENT(IN) :: EPS
              INTEGER(KIND=4), INTENT(IN) :: SUBIW
              REAL(KIND=8), INTENT(OUT) :: VCR
              LOGICAL(KIND=4), INTENT(OUT) :: ERROR
              CHARACTER(*), INTENT(OUT) :: MESSAGE
              INTEGER(KIND=4), INTENT(IN) :: WFORM
              REAL(KIND=8), INTENT(IN) :: R
              REAL(KIND=8), INTENT(IN) :: PHI_PHASE
              REAL(KIND=8), INTENT(IN) :: UWBIH
            END SUBROUTINE BEDTR2004
          END INTERFACE 
        END MODULE BEDTR2004__genmod
