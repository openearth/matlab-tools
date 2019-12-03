! This file is to be added to SWMUD.for.
!
!*******************************************************************
!                                                                  *
      SUBROUTINE BACKUPM (SPCSIG,KGRPNT,XCGRID,YCGRID,KMUDR,KMUDI)
!                                                                  *
!*******************************************************************
!
!      USE OCPCOMM2                                                !40.61mud LENFNM
!      USE OCPCOMM4                                                !40.61mud ITMOPT
!      USE SWCOMM2                                                 !40.61mud XOFFS
!      USE SWCOMM3                                                 !40.61mud MSC
!      USE SWCOMM4                                                 !40.61mud KSPHER

      USE OCPCOMM1                                                        40.41
      USE OCPCOMM2                                                        40.41
      USE OCPCOMM3                                                        40.41
      USE OCPCOMM4                                                        40.41
      USE SWCOMM1                                                         40.41
      USE SWCOMM2                                                         40.41
      USE SWCOMM3                                                         40.41
      USE SWCOMM4                                                         40.41
      USE M_PARALL                                                        40.31


!
!   --|-----------------------------------------------------------|--
!     | Delft University of Technology                            |
!     | Faculty of Civil Engineering                              |
!     | Environmental Fluid Mechanics Section                     |
!     | P.O. Box 5048, 2600 GA  Delft, The Netherlands            |
!     |                                                           |
!     | Programmers: R.C. Ris, N. Booij,                          |
!     |              IJ.G. Haagsma, A.T.M.M. Kieftenburg,         |
!     |              M. Zijlema, E.E. Kriezi,                     |
!     |              R. Padilla-Hernandez, L.H. Holthuijsen       |
!     |              G.J. de Boer                                 |
!   --|-----------------------------------------------------------|--
!
!
!     SWAN (Simulating WAves Nearshore); a third generation wave model
!     Copyright (C) 2004-2005  Delft University of Technology
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!     GNU General Public License for more details.
!
!     A copy of the GNU General Public License is available at
!     http://www.gnu.org/copyleft/gpl.html#SEC3
!     or by writing to the Free Software Foundation, Inc.,
!     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!
!     ver 40.00, Apr 1998 by N.Booij: new subroutine
!
!   Purpose
!
!  0. Authors
!
!     30.82: IJsbrand Haagsma
!     40.00, 40.13: Nico Booij
!     34.01: Jeroen Adema
!     40.31: Marcel Zijlema
!     40.41: Marcel Zijlema
!     40.61mud: Gerben J. de Boer, BACKUP > BACKUPM
!
!  1. Updates
!
!     40.00, Apr. 98: New subroutine BACKUP
!     30.82, Oct. 98: Updated description of SPCDIR
!     34.01, Feb. 99: Introducing STPNOW
!     40.03, Nov. 99: ITMOPT is written as time coding option
!     40.13, Jan. 01: option Spherical was not yet taken care of
!     40.31, Dec. 03: appending number to file name i.c. of
!                     parallel computing
!     40.41, Oct. 04: common blocks replaced by modules, include files removed
!     40.61mud:May. 08: rewritten to write arrays of real and imag wavenumber = f(x,y,sigma)
!
!  2. Purpose
!
!     backup current state of the complex wave number field to a file (to detect errors)
!
!  4. Argument variables
!
! i   SPCSIG: Relative frequencies in computational domain in sigma-space 30.82
! i   XCGRID: Coordinates of computational grid in x-direction            30.82
! i   YCGRID: Coordinates of computational grid in y-direction            30.82
!
      REAL    SPCSIG(MSC)                                                 30.82
      REAL    XCGRID(MXC,MYC),    YCGRID(MXC,MYC)                         30.82
      REAL      :: KMUDR (MCGRD,MSC)                                     !40.61mud
      REAL      :: KMUDI (MCGRD,MSC)                                     !40.61mud

!
!  8. Subroutines used
!
      LOGICAL STPNOW                                                      34.01
!
! 13. Source text
!
      INTEGER   KGRPNT(MXC,MYC)
      CHARACTER (LEN=8) :: CRFORM = '(2F14.4)'                            40.41
      CHARACTER FILENMMUD*(LENFNM)
      LOGICAL   EQREAL                                                     40.41
      SAVE      IENT
      DATA      IENT /0/
      CALL STRACE (IENT, 'BACKUPM')
!
!     ==================================================================
!
!     HOTFile  'FNAME'                                                    40.00
!
!     ==================================================================
!
!      CALL INCSTR ('FNAME', FILENM, 'REQ', ' ')
      FILENMMUD = 'MUDFile' ! for release use 'FNAME' as basis ?
