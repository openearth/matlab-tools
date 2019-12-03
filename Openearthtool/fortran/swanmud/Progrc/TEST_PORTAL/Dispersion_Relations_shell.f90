! DISPERSION_RELATIONS_SHELL   wrapper for DISPERSION_RELATIONS
!
! Literature:
!     1) Kranenburg, W.M., 2008. 'Wave damping by fluid mud', M.Sc. thesis TU Delft and WL | Delft hydraulics.
!        http://resolver.tudelft.nl/uuid:7644eb5b-0ec9-4190-9f72-ccd7b50cfc47 (purl)
!     2) Kranenburg, W.M., J.C. Winterwerp, G.J. de Boer, J.M. Cornelisse and M. Zijlema,
!        2010. SWAN-mud, an engineering model for mud-induced wave-damping, ASCE,
!        Journal of Hydraulic Engineering, in press.
!
! See also: DISPERSION_RELATIONS, IMSL zanly

!   --------------------------------------------------------------------
!   Copyright (C) 2008 Delft University of Technology & WL | Delft Hydraulics > Deltares
!       Wouter M. Kranenburg & Gerben J. de Boer
!
!       W.M.Kranenburg@utwente.nl & g.j.deboer@tudelft.nl	
!
!       Fluid Mechanics Section
!       Faculty of Civil Engineering and Geosciences
!       PO Box 5048
!       2600 GA Delft
!       The Netherlands
!
!   This library is free software; you can redistribute it and/or
!   modify it under the terms of the GNU Lesser General Public
!   License as published by the Free Software Foundation; either
!   version 2.1 of the License, or (at your option) any later version.
!
!   This library is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
!   Lesser General Public License for more details.
!
!   You should have received a copy of the GNU Lesser General Public
!   License along with this library; if not, write to the Free Software
!   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
!   USA or
!   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
!   --------------------------------------------------------------------

PROGRAM DISPERSION_RELATIONS_SHELL

USE Dispersion_Relations

implicit none

