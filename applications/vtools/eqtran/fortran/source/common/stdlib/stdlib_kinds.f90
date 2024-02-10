!> DO NOT EDIT! See readme.txt for details

!> Version: experimental
module stdlib_kinds
  use iso_fortran_env, only: int8, int16, int32, int64
  use iso_c_binding, only: c_bool
  implicit none
  private
  public :: sp, dp, int8, int16, int32, int64, lk, c_bool

  !> Single precision real numbers
  integer, parameter :: sp = selected_real_kind(6)

  !> Double precision real numbers
  integer, parameter :: dp = selected_real_kind(15)

  !> Default logical kind parameter
  integer, parameter :: lk = kind(.true.)

end module stdlib_kinds
