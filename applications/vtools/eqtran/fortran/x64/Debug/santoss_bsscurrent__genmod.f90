        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_BSSCURRENT__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_BSSCURRENT(I2D3D,G,D,D50,D90,DELTA,UNET, &
     &ANG,ZREF,RH,RL,UNET_DELWBLT,DELWBLT,SC,SCX,SCY)
              INTEGER(KIND=4), INTENT(IN) :: I2D3D
              REAL(KIND=8), INTENT(IN) :: G
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D90
              REAL(KIND=8), INTENT(IN) :: DELTA
              REAL(KIND=8), INTENT(IN) :: UNET
              REAL(KIND=8), INTENT(IN) :: ANG
              REAL(KIND=8), INTENT(IN) :: ZREF
              REAL(KIND=8), INTENT(IN) :: RH
              REAL(KIND=8), INTENT(IN) :: RL
              REAL(KIND=8), INTENT(OUT) :: UNET_DELWBLT
              REAL(KIND=8), INTENT(OUT) :: DELWBLT
              REAL(KIND=8), INTENT(OUT) :: SC
              REAL(KIND=8), INTENT(OUT) :: SCX
              REAL(KIND=8), INTENT(OUT) :: SCY
            END SUBROUTINE SANTOSS_BSSCURRENT
          END INTERFACE 
        END MODULE SANTOSS_BSSCURRENT__genmod
