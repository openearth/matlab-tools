        !COMPILER-GENERATED INTERFACE MODULE: Mon Aug 19 09:02:54 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE ENLOSS__genmod
          INTERFACE 
            SUBROUTINE ENLOSS(AG,D1,EWEIR,HKRUIN,HOV,QUNIT,QVOLK,TOEST, &
     &VOV,EWBEN,WSBOV,WSBEN,DTE,DTEFRI,IFLAGWEIR,CRESTL,RMPBOV,RMPBEN,  &
     &VEG,TESTFIXEDWEIRS,VILLEMONTECD1,VILLEMONTECD2,IFLAGCRITERIUMVOL, &
     &IFLAGLOSSVOL,VILLEMONTECD3)
              REAL(KIND=8), INTENT(IN) :: AG
              REAL(KIND=8), INTENT(IN) :: D1
              REAL(KIND=8), INTENT(IN) :: EWEIR
              REAL(KIND=8), INTENT(IN) :: HKRUIN
              REAL(KIND=8), INTENT(IN) :: HOV
              REAL(KIND=8), INTENT(IN) :: QUNIT
              REAL(KIND=8), INTENT(IN) :: QVOLK
              CHARACTER(LEN=4), INTENT(INOUT) :: TOEST
              REAL(KIND=8), INTENT(IN) :: VOV
              REAL(KIND=8), INTENT(IN) :: EWBEN
              REAL(KIND=8), INTENT(IN) :: WSBOV
              REAL(KIND=8), INTENT(IN) :: WSBEN
              REAL(KIND=8), INTENT(OUT) :: DTE
              REAL(KIND=8), INTENT(IN) :: DTEFRI
              INTEGER(KIND=4), INTENT(IN) :: IFLAGWEIR
              REAL(KIND=8), INTENT(IN) :: CRESTL
              REAL(KIND=8), INTENT(IN) :: RMPBOV
              REAL(KIND=8), INTENT(IN) :: RMPBEN
              REAL(KIND=8), INTENT(IN) :: VEG
              INTEGER(KIND=4), INTENT(IN) :: TESTFIXEDWEIRS
              REAL(KIND=8), INTENT(IN) :: VILLEMONTECD1
              REAL(KIND=8), INTENT(IN) :: VILLEMONTECD2
              INTEGER(KIND=4), INTENT(IN) :: IFLAGCRITERIUMVOL
              INTEGER(KIND=4), INTENT(IN) :: IFLAGLOSSVOL
              REAL(KIND=8), INTENT(IN) :: VILLEMONTECD3
            END SUBROUTINE ENLOSS
          END INTERFACE 
        END MODULE ENLOSS__genmod
