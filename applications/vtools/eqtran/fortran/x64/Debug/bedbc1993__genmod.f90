        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE BEDBC1993__genmod
          INTERFACE 
            SUBROUTINE BEDBC1993(TP,UORB,RHOWAT,H1,UMOD,ZUMOD,D50,D90,  &
     &Z0CUR,Z0ROU,DSTAR,TAUCR,AKS,USUS,ZUSUS,UWB,DELR,MUC,TAUWAV,USTARC,&
     &TAUC,TAUBCW,TAURAT,TA,CAKS,DSS,MUDFRAC,EPS,AKSFAC,RWAVE,CAMAX,RDC,&
     &RDW,IOPKCW,IOPSUS,VONKAR,WAVE,TAUADD,BETAM,AWB)
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: UORB
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(IN) :: UMOD
              REAL(KIND=8), INTENT(IN) :: ZUMOD
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: Z0CUR
              REAL(KIND=8), INTENT(IN) :: Z0ROU
              REAL(KIND=8), INTENT(IN) :: DSTAR
              REAL(KIND=8), INTENT(IN) :: TAUCR
              REAL(KIND=8), INTENT(OUT) :: AKS
              REAL(KIND=8), INTENT(OUT) :: USUS
              REAL(KIND=8), INTENT(OUT) :: ZUSUS
              REAL(KIND=8), INTENT(OUT) :: UWB
              REAL(KIND=8), INTENT(OUT) :: DELR
              REAL(KIND=8), INTENT(OUT) :: MUC
              REAL(KIND=8), INTENT(OUT) :: TAUWAV
              REAL(KIND=8), INTENT(OUT) :: USTARC
              REAL(KIND=8), INTENT(OUT) :: TAUC
              REAL(KIND=8), INTENT(OUT) :: TAUBCW
              REAL(KIND=8), INTENT(OUT) :: TAURAT
              REAL(KIND=8), INTENT(OUT) :: TA
              REAL(KIND=8), INTENT(OUT) :: CAKS
              REAL(KIND=8), INTENT(INOUT) :: DSS
              REAL(KIND=8), INTENT(IN) :: MUDFRAC
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8), INTENT(IN) :: AKSFAC
              REAL(KIND=8), INTENT(IN) :: RWAVE
              REAL(KIND=8), INTENT(IN) :: CAMAX
              REAL(KIND=8), INTENT(IN) :: RDC
              REAL(KIND=8), INTENT(IN) :: RDW
              INTEGER(KIND=4), INTENT(IN) :: IOPKCW
              INTEGER(KIND=4), INTENT(IN) :: IOPSUS
              REAL(KIND=8), INTENT(IN) :: VONKAR
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              REAL(KIND=8), INTENT(IN) :: TAUADD
              REAL(KIND=8), INTENT(IN) :: BETAM
              REAL(KIND=8), INTENT(OUT) :: AWB
            END SUBROUTINE BEDBC1993
          END INTERFACE 
        END MODULE BEDBC1993__genmod
