        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRANB5__genmod
          INTERFACE 
            SUBROUTINE TRANB5(U,V,D50,D90,CHEZY,H,HRMS,TP,DIR,NPAR,PAR, &
     &DZDX,DZDY,VONKAR,WS,POROS,SBOTX,SBOTY,SSUSX,SSUSY,CESUS)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: U
              REAL(KIND=8), INTENT(IN) :: V
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: CHEZY
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: DIR
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: DZDX
              REAL(KIND=8), INTENT(IN) :: DZDY
              REAL(KIND=8), INTENT(IN) :: VONKAR
              REAL(KIND=8), INTENT(IN) :: WS
              REAL(KIND=8), INTENT(IN) :: POROS
              REAL(KIND=8), INTENT(OUT) :: SBOTX
              REAL(KIND=8), INTENT(OUT) :: SBOTY
              REAL(KIND=8), INTENT(OUT) :: SSUSX
              REAL(KIND=8), INTENT(OUT) :: SSUSY
              REAL(KIND=8), INTENT(OUT) :: CESUS
            END SUBROUTINE TRANB5
          END INTERFACE 
        END MODULE TRANB5__genmod
