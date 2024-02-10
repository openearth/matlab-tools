        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE BEDTR1993__genmod
          INTERFACE 
            SUBROUTINE BEDTR1993(UUU,VVV,U2DH,D50,D90,H1,TAURAT,USTARC, &
     &MUC,RHOSOL,DSTAR,WS,HRMS,TP,TETA,RLABDA,UMOD,QBCU,QBCV,QBWU,QBWV, &
     &QSWU,QSWV,RHOWAT,AG,WAVE,EPS,UON,UOFF,VCR,ERROR,MESSAGE)
              REAL(KIND=8), INTENT(IN) :: UUU
              REAL(KIND=8), INTENT(IN) :: VVV
              REAL(KIND=8), INTENT(IN) :: U2DH
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(IN) :: TAURAT
              REAL(KIND=8), INTENT(IN) :: USTARC
              REAL(KIND=8), INTENT(IN) :: MUC
              REAL(KIND=8), INTENT(IN) :: RHOSOL
              REAL(KIND=8), INTENT(IN) :: DSTAR
              REAL(KIND=8), INTENT(IN) :: WS
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: TETA
              REAL(KIND=8), INTENT(IN) :: RLABDA
              REAL(KIND=8), INTENT(IN) :: UMOD
              REAL(KIND=8), INTENT(OUT) :: QBCU
              REAL(KIND=8), INTENT(OUT) :: QBCV
              REAL(KIND=8), INTENT(OUT) :: QBWU
              REAL(KIND=8), INTENT(OUT) :: QBWV
              REAL(KIND=8), INTENT(OUT) :: QSWU
              REAL(KIND=8), INTENT(OUT) :: QSWV
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              REAL(KIND=8), INTENT(IN) :: AG
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8), INTENT(OUT) :: UON
              REAL(KIND=8), INTENT(OUT) :: UOFF
              REAL(KIND=8), INTENT(OUT) :: VCR
              LOGICAL(KIND=4), INTENT(OUT) :: ERROR
              CHARACTER(*), INTENT(OUT) :: MESSAGE
            END SUBROUTINE BEDTR1993
          END INTERFACE 
        END MODULE BEDTR1993__genmod
