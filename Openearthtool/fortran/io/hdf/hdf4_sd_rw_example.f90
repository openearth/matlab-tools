program hdf4_sd_rw_example
!HDF4_SD_RW_EXAMPLE  Example program to read data from HDF file using module HDF4_SD_RW
!
!See also: HDF4_SD_RW

! $Id: hdf4_sd_rw_example.f90 2175 2010-01-21 13:48:14Z boer_g $
! $Date: 2010-01-21 05:48:14 -0800 (Thu, 21 Jan 2010) $
! $Author: boer_g $
! $Revision: 2175 $
! $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/fortran/io/hdf/hdf4_sd_rw_example.f90 $
! $Keywords:$

   use hdf4_sd_rw

   implicit none

   !     Declarations
   !---------------------------
      character (256)                        :: FILE_NAME ! 1024 plain HDF, 256 for NC Interface (http://hdf.ncsa.uiuc.edu/UG41r3_html/Fundmtls4.html, TABLE 2I).
      logical                                :: debug = .false. !.true.
      real(4), dimension(:,:), allocatable   :: lon, lat, data_value
      character (256)                        :: data_units, data_name
      integer        DFACC_READ
      parameter     (DFACC_READ = 1)

  
   !     HDF declarations
   !---------------------------
      integer :: sfstart, sfend, status, sd_id

   !     Open hdf
   !---------------------------

   FILE_NAME = 'zeta_D3D_2003.hdf'
   sd_id     = sfstart(FILE_NAME, DFACC_READ)
   

   !     Read hdf stuff
   !---------------------------

   data_units = ' '
   call HDF4_ATTR_READ (sd_id,'zeta units'    ,data_units,debug)
   write(*,*) 'data_units'
   write(*,*)  data_units
   write(*,*) '--------------------------------------'

   data_name = ' '
   call HDF4_ATTR_READ (sd_id,'variable: zeta',data_name ,debug)
   write(*,*) 'data_name'
   write(*,*)  data_name
   write(*,*) '--------------------------------------'

   call HDF4_SDS2D_READ(sd_id,'lon'           ,lon       ,debug)
   write(*,*) 'lon'
   write(*,*)  lon
   write(*,*) '--------------------------------------'

   call HDF4_SDS2D_READ(sd_id,'lat'           ,lat       ,debug)
   write(*,*) 'lat'
   write(*,*)  lat
   write(*,*) '--------------------------------------'

   call HDF4_SDS2D_READ(sd_id,'zeta_004997'   ,data_value,debug) ! hdfinfo shows to 'zeta_004997'
   write(*,*) 'data_value'
   write(*,*)  data_value
   write(*,*) '--------------------------------------'

   status = sfend  (sd_id)

end program hdf4_sd_rw_example

! EOF