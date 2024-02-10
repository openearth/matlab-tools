        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRANB7__genmod
          INTERFACE 
            SUBROUTINE TRANB7(UTOT,D50,D90,H,NPAR,PAR,SBOT,SSUS,VONKAR, &
     &MUDFRAC)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
              REAL(KIND=8), INTENT(IN) :: VONKAR
              REAL(KIND=8), INTENT(IN) :: MUDFRAC
            END SUBROUTINE TRANB7
          END INTERFACE 
        END MODULE TRANB7__genmod
