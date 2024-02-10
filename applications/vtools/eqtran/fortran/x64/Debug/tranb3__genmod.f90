        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRANB3__genmod
          INTERFACE 
            SUBROUTINE TRANB3(UTOT,D35,C,H,NPAR,PAR,SBOT,SSUS)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: D35
              REAL(KIND=8), INTENT(IN) :: C
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
            END SUBROUTINE TRANB3
          END INTERFACE 
        END MODULE TRANB3__genmod