!! Parameters
!! --------------------------------

   !! General
   !! --------------------------------
      real,    parameter                 :: pi     = 3.141592653589793259 
      complex, parameter                 :: ic     = (0.0,1.0)
      integer                            :: ncommentline
      character(256)                     :: line
      integer                            :: nval, npar, ival, idims, ndims
      integer, dimension(:), allocatable :: dims
      
   !! IO
   !! --------------------------------
      character(LEN=256) :: file_in , file_out ! ISO length
      integer            ::  fid_in  = 10
      integer            ::  fid_out = 20
      
   !! IN (load data per one line: optimal for memory use
   !!    (load entire vector    : optimal for speed
   !! --------------------------------
      type Dispersion_Relations_parameters_single
         real            :: T
         real            :: Omega      !(calculated out of T)
         real            :: hw
         real            :: hm
         real            :: rhow
         real            :: rhom
         real            :: nuw
         real            :: num
         real            :: g = 9.81231
      endtype Dispersion_Relations_parameters_single
      
      type(Dispersion_Relations_parameters_single) :: I ! I<NPUT>
      
   !! OUT
   !! --------------------------------
      type Dispersion_Relations_wavenumbers_single
         real    :: kGuo
         complex :: kGade
         complex :: kSV
         complex :: kDeWit
         complex :: kDelft
         complex :: kDalr
         complex :: kNg
      endtype Dispersion_Relations_wavenumbers_single
      
      type(Dispersion_Relations_wavenumbers_single) :: O ! O<UTPUT>
      
      ! Declarations connected only to FDALR
      !real, parameter :: Zeta   = 0.1  !Probably needed to calculate the constants, but in my opinion not needed for a DR!
      !real, parameter :: Lg     = 40.  !Is it correct to give a Lg AND a K as well???

!! User input
!! --------------------------------

   write(*,*) 'Dispersion_Relations_shell using Dispersion_Relations module'
   write(*,*) 'version: ', Dispersion_Relations_version
   write(*,*) 'The format description of the ASCII input file is:'
   write(*,*) '* any # of comment lines starting with ''%'' (no leading spaces/tabs)'
   write(*,*) '* comment line with descriptor of columns:'
   write(*,*) '   %  1   2       3   4   5       6       7      8'
   write(*,*) '   %  T   Omega   H   D   Rhow    Rhom    nuw    num'  
   write(*,*) '   % [s] [rad/s] [m] [m] [kg/m3] [kg/m3] [m2/s] [m2/s]'
   write(*,*) '* 1 line with >=5 numbers numbers being: '
   write(*,*) ' number_of_rows'
   write(*,*) '  number_of_columns(=8)'
   write(*,*) '   number_of_dimensions_of_original_matrix(>=2) '
   write(*,*) '    dimension(1) ... dimension(n-1)'
   write(*,*) '     dimension(n)=8'
   write(*,*) '* data block of size [number_of_rows number_of_columns] with 8 columns and any number of rows'
   write(*,*) ' column 1 -     T [s]'
   write(*,*) ' column 2 - Omega [rad/s]'
   write(*,*) ' column 3 -    hw [m]'
   write(*,*) ' column 4 -    hm [m]'
   write(*,*) ' column 5 -  rhow [kg/m3]'
   write(*,*) ' column 6 -  rhom [kg/m3]'
   write(*,*) ' column 7 -   nuw [m2/s]'
   write(*,*) ' column 8 -   num [m2/s]'
   write(*,*) ''
   write(*,*) 'Give the name of the INPUT  file with the data vectors        :'
   read (*,*) file_in 
   write(*,*) ''
   write(*,*) 'Give the name of the OUTPUT file (NOT same name as input file):'
   read (*,*) file_out 
   write(*,*) ''

!! Read input file
!! --------------------------------

!    read(i_mdf_file,'(A)',IOSTAT=iost)    key
!    find_dep: DO WHILE & !not end of file
!    ( iost .EQ. 0 )
!        if (uppercase(key)=='FILDEP') then
!            backspace(i_mdf_file)
!            read(i_mdf_file,'(T10,A)',IOSTAT=iost) fname_dep
!        endif
!        read(i_mdf_file,'(A)',IOSTAT=iost)    key
!    enddo find_dep

   open(fid_in,file=file_in)
   read(fid_in,'(a)') line
   !!write(*,*) '>>',trim(line)
   ncommentline = 0
   DO while (line(1:1).eq.'%')
      ncommentline = ncommentline + 1
      read(fid_in,'(a)') line
      !!write(*,*) '>>',trim(line)
   ENDDO
   read(line,*) nval, npar, ndims ! dims is required to be able to reshape multi-dimensional arrays

   allocate(dims(1:ndims))
   read(line,*) nval, npar, ndims, dims
   
!! Loop cases
!! --------------------------------

!         fid_out = Dispersion_Relations_shell_write_start(file_in, file_out)
!FUNCTION fid_out = Dispersion_Relations_shell_write_start(file_in, file_out)

   open  (fid_out,file=file_out)
   write (fid_out,'(2A)')'% Name of inputfile: ', file_in
   write (fid_out,'(2A)')'% Name of file:      ', file_out
   write (fid_out,'(2A)')'% Used DR:           All'
   write (fid_out,'(2A)')'% Explanation:       Output of iteration to zero crossings. ', &
                           'Gives the values of K where F=0.'
   write (fid_out,'(A)')'% '
   write (fid_out,'(1a1,1a10,7a11,13a14)') &
                  '%','T'   ,'Omega','hw'  ,'hm'  , 'rhow','rhom' ,'nuw','num', &
                      'kGuo', &
                      'Re(kGade)' , 'Im(kGade)', 'Re(kSV)'  ,   'Im(kSV)', &
                      'Re(kDeWit)','Im(kDeWit)','Re(kDelft)','Im(kDelft)', &
                      'Re(kDalr)' , 'Im(kDalr)', 'Re(kNg)'  ,   'Im(kNg)'
   write (fid_out,'(1a1,1a10,7a11,13a14)') &
                  '%','[s]'       ,'[rad/s]','[m]'  ,'[m]'  , '[kg/m3]','[kg/m3]' ,'[m2/s]','[m2/s]', &
                      '[rad/s]'   , &
                      '[rad/s]'   , '[rad/s]'  , '[rad/s]'  ,   '[rad/s]', &
                      '[rad/s]'   , '[rad/s]'  , '[rad/s]'  ,   '[rad/s]', &
                      '[rad/s]'   , '[rad/s]'  , '[rad/s]'  ,   '[rad/s]'
   ! increase number of columns to accomodate new output variables as well
   dims(ndims) = 21 
   ! dims is required in file header to be able to reshape 
   ! multi-dimensional arrays to their original size
   write (fid_out,'(I,I,256I,I)') nval, 21, ndims, dims  ! explicit formatting to make sure all dimensions are on line
!! for some reason the dimns=21 comes on teh enxt line with write (fid_out,'(256I)')
!END FUNCTION Dispersion_Relations_shell_write_start

   ! Apply zerofinder on each row of the input file
   DO ival = 1,nval

   write(*,*) ival, ' / ',nval
   
      read(fid_in,*)       I%T, I%Omega,      I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num ! DO NOT USED FIXED FORMAT WHEN READING !!!
      
      O%kGuo   = GUO2002       (I%Omega, I%g, I%hw)
      O%kGade  = GADE1958      (I%Omega, I%g, I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num)
      O%kSV    = SV            (I%Omega, I%g, I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num)
      CALL KDEWIT1995(O%kDeWit, I%Omega, I%g, I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num)
      CALL KDELFT2008(O%kDelft, I%Omega, I%g, I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num)
      CALL KDALR1978 (O%kDalr,  I%Omega, I%g, I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num)
      O%kNg    = NG2000        (I%Omega, I%g, I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num)
      
      write (fid_out,'(2F11.3, 2F11.4, 2F11.2, 2E11.3, 13E14.6)')    &
                           I%T, I%Omega,      I%hw, I%hm, I%rhow, I%rhom, I%nuw, I%num,     &
      O%kGuo,                                                        &
      real(O%kGade),  imag(O%kGade),  real(O%kSV),    imag(O%kSV),   &
      real(O%kDeWit), imag(O%kDeWit), real(O%kDelft), imag(O%kDelft),&
      real(O%kDalr),  imag(O%kDalr),  real(O%kNg),    imag(O%kNg)
   ENDDO

close(fid_in)
close(fid_out)

END PROGRAM DISPERSION_RELATIONS_SHELL

! EOF