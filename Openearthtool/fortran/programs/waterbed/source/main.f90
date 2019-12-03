      program main_1DV
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     copyright (c) 2009 Technische Universiteit Delft
!        bram van prooijen
!        b.c.vanprooijen@tudelft.nl
!        +31(0)15 2784070   
!        faculty of civil engineering and geosciences
!        department of hydraulic engineering
!        po box 5048
!        2600 ga delft
!        the netherlands
!        
!     this library is free software; you can redistribute it and/or
!     modify it under the terms of the gnu lesser general public
!     license as published by the free software foundation; either
!     version 2.1 of the license, or (at your option) any later version.
!
!     this library is distributed in the hope that it will be useful,
!     but without any warranty; without even the implied warranty of
!     merchantability or fitness for a particular purpose.  see the gnu
!     lesser general public license for more details.
!
!     you should have received a copy of the gnu lesser general public
!     license along with this library; if not, write to the free software
!     foundation, inc., 59 temple place, suite 330, boston, ma  02111-1307
!     usa
!
!   This research is supported by the Technology Foundation STW, applied
!   science division of NWO and the technology programme of the Ministry
!   of Economic Affairs.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   description:
!   this is the main program to steer the water-bed exchange modules with a single cell. 
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



!   list of modules used
   use namelist         !input parameters
   use plug_mod
   use parameters_sed_mod
   use flow_mod         !module for flow
   use transport_mod      !module for the transport of suspended sediment
   use waterbed_fluxes_mod         !module for the erosion rate
   use bed_mod            !module for the bed mass balance
   use post_process_mod   !module for the 


!   initialize
   call readinputfile      !namelist
   call plug_1dv_param
   call initialize_flow   !flow_mod
   call initialize_flux   !fluxes_mod
   call initialize_trans   !transport_mod
   call initialize_bed      !bed_mod


   !set time
   time=0.

   !output initial condition
   call bedprofile(1,1,1,1,n_time) !post_process_mod


!  this is the time-loop
   do i_time=1,n_time

      
   !determine the flow at time t^(n+1)
   ! in flow_mod
      call flow_tide(time)                     

   !determine the explicit deposition rate d_ex formulation
   ! in fluxes_mod   
!      call deposition_ex(c,h_old)

   !determine the erosion rate formulation
   ! in fluxes_mod         
      select case(erosion_form)
         case('constant')
!            call erosion_constant
         case('kandiah')
!            call erosion_kandiah(u_new,cf)   
      end select


   !determine the number of subtime steps per cell      
   ! in fluxes_mod
      call set_frac_t
                     
   !bed mass balance
   ! in bed_mod   
      call bed_predict(flux%d_ex,flux%e,flux%nt_sub,flux%ep)

   
   !transport equation
   ! in transport_mod
      call trans_form1


   !corrector step: account for implicit deposition term
   ! in bed_mod   

      call bed_correct(flux%d_im,flux%d_ex,flux%nt_sub)


   !postprocessing
   ! in post_process_mod
!      if (mod(i_time,t_int)==0) then
!         call bedprofile(1,1,1,1,n_time)
!      endif


   enddo
   


   end program main_1dv    






