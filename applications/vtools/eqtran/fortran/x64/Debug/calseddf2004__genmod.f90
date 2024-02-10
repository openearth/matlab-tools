        !COMPILER-GENERATED INTERFACE MODULE: Fri Feb  9 15:47:03 2024
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE CALSEDDF2004__genmod
          INTERFACE 
            SUBROUTINE CALSEDDF2004(USTARC,WS,TP,HRMS,H1,SEDDIF,KMAX,SIG&
     &,THICK,DICWW,TAUWAV,TAUC,LTUR,DELW,RHOWAT,UWBIH,AKS,CAKS,CAKS_SS3D&
     &,DELTAS,AKS_SS3D,D50,SALINITY,WS0,PSI,EPSPAR,EPS,VONKAR,SALMAX,   &
     &WAVE,EPSMAX,EPSMXC)
              INTEGER(KIND=4), INTENT(IN) :: KMAX
              REAL(KIND=8), INTENT(IN) :: USTARC
              REAL(KIND=8), INTENT(IN) :: WS(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: TP
              REAL(KIND=8), INTENT(IN) :: HRMS
              REAL(KIND=8), INTENT(IN) :: H1
              REAL(KIND=8), INTENT(OUT) :: SEDDIF(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: SIG(KMAX)
              REAL(KIND=8), INTENT(IN) :: THICK(KMAX)
              REAL(KIND=8), INTENT(IN) :: DICWW(0:KMAX)
              REAL(KIND=8), INTENT(IN) :: TAUWAV
              REAL(KIND=8), INTENT(IN) :: TAUC
              INTEGER(KIND=4), INTENT(IN) :: LTUR
              REAL(KIND=8), INTENT(IN) :: DELW
              REAL(KIND=8), INTENT(IN) :: RHOWAT
              REAL(KIND=8), INTENT(IN) :: UWBIH
              REAL(KIND=8), INTENT(IN) :: AKS
              REAL(KIND=8), INTENT(IN) :: CAKS
              REAL(KIND=8), INTENT(OUT) :: CAKS_SS3D
              REAL(KIND=8), INTENT(OUT) :: DELTAS
              REAL(KIND=8), INTENT(OUT) :: AKS_SS3D
              REAL(KIND=8), INTENT(IN) :: D50
              REAL(KIND=8), INTENT(IN) :: SALINITY
              REAL(KIND=8), INTENT(IN) :: WS0
              REAL(KIND=8), INTENT(IN) :: PSI
              LOGICAL(KIND=4), INTENT(IN) :: EPSPAR
              REAL(KIND=8), INTENT(IN) :: EPS
              REAL(KIND=8), INTENT(IN) :: VONKAR
              REAL(KIND=8), INTENT(IN) :: SALMAX
              LOGICAL(KIND=4), INTENT(IN) :: WAVE
              REAL(KIND=8), INTENT(OUT) :: EPSMAX
              REAL(KIND=8), INTENT(OUT) :: EPSMXC
            END SUBROUTINE CALSEDDF2004
          END INTERFACE 
        END MODULE CALSEDDF2004__genmod
