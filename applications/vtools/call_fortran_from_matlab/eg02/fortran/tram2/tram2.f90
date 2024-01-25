!  tram2.f90 
!
!  FUNCTIONS/SUBROUTINES exported from tram2.dll:
!  tram2 - subroutine 
!
subroutine tram2(a,b,c,d)

  ! Expose subroutine tram2 to users of this DLL
  !
  !DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'tram2' :: tram2


  ! Variables

implicit none

double precision, intent(in) :: a
double precision, intent(in) :: b
double precision, intent(out) :: c
double precision, intent(out) :: d

 ! Body of tram2

c=a+b
d=a*b

end subroutine tram2
