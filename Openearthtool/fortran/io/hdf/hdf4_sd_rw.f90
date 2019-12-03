module hdf4_sd_rw
!HDF4_SD_RW   Routines to read/write fortran characters/arrays to HDF-SD datasets.
!
! This module contains subroutines that are general and do not need any changes.
!
!   * HDF4_ATTR_WRITE  - Save one assumed-length character variable as HDF file attribute
!   * HDF4_ATTR_READ   - Load HDF file attribute as one assumed-length character variable
!
!   * HDF4_SDS0D_WRITE - Save real(4) scalar    as 1D HDF SD
!   * HDF4_SDS1D_WRITE - Save real(4) 1D vector as 1D HDF SD
!   * HDF4_SDS2D_WRITE - Save real(4) 2D matrix as 2D HDF SD
!   * HDF4_SDS3D_WRITE - Save real(4) 3D matrix as 3D HDF SD
!
!   * HDF4_SDS0D_READ  - Load 1D HDF SD into             real(4) scalar
!   * HDF4_SDS1D_READ  - Load 1D HDF SD into allocatable real(4) 1D vector
!   * HDF4_SDS2D_READ  - Load 2D HDF SD into allocatable real(4) 2D matrix
!   * HDF4_SDS3D_READ  - Load 3D HDF SD into allocatable real(4) 3D matrix
!
! The call of all these functions is syntactically always the same, both
! for reading and for writing:
!
!    call HDF4_###(sd_id,NAME,VALUE,debug)
!
! where 
!
! sd_id   is the file identifier to be obtained prior/after to the call with
!
!    sd_id  = sfstart(FILE_NAME, DFACC_CREATE)
!    status = sfend  (sd_id)
!
!         with:
!         * DFACC_READ   1 Read only access
!         * DFACC_WRITE  2 Read and write access
!         * DFACC_CREATE 4 Create with read and write acces    
!
!         Verify not to call an existing file with DFACC_WRITE because 
!         it does not prompt for exisitng file, but instantaneously wipes it.
!
! NAME    The label of the SD data object. Note that the NAME
!         is not a unique identifier in the SD file, only the 
!         SD data object numbers are unique, the names are simply labels.
! VALUE   fortran array or character variable 
!         the size of the SD data object is automaticaly determined
!         from the size of the fortran object and vv.
! debug   a boolean to speficy whether debug information 
!         should be written to standard output.
!
! The code is contructed using documentation and examples @
! http://www.hdfgroup.org/training/HDFtraining/
! notably on the examples from EXAMPLES_SD.FC
!
! Add the following lib files to Menu Project > Settings > tab Link [Windows OS, Visual Studio]: 
! Add the *.dll to your OS path or simply to the same directory as the executable.
! Note that adding them to your path might conflict with other versions of
! these libraries, notably the ones used by Matlab.
!
! All four sets of *.lib and *.dll below can be obtained from:
! http://www.hdfgroup.org/release4/obtain.html
!
! HDF 4 Software
!   PATH\hd421m.lib PATH\hm421m.lib
!
! ZLIB Compression
!   PATH\zdll.lib
!
! SZIP Compression
!   PATH\szlibdll.lib
!
! JPEG Compression
!  Not required.
!
! Default total link list Compaq Visual Fortran:
!    kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib 
! should be expanded with
!    PATH\hd421m.lib 
!    PATH\hm421m.lib 
!    PATH\zdll.lib 
!    PATH\szlibdll.lib
!
! NOTE LIMITATIONS:
! * HDF4 files cannot exceed a filesize of 2GB, but usually even less.
!   Solution: use multiple files, or explore on HDF5 or netCDF instead.
! * HDF4 files cannot have more than 20,000 object in them, but usually even less.
!   With only HDF-SD arrays and file attributes, we experienced a limit of 5000 objects.
!   Solution: use arrays with more dimensions, use multiple files, or explore on HDF5 or netCDF instead.
!
! See also: sfstart,   sfend,                                  ! file
!           sfscatt,                                           ! save attribute
!           sffattr,   sfgainfo, sfrattr,                      ! load attribute
!           sfcreate,  sfwdata,                     sfendacc,  ! save array
!           sfn2index, sfselect, sfginfo,  sfrdata, sfendacc   ! load array

