function mult2(a) result(b)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'mult2' :: mult2
    implicit none
    
    integer, intent(in):: a
    integer :: b
    
    b=a*2
    
end function mult2
    
function mult2_double(a) result(b)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'mult2_double' :: mult2_double
    implicit none
    
    double precision, intent(in):: a
    double precision :: b
    
    b=a*2
    
end function mult2_double
