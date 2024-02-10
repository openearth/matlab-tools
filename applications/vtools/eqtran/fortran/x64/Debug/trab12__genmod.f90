        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:06 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRAB12__genmod
          INTERFACE 
            SUBROUTINE TRAB12(U,V,HRMS,H,TP,DIR,D50,NPAR,PAR,SBOTX,SBOTY&
     &,SSUSX,SSUSY,UBOT,VONKAR,UBOT_FROM_COM)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: U
              REAL(KIND=8), INTENT(IN) :: V
              REAL(KIND=8) :: HRMS
              REAL(KIND=8) :: H
              REAL(KIND=8) :: TP
              REAL(KIND=8), INTENT(IN) :: DIR
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(OUT) :: SBOTX
              REAL(KIND=8), INTENT(OUT) :: SBOTY
              REAL(KIND=8), INTENT(OUT) :: SSUSX
              REAL(KIND=8), INTENT(OUT) :: SSUSY
              REAL(KIND=8) :: UBOT
              REAL(KIND=8), INTENT(IN) :: VONKAR
              LOGICAL(KIND=4), INTENT(IN) :: UBOT_FROM_COM
            END SUBROUTINE TRAB12
          END INTERFACE 
        END MODULE TRAB12__genmod