! To DO: make debug an optional argument, with as default value false

!   --------------------------------------------------------------------
!   Copyright (C) 2007-2008 Delft University of Technology
!       Gerben J. de Boer
!
!       <g.j.deboer@tudelft.nl>, <gerben.deboer@deltares.nl>
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
!   http://www.gnu.org/licenses/licenses.html,
!   http://www.gnu.org/,
!   http://www.fsf.org/
!   -------------------------------------------------------------------

! $Id: hdf4_sd_rw.f90 2175 2010-01-21 13:48:14Z boer_g $
! $Date: 2010-01-21 05:48:14 -0800 (Thu, 21 Jan 2010) $
! $Author: boer_g $
! $Revision: 2175 $
! $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/fortran/io/hdf/hdf4_sd_rw.f90 $
! $Keywords:$

!     declarations
!---------------------------
    
   implicit none

   ! http://publib.boulder.ibm.com/infocenter/macxhelp/v6v81/index.jsp?topic=/com.ibm.xlf81m.doc/pgs/ug34.htm
   real(4) :: nan
   data nan /z'7f800001'/

contains

!! ==================================================
!! HDF4_ATTR_WRITE
!! ==================================================

   subroutine HDF4_ATTR_WRITE(sd_id,FILE_ATTR_NAME,FILE_ATTR_VALUE,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer     , intent(in)   :: sd_id 
      character(*), intent(in)   :: FILE_ATTR_NAME
      character(*), intent(in)   :: FILE_ATTR_VALUE ! case-sensitive !, max 64 ???   
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfscatt     
      
   !     Parameter declaration.
   !---------------------------
      parameter                     DFNT_CHAR8   = 4
      
   !     Variable declaration 
   !---------------------------  
   
      integer                    :: sds_id , status, n_values
   
   !     Write file attributes
   !     Set an attribute that describes the file contents. 
   !     Make sure not to write one with length 0 !!!
   !--------------------------- 
   
         if (debug) then
         write(*,*)     'FILE_ATTR_NAME :'  ,trim(FILE_ATTR_NAME)
         write(*,*) trim(FILE_ATTR_NAME),':',trim(file_attr_value)
         endif

         n_values = max(1,len_trim(FILE_ATTR_VALUE))
         status   = sfscatt(sd_id, &
                            FILE_ATTR_NAME, &
                            DFNT_CHAR8, &
                            n_values, &
                            FILE_ATTR_VALUE)   

   end subroutine HDF4_ATTR_WRITE
   
!! ==================================================
!! HDF4_ATTR_READ
!! ==================================================

   subroutine HDF4_ATTR_READ(sd_id,FILE_ATTR_NAME,FILE_ATTR_VALUE,debug)
      
   !     Input/output declaration.
   !---------------------------

      integer     , intent(in)   :: sd_id 
      character(*), intent(in)   :: FILE_ATTR_NAME
      character(*), intent(inout):: FILE_ATTR_VALUE ! case-sensitive !, max 64 ???   
      logical     , intent(in)   :: debug

   !     Parameter declaration.
   !---------------------------
      ! data_type:
      ! http://hdf.ncsa.uiuc.edu/UG41r3_html/Fundmtls4.html#3081, TABLE 2F
      ! 5 = float32
      ! 6 = float64
      integer      data_type
      character*64 attr_name

   !     Function declaration.
   !---------------------------
      integer status
      integer sffattr,sfgainfo,sfrattr

   !     Variable declaration 
   !---------------------------
      integer attr_index, n_values

   !     a.Find the file attribute defined by file_attr_name.
   !       Note that the first parameter is an SD interface identifier.
   !     b.Get information about the file attribute. (file_attr_name=attr_name
   !     c.Read the file attribute data. 
   !---------------------------

      attr_index     = sffattr (sd_id, FILE_ATTR_NAME)
      status         = sfgainfo(sd_id, attr_index, attr_name, data_type,n_values)
      status         = sfrattr (sd_id, attr_index, FILE_ATTR_VALUE)

         if (debug) then
         write(*,*)     'FILE_ATTR_NAME :'  ,trim(FILE_ATTR_NAME)
         write(*,*) trim(FILE_ATTR_NAME),':',trim(file_attr_value)
         endif
   
   end subroutine HDF4_ATTR_READ

!! ==================================================
!! HDF4_SDS0D_WRITE
!! ==================================================

   subroutine HDF4_SDS0D_WRITE(sd_id,SDS_NAME,SDS_VALUE0D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), dimension(1)      :: SDS_VALUE0D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfcreate, sfwdata, sfendacc   

   !     Parameter declaration.
   !---------------------------
      parameter                     DFNT_FLOAT32 = 5 ! same as SDS_VALUE#D

   !     Variable declaration 
   !---------------------------
      
      integer                    :: sds_id , status
      parameter                     data_type = DFNT_FLOAT32 ! same as sds_value
      parameter                     rank = 1
      integer, dimension(1:rank) :: start, edges, stride
      integer, dimension(1:rank) :: dim_sizes
      integer                    :: dim_index1,dim_index2

   !     Initialize
   !---------------------------

      dim_sizes(1) = 1

      sds_id    = sfcreate(sd_id, SDS_NAME, data_type, rank, dim_sizes(1:rank)); ! To create new data set
      
      if (debug) then
         write(*,*) 'SDS_NAME:',SDS_NAME,' = ',SDS_VALUE0D(1)
         write(*,'(x,i9,X,i6,x,i9,x,i4,x,3(i4))') &
                           sd_id, &
                           sds_id,&
                           data_type,&
                           rank,&
                           dim_sizes(1:rank)
      endif

      !     Define the location and size of the data to be written
      !     to the data set. Note that setting values of the sds_value stride to 1
      !     specifies the contiguous writing of data.
      !---------------------------

       start (1) = 0              ! counting is zero-based (C convenction)
       edges (1) = dim_sizes(1)   ! NOT edge, but # of values to be written, here entire 2D slice
       stride(1) = 1
       
       status = sfwdata(sds_id, start, stride, edges, SDS_VALUE0D(1))

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS0D_WRITE

!! ==================================================
!! HDF4_SDS0D_READ
!! ==================================================

   subroutine HDF4_SDS0D_READ(sd_id,SDS_NAME,SDS_VALUE0D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), dimension(1)      :: SDS_VALUE0D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfn2index, sfselect, sfginfo, sfrdata, sfendacc

   !     Parameter declaration.
   !---------------------------
      parameter                        DFNT_FLOAT32 = 5  ! same as SDS_VALUE#D
      parameter                        MAXRANK      = 32 ! max 32, but we read only 0D-3D matrices, and our arrays need pre defined a rank.

   !     Variable declaration 
   !---------------------------
      
      character(LEN=LEN(SDS_NAME))  :: SDS_NAMEread ! sfginfo reads it although we already know it
      
      integer                       :: sds_id , status, sds_index, n_attrs
      integer                       :: data_type
      integer                       :: rank

      integer, dimension(1:MAXRANK) :: start, edges, stride
      integer, dimension(1:MAXRANK) :: dim_sizes
      integer                       :: dim_index1

   !     Initialize
   !---------------------------

         sds_index = sfn2index(sd_id,  SDS_NAME) ! returns -1 when failed, 0 is first succesful number (zero based)
         sds_id    = sfselect (sd_id,  sds_index)

         status    = sfginfo  (sds_id, SDS_NAMEread, rank, dim_sizes, data_type, n_attrs)

         ! check 
         ! rank == 1
         ! data_type == DFNT_FLOAT32 ! same as sds_value

         start (1) = 0              ! counting is zero-based (C convenction)
         edges (1) = dim_sizes(1)   ! NOT edge, but # of values to be written, here entire 2D slice
         stride(1) = 1
         
         status    = sfrdata(sds_id, start, stride, edges, SDS_VALUE0D)              !d,5
         
         if (debug) then
         write(*,*) 'sds_name:',SDS_NAME,' = ',SDS_VALUE0D

         write(*,'(x,i9,X,i6,x,i6,x,i4,x,i9,x,i7,x,'':'',32(i5,''x''))') &
                 sds_index,sds_id,status,rank,data_type,n_attrs,dim_sizes(1:rank)
         endif

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS0D_READ

!! ==================================================
!! HDF4_SDS1D_WRITE
!! ==================================================

   subroutine HDF4_SDS1D_WRITE(sd_id,SDS_NAME,SDS_VALUE1D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), dimension(:)      :: SDS_VALUE1D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfcreate, sfwdata, sfendacc   

   !     Parameter declaration.
   !---------------------------
      parameter                        DFNT_FLOAT32 = 5 ! same as SDS_VALUE#D


   !     Variable declaration 
   !---------------------------
      
      integer                       :: sds_id , status
      parameter                        data_type = DFNT_FLOAT32 ! same as sds_value
      parameter                        rank = 1
      integer, dimension(1:rank)    :: start, edges, stride
      integer, dimension(1:rank)    :: dim_sizes
      integer                       :: dim_index1,dim_index2

   !     Initialize
   !---------------------------

      dim_sizes(1) = size(SDS_VALUE1D,1)
      
      sds_id    = sfcreate(sd_id, SDS_NAME, data_type, rank, dim_sizes(1:rank)); ! To create new data set
      
      if (debug) then
         write(*,*) 'SDS_NAME:',SDS_NAME
         write(*,'(x,i9,X,i6,x,i9,x,i4,x,3(i4))') &
                           sd_id, &
                           sds_id,&
                           data_type,&
                           rank,&
                           dim_sizes(1:rank)
      endif

      !     Define the location and size of the data to be written
      !     to the data set. Note that setting values of the sds_value stride to 1
      !     specifies the contiguous writing of data.
      !---------------------------

       start (1) = 0            ! counting is zero-based (C convenction)
       edges (1) = dim_sizes(1) ! NOT edge, but # of values to be written, here entire 2D slice
       stride(1) = 1
       
       status = sfwdata(sds_id, start, stride, edges, SDS_VALUE1D(:))

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS1D_WRITE

!! ==================================================
!! HDF4_SDS1D_READ
!! ==================================================

   subroutine HDF4_SDS1D_READ(sd_id,SDS_NAME,SDS_VALUE1D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), allocatable, dimension(:) :: SDS_VALUE1D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfn2index, sfselect, sfginfo, sfrdata, sfendacc

   !     Parameter declaration.
   !---------------------------
      parameter                        DFNT_FLOAT32 = 5  ! same as SDS_VALUE#D
      parameter                        MAXRANK      = 32 !max 32, but we read only 0D-3D matrices, and our arrays need pre defined a rank.

   !     Variable declaration 
   !---------------------------
      
      character(LEN=LEN(SDS_NAME))  :: SDS_NAMEread ! sfginfo reads it although we already know it
      
      integer                       :: sds_id , status, sds_index, n_attrs
      integer                       :: data_type
      integer                       :: rank

      integer, dimension(1:MAXRANK) :: start, edges, stride
      integer, dimension(1:MAXRANK) :: dim_sizes
      integer                       :: dim_index1

   !     Initialize
   !---------------------------

         sds_index = sfn2index(sd_id,  SDS_NAME) ! returns -1 when failed, 0 is first succesful number (zero based)
         sds_id    = sfselect (sd_id,  sds_index)

         status    = sfginfo  (sds_id, SDS_NAMEread, rank, dim_sizes, data_type, n_attrs)

         ! check 
         ! rank == 1
         ! data_type == DFNT_FLOAT32 ! same as sds_value

         start (1) = 0              ! counting is zero-based (C convenction)
         edges (1) = dim_sizes(1)   ! NOT edge, but # of values to be written, here entire 2D slice
         stride(1) = 1
         
         if (allocated(SDS_VALUE1D)) then
            write(*,*) 'Programming error: for field ',SDS_NAME,' :'
            stop 'pointer already allocated'
         else
            allocate(SDS_VALUE1D(1:dim_sizes(1)))
            SDS_VALUE1D = 0
            status      = sfrdata(sds_id, start, stride, edges, SDS_VALUE1D(:))
         endif
         
         if (debug) then
         write(*,*) 'sds_name:',SDS_NAME

         write(*,'(x,i9,X,i6,x,i6,x,i4,x,i9,x,i7,x,'':'',32(i5,''x''))') &
                 sds_index,sds_id,status,rank,data_type,n_attrs,dim_sizes(1:rank)
         endif

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS1D_READ

!! ==================================================
!! HDF4_SDS2D_WRITE
!! ==================================================

   subroutine HDF4_SDS2D_WRITE(sd_id,SDS_NAME,SDS_VALUE2D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), dimension(:,:)    :: SDS_VALUE2D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfcreate, sfwdata, sfendacc   

   !     Parameter declaration.
   !---------------------------
      parameter                         DFNT_FLOAT32 = 5 ! same as SDS_VALUE#D


   !     Variable declaration 
   !---------------------------
      
      integer                       :: sds_id , status
      parameter                        data_type = DFNT_FLOAT32 ! same as sds_value
      parameter                        rank = 2
      integer, dimension(1:rank)    :: start, edges, stride
      integer, dimension(1:rank)    :: dim_sizes
      integer                       :: dim_index1,dim_index2

   !     Initialize
   !---------------------------

      dim_sizes(1) = size(SDS_VALUE2D,1)
      dim_sizes(2) = size(SDS_VALUE2D,2)
      
      sds_id    = sfcreate(sd_id, SDS_NAME, data_type, rank, dim_sizes(1:rank)); ! To create new data set
      
      if (debug) then
         write(*,*) 'SDS_NAME:',SDS_NAME
         write(*,'(x,i9,X,i6,x,i9,x,i4,x,3(i4))') &
                           sd_id, &
                           sds_id,&
                           data_type,&
                           rank,&
                           dim_sizes(1:rank)
      endif

      !     Define the location and size of the data to be written
      !     to the data set. Note that setting values of the sds_value stride to 1
      !     specifies the contiguous writing of data.
      !---------------------------

       start (1:2) = 0              ! counting is zero-based (C convenction)
       edges (1:2) = dim_sizes(1:2) ! NOT edge, but # of values to be written, here entire 2D slice
       stride(1:2) = 1
       
       status = sfwdata(sds_id, start, stride, edges, SDS_VALUE2D(:,:))

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS2D_WRITE

!! ==================================================
!! HDF4_SDS2D_READ
!! ==================================================

   subroutine HDF4_SDS2D_READ(sd_id,SDS_NAME,SDS_VALUE2D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), allocatable, dimension(:,:) :: SDS_VALUE2D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfn2index, sfselect, sfginfo, sfrdata, sfendacc

   !     Parameter declaration.
   !---------------------------
      parameter                        DFNT_FLOAT32 = 5  ! same as SDS_VALUE#D
      parameter                        MAXRANK      = 32 !max 32, but we read only 0D-3D matrices, and our arrays need pre defined a rank.

   !     Variable declaration 
   !---------------------------
      
      character(LEN=LEN(SDS_NAME))  :: SDS_NAMEread ! sfginfo reads it although we already know it
      
      integer                       :: sds_id , status, sds_index, n_attrs
      integer                       :: data_type
      integer                       :: rank

      integer, dimension(1:MAXRANK) :: start, edges, stride
      integer, dimension(1:MAXRANK) :: dim_sizes
      integer                       :: dim_index1,dim_index2

   !     Initialize
   !---------------------------

         sds_index = sfn2index(sd_id,  SDS_NAME) ! returns -1 when failed, 0 is first succesful number (zero based)
         sds_id    = sfselect (sd_id,  sds_index)

         status    = sfginfo  (sds_id, SDS_NAMEread, rank, dim_sizes, data_type, n_attrs)

         ! check 
         ! rank == 1
         ! data_type == DFNT_FLOAT32 ! same as sds_value

         start (1:2) = 0                ! counting is zero-based (C convenction)
         edges (1:2) = dim_sizes(1:2)   ! NOT edge, but # of values to be written, here entire 2D slice
         stride(1:2) = 1
         
         if (allocated(SDS_VALUE2D)) then
            write(*,*) 'Programming error: for field ',SDS_NAME,' :'
            stop 'pointer already allocated'
         else
            allocate(SDS_VALUE2D(1:dim_sizes(1),1:dim_sizes(2)))
            SDS_VALUE2D = 0
            status      = sfrdata(sds_id, start, stride, edges, SDS_VALUE2D(:,:))
         endif
         
         if (debug) then
         write(*,*) 'sds_name:',SDS_NAME

         write(*,'(x,i9,X,i6,x,i6,x,i4,x,i9,x,i7,x,'':'',32(i5,''x''))') &
                 sds_index,sds_id,status,rank,data_type,n_attrs,dim_sizes(1:rank)
         endif

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS2D_READ

!! ==================================================
!! HDF4_SDS3D_WRITE
!! ==================================================

   subroutine HDF4_SDS3D_WRITE(sd_id,SDS_NAME,SDS_VALUE3D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), dimension(:,:,:)  :: SDS_VALUE3D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfcreate, sfwdata, sfendacc   

   !     Parameter declaration.
   !---------------------------
      parameter                         DFNT_FLOAT32 = 5 ! same as SDS_VALUE#D


   !     Variable declaration 
   !---------------------------
      
      integer                        :: sds_id , status
      parameter                         data_type = DFNT_FLOAT32 ! same as sds_value
      parameter                         rank = 3
      integer, dimension(1:rank)     :: start, edges, stride
      integer, dimension(1:rank)     :: dim_sizes
      integer                        :: dim_index1,dim_index2,dim_index3
      
   !     Initialize
   !---------------------------

      dim_sizes(1) = size(SDS_VALUE3D,1)
      dim_sizes(2) = size(SDS_VALUE3D,2)
      dim_sizes(3) = size(SDS_VALUE3D,3)      
      
      sds_id    = sfcreate(sd_id, SDS_NAME, data_type, rank, dim_sizes(1:rank)); ! To create new data set
      
      if (debug) then
         write(*,*) 'SDS_NAME:',SDS_NAME
         write(*,'(x,i9,X,i6,x,i9,x,i4,x,3(i4))') &
                           sd_id, &
                           sds_id,&
                           data_type,&
                           rank,&
                           dim_sizes(1:rank)
      endif

      !     Define the location and size of the data to be written
      !     to the data set. Note that setting values of the sds_value stride to 1
      !     specifies the contiguous writing of data.
      !---------------------------

       start (1:2) = 0              ! counting is zero-based (C convenction)
       edges (1:2) = dim_sizes(1:2) ! NOT edge, but # of values to be written, here entire 2D slice
       stride(1:2) = 1
       
      !     Write the stored data to the data set named in SDS_NAME.
      !     Note that the routine sfwdata is used instead of sfwcdata 
      !     to write the numeric data.
      !     Note that the stack can handle only 500 x 500 values per call
      !     so we loop in the 3rd dimension.
      !---------------------------
      !     Writing a large 3D matrix at once like this
      !        status = sfwdata(sds_id, start, stride, edges, sds_value(:,:,:))
      !     leads to the following error [Windows OS, Visual Studio]:      
      !        forrtl: severe (170): Program Exception - stack overflow
      !---------------------------
      
      do dim_index3=1,dim_sizes(3)
      
         start (3) = dim_index3-1 ! counting is zero-based (C convenction)
         edges (3) = 1            ! NOT edge, but # of values to be written, so 1
         stride(3) = 1
      
         status = sfwdata(sds_id, start, stride, edges, SDS_VALUE3D(:,:,dim_index3))
      
      enddo       

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS3D_WRITE

!! ==================================================
!! HDF4_SDS3D_READ
!! ==================================================

   subroutine HDF4_SDS3D_READ(sd_id,SDS_NAME,SDS_VALUE3D,debug)
   
   !     Input/output declaration.
   !---------------------------

      integer                    :: sd_id 
      character(*)               :: SDS_NAME ! case-sensitive !, max 64 ???
      real(4), allocatable, dimension(:,:,:) :: SDS_VALUE3D ! same rank as variable rank below
      logical     , intent(in)   :: debug
      
   !     Function declaration.
   !---------------------------
      integer sfn2index, sfselect, sfginfo, sfrdata, sfendacc

   !     Parameter declaration.
   !---------------------------
      parameter                        DFNT_FLOAT32 = 5  ! same as SDS_VALUE#D
      parameter                        MAXRANK      = 32 ! max 32, but we read only 0D-3D matrices, and our arrays need pre defined a rank.

   !     Variable declaration 
   !---------------------------
      
      character(LEN=LEN(SDS_NAME))  :: SDS_NAMEread ! sfginfo reads it although we already know it
      
      integer                       :: sds_id , status, sds_index, n_attrs
      integer                       :: data_type
      integer                       :: rank

      integer, dimension(1:MAXRANK) :: start, edges, stride
      integer, dimension(1:MAXRANK) :: dim_sizes
      integer                       :: dim_index1,dim_index2,dim_index3

   !     Initialize
   !---------------------------

         sds_index = sfn2index(sd_id,  SDS_NAME) ! returns -1 when failed, 0 is first succesful number (zero based)
         sds_id    = sfselect (sd_id,  sds_index)

         status    = sfginfo  (sds_id, SDS_NAMEread, rank, dim_sizes, data_type, n_attrs)

         ! check 
         ! rank == 1
         ! data_type == DFNT_FLOAT32 ! same as sds_value

         start (1:3) = 0                ! counting is zero-based (C convenction)
         edges (1:3) = dim_sizes(1:3)   ! NOT edge, but # of values to be written, here entire 2D slice
         stride(1:3) = 1
         
         if (allocated(SDS_VALUE3D)) then
            write(*,*) 'Programming error: for field ',SDS_NAME,' :'
            stop 'pointer already allocated'
         else
            allocate(SDS_VALUE3D(1:dim_sizes(1),1:dim_sizes(2),1:dim_sizes(3)))
            SDS_VALUE3D = 0

            !     Write the stored data to the data set named in SDS_NAME.
            !     Note that the stack can has been noticed to be able 
            !     only to hanlde 500 x 500 values per call when writing (HDF4_SDS3D) 
            !     so we loop in the 3rd dimension here also for reading (HDF4_SDS3D).
            !---------------------------
  
              do dim_index3=1,dim_sizes(3)
            
               start (3) = dim_index3-1 ! counting is zero-based (C convenction)
               edges (3) = 1            ! NOT edge, but # of values to be written, so 1
               stride(3) = 1
            
               status = sfrdata(sds_id, start, stride, edges, SDS_VALUE3D(:,:,dim_index3))
            
            enddo       

         endif
         
         if (debug) then
         write(*,*) 'sds_name:',SDS_NAME

         write(*,'(x,i9,X,i6,x,i6,x,i4,x,i9,x,i7,x,'':'',32(i5,''x''))') &
                 sds_index,sds_id,status,rank,data_type,n_attrs,dim_sizes(1:rank)
         endif

      !     Terminate access to the data set.
      !---------------------------

      status = sfendacc(sds_id)

   end subroutine HDF4_SDS3D_READ

end module hdf4_sd_rw

!! EOF