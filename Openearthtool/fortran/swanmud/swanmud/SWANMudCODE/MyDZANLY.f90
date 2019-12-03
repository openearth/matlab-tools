!  This subroutine is witten based on the algorithm presented in
!  Press 2007 Numerical Recipes, The Art of Scientific Computing
!  page: 466 
!  This function is written to replace the DZANLY from 
!  commercial library IMSL
!
!  written by: Seyed Mostafa Siadatmousavi
!
subroutine DZANLY(Func,ERRABS,ERRREL,NK,NN,NG,kk,ITMAX,xxi,Info)
      complex*16            :: kk
      integer               :: Info, ITMAX
      complex*16            :: xxi
      real                  :: ERRABS , ERRREL
      integer               :: i
      complex(8)            :: x0, x1, x2, y0, y1, y2, x3, y3, xc
      complex(8)            :: a, b, c, q , den1, den2, dis
      INTERFACE
        FUNCTION Func(r)
          complex(8):: Func
          complex(8), INTENT(IN) :: r
        END FUNCTION Func
      END INTERFACE
!     Func  :    The function we need its zeros
!     ERRABS:    If (ABS(F(Z)).LE.ERRABS)then Z is accepted as a zero.
!     ERRREL:    A zero is accepted if the difference in two successive
!                   approximations to this zero is within ERRREL
!     NK    :    The number of previously known zeros (Not used in this
!                   algorithm)
!     NN    :    The number of new zeros to be found (Equals to 1 in
!                   this algorithm))
!     NG    :    The number of initial guesses provided (Equals to 1 in
!                   this algorithm))
!     kk    :    Initial value
!     ITMAX :    Maximum number of itterations
!     xxi   :    Potential solution
!     Info  :    >0 successful, 0: more itteration may help, <0: failed
!                    to converge
      xxi=0;
!     Mullers Method
      xc = kk
      x0 = xc - 1
      x1 = xc
      x2 = xc + 1
      y0 = Func( x0 )
      y1 = Func( x1 )
      y2 = Func( x2 )
      Do i=1,ITMAX
        q=( x2 - x1 )/( x1 - x0 )
        a = q * y2 - q * ( 1 + q ) * y1 + q * q * y0
        b = ( 2 * q + 1 ) * y2 - ( 1+q ) * ( 1 + q ) * y1 + q * q * y0
        c = ( 1 + q ) * y2 ;
        dis= b * b - 4 * a * c
        den1 = ( b + sqrt ( dis ) );
        den2 = ( b - sqrt ( dis ) )
        if ( abs( den1 ) .lt. abs( den2 )  ) then
          den1 = den2
        endif
        if ( abs( den1 ) .ge. 1e-9 ) then
           x3 = x2 - (x2 - x1) * ( 2 * c / den1 )
           y3 = Func( x3 )
           x0 = x1
           y0 = y1
           x1 = x2
           y1 = y2
           if ( ( abs( x3 - x2 ) .lt. ERRREL ) .or.                    &
                                      ( abs( y3 ) .lt.  ERRABS ) ) then
             exit
           else
             x2 = x3
             y2 = y3
           endif
        else
           exit
        endif
      EndDo
      if ( i .eq. ITMAX ) then
        Info =  0
      elseif (abs( y3 ) .lt.  ERRABS) then
        Info =  i
      else
        Info = -i
     endif
      xxi = x3
end subroutine
