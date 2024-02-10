        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_RIPPLE__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_RIPPLE(D50,UWC,UWT,DELTA,G,AW,RH,RL)
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: UWC
              REAL(KIND=8), INTENT(IN) :: UWT
              REAL(KIND=8), INTENT(IN) :: DELTA
              REAL(KIND=8), INTENT(IN) :: G
              REAL(KIND=8), INTENT(IN) :: AW
              REAL(KIND=8), INTENT(OUT) :: RH
              REAL(KIND=8), INTENT(OUT) :: RL
            END SUBROUTINE SANTOSS_RIPPLE
          END INTERFACE 
        END MODULE SANTOSS_RIPPLE__genmod
