MODULE Writings

USE Common_Block1


CONTAINS


! ----------------------------------------------------------------------------------
! SUBROUTINE Prep_Output_Iteration
! Makes header of output-file
! ----------------------------------------------------------------------------------

SUBROUTINE Prep_Output_Iteration

	open  (50,file=Outputfile)
	write (50,'(2A)')'% Name of file:      ', Outputfile
	write (50,'(2A)')'% Name of inputfile: ', Inputfile
	write (50,'(2A)')'% Used DR:           All'
	write (50,'(2A)')'% Explanation:       Output of iteration to zero crossings. ', &
										  'Gives the values of K where F=0.'
	write (50,'(A)')'% '
	write (50,'(1a1,1a10,7a11,13a14)')									&
			'%', 'T','Omega','H','D',									&
			'rhow','rhom','nuw','num',									&
			'kGuo',														&
			'Re(kGade)', 'Im(kGade)', 'Re(kSV)',   'Im(kSV)',			&
			'Re(kDeWit)','Im(kDeWit)','Re(kDelft)','Im(kDelft)',		&
			'Re(kDalr)', 'Im(kDalr)', 'Re(kNg)',   'Im(kNg)'




END SUBROUTINE Prep_Output_Iteration





! ----------------------------------------------------------------------------------
! SUBROUTINE Read_Header_Inputfile
! Reads header of inputfile, consisting out of 5 lines of text
! ----------------------------------------------------------------------------------

SUBROUTINE Read_Header_Inputfile

open(10,file=Inputfile)				! Param.in of Param2.in
read(10,'(A)') tekst
read(10,'(A)') tekst
read(10,'(2I11)') rows, columns
read(10,'(A)') tekst
read(10,'(A)') tekst


END SUBROUTINE Read_Header_Inputfile




! ----------------------------------------------------------------------------------
! SUBROUTINE Read_Header_Runlist
! Reads header of Runlist, consisting out of 5 lines of text
! ----------------------------------------------------------------------------------

SUBROUTINE Read_Header_Runlist

! Read header runlist
open(11,file=Runlist)			
read(11,'(A)') tekst
read(11,'(A)') tekst
read(11,'(A)') tekst
read(11,'(A)') tekst
read(11,'(A)') tekst

END SUBROUTINE Read_Header_Runlist




! ----------------------------------------------------------------------------------
! SUBROUTINE Read_and_Assign_Filenames_and_DR
! Reads one row out of the runlist and determines filenames and DR out of it
! ----------------------------------------------------------------------------------

SUBROUTINE Read_and_Assign_Filenames_and_DR

read(11,'(2A11)') pos1, pos2
Inputset		= pos1(5:11)
DR				= pos2(8:11)
Inputfile		= 'Inputmap\'//Inputset//'.in'
Outputfile		= 'Outputmap\OUT_'//Inputset//'.dat'

END SUBROUTINE Read_and_Assign_Filenames_and_DR



END MODULE Writings


