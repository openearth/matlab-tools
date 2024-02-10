        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_BSS1__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_BSS1(I2D3D,G,D,D50,D90,DELTA,AW,UW,UNET, &
     &ZREF,RH,RL,UWC,UWT,ANG,UC,UT,THETA,KSW,KSC,FC,FW,FCW,UNET_DELWBLT,&
     &ALPHA,DELWBLT)
              INTEGER(KIND=4), INTENT(IN) :: I2D3D
              REAL(KIND=8), INTENT(IN) :: G
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: DELTA
              REAL(KIND=8), INTENT(IN) :: AW
              REAL(KIND=8), INTENT(IN) :: UW
              REAL(KIND=8), INTENT(IN) :: UNET
              REAL(KIND=8), INTENT(IN) :: ZREF
              REAL(KIND=8), INTENT(IN) :: RH
              REAL(KIND=8), INTENT(IN) :: RL
              REAL(KIND=8), INTENT(IN) :: UWC
              REAL(KIND=8), INTENT(IN) :: UWT
              REAL(KIND=8), INTENT(IN) :: ANG
              REAL(KIND=8), INTENT(INOUT) :: UC
              REAL(KIND=8), INTENT(INOUT) :: UT
              REAL(KIND=8), INTENT(OUT) :: THETA
              REAL(KIND=8), INTENT(OUT) :: KSW
              REAL(KIND=8), INTENT(OUT) :: KSC
              REAL(KIND=8), INTENT(OUT) :: FC
              REAL(KIND=8), INTENT(OUT) :: FW
              REAL(KIND=8), INTENT(OUT) :: FCW
              REAL(KIND=8), INTENT(OUT) :: UNET_DELWBLT
              REAL(KIND=8), INTENT(OUT) :: ALPHA
              REAL(KIND=8), INTENT(OUT) :: DELWBLT
            END SUBROUTINE SANTOSS_BSS1
          END INTERFACE 
        END MODULE SANTOSS_BSS1__genmod
