MODULE WATERBED_MOD
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     Copyright (C) 2009 Technische Universiteit Delft
!        Bram van Prooijen
!        b.c.vanprooijen@tudelft.nl
!	   +31(0)15 2784070   
!        Faculty of Civil Engineering and Geosciences
!        department of Hydraulic Engineering
!	   PO Box 5048
!        2600 GA Delft
!        The Netherlands
!        
!     This library is free software; you can redistribute it and/or
!     modify it under the terms of the GNU Lesser General Public
!     License as published by the Free Software Foundation; either
!     version 2.1 of the License, or (at your option) any later version.
!
!     This library is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
!     Lesser General Public License for more details.
!
!     You should have received a copy of the GNU Lesser General Public
!     License along with this library; if not, write to the Free Software
!     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
!     USA
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!	Description:
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	USE NAMELIST			!input parameters
	USE FLUXES_MOD			!module for the erosion rate
	USE BED_MOD				!module for the bed mass balance
	USE PLUG
	USE POST_PROCESS_MOD	!module for the 


	IMPLICIT NONE 


	CONTAINS

	SUBROUTINE BED_UPDATE2

	IF (.not. allocated(bed) ) THEN
!	INITIALIZE
		CALL readinputfile		!NAMELIST
		CALL INITIALIZE_FLUX	!FLUXES_MOD
		CALL INITIALIZE_BED		!BED_MOD

!	write ininital conditions
		CALL BEDPROFILE(1,1,1,1,N_time) !POST_PROCESS_MOD

!	model package
!		SELECT CASE(package)
!			CASE('XBEACH')
				CALL PLUG_XBEACH
!		END SELECT

	ENDIF

	write(*,*) 'waterbed'
	!Determine the explicit deposition rate D_ex formulation
	! in FLUXES_MOD	
!		SELECT CASE(deposition_form)
!			CASE('GALAPPATTI')
!				CALL DEPOSITION_GALAPPATTI(water%c,water%Tsg)
!		END SELECT


	!Determine the erosion rate formulation
	! in FLUXES_MOD			
		SELECT CASE(erosion_form)
			CASE('CONSTANT')
				CALL EROSION_CONSTANT
			CASE('KANDIAH')
!				CALL EROSION_KANDIAH(u_new,cf)	
			CASE('SOULSBY_VANRIJN')
				CALL SOULSBY_VANRIJN
		END SELECT

	!Determine the number of subtime steps per cell		
	! in FLUXES_MOD
		CALL SET_FRAC_T
							
	!bed mass balance
	! in BED_MOD	
		CALL BED_PREDICT(flux%D_ex,flux%E,flux%Nt_sub,flux%Ep)

	!postprocessing
	! in POST_PROCESS_MOD
		IF (mod(i_time,T_int)==0) THEN
			CALL BEDPROFILE(1,1,1,1,N_time)
		ENDIF

	

	END	SUBROUTINE BED_UPDATE2



END MODULE WATERBED_MOD


