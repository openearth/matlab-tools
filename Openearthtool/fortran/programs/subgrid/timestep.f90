subroutine timestep

use dataspace
implicit doubleprecision (a-h,o-z)

  bla=0;
  call curu
  call comp_hu_au
  call s1uimpvexp
  u0=u1;v0=v1;s0=s1;bla=1;
  call curu
  call comp_hu_au
  call s1uimpvexp
  call hisout

 

end subroutine timestep