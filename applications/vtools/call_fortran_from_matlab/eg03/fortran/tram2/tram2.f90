!  tram2.f90 
!
!  FUNCTIONS/SUBROUTINES exported from tram2.dll:
!  tram2 - subroutine 
!
subroutine tram2(a,b,c, &
!
                 d,e,f,g)

  ! Expose subroutine tram2 to users of this DLL
  !
  !DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'tram2' :: tram2


  ! Variables

implicit none

double precision, intent(in) :: a
double precision, intent(in) :: b
double precision, intent(out) :: c
double precision, intent(out) :: d
double precision, dimension(2), intent(out) :: e
logical, intent(out) :: f
character(4), intent(out) :: g

 ! Body of tram2

c=a+b
d=a*b
e=e*a
if (a>b) then
    f=.true.
else
    f=.false.
endif
g='aaaa'

end subroutine tram2
