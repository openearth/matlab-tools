	MODULE TRANSPORT_MOD
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
!	SUBROUTINE INITIALIZE_TRANS
!	SUBROUTINE TRANS_FORM1
!
!	....
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


	USE parameters_sed_mod
	USE MATLAB_IO
	USE FLOW_MOD,		ONLY: u_old,h_old,cf,u_new,h_new	


	IMPLICIT NONE    
	
	!
	!PUBLIC DATA 
	REAL,DIMENSION(:,:,:) , ALLOCATABLE:: c




      CONTAINS


	SUBROUTINE INITIALIZE_TRANS
	REAL , DIMENSION(inp%M_grid*inp%N_grid*inp%N_frac)		:: c_dummy
	INTEGER								:: t,i,j,k,l,m,n

	ALLOCATE(c(inp%M_grid,inp%N_grid,inp%N_frac))


	CALL rdmat2real(inp%c_init_fname,c_dummy,1,inp%M_grid*inp%N_grid*inp%N_frac,'c')


	!read delta
	t=0
	DO m=1,inp%M_grid		
	DO n=1,inp%N_grid		
		DO k=1,inp%N_frac
			t=t+1
  		    c(m,n,k)=c_dummy(t)
		ENDDO			
	ENDDO	
	ENDDO	
	
	write(*,*) 'trans is initialized'
	END SUBROUTINE INITIALIZE_TRANS


	!
	!
	!
	!
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	

	SUBROUTINE TRANS_FORM1
	INTEGER i	
	
	DO i=1,inp%N_frac	
		c(:,:,i)=( c(:,:,i)/inp%dt - (1-inp%theta_c) * flux%D_ex(:,:,i)/h_old(:,:) + flux%Ep(:,:,i)/h_old(:,:) ) &
     					 /  (1/inp%dt + inp%theta_c* inp%w_s(i)/h_new(:,:) )

		flux%D_im(:,:,i)= inp%w_s(i)*c(:,:,i)
	ENDDO


	END SUBROUTINE TRANS_FORM1


	END	MODULE TRANSPORT_MOD