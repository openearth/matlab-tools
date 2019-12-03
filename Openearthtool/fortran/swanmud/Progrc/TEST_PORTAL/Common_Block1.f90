MODULE Common_Block1




! Declaration of global parameters
! These parameters have to be accessible from the DR-functions


! Declaration / Initialisation:
real,    parameter :: pi     = 3.141592653589793259 
real,    parameter :: gS     = 9.81231
complex, parameter :: ic     = (0.0,1.0)


! Auxilliary parameters:
integer :: runcounter, p		! counters loops through runlist and through inputfile
integer :: rows, columns		! characteristics of inputfile


! Declaration needed for read-in runlist and inputfile
character(LEN=12)    :: Runlist
character(LEN=80)	 :: tekst
character(LEN=11)	 :: pos1,pos2
character(LEN=7)     :: Inputset
character(LEN=4)     :: DR
character(LEN=87)    :: Inputfile
character(LEN=29)    :: Outputfile



! Input calculations:
real :: TS     	 
real :: HS
real :: hwS 
real :: DS
real :: hmS
real :: rhowS
real :: rhomS
real :: nuwS
real :: numS
real :: OmegaS      !(calculated out of T)


! Declarations connected only to FDALR
real, parameter :: Zeta   = 0.1		!Probably needed to calculate the constants, but in my opinion not needed for a DR!
real, parameter :: Lg     = 40.		!Is it correct to give a Lg AND a K as well???


END MODULE	Common_Block1



