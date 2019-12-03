module bdc_module
!!--module description----------------------------------------------------------
!
! This module exposes the functions of the bedcomposition_module and declares
! a persistent bedcomposition variable.
!
!!--module declarations---------------------------------------------------------
use bedcomposition_module
use message_module

public
private bdc
private BDCLIST_LENGTH
private bdclist

type bdc
    type(message_stack) :: messages
    type(bedcomp_data)  :: bedcomposition
    logical             :: inuse = .false.
end type bdc

integer, parameter :: BDCLIST_LENGTH = 100
type(bdc), dimension(:), pointer :: bdclist

contains

function new_bdc(bedcomposition,messages) result (this)
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    implicit none
    !
    ! Call variables
    !
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
    integer                       :: this           ! bdc instance number
    !
    ! Local variables
    !
    integer :: i
    integer :: istat
!
!! executable statements -------------------------------------------------------
!
    if (.not.associated(bdclist)) then
       allocate(bdclist(100), STAT=istat)
       if (istat/=0) then
          this = -1
          return
       endif
    endif
    do i = 1,BDCLIST_LENGTH
       if (.not.bdclist(i)%inuse) then
           this = i
           bedcomposition => bdclist(i)%bedcomposition
           messages       => bdclist(i)%messages
           !
           istat = initmorlyr(bedcomposition)
           call initstack(messages)
           !
           bdclist(i)%inuse = .true.
           return
       endif
    enddo
end function new_bdc


function get_bdc(this,bedcomposition,messages) result (istat)
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    implicit none
    !
    ! Call variables
    !
    type(message_stack), pointer    :: messages       ! message stack object
    type(bedcomp_data) , pointer    :: bedcomposition ! bed composition object
    integer            , intent(in) :: this           ! bdc instance number
    integer                         :: istat
    !
    ! Local variables
    !
!
!! executable statements -------------------------------------------------------
!
    if (.not.associated(bdclist)) then
       istat = -1
       return
    elseif (this<1 .or. this>BDCLIST_LENGTH) then
       istat = -2
       return
    elseif (.not.bdclist(this)%inuse) then
       istat = -3
       return
    else
       bedcomposition => bdclist(this)%bedcomposition
       messages       => bdclist(this)%messages
       istat = 0
    endif
end function get_bdc


function destroy_bdc(this) result (istat)
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this           ! bdc instance number
    !
    ! Local variables
    !
    integer :: i
    integer :: istat
!
!! executable statements -------------------------------------------------------
!
    if (.not.associated(bdclist)) then
       istat = -1
       return
    elseif (this<1 .or. this>BDCLIST_LENGTH) then
       istat = -2
       return
    elseif (.not.bdclist(this)%inuse) then
       istat = -3
       return
    else
       istat = clrmorlyr(bdclist(this)%bedcomposition)
       call clearstack(bdclist(this)%messages)
       bdclist(this)%inuse = .false.
    endif
end function destroy_bdc

end module bdc_module