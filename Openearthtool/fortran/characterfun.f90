module characterfun
!CHARACTERFUN   Small tools to manipulate character arrays
!
! UPPERCASE: make all letters uppercase
! LOWERCASE: make all letters lowercase
! REVERSE  : reverse complete string
!
!See also: 

!   --------------------------------------------------------------------
!   Copyright (C) 2002 Delft University of Technology
!       Gerben J. de Boer
!
!       g.j.deboer@tudelft.nl (also: gerben.deboer@wldelft.nl)
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
!   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/ 
!   --------------------------------------------------------------------

! $Id: characterfun.f90 341 2009-04-07 11:25:31Z boer_g $
! $Date: 2009-04-07 04:25:31 -0700 (Tue, 07 Apr 2009) $
! $Author: boer_g $
! $Revision: 341 $
! $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/fortran/characterfun.f90 $
! $Keywords:$

! ascii numbers
! -------------

integer	:: alowercase =  65
integer	:: zlowercase =  90
integer	:: AUPPERCASE =  97
integer	:: ZUPPERCASE = 122

contains

! function to change all tokens of a character-array to uppercase
! ------------------------------------------------------------

function uppercase(string)

    character(LEN=*)           ::	string
    character(LEN=LEN(string)) ::	uppercase
	integer			            ::	i,j

    do i=1,len(string)
        j = ichar (string(i:i))
        if ( (j >= AUPPERCASE) .and. (j <= ZUPPERCASE) ) then
           j = j - ( AUPPERCASE - alowercase ) !32
           uppercase(i:i) = char (j)
        else
           uppercase(i:i) = string(i:i)
        endif
    enddo

end function uppercase

! function to change all tokens of a character-array to lowercase
! ------------------------------------------------------------

function lowercase(string)

    character(LEN=*)           ::	string
    character(LEN=LEN(string)) ::	lowercase
	integer			            ::	i,j

    do i=1,len(string)
        j = ichar (string(i:i))
        if ( (j >= alowercase) .and. (j <= zlowercase) ) then
           j = j + ( AUPPERCASE - alowercase ) !32
           lowercase(i:i) = char (j)
        else
           lowercase(i:i) = string(i:i)
        endif
    enddo

end function lowercase

! function to reverse all tokens of a character-array 
! ------------------------------------------------------------

function reverse(word)

    character(LEN=*)            :: word
    character(LEN=LEN(word))    :: reverse
	integer			            :: i, lenstr

	lenstr=len(word)

    do i=1,lenstr
		reverse(lenstr-i+1:lenstr-i+1)=word(i:i)
    enddo

endfunction reverse

end module characterfun

! EOF

