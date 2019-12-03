   module post_process_mod
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
!   description:
!   this module contains:
!   subroutine bedprofile
!   subroutine writemap
!
!   ....
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


   use parameters_sed_mod        ! parameters
   use matlab_io

   implicit none
   save

      
      integer :: k,l,outputno,t
   character(len=300) fmatname
   


      contains

   subroutine bedprofile(m,n,i0,di,ni)
   integer , intent(in) :: m,n,i0,di,ni


!   if ( 1.0*i_time-(di*(floor(1.*i_time/di))).eq.0.  ) then 

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!   if (i_time.eq.1) then
!      outputno=1
!   endif

   outputno=outputno+1

      write(fmatname,105) 'bedprofile_',m,'_',int(outputno),'.mat' 
105          format(a,i5.5,a,i5.5,a) 
      call wrreal2matf(fmatname,dble(bed(m,n)%p)    ,inp%n_lay,inp%n_frac,'p')   
      call wrreal2matf(fmatname,dble(bed(m,n)%delta),inp%n_lay,1     ,'delta')
      call wrreal2matf(fmatname,dble(bed(m,n)%z0)   ,1    ,1     ,'z0')

!   endif


   end   subroutine bedprofile





   subroutine writemap(t_output)  !xbeach only


   real , dimension(:) , allocatable :: out_p,out_delta
   integer :: i,j,k,l,m,n,t
   real t_output

   allocate(out_p(1:inp%m_grid*inp%n_grid*inp%n_lay*inp%n_frac))
   allocate(out_delta(1:inp%m_grid*inp%n_grid*inp%n_lay))


   t=0
   do m=1,inp%m_grid
   do n=1,inp%n_grid
      do k=1,inp%n_lay
         do l=1,inp%n_frac
            t=t+1
            out_p(t)=bed(m,n)%p(k,l)
         enddo   
      enddo   
   enddo   
   enddo   

   write(fmatname,105) 'bed_',int(t_output),'.mat' 
 105          format(a,i5.5,a) 
   call wrreal2matf(fmatname,dble(out_p),inp%m_grid*inp%n_grid*inp%n_lay*inp%n_frac,1,'p')
   
   t=0
   do m=1,inp%m_grid
   do n=1,inp%n_grid
      do k=1,inp%n_lay
         t=t+1
            out_delta(t)=bed(m,n)%delta(k)
      enddo   
   enddo      
   enddo

   call wrreal2matf(fmatname,dble(out_delta),inp%m_grid*inp%n_grid*inp%n_lay,1,'delta')
   call wrreal2matf(fmatname,dble(bed_grid%z),inp%m_grid,inp%n_grid,'z')
   call wrreal2matf(fmatname,dble(flux%ep(:,:,1)),inp%m_grid,inp%n_grid,'ep')



   end   subroutine writemap


   end    module post_process_mod
