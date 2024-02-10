        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:04 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE UA_RVR__genmod
          INTERFACE 
            SUBROUTINE UA_RVR(FACAS,FACSK,SWS,H,HRMS,RLABDA,URMS,UA)
              REAL(KIND=8), INTENT(IN) :: FACAS
              REAL(KIND=8), INTENT(IN) :: FACSK
              INTEGER(KIND=4), INTENT(IN) :: SWS
              REAL(KIND=8), INTENT(IN) :: H
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: RLABDA
              REAL(KIND=8), INTENT(IN) :: URMS
              REAL(KIND=8), INTENT(OUT) :: UA
            END SUBROUTINE UA_RVR
          END INTERFACE 
        END MODULE UA_RVR__genmod
