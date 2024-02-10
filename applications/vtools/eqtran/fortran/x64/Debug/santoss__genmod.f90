        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS__genmod
          INTERFACE 
            SUBROUTINE SANTOSS(H,D50,D90,HRMS,TP,UORB,TETA,UUU,VVV,UMOD,&
     &ZUMOD,AG,VICMOL,RHOSOL,RHOWAT,SW_EFFECTS,AS_EFFECTS,PL_EFFECTS,   &
     &SL_EFFECTS,DZDUU,DZDVV,I2D3D,SBCU,SBCV,SBWU,SBWV,SSWU,SSWV,UWC,UWT&
     &,RH,KSW,KSC,UCREPR,UTREPR,FCWC,FCWT,SCREPR,STREPR,PC,PT,OCC,OTC,  &
     &OTT,OCT,TC,TT,PHICX,PHITX,QSU,SK,AS,ERROR,MESSAGE)
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: UORB
              REAL(KIND=8), INTENT(IN) :: TETA
              REAL(KIND=8), INTENT(IN) :: UUU
              REAL(KIND=8), INTENT(IN) :: VVV
              REAL(KIND=8), INTENT(IN) :: UMOD
              REAL(KIND=8), INTENT(IN) :: ZUMOD
              REAL(KIND=8), INTENT(IN) :: AG
              REAL(KIND=8), INTENT(IN) :: VICMOL
              REAL(KIND=8), INTENT(IN) :: RHOSOL
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              INTEGER(KIND=4), INTENT(IN) :: SW_EFFECTS
              INTEGER(KIND=4), INTENT(IN) :: AS_EFFECTS
              INTEGER(KIND=4), INTENT(IN) :: PL_EFFECTS
              INTEGER(KIND=4), INTENT(IN) :: SL_EFFECTS
              REAL(KIND=8), INTENT(IN) :: DZDUU
              REAL(KIND=8), INTENT(IN) :: DZDVV
              INTEGER(KIND=4), INTENT(IN) :: I2D3D
              REAL(KIND=8), INTENT(OUT) :: SBCU
              REAL(KIND=8), INTENT(OUT) :: SBCV
              REAL(KIND=8), INTENT(OUT) :: SBWU
              REAL(KIND=8), INTENT(OUT) :: SBWV
              REAL(KIND=8), INTENT(OUT) :: SSWU
              REAL(KIND=8), INTENT(OUT) :: SSWV
              REAL(KIND=8), INTENT(OUT) :: UWC
              REAL(KIND=8), INTENT(OUT) :: UWT
              REAL(KIND=8), INTENT(OUT) :: RH
              REAL(KIND=8), INTENT(OUT) :: KSW
              REAL(KIND=8), INTENT(OUT) :: KSC
              REAL(KIND=8), INTENT(OUT) :: UCREPR
              REAL(KIND=8), INTENT(OUT) :: UTREPR
              REAL(KIND=8), INTENT(OUT) :: FCWC
              REAL(KIND=8), INTENT(OUT) :: FCWT
              REAL(KIND=8), INTENT(OUT) :: SCREPR
              REAL(KIND=8), INTENT(OUT) :: STREPR
              REAL(KIND=8), INTENT(OUT) :: PC
              REAL(KIND=8), INTENT(OUT) :: PT
              REAL(KIND=8), INTENT(OUT) :: OCC
              REAL(KIND=8), INTENT(OUT) :: OTC
              REAL(KIND=8), INTENT(OUT) :: OTT
              REAL(KIND=8), INTENT(OUT) :: OCT
              REAL(KIND=8), INTENT(OUT) :: TC
              REAL(KIND=8), INTENT(OUT) :: TT
              REAL(KIND=8), INTENT(OUT) :: PHICX
              REAL(KIND=8), INTENT(OUT) :: PHITX
              REAL(KIND=8), INTENT(OUT) :: QSU
              REAL(KIND=8), INTENT(OUT) :: SK
              REAL(KIND=8), INTENT(OUT) :: AS
              LOGICAL(KIND=4), INTENT(OUT) :: ERROR
              CHARACTER(LEN=256), INTENT(OUT) :: MESSAGE
            END SUBROUTINE SANTOSS
          END INTERFACE 
        END MODULE SANTOSS__genmod
