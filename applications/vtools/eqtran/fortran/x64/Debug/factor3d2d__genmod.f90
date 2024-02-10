        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE FACTOR3D2D__genmod
          INTERFACE 
            SUBROUTINE FACTOR3D2D(KMAX,AKS,KMAXSD,SIG,THICK,SEDDIF,WS,  &
     &BAKDIF,Z0ROU,H1,FACTOR)
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              REAL(KIND=8), INTENT(INOUT) :: AKS
              INTEGER(KIND=4), INTENT(OUT) :: KMAXSD
              REAL(KIND=8), INTENT(IN) :: SIG(KMAX)
              REAL(KIND=8), INTENT(IN) :: THICK(KMAX)
              REAL(KIND=8), INTENT(IN) :: SEDDIF(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: WS(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: BAKDIF
              REAL(KIND=8), INTENT(IN) :: Z0ROU
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(OUT) :: FACTOR
            END SUBROUTINE FACTOR3D2D
          END INTERFACE 
        END MODULE FACTOR3D2D__genmod
