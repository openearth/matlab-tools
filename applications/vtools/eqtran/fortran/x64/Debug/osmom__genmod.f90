        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE OSMOM__genmod
          INTERFACE 
            SUBROUTINE OSMOM(HRMS,DEPTH,TP,G,CR,QBB,EV1B,EV2B,EV3B,EV5B,&
     &OD2B,OD3B,OD4B)
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: DEPTH
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: G
              REAL(KIND=8), INTENT(IN) :: CR
              REAL(KIND=8), INTENT(IN) :: QBB
              REAL(KIND=8) :: EV1B
              REAL(KIND=8) :: EV2B
              REAL(KIND=8) :: EV3B
              REAL(KIND=8) :: EV5B
              REAL(KIND=8) :: OD2B
              REAL(KIND=8) :: OD3B
              REAL(KIND=8) :: OD4B
            END SUBROUTINE OSMOM
          END INTERFACE 
        END MODULE OSMOM__genmod
