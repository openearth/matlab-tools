! PROGRAM TEST
!
! AUTHOR:		w.m.kranenburg
! DATE:			juni 2007
! PROJECT:		master thesis 'wave damping by fluid mud'
! TASKMASTER:	WL|Delft Hydraulics, TU Delft
!
! OBJECTIVES:
! Run subroutine zerofinder for different inputs from file(s)
! See zerofinder for more details about objectives	




PROGRAM TEST


USE Writings 
USE Common_Block1
USE Dispersion_Relations

! ------------------------------------------------------------------------------
! NB: ONLY PLACE IN CODE WHERE SOMETHING HAS TO BE SET BY HAND
! Give the name of the Runlist
! Runlist is overview file of runs, declares inputset and DR for each run
! Inputset gives the parameter combinations for that run
! ------------------------------------------------------------------------------

real    :: kGuoS
complex :: kGadeS
complex :: kSVS
complex :: kDeWitS
complex :: kDelftS
complex :: kDalrS
complex :: kNgS

Runlist = 'Runlist00.in'

CALL Read_Header_Runlist

DO runcounter = 1,1	! add number of rows in runlist

write(*,*) 'Runcounter = ', Runcounter
	
	CALL Read_and_Assign_Filenames_and_DR
	CALL Read_Header_Inputfile
	CALL Prep_Output_Iteration

	! Apply zerofinder on each row of the input file
	DO p = 1,rows
		read(10,'(2F11.6, 2F11.4, 2F11.2, 2E11.3)') TS, OmegaS, HS, DS, rhowS, rhomS, nuwS, numS
		
		kGuoS   = GUO2002  (     OmegaS, gS, HS)
		kGadeS  = GADE1958 (     OmegaS, gS, HS, DS, rhowS, rhomS, nuwS, numS)
		kSVS    = SV       (     OmegaS, gS, HS, DS, rhowS, rhomS, nuwS, numS)
		CALL KDEWIT1995(kDeWitS, OmegaS, gS, HS, DS, rhowS, rhomS, nuwS, numS)
		CALL KDELFT2008(kDelftS, OmegaS, gS, HS, DS, rhowS, rhomS, nuwS, numS)
		CALL KDALR1978 (kDalrS,  OmegaS, gS, HS, DS, rhowS, rhomS, nuwS, numS)
		kNgS    = NG2000   (     OmegaS, gS, HS, DS, rhowS, rhomS, nuwS, numS)


		write (50,'(2F11.3, 2F11.4, 2F11.2, 2E11.3, 13E14.6)')					&
				TS, OmegaS, HS, DS, rhowS, rhomS, nuwS, numS,					&
				kGuoS, 															&         
				real(kGadeS),  imag(kGadeS),  real(kSVS),    imag(kSVS),	    &
				real(kDeWitS), imag(kDeWitS), real(kDelftS), imag(kDelftS),     &
				real(kDalrS),  imag(kDalrS),  real(kNgS),    imag(kNgS)
	END DO


	close(10)
	close(50)

END DO !runcounter-loop


END PROGRAM TEST