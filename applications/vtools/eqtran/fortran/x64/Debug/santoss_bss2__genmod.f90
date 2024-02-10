        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_BSS2__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_BSS2(SW_EFFECTS,AS_EFFECTS,G,D,RHOW,RHOS,&
     &DELTA,D50,D90,B,R,T,UW,AW,UWC,UWT,UC,UT,UNET_DELWBLT,ANG,DELWBLT, &
     &ALPHA,KSW,KSC,FW,FCW,TC,TT,TCU,TCD,TTU,TTD,FC,SC,ST,SWC,SWT,SCX,  &
     &SCY,STX,STY,FCWC,FCWT)
              INTEGER(KIND=4), INTENT(IN) :: SW_EFFECTS
              INTEGER(KIND=4), INTENT(IN) :: AS_EFFECTS
              REAL(KIND=8), INTENT(IN) :: G
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: RHOW
              REAL(KIND=8), INTENT(IN) :: RHOS
              REAL(KIND=8), INTENT(IN) :: DELTA
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: B
              REAL(KIND=8), INTENT(IN) :: R
              REAL(KIND=8), INTENT(IN) :: T
              REAL(KIND=8), INTENT(IN) :: UW
              REAL(KIND=8), INTENT(IN) :: AW
              REAL(KIND=8), INTENT(IN) :: UWC
              REAL(KIND=8), INTENT(IN) :: UWT
              REAL(KIND=8), INTENT(IN) :: UC
              REAL(KIND=8), INTENT(IN) :: UT
              REAL(KIND=8), INTENT(IN) :: UNET_DELWBLT
              REAL(KIND=8), INTENT(IN) :: ANG
              REAL(KIND=8), INTENT(IN) :: DELWBLT
              REAL(KIND=8), INTENT(IN) :: ALPHA
              REAL(KIND=8), INTENT(IN) :: KSW
              REAL(KIND=8), INTENT(IN) :: KSC
              REAL(KIND=8), INTENT(IN) :: FW
              REAL(KIND=8), INTENT(IN) :: FCW
              REAL(KIND=8), INTENT(IN) :: TC
              REAL(KIND=8), INTENT(IN) :: TT
              REAL(KIND=8), INTENT(IN) :: TCU
              REAL(KIND=8), INTENT(IN) :: TCD
              REAL(KIND=8), INTENT(IN) :: TTU
              REAL(KIND=8), INTENT(IN) :: TTD
              REAL(KIND=8), INTENT(INOUT) :: FC
              REAL(KIND=8), INTENT(OUT) :: SC
              REAL(KIND=8), INTENT(OUT) :: ST
              REAL(KIND=8), INTENT(OUT) :: SWC
              REAL(KIND=8), INTENT(OUT) :: SWT
              REAL(KIND=8), INTENT(OUT) :: SCX
              REAL(KIND=8), INTENT(OUT) :: SCY
              REAL(KIND=8), INTENT(OUT) :: STX
              REAL(KIND=8), INTENT(OUT) :: STY
              REAL(KIND=8), INTENT(OUT) :: FCWC
              REAL(KIND=8), INTENT(OUT) :: FCWT
            END SUBROUTINE SANTOSS_BSS2
          END INTERFACE 
        END MODULE SANTOSS_BSS2__genmod
