        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:06 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE BAILTR__genmod
          INTERFACE 
            SUBROUTINE BAILTR(H,HRMS,TP,THETAW,W,DZDX,DZDY,SBKSI,SBETA, &
     &SSKSI,SSETA,EPSSL,FACA,FACU,AG)
              REAL(KIND=8) :: H
              REAL(KIND=8) :: HRMS
              REAL(KIND=8) :: TP
              REAL(KIND=8), INTENT(IN) :: THETAW
              REAL(KIND=8), INTENT(IN) :: W
              REAL(KIND=8), INTENT(IN) :: DZDX
              REAL(KIND=8), INTENT(IN) :: DZDY
              REAL(KIND=8), INTENT(OUT) :: SBKSI
              REAL(KIND=8), INTENT(OUT) :: SBETA
              REAL(KIND=8), INTENT(OUT) :: SSKSI
              REAL(KIND=8), INTENT(OUT) :: SSETA
              REAL(KIND=8), INTENT(IN) :: EPSSL
              REAL(KIND=8), INTENT(IN) :: FACA
              REAL(KIND=8), INTENT(IN) :: FACU
              REAL(KIND=8), INTENT(IN) :: AG
            END SUBROUTINE BAILTR
          END INTERFACE 
        END MODULE BAILTR__genmod
