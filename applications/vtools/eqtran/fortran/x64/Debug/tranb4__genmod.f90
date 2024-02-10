        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRANB4__genmod
          INTERFACE 
            SUBROUTINE TRANB4(UTOT,D,CHEZY,NPAR,PAR,HIDEXP,SBOT,SSUS)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: CHEZY
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: HIDEXP
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
            END SUBROUTINE TRANB4
          END INTERFACE 
        END MODULE TRANB4__genmod
