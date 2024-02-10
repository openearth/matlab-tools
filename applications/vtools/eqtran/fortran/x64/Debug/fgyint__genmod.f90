        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE FGYINT__genmod
          INTERFACE 
            FUNCTION FGYINT(A,B,Z,EPS,TERFGY)
              REAL(KIND=8), INTENT(IN) :: A
              REAL(KIND=8), INTENT(IN) :: B
              REAL(KIND=8), INTENT(IN) :: Z
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8) :: TERFGY
              EXTERNAL TERFGY
              REAL(KIND=8) :: FGYINT
            END FUNCTION FGYINT
          END INTERFACE 
        END MODULE FGYINT__genmod
