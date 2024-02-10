        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRAN9T__genmod
          INTERFACE 
            SUBROUTINE TRAN9T(UTOT,D50,D90,CHEZY,H,UST,NPAR,PAR,SBOT,   &
     &SSUS)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: CHEZY
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: UST
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
            END SUBROUTINE TRAN9T
          END INTERFACE 
        END MODULE TRAN9T__genmod
