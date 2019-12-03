   module namelist
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     copyright (c) 2009 technische universiteit delft
!        bram van prooijen
!        b.c.vanprooijen@tudelft.nl
!      +31(0)15 2784070   
!        faculty of civil engineering and geosciences
!        department of hydraulic engineering
!      po box 5048
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
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   description: read input file...
!
!   to do:
!   the parameters still have to be put in a type. e.g. wb_param%
!   ....
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


   implicit none
   save


   ! declaration of input variables
   integer ios

   !general 
   character(len=300) ,target ::     inputfname
   real               ,target ::     dt                   ! time step
   integer            ,target ::     n_time                  !number of time steps

   !grid
   integer            ,target ::     m_grid
   integer            ,target ::     n_grid
   real               ,target ::     z_bed_fname                ! initial bed level


   !flow
   character(len=300) ,target ::     vel_fname            !velocity file
   character(len=300) ,target ::     cf_fname             ! friction coefficient
   real               ,target ::     rho_w               ! density of water

   
   !sediment
   integer            ,target ::     n_frac
   character(len=300) ,target ::     c_init_fname             !concentration file
   real               ,target ::     rho_s                ! density of sediment
   real, dimension(100),target ::    w_s     ! settling velocity
   real               ,target ::     theta_c         ! theta for the transport equation


   !bed
   integer             ,target ::    var_layer               !erosion formulation   
   character(len=300)  ,target ::    p_init_fname         !velocity file
   integer             ,target ::    n_lay
   character(len=300)  ,target ::    delta_fname           !file with delta (mxnx3) delta_top, delta(2) and delta(3:n_lay)
   real                ,target ::    lim_split             ! split threshold
   real                ,target ::    lim_merge             ! merge threshold
   real                ,target ::    dif_bed               ! diffusivity
   real                ,target ::    phi_s                 ! solid volume fraction [-]
   real                ,target ::    frac_delta          ! the relative thickness to split the timestep


   !erosion_formulation
   character(len=300)  ,target ::    erosion_form         !erosion formulation   
   real, dimension(100) ,target ::   tau_c            !discretisation of the bed strength
   real                 ,target ::   e_0                  !erosion rate parameter


   !postproces
   integer              ,target ::   t_start      
!   integer              ,target ::   t_int      
   integer              ,target ::   t_end      
   integer              ,target ::   m_post      
   real                 ,target ::   dt_output      


   ! other parameters, not in the input file
   integer              ,target ::   i_time
   real                 ,target ::   time


   save
     
   contains



subroutine readinputfile      ! all input variables


   call getarg(1,inputfname)
   write(*,*) 'reading   ',inputfname

   namelist /general/dt,n_time
   namelist /grid/m_grid,n_grid,z_bed_fname
   namelist /flow/vel_fname,cf_fname,rho_w
   namelist /sediment/n_frac   
   namelist /sediment/c_init_fname,rho_s,w_s,theta_c   
   namelist /bed/var_layer,p_init_fname,n_lay,delta_fname,lim_split,lim_merge,dif_bed,phi_s,frac_delta 
   namelist /erosion_formulation/erosion_form,tau_c,e_0
   namelist /postproces/t_start,t_end,m_post,dt_output          


      ! read the items of the inputfile
   open (unit=11,file=inputfname ,iostat=ios,action='read')
   read (unit=11,nml=general     ,iostat=ios)
   read (unit=11,nml=grid        ,iostat=ios)
   read (unit=11,nml=flow        ,iostat=ios)
   read (unit=11,nml=sediment    ,iostat=ios)
   read (unit=11,nml=bed         ,iostat=ios)
   read (unit=11,nml=erosion_formulation,iostat=ios)
   read (unit=11,nml=postproces  ,iostat=ios)
   

   write(*,*) 'readinput finished'


   end subroutine readinputfile

 end module namelist
