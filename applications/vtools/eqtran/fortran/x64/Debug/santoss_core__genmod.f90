        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:05 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SANTOSS_CORE__genmod
          INTERFACE 
            SUBROUTINE SANTOSS_CORE(PL_EFFECTS,SW_EFFECTS,G,D50,D,HW,   &
     &RHOS,RHOW,DELTA,TP,R,B,TC,TT,TCU,TCD,TTU,TTD,SFLTC,SFLTT,WSS,RH,  &
     &SCR_C,SCR_T,SC,ST,SCX,SCY,STX,STY,UC,UT,N,M,ALPHAS,ALPHAR,PCR,PC, &
     &PT,OC,OCC,OCT,OT,OTT,OTC,PHICX,PHITX,PHICY,PHITY,QSX,QSY)
              INTEGER(KIND=4), INTENT(IN) :: PL_EFFECTS
              INTEGER(KIND=4), INTENT(IN) :: SW_EFFECTS
              REAL(KIND=8), INTENT(IN) :: G
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: D
              REAL(KIND=8), INTENT(IN) :: HW
              REAL(KIND=8), INTENT(IN) :: RHOS
              REAL(KIND=8), INTENT(IN) :: RHOW
              REAL(KIND=8), INTENT(IN) :: DELTA
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: R
              REAL(KIND=8), INTENT(IN) :: B
              REAL(KIND=8), INTENT(IN) :: TC
              REAL(KIND=8), INTENT(IN) :: TT
              REAL(KIND=8), INTENT(IN) :: TCU
              REAL(KIND=8), INTENT(IN) :: TCD
              REAL(KIND=8), INTENT(IN) :: TTU
              REAL(KIND=8), INTENT(IN) :: TTD
              REAL(KIND=8), INTENT(IN) :: SFLTC
              REAL(KIND=8), INTENT(IN) :: SFLTT
              REAL(KIND=8), INTENT(IN) :: WSS
              REAL(KIND=8), INTENT(IN) :: RH
              REAL(KIND=8), INTENT(IN) :: SCR_C
              REAL(KIND=8), INTENT(IN) :: SCR_T
              REAL(KIND=8), INTENT(IN) :: SC
              REAL(KIND=8), INTENT(IN) :: ST
              REAL(KIND=8), INTENT(IN) :: SCX
              REAL(KIND=8), INTENT(IN) :: SCY
              REAL(KIND=8), INTENT(IN) :: STX
              REAL(KIND=8), INTENT(IN) :: STY
              REAL(KIND=8), INTENT(IN) :: UC
              REAL(KIND=8), INTENT(IN) :: UT
              REAL(KIND=8), INTENT(IN) :: N
              REAL(KIND=8), INTENT(IN) :: M
              REAL(KIND=8), INTENT(IN) :: ALPHAS
              REAL(KIND=8), INTENT(IN) :: ALPHAR
              REAL(KIND=8), INTENT(IN) :: PCR
              REAL(KIND=8), INTENT(OUT) :: PC
              REAL(KIND=8), INTENT(OUT) :: PT
              REAL(KIND=8), INTENT(OUT) :: OC
              REAL(KIND=8), INTENT(OUT) :: OCC
              REAL(KIND=8), INTENT(OUT) :: OCT
              REAL(KIND=8), INTENT(OUT) :: OT
              REAL(KIND=8), INTENT(OUT) :: OTT
              REAL(KIND=8), INTENT(OUT) :: OTC
              REAL(KIND=8), INTENT(OUT) :: PHICX
              REAL(KIND=8), INTENT(OUT) :: PHITX
              REAL(KIND=8), INTENT(OUT) :: PHICY
              REAL(KIND=8), INTENT(OUT) :: PHITY
              REAL(KIND=8), INTENT(OUT) :: QSX
              REAL(KIND=8), INTENT(OUT) :: QSY
            END SUBROUTINE SANTOSS_CORE
          END INTERFACE 
        END MODULE SANTOSS_CORE__genmod
