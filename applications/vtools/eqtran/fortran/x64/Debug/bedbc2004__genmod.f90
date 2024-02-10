        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE BEDBC2004__genmod
          INTERFACE 
            SUBROUTINE BEDBC2004(TP,RHOWAT,H1,UMOD,D10,ZUMOD,D50,D90,   &
     &Z0CUR,Z0ROU,DRHO,DSTAR,TAUCR0,U2DHIM,AKS,RA,USUS,ZUSUS,UWB,MUC,   &
     &TAUWAV,USTARC,TAUC,TAURAT,TA,CAKS,DSS,UWC,UUU,VVV,RLABDA,TAUBCW,  &
     &HRMS,DELW,UON,UOFF,UWBIH,DELM,FC1,FW1,PHICUR,KSCR,I2D3D,MUDFRAC,  &
     &FSILT,TAUCR1,PSI,DZDUU,DZDVV,EPS,CAMAX,IOPSUS,AG,WAVE,TAUADD,     &
     &GAMTCR,BETAM,AWB,WFORM,PHI_PHASE,R)
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(IN) :: UMOD
              REAL(KIND=8), INTENT(IN) :: D10
              REAL(KIND=8), INTENT(IN) :: ZUMOD
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: Z0CUR
              REAL(KIND=8), INTENT(IN) :: Z0ROU
              REAL(KIND=8), INTENT(IN) :: DRHO
              REAL(KIND=8), INTENT(IN) :: DSTAR
              REAL(KIND=8), INTENT(IN) :: TAUCR0
              REAL(KIND=8) :: U2DHIM
              REAL(KIND=8), INTENT(OUT) :: AKS
              REAL(KIND=8), INTENT(OUT) :: RA
              REAL(KIND=8), INTENT(OUT) :: USUS
              REAL(KIND=8), INTENT(OUT) :: ZUSUS
              REAL(KIND=8), INTENT(OUT) :: UWB
              REAL(KIND=8), INTENT(OUT) :: MUC
              REAL(KIND=8), INTENT(OUT) :: TAUWAV
              REAL(KIND=8), INTENT(OUT) :: USTARC
              REAL(KIND=8), INTENT(OUT) :: TAUC
              REAL(KIND=8), INTENT(OUT) :: TAURAT
              REAL(KIND=8), INTENT(OUT) :: TA
              REAL(KIND=8), INTENT(OUT) :: CAKS
              REAL(KIND=8), INTENT(OUT) :: DSS
              REAL(KIND=8) :: UWC
              REAL(KIND=8), INTENT(IN) :: UUU
              REAL(KIND=8), INTENT(IN) :: VVV
              REAL(KIND=8), INTENT(IN) :: RLABDA
              REAL(KIND=8), INTENT(OUT) :: TAUBCW
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(OUT) :: DELW
              REAL(KIND=8), INTENT(OUT) :: UON
              REAL(KIND=8), INTENT(OUT) :: UOFF
              REAL(KIND=8), INTENT(OUT) :: UWBIH
              REAL(KIND=8) :: DELM
              REAL(KIND=8), INTENT(OUT) :: FC1
              REAL(KIND=8) :: FW1
              REAL(KIND=8), INTENT(OUT) :: PHICUR
              REAL(KIND=8), INTENT(IN) :: KSCR
              INTEGER(KIND=4), INTENT(IN) :: I2D3D
              REAL(KIND=8), INTENT(IN) :: MUDFRAC
              REAL(KIND=8), INTENT(OUT) :: FSILT
              REAL(KIND=8), INTENT(OUT) :: TAUCR1
              REAL(KIND=8), INTENT(OUT) :: PSI
              REAL(KIND=8), INTENT(IN) :: DZDUU
              REAL(KIND=8), INTENT(IN) :: DZDVV
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8), INTENT(IN) :: CAMAX
              INTEGER(KIND=4), INTENT(IN) :: IOPSUS
              REAL(KIND=8), INTENT(IN) :: AG
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              REAL(KIND=8), INTENT(IN) :: TAUADD
              REAL(KIND=8), INTENT(IN) :: GAMTCR
              REAL(KIND=8), INTENT(IN) :: BETAM
              REAL(KIND=8), INTENT(OUT) :: AWB
              INTEGER(KIND=4), INTENT(IN) :: WFORM
              REAL(KIND=8), INTENT(OUT) :: PHI_PHASE
              REAL(KIND=8), INTENT(OUT) :: R
            END SUBROUTINE BEDBC2004
          END INTERFACE 
        END MODULE BEDBC2004__genmod
