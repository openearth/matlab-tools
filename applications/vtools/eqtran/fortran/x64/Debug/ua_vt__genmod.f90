        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE UA_VT__genmod
          INTERFACE 
            SUBROUTINE UA_VT(FACAS,FACSK,SWS,H,HRMS,TP,AG,URMS,UA)
              REAL(KIND=8), INTENT(IN) :: FACAS
              REAL(KIND=8), INTENT(IN) :: FACSK
              INTEGER(KIND=4), INTENT(IN) :: SWS
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: AG
              REAL(KIND=8), INTENT(IN) :: URMS
              REAL(KIND=8), INTENT(OUT) :: UA
            END SUBROUTINE UA_VT
          END INTERFACE 
        END MODULE UA_VT__genmod