!     --- append node number to FILENM in case of parallel computing      40.31
!     IF ( PARLL ) THEN                                                   40.31
!        ILPOS = INDEX ( FILENM, ' ' )-1                                  40.31
!        WRITE(FILENM(ILPOS+1:ILPOS+4),33) INODE                          40.31
! 33     FORMAT('-',I3.3)                                                 40.31
!     END IF                                                              40.31
      NREF = 0 ! new file of type:'ONSU/F'=
      IERR = 0 ! New Formatted file
      CALL FOR (NREF, FILENMMUD, 'UF', IERR)
      IF (STPNOW()) RETURN                                                34.01
      WRITE (NREF, 102) 'SWAN   1', 'SWAN standard file, with version'
      IF (NSTATM.EQ.1) THEN
       WRITE (NREF, 102) 'TIME', 'time-dependent data'
 102    FORMAT (A, T41, A)                                                40.00
       WRITE (NREF, 103) ITMOPT, 'time coding option'                     40.03
 103    FORMAT (I6, T41, A)                                               40.00
      ENDIF
      IF (KSPHER.EQ.0) THEN                                               40.13
        WRITE (NREF, 102) 'LOCATIONS', 'locations in x-y-space'
        CRFORM = '(2F14.4)'                                               40.41
      ELSE                                                                40.13
        WRITE (NREF, 102) 'LONLAT', 'locations on the globe'              40.13
        CRFORM = '(2F12.6)'                                               40.41
      ENDIF                                                               40.13
!     Add essential info to reshape 1D array back to 2D array   
	WRITE (NREF, '(3(I6,X), T41, A)')
     &                  MXC*MYC,MXC,MYC, 'number of locations,mxc,myc'   !40.61mud
      DO IX = 1, MXC
        DO IY = 1, MYC
          IF ( EQREAL(XCGRID(IX,IY), EXCFLD(8)) .AND.                     40.41
     &         EQREAL(YCGRID(IX,IY), EXCFLD(9)) ) THEN                    40.41
            WRITE (NREF, FMT=CRFORM) EXCFLD(8), EXCFLD(9)                 40.41
          ELSE
            WRITE (NREF, FMT=CRFORM) DBLE(XCGRID(IX,IY)) + DBLE(XOFFS),
     &                               DBLE(YCGRID(IX,IY)) + DBLE(YOFFS)    40.00
          ENDIF                                                           40.41
        ENDDO
      ENDDO
      WRITE (NREF, 102) 'RFREQ', 'relative frequencies in Hz'             40.00
      WRITE (NREF, 103) MSC, 'number of frequencies'                      40.00
      DO 120 IS = 1, MSC
        WRITE (NREF, 114) SPCSIG(IS)/PI2
 114    FORMAT (F10.4)
 120  CONTINUE
! skip directions
      WRITE (NREF, 132) 2                                                !40.61mud 
!     See also: SWSPEC in swanout2.for
 132  FORMAT ('QUANT', /, I6, T41, 'number of quantities in table')       40.00
!         QUANT # 1
          WRITE (NREF, 102) 'KREAL','Real wave number for 2L fluid mud'   40.61mud
          WRITE (NREF, 102) 'rad/m','unit'                                40.61mud
          WRITE (NREF, 102)  '0.'  ,'exception value'                     40.61mud CHANGE TO OVEXCV(IVTYPE) IVTYPE=58 !!!!
!         QUANT # 2
          WRITE (NREF, 102) 'KIMAG','Imaginary wave number 2L fluid mud'  40.61mud
          WRITE (NREF, 102) 'rad/m','unit'                                40.61mud
          WRITE (NREF, 102)  '0.'  ,'exception value'                     40.61mud CHANGE TO OVEXCV(IVTYPE) IVTYPE=59 !!!!
 !
!     writing of heading is completed, write time if nonstationary
!
!     IF (NSTATM.EQ.1) THEN
!       WRITE (NREF, 202) CHTIME                                          40.00
!202    FORMAT (A18, T41, 'date and time')
!     ENDIF
!
      DO 290 IX = 1, MXC
        DO 280 IY = 1, MYC
          INDX = KGRPNT(IX,IY)
          IF (INDX.EQ.1) THEN
            ! NOTE:  no LOCATION keyword when NODATA 
            WRITE (NREF,220) 'NODATA'                                     40.08
          ELSE
!          WRITE (NREF,*) 'FACTOR'
!          WRITE (NREF,*) 1
          WRITE (NREF,'(A,X,3(I6,X), T41, A)') 
     &       'LOCATION', (IX-1)*MYC+IY, IX, IY, '(ix-1)*myc+iy, ix, iy'
            IF (KMUDR(INDX,1)==-1) THEN !  shallower than DEPMIN
              DO IS = 1, MSC
               WRITE (NREF,*) 0., 0.
              ENDDO
            ELSE
              DO IS = 1, MSC
               WRITE (NREF,*) KMUDR(INDX,IS), KMUDI(INDX,IS)
              ENDDO
            ENDIF
          ENDIF
 280    CONTINUE
 290  CONTINUE
 220  FORMAT (A6)                                                         40.08
      CLOSE (NREF)
      RETURN
!     end of subr BACKUPM
      END
