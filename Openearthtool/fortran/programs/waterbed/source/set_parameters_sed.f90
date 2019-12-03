   module parameters_sed_mod
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

!input parameters
type input_type
   !general
   integer               ,pointer  ::   itime              ! number of timesteps
   real                  ,pointer  ::   dt                 !timestep

   !grid
   integer               ,pointer  ::   m_grid             ! number of grid points in m-dir
   integer               ,pointer  ::   n_grid             ! number of grid points in n-dir

   !water 
   real                  ,pointer  ::   rho_w              ! density of water
  
   !sediment
   integer               ,pointer  ::   n_frac
   character(len=300)    ,pointer  ::   c_init_fname       !concentration file
   real                  ,pointer  ::   rho_s              ! density of sediment
   real    ,dimension(:) ,pointer  ::   w_s                ! settling velocity
   real                  ,pointer  ::   theta_c            ! theta for the transport equation


   !bed
   character			 ,pointer  ::   p_init_fname       !file with initial mass fractions (M_gridxN_gridxN_layxN_frac)
   character             ,pointer  ::   delta_fname        !file with delta (MxNx3) delta_top, delta(2) and delta(3:N_lay)
   integer               ,pointer  ::   var_layer          !erosion formulation   
   integer               ,pointer  ::   n_lay
   real                  ,pointer  ::   lim_split          ! split threshold
   real                  ,pointer  ::   lim_merge          ! merge threshold
   real                  ,pointer  ::   dif_bed            ! diffusivity
   real                  ,pointer  ::   phi_s              ! solid volume fraction [-]
   real                  ,pointer  ::   frac_delta         ! the relative thickness to split the timestep


   !erosion_formulation
   character             ,pointer  ::   erosion_form       !erosion formulation   
   real    ,dimension(:) ,pointer  ::   tau_c              !discretisation of the bed strength
   real                  ,pointer  ::   e_0                !erosion rate parameter

   !output
   real                  ,pointer  ::   dt_output          !time interval for output

end type input_type
type(input_type)            :: inp




   !fluxes
   type flux_type   
      real,dimension(:)          , pointer  :: ws         !settling velocity
      real,dimension(:,:,:)      , pointer  :: e         !erosion rate
      real,dimension(:,:,:)      , pointer  :: ep        !erosion rate times the mass fraction
      real,dimension(:,:,:)      , pointer  :: d_im      !implicit deposition rate
      real,dimension(:,:,:)      , pointer  :: d_ex      !explicit deposition rate
      integer, dimension(:,:)    , pointer  :: nt_sub      !number of sub time steps
   end type flux_type
   type(flux_type)                          :: flux


   !bed
   type bed_type
      real                              , pointer     :: z0      !bottom level 
      real ,             dimension(:)   , pointer     :: delta   !layer thickness
      real ,             dimension(:,:) , pointer     :: p      !mass fraction
   end type bed_type
   type(bed_type)      , dimension(:,:) , pointer     :: bed
      
   type bed_grid_type
      real             , dimension(:,:) , pointer     :: z      !bed level
   end type bed_grid_type

   type(bed_grid_type)                                :: bed_grid

      
end module parameters_sed_mod
