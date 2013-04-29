subroutine distance(sferic    ,x1        ,y1        ,x2        ,y2        , &
                  & d12       )
!!--copyright-------------------------------------------------------------------
! Copyright (c) 2006, WL | Delft Hydraulics. All rights reserved.
!!--disclaimer------------------------------------------------------------------
! This code is part of the Delft3D software system. WL|Delft Hydraulics has
! developed c.q. manufactured this code to its best ability and according to the
! state of the art. Nevertheless, there is no express or implied warranty as to
! this software whether tangible or intangible. In particular, there is no
! express or implied warranty as to the fitness for a particular purpose of this
! software, whether tangible or intangible. The intellectual property rights
! related to this software code remain with WL|Delft Hydraulics at all times.
! For details on the licensing agreement, we refer to the Delft3D software
! license and any modifications to this license, if applicable. These documents
! are available upon request.
!!--version information---------------------------------------------------------
! $Author$
! $Date$
! $Revision$
!!--description-----------------------------------------------------------------
!
!    Function: Calculates distance between two points on earth
! Method used: Circular distance when sferic is true,
!              Euclidic distance when sferic is false
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
!
! Global variables
!
    logical , intent(in)  :: sferic !  Description and declaration in tricom.igs
    real    , intent(out) :: d12    !!  Calculated distance from 1 to 2
    real    , intent(in)  :: x1     !!  X coordinate of point 1 (deg or m)
    real    , intent(in)  :: x2     !!  X coordinate of point 2 (deg or m)
    real    , intent(in)  :: y1     !!  Y coordinate of point 1 (deg or m)
    real    , intent(in)  :: y2     !!  Y coordinate of point 2 (deg or m)
!
! Local variables
!
    real     :: alpha  ! Half angle (in radials) between points 1 and 2
    real     :: d128   ! Double precision d12
    real     :: dslin  ! Linear distance between points 1 and 2
    real     :: x1rad  ! X1 in radials
    real     :: x2rad  ! X2 in radials
    real     :: y1rad  ! Y1 in radials
    real     :: y2rad  ! Y2 in radials
    real     :: xcrd1  ! X coordinate of point 1
    real     :: xcrd2  ! X coordinate of point 2
    real     :: ycrd1  ! Y coordinate of point 1
    real     :: ycrd2  ! Y coordinate of point 2
    real     :: zcrd1  ! Z coordinate of point 1
    real     :: zcrd2  ! Z coordinate of point 2

    real     :: ddeg2rad
    real     :: dearthrad
    real     :: pi
!
!! executable statements -------------------------------------------------------
!
    pi         = acos(-1.)
    ddegrad    = pi/180.
    dearthrad  = 6378137.0
    !
    if (sferic) then
       x1rad = real(x1)*ddegrad
       x2rad = real(x2)*ddegrad
       y1rad = real(y1)*ddegrad
       y2rad = real(y2)*ddegrad
       !
       xcrd1 = cos(y1rad)*sin(x1rad)
       ycrd1 = cos(y1rad)*cos(x1rad)
       zcrd1 = sin(y1rad)
       !
       xcrd2 = cos(y2rad)*sin(x2rad)
       ycrd2 = cos(y2rad)*cos(x2rad)
       zcrd2 = sin(y2rad)
       !
       dslin = sqrt((xcrd2-xcrd1)**2 + (ycrd2-ycrd1)**2 + (zcrd2-zcrd1)**2)
       alpha = asin(dslin/2.0)
       d128  = dearthrad*2.0*alpha
    else
       xcrd1 = real(x1)
       xcrd2 = real(x2)
       ycrd1 = real(y1)
       ycrd2 = real(y2)
       d128  = sqrt((xcrd2 - xcrd1)**2 + (ycrd2 - ycrd1)**2)
    endif
    d12 = real(d128)
end subroutine distance
