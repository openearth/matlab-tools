        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRANB2__genmod
          INTERFACE 
            SUBROUTINE TRANB2(UTOT,D50,D90,CHEZY,H,NPAR,PAR,HIDEXP,SBOT,&
     &SSUS)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: CHEZY
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: HIDEXP
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
            END SUBROUTINE TRANB2
          END INTERFACE 
        END MODULE TRANB2__genmod
