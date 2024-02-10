        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE TRAB19__genmod
          INTERFACE 
            SUBROUTINE TRAB19(U,V,HRMS,RLABDA,TETA,H,TP,D50,D15,D90,NPAR&
     &,PAR,DZBDT,VICMOL,POROS,CHEZY,DZDX,DZDY,SBOTX,SBOTY,CESUS,UA,VA,  &
     &UBOT,KWTUR,UBOT_FROM_COM)
              INTEGER(KIND=4), INTENT(IN) :: NPAR
              REAL(KIND=8), INTENT(IN) :: U
              REAL(KIND=8), INTENT(IN) :: V
              REAL(KIND=8) :: HRMS
              REAL(KIND=8), INTENT(IN) :: RLABDA
              REAL(KIND=8), INTENT(IN) :: TETA
              REAL(KIND=8) :: H
              REAL(KIND=8) :: TP
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D15
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: PAR(NPAR)
              REAL(KIND=8), INTENT(IN) :: DZBDT
              REAL(KIND=8), INTENT(IN) :: VICMOL
              REAL(KIND=8), INTENT(IN) :: POROS
              REAL(KIND=8), INTENT(IN) :: CHEZY
              REAL(KIND=8), INTENT(IN) :: DZDX
              REAL(KIND=8), INTENT(IN) :: DZDY
              REAL(KIND=8), INTENT(OUT) :: SBOTX
              REAL(KIND=8), INTENT(OUT) :: SBOTY
              REAL(KIND=8), INTENT(OUT) :: CESUS
              REAL(KIND=8), INTENT(OUT) :: UA
              REAL(KIND=8), INTENT(OUT) :: VA
              REAL(KIND=8), INTENT(IN) :: UBOT
              REAL(KIND=8), INTENT(IN) :: KWTUR
              LOGICAL(KIND=4), INTENT(IN) :: UBOT_FROM_COM
            END SUBROUTINE TRAB19
          END INTERFACE 
        END MODULE TRAB19__genmod
