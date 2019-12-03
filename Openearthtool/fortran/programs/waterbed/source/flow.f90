	MODULE FLOW_MOD

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
!	This module contains:
!	SUBROUTINE INITIALIZE_FLOW
!	SUBROUTINE FLOW_TIDE
!	SUBROUTINE FLOW_FORM1
!	....
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	USE namelist
	USE MATLAB_IO


	IMPLICIT NONE    

	!!!FLOW
	REAL,DIMENSION(:,:) , ALLOCATABLE:: u_old,h_old,cf
	REAL,DIMENSION(:,:) , ALLOCATABLE:: u_new,h_new


	CONTAINS	



	SUBROUTINE INITIALIZE_FLOW
	
	ALLOCATE(u_old(M_grid,N_grid),h_old(M_grid,N_grid),cf(M_grid,N_grid))
	ALLOCATE(u_new(M_grid,N_grid),h_new(M_grid,N_grid))



	! read flow file timeseries
	

	u_old=1.
	h_old=2.
	u_new=u_old
	h_new=h_old

	cf=0.003

	write(*,*) 'flow is initialized'


	END SUBROUTINE INITIALIZE_FLOW



	SUBROUTINE FLOW_TIDE(time)
	REAL, INTENT(IN):: time
	u_old=u_new
	h_old=h_new
	u_new=cos(time*2.*3.14/12./3600.)
	h_new=h_new
	cf=0.003
	
	END SUBROUTINE FLOW_TIDE



	SUBROUTINE FLOW_FORM1

	u_new=u_old
	h_new=u_old



				

	END SUBROUTINE FLOW_FORM1


	END	MODULE FLOW_MOD