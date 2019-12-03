module plug_mod

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!   copyright (c) 2009 technische universiteit delft
!   bram van prooijen
!   b.c.vanprooijen@tudelft.nl
!      +31(0)15 2784070   
!   faculty of civil engineering and geosciences
!   department of hydraulic engineering
!      po box 5048
!   2600 ga delft
!   the netherlands
!   
!   this library is free software; you can redistribute it and/or
!   modify it under the terms of the gnu lesser general public
!   license as published by the free software foundation; either
!   version 2.1 of the license, or (at your option) any later version.
!
!   this library is distributed in the hope that it will be useful,
!   but without any warranty; without even the implied warranty of
!   merchantability or fitness for a particular purpose.  see the gnu
!   lesser general public license for more details.
!
!   you should have received a copy of the gnu lesser general public
!   license along with this library; if not, write to the free software
!   foundation, inc., 59 temple place, suite 330, boston, ma  02111-1307
!   usa
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   this module contains the plugs to different packages
!   subroutine plug_xbeach(u,c,z)
!
!   to do: use input from main package to reset some parameters like n_frac
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

use parameters_sed_mod        ! parameters

contains




subroutine plug_1dv_param
use namelist
use parameters_sed_mod

inp%dt             =>   dt             
inp%m_grid         =>   m_grid         
inp%n_grid         =>   n_grid         
inp%rho_w          =>   rho_w          
inp%n_frac	       =>   n_frac
inp%rho_s          =>   rho_s          
inp%w_s            =>   w_s            
inp%theta_c        =>   theta_c        
inp%p_init_fname   =>   p_init_fname   
inp%delta_fname    =>   delta_fname    
inp%var_layer      =>   var_layer      
inp%n_lay          =>   n_lay
inp%lim_split      =>   lim_split      
inp%lim_merge      =>   lim_merge      
inp%dif_bed        =>   dif_bed        
inp%phi_s          =>   phi_s          
inp%frac_delta     =>   frac_delta     
inp%erosion_form   =>   erosion_form   
inp%tau_c          =>   tau_c          
inp%e_0            =>   e_0            
inp%dt_output      =>   dt_output      


end subroutine plug_1dv_param


end module plug_mod






