   module bed_mod

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     copyright (c) 2009 technische universiteit delft
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
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   description:
!   this module contains:
!   subroutine initialize_bed
!   subroutine bed_predict
!   subroutine bed_correct
!   ....
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


   use parameters_sed_mod        ! parameters
   use matlab_io                 !read/write matlab files


   implicit none
        

   contains


!!!!!!!!!!!!!!!
   subroutine initialize_bed
   implicit none

!set local parameters
   integer                              i,j,k,l,m,n,t
   real , dimension(:) , allocatable :: p_dummy,delta_dummy



!allocate
   allocate(bed(1:inp%m_grid,1:inp%n_grid))
   allocate(bed_grid%z(1:inp%m_grid,1:inp%n_grid))

   do m=1,inp%m_grid
      do n=1,inp%n_grid
         allocate(bed(m,n)%delta(1:inp%n_lay))
         allocate(bed(m,n)%p(1:inp%n_lay,1:inp%n_frac))
         allocate(bed(m,n)%z0)
      enddo
   enddo

   allocate(p_dummy(1:inp%m_grid*inp%n_grid*inp%n_lay*inp%n_frac))
   allocate(delta_dummy(1:inp%m_grid*inp%n_grid*3))



!read initial conditions
   !read initial mass fraction
   call rdmat2real(inp%p_init_fname,p_dummy,1,inp%m_grid*inp%n_grid*inp%n_lay*inp%n_frac,'p')

   t=0
   do m=1,inp%m_grid
      do n=1,inp%n_grid
         do k=1,inp%n_lay
            do l=1,inp%n_frac
               t=t+1
               bed(m,n)%p(k,l)=p_dummy(t)
            enddo
         enddo   
      enddo   
   enddo   


   call rdmat2real(inp%delta_fname,delta_dummy,1,inp%m_grid*inp%n_grid*3,'delta')
   !read delta 
   t=0
   do m=1,inp%m_grid
      do n=1,inp%n_grid
         do k=1,3
            t=t+1

            select case(k)
               case(1)
                  bed(m,n)%delta(1:inp%var_layer-1)=delta_dummy(t)
               case(2)
                  bed(m,n)%delta(inp%var_layer)=delta_dummy(t)
               case(3)
                  bed(m,n)%delta(inp%var_layer+1:inp%n_lay)=delta_dummy(t)
            end select
         enddo
      enddo   
   enddo      

   
   write(*,*) 'bed is initialized'

   end subroutine initialize_bed







   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !
   !
   !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 


   subroutine bed_predict(d,e,nt_sub,ep) 
   use parameters_sed_mod        ! parameters

   implicit none
   
! set parameters
   real    ,intent (in) , dimension(inp%m_grid,inp%n_grid,inp%n_frac)      :: d,e       !deposition and erosion rate [kg/m2/s]
   integer ,intent (in) , dimension(inp%m_grid,inp%n_grid)                 :: nt_sub    !number of sub time steps
   real    ,intent (out), dimension(inp%m_grid,inp%n_grid,inp%n_frac)      :: ep        !total erosion rate times the mass fraction


