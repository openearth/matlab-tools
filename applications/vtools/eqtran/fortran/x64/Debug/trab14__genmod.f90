        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRAB14__genmod
          INTERFACE 
            SUBROUTINE TRAB14(UTOT,D50,CHEZY,NPAR,PAR,HIDEXP,SBOT,SSUS)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: CHEZY
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: HIDEXP
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
            END SUBROUTINE TRAB14
          END INTERFACE 
        END MODULE TRAB14__genmod
