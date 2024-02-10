        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_ABREU__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_ABREU(HRMS,KM,D,R_AB,PHI_AB,URMS,TP,NT,TW&
     &,UORB)
              INTEGER(KIND=4), INTENT(IN) :: NT
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: KM
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: R_AB
              REAL(KIND=8), INTENT(IN) :: PHI_AB
              REAL(KIND=8), INTENT(IN) :: URMS
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(OUT) :: TW(NT)
              REAL(KIND=8), INTENT(OUT) :: UORB(NT)
            END SUBROUTINE SANTOSS_ABREU
          END INTERFACE 
        END MODULE SANTOSS_ABREU__genmod