! local variables
   real ,dimension(:),         pointer               :: delta         !layer thickness
   real ,dimension(:,:),                   pointer   :: p             !mass fraction
   real ,dimension(inp%m_grid,inp%n_grid,inp%n_frac) :: ep_sub        !erosion rate times the mass fraction per subtimestep   
   real ,dimension(inp%n_lay,inp%n_frac)             :: mass          !mass per layer
   real ,dimension(inp%n_lay,3)                      :: dif,a
   real ,dimension(inp%n_lay)                        :: b,ap          !help matrices
   real                                              :: ed            !sum of erosion and deposition
 
     
   integer                                           :: m,n,i,j
   integer                                           :: t_sub         !sub timestep  
   integer                                           :: n_lay_dum     !dummy number of layers

   
   ep=0.
   

   do m=1,inp%m_grid   !loop over the elements
    do n=1,inp%n_grid   !loop over the elements
      do t_sub=1,nt_sub(m,n)  !loop over the subtimesteps
         delta=>bed(m,n)%delta
         p=>bed(m,n)%p

         !set the lower limit
	     bed(m,n)%z0=bed_grid%z(m,n)-sum(delta)

         !initialize s
               
         ep_sub(m,n,:)=e(m,n,:)*p(1,:)
         ep(m,n,:)=ep(m,n,:)+ep_sub(m,n,:)/nt_sub(m,n)            
                  
         !step 1: define the diffusion matrix dif, 
         !this matrix is equal for all fractions, this might not be the case in reality!!!         

         if (inp%dif_bed.eq. 0.) then
            n_lay_dum=inp%var_layer+1 
         else
            n_lay_dum=inp%n_lay
            dif(1:inp%n_lay,1:3)=0.   

            dif(1,2)=-2./( delta(2 )+delta(1) )
            dif(1,3)= 2./( delta(2 )+delta(1) )
            
            forall (i=2:inp%n_lay-1)
               dif(i,1)= 2./(delta(i)+delta(i-1))
               dif(i,2)=-2./(delta(i)+delta(i-1)) - 2./(delta(i)+delta(i+1))
               dif(i,3)=                            2./(delta(i)+delta(i+1))
            end forall
            
            dif(inp%n_lay,1)= 2./(delta(inp%n_lay-1)+delta(inp%n_lay))
            dif(inp%n_lay,2)=-2./(delta(inp%n_lay-1)+delta(inp%n_lay))
         
            !later a variable bed_dif can be used, for now it is constant...
            dif=inp%dif_bed*inp%rho_s*inp%phi_s*dif
         endif


         !step 2: determine the total erosion/deposition 
         !positive in case of erosion, see it as a downward velocity (but kg/m2/s)  
         ed = sum(ep_sub(m,n,:))- sum(d(m,n,:))
                  

         do j=1,inp%n_frac
            a=0.
            ap=0.
            b=0.

            !initialize mass
            mass(:,j)=p(:,j)*(delta*inp%rho_s*inp%phi_s)
            
            !step 3: build matrix a                     

            select case(inp%var_layer)

               case(1)
                  !in this case: a=0
               case(2)
                  a (1,1:3)= (/0.          ,  min(ed,0.) ,  max(ed,0.) /)   
                  a (2,1:3)= (/-min(ed,0.) , -max(ed,0.) ,   0.          /)
               case(3:1000)
                  a (1,1:3)= (/0.          ,  min(ed,0.) ,  max(ed,0.) /)   

                  a (2:inp%var_layer-1,1)=-min(ed,0.)
                  a (2:inp%var_layer-1,2)=-abs(ed)
                  a (2:inp%var_layer-1,3)=max(ed,0.)

                  a (inp%var_layer,1:3)= (/-min(ed,0.) , -max(ed,0.) ,   0.          /)

            end select


            !add diffusion
            if (inp%dif_bed.eq.0.) then
            else
               a=a+dif
            endif

            !step 4: determine rhs
            ap(1)  =sum(a(1,2:3) * p(1:2,j))
            forall (i=2:n_lay_dum-1)
                 ap  (i)=sum(a  (i,:)*p  (i-1:i+1,j))
            end forall
            ap  (n_lay_dum)=sum(a  (n_lay_dum,1:2)*p  (n_lay_dum-1:n_lay_dum,j))         

            b(1)  =d(m,n,j)  - ep_sub(m,n,j) 

            !step 5: update mass
            mass(1:n_lay_dum,j) = mass(1:n_lay_dum,j) + inp%dt/nt_sub(m,n)* (ap(1:n_lay_dum)+b(1:n_lay_dum))

         enddo !fractions


		!determine help variables p and delta
         forall (i=1:n_lay_dum)
            bed(m,n)%p(i,:)  =mass(i,:)/sum(mass(i,:))
         end forall
         delta(inp%var_layer)=sum(mass(inp%var_layer,:))/(inp%rho_s*inp%phi_s)
  


