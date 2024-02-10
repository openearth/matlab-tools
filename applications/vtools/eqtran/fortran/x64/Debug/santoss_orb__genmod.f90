        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_ORB__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_ORB(NT,AS_EFFECTS,TW,UORB,UNET,ANG,TP,   &
     &RHOWAT,D,HW,AW,UW,UWC,UWT,UWCREPR,UWTREPR,TC,TCU,TCD,TT,TTU,TTD,UC&
     &,UT,UCX,UTX,UCY,UTY,UCXREPR,UTXREPR,UCREPR,UTREPR,B)
              INTEGER(KIND=4), INTENT(IN) :: NT
              INTEGER(KIND=4), INTENT(IN) :: AS_EFFECTS
              REAL(KIND=8), INTENT(IN) :: TW(NT)
              REAL(KIND=8), INTENT(IN) :: UORB(NT)
              REAL(KIND=8), INTENT(IN) :: UNET
              REAL(KIND=8), INTENT(IN) :: ANG
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: HW
              REAL(KIND=8), INTENT(INOUT) :: AW
              REAL(KIND=8), INTENT(INOUT) :: UW
              REAL(KIND=8), INTENT(INOUT) :: UWC
              REAL(KIND=8), INTENT(INOUT) :: UWT
              REAL(KIND=8), INTENT(INOUT) :: UWCREPR
              REAL(KIND=8), INTENT(INOUT) :: UWTREPR
              REAL(KIND=8), INTENT(OUT) :: TC
              REAL(KIND=8), INTENT(OUT) :: TCU
              REAL(KIND=8), INTENT(OUT) :: TCD
              REAL(KIND=8), INTENT(OUT) :: TT
              REAL(KIND=8), INTENT(OUT) :: TTU
              REAL(KIND=8), INTENT(OUT) :: TTD
              REAL(KIND=8), INTENT(OUT) :: UC
              REAL(KIND=8), INTENT(OUT) :: UT
              REAL(KIND=8), INTENT(OUT) :: UCX
              REAL(KIND=8), INTENT(OUT) :: UTX
              REAL(KIND=8), INTENT(OUT) :: UCY
              REAL(KIND=8), INTENT(OUT) :: UTY
              REAL(KIND=8), INTENT(OUT) :: UCXREPR
              REAL(KIND=8), INTENT(OUT) :: UTXREPR
              REAL(KIND=8), INTENT(OUT) :: UCREPR
              REAL(KIND=8), INTENT(OUT) :: UTREPR
              REAL(KIND=8), INTENT(OUT) :: B
            END SUBROUTINE SANTOSS_ORB
          END INTERFACE 
        END MODULE SANTOSS_ORB__genmod
