        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRABG__genmod
          INTERFACE 
            SUBROUTINE TRABG(UTOT,DI,TAUB,NPAR,PAR,SBOT,SSUS,DG,DGSD,   &
     &CHEZY)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: UTOT
              REAL(KIND=8), INTENT(IN) :: DI
              REAL(KIND=8), INTENT(IN) :: TAUB
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(OUT) :: SBOT
              REAL(KIND=8), INTENT(OUT) :: SSUS
              REAL(KIND=8), INTENT(IN) :: DG
              REAL(KIND=8), INTENT(IN) :: DGSD
              REAL(KIND=8), INTENT(IN) :: CHEZY
            END SUBROUTINE TRABG
          END INTERFACE 
        END MODULE TRABG__genmod