!        !!!!!!!!!!!!!!!!!!!!!!!!!!
         ! modify grid
         !!!!!!!!!!!!!!!!!!!!!!!!!!

         !merge two upper layers in case of erosion
         if (delta(inp%var_layer)<inp%lim_merge*delta(inp%var_layer+1)) then
            forall( i=1:inp%n_frac)
              p(inp%var_layer,i)               =(delta(inp%var_layer)*p(inp%var_layer,i)+ delta(inp%var_layer+1)*p(inp%var_layer+1,i)  ) &
                                                     /(delta(inp%var_layer)+delta(inp%var_layer+1)) 
              p(inp%var_layer+1:inp%n_lay-1,i) =p(inp%var_layer+2:inp%n_lay,i)
              p(inp%n_lay,i)                   =p(inp%n_lay,i) 
            end forall
            delta(inp%var_layer)               =delta(inp%var_layer+1)+delta(inp%var_layer)
            bed(m,n)%z0                        =bed(m,n)%z0-delta(inp%var_layer+1)
         endif

         !split upper layer in case of erosion
         if (delta(inp%var_layer)>inp%lim_split*delta(inp%var_layer+1)) then
            p(inp%var_layer+1:inp%n_lay,:) = p(inp%var_layer:inp%n_lay-1,:)
            delta(inp%var_layer)           = delta(inp%var_layer)-delta(inp%var_layer+1)
            bed(m,n)%z0                    = bed(m,n)%z0+delta(inp%var_layer+1)
         endif

      enddo  !sub time steps

      bed_grid%z(m,n)   = bed(m,n)%z0   + sum(delta)

    enddo !grid x
   enddo !grid y


   end subroutine bed_predict





   subroutine bed_correct(d_im,d_ex,nt_sub)
   implicit none
   
   real    ,intent (in), dimension(inp%m_grid,inp%n_grid,inp%n_frac)   :: d_im,d_ex   !deposition and erosion rate
   integer ,intent (in), dimension(inp%m_grid,inp%n_grid)          :: nt_sub      !number of sub time steps


   ! local variables
   real ,dimension(:),         pointer   :: delta
   real ,dimension(:,:),                   pointer   :: p
   real ,dimension(inp%m_grid,inp%n_grid,inp%n_frac)             :: d
   real ,dimension(inp%n_lay,3)                          :: a
   real ,dimension(inp%n_lay)                            :: b,ap
   real ,dimension(inp%n_lay,inp%n_frac)                     :: mass       !mass per layer
   real                                              :: dsum
      
   integer                                           :: m,n,i,j,t_sub   
   integer                                           :: n_lay_dum


   !in the predictor step, d_ex is used
   !in the transport equation theta*d_im+(1-theta)d_ex   is used
   !the correction is: theta*(d_im-d_ex) 
   !theta=1
   d=(d_im-d_ex)
   

   do m=1,inp%m_grid
    do n=1,inp%n_grid
      do t_sub=1,nt_sub(m,n)  !loop over the subtimesteps
         delta=>bed(m,n)%delta
         p=>bed(m,n)%p

         dsum=sum(d(m,n,:))

         n_lay_dum=inp%var_layer+1
         do j=1,inp%n_frac
            a=0.
            ap=0.
            b=0.

            !initialize s
            mass(:,j)=p(:,j)*(delta*inp%rho_s*inp%phi_s)


            !step 3: build matrix a            
            !erosion/deposition            

            select case(inp%var_layer)

               case(1)
               case(2)
                  a (1,1:3)= (/0.   , -dsum    ,   0.   /)   
                  a (2,1:3)= (/dsum , 0.       ,   0.    /)
               case(3:1000)
                  a (1,1:3)= (/0. ,   -dsum,   0.   /)   

                  a (2:inp%var_layer-1,1)=dsum
                  a (2:inp%var_layer-1,2)=-dsum
                  a (2:inp%var_layer-1,3)=0.

                  a (2:inp%var_layer  ,1)=dsum
            
            end select


            !step 4: determine rhs
            ap(1)  =sum(a(1,2:3) * p(1:2,j))
            forall(i=2:n_lay_dum-1)
                 ap  (i)=sum(a  (i,:)*p  (i-1:i+1,j))
            end forall
            ap  (n_lay_dum)=sum(a  (n_lay_dum,1:2)*p  (n_lay_dum-1:n_lay_dum,j))
         
            b(1)  =d(m,n,j)       
   
            !step 5: update s
            mass(1:n_lay_dum,j) = mass(1:n_lay_dum,j) + inp%dt/nt_sub(m,n)* (ap(1:n_lay_dum)+b(1:n_lay_dum))            


         enddo ! fractions


         !determine help variables  
         forall (i=1:n_lay_dum)
            p(i,:)  =mass(i,:)/sum(mass(i,:))
         end forall
         delta(inp%var_layer)=sum(mass(inp%var_layer,:))/(inp%rho_s*inp%phi_s)

      
!        !!!!!!!!!!!!!!!!!!!!!!!!!!
         ! modify grid
         !!!!!!!!!!!!!!!!!!!!!!!!!!


         !merge two upper layers in case of erosion
         bed(m,n)%z0=bed_grid%z(m,n)-sum(delta)
         if (delta(inp%var_layer)<inp%lim_merge*delta(inp%var_layer+1)) then
            forall (i=1:inp%n_frac)
              p(inp%var_layer,i)               =(delta(inp%var_layer)*p(inp%var_layer,i)  &
                                                   +delta(inp%var_layer+1)*p(inp%var_layer+1,i) &
                                                 )/(delta(inp%var_layer)+delta(inp%var_layer+1)) 
              p(inp%var_layer+1:inp%n_lay-1,i) =p(inp%var_layer+2:inp%n_lay,i)
              p(inp%n_lay,i)                   =p(inp%n_lay,i) 
            end forall
            delta(inp%var_layer)               =delta(inp%var_layer+1)+delta(inp%var_layer)
            bed(m,n)%z0                        =bed(m,n)%z0-delta(inp%var_layer+1)
         endif

         !split upper layer in case of erosion
         if (delta(inp%var_layer)>inp%lim_split*delta(inp%var_layer+1)) then
            p(inp%var_layer+1:inp%n_lay,:)  =p(inp%var_layer:inp%n_lay-1,:)
            delta(inp%var_layer)            =delta(inp%var_layer)-delta(inp%var_layer+1)
            bed(m,n)%z0                     =bed(m,n)%z0+delta(inp%var_layer+1)
         endif

      enddo  !sub time steps


 
    enddo !grid
   enddo !grid



   end subroutine bed_correct



   end module bed_mod
