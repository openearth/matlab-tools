        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE WAVENR__genmod
          INTERFACE 
            SUBROUTINE WAVENR(WATER_DEPTH,PERIOD,WAVE_NUMBER,           &
     &LOCAL_GRAVITY)
              REAL(KIND=8), INTENT(IN) :: WATER_DEPTH
              REAL(KIND=8), INTENT(IN) :: PERIOD
              REAL(KIND=8), INTENT(OUT) :: WAVE_NUMBER
              REAL(KIND=8), INTENT(IN) :: LOCAL_GRAVITY
            END SUBROUTINE WAVENR
          END INTERFACE 
        END MODULE WAVENR__genmod
