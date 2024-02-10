        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE WAVE__genmod
          INTERFACE 
            SUBROUTINE WAVE(UO,T,UUVAR,PI,WH,C,RK,H,AG,WAVEK)
              REAL(KIND=8) :: UO
              REAL(KIND=8), INTENT(IN) :: T
              REAL(KIND=8) :: UUVAR
              REAL(KIND=8), INTENT(IN) :: PI
              REAL(KIND=8), INTENT(IN) :: WH
              REAL(KIND=8), INTENT(IN) :: C
              REAL(KIND=8), INTENT(IN) :: RK
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: AG
              REAL(KIND=8), INTENT(IN) :: WAVEK
            END SUBROUTINE WAVE
          END INTERFACE 
        END MODULE WAVE__genmod
