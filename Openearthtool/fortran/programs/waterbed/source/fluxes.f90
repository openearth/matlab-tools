   module waterbed_fluxes_mod

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
!   description:
!   this module contains:
!   subroutine initialize_flux
!   subroutine set_ws
!   subroutine soulsby_vanrijn
!   subroutine flux_bvp
!   subroutine set_frac_t
!   ....
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


   use parameters_sed_mod        ! parameters

   implicit none
 
   
   contains

   
   subroutine initialize_flux
   
   allocate(flux%ws(inp%n_frac))
   allocate(flux%e(inp%m_grid,inp%n_grid,inp%n_frac))
   allocate(flux%ep(inp%m_grid,inp%n_grid,inp%n_frac))
   allocate(flux%d_im(inp%m_grid,inp%n_grid,inp%n_frac))
   allocate(flux%d_ex(inp%m_grid,inp%n_grid,inp%n_frac))
   allocate(flux%nt_sub(inp%m_grid,inp%n_grid))


   flux%ws=0.
   flux%e=0.
   flux%ep=0.
   flux%d_im=0.
   flux%d_ex=0.
   flux%nt_sub=1

   write(*,*) 'fluxes are initialized'

   end subroutine initialize_flux








   subroutine set_frac_t
   !this subr determines flux%nt_sub, i.e. the number of subtimesteps
   integer  :: j,m,n
   real, dimension(inp%n_frac)  :: ed
   integer :: nt_e,nt_d

   do m=1,inp%m_grid
   do n=1,inp%n_grid
      ed=1./(inp%rho_s*(inp%phi_s))  *  (  flux%e(m,n,1:inp%n_frac) *bed(m,n)%p(1,:) - flux%d_ex(m,n,:)   )
      

      nt_e=max(1,ceiling(1.*maxval(ed(:)*inp%dt / (inp%frac_delta*bed(m,n)%delta(1)*bed(m,n)%p(1,:) ) )))
      
      nt_d= max( 1, ceiling( abs(sum(ed)) *inp%dt/inp%frac_delta/minval(bed(m,n)%delta(:))   ))

      flux%nt_sub(m,n)=max(nt_e,nt_d)

   end do   
   end do   

   if (any(flux%nt_sub.gt.1)) then
      write(*,*) maxval(flux%nt_sub)
   endif   


   end subroutine set_frac_t




   end module waterbed_fluxes_mod
