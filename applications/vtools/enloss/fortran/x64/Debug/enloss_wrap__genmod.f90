        !COMPILER-GENERATED INTERFACE MODULE: Mon Aug 19 09:02:54 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE ENLOSS_WRAP__genmod
          INTERFACE 
            SUBROUTINE ENLOSS_WRAP(D1,BUP,VBOV,HUNOWEIR,WSBEN,WSBOV,    &
     &IFLAGWEIR,CRESTL,RMPBEN,RMPBOV,VEG,VILLEMONTECD1,VILLEMONTECD2,   &
     &IFLAGCRITERIUMVOL,IFLAGLOSSVOL,DTE,TOEST,TESTFIXEDWEIRS,          &
     &VILLEMONTECD3)
              REAL(KIND=8), INTENT(IN) :: D1
              REAL(KIND=8), INTENT(IN) :: BUP
              REAL(KIND=8), INTENT(IN) :: VBOV
              REAL(KIND=8), INTENT(IN) :: HUNOWEIR
              REAL(KIND=8), INTENT(IN) :: WSBEN
              REAL(KIND=8), INTENT(IN) :: WSBOV
              INTEGER(KIND=4), INTENT(IN) :: IFLAGWEIR
              REAL(KIND=8), INTENT(IN) :: CRESTL
              REAL(KIND=8), INTENT(IN) :: RMPBEN
              REAL(KIND=8), INTENT(IN) :: RMPBOV
              REAL(KIND=8), INTENT(IN) :: VEG
              REAL(KIND=8), INTENT(IN) :: VILLEMONTECD1
              REAL(KIND=8), INTENT(IN) :: VILLEMONTECD2
              INTEGER(KIND=4), INTENT(IN) :: IFLAGCRITERIUMVOL
              INTEGER(KIND=4), INTENT(IN) :: IFLAGLOSSVOL
              REAL(KIND=8) :: DTE
              CHARACTER(LEN=4) :: TOEST
              INTEGER(KIND=4), INTENT(IN) :: TESTFIXEDWEIRS
              REAL(KIND=8), INTENT(IN) :: VILLEMONTECD3
            END SUBROUTINE ENLOSS_WRAP
          END INTERFACE 
        END MODULE ENLOSS_WRAP__genmod
