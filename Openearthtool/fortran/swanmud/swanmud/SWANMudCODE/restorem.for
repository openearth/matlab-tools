! This file is to be added to SWMUD.for.
!
!*******************************************************************
!                                                                  *
      SUBROUTINE RESTOREM (SPCSIG,KGRPNT,XCGRID,YCGRID,KMUDR,KMUDI)
!     SUBROUTINE INITVA( AC2, SPCSIG, SPCDIR, KGRPNT, XCGRID,             40.31
!    &                   YCGRID, XYTST )                                  40.31
!*******************************************************************

      USE OCPCOMM1                                                        40.41
      USE OCPCOMM2                                                        40.41
      USE OCPCOMM3                                                        40.41
      USE OCPCOMM4                                                        40.41
      USE SWCOMM1                                                         40.41
      USE SWCOMM2                                                         40.41
      USE SWCOMM3                                                         40.41
      USE SWCOMM4                                                         40.41
      USE TIMECOMM                                                        40.41
      USE M_PARALL                                                        40.31
!
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
!  0. Authors
!
!     30.70: Nico Booij
!     30.72: IJsbrand Haagsma
!     30.82: IJsbrand Haagsma
!     34.01: Jeroen Adema
!     40.03, 40.13: Nico Booij
!     40.31: Marcel Zijlema
!     40.41: Marcel Zijlema
!
!  1. Updates
!
!     30.70, Oct. 97: New subroutine
!     30.72, Feb. 98: Introduced generic names XCGRID, YCGRID and SPCSIG for SWAN
!     30.82, Oct. 98: Updated description of SPCDIR
!     30.82, Dec. 98: Corrected the arguments in CALL SINTRP(..)
!     34.01, Feb. 99: Introducing STPNOW
!     40.00, Aug. 99: modification for 1D mode; new option INIT PAR
!                     init restart added
!     40.03, Nov. 99: after reading comment line, jump to 110 (not 100)
!                     additional test output added
!                     possibility added to initialize in limited region (PAR case)
!                     function EQCSTR used to compare strings
!     40.13, Jan. 01: option Spherical was not yet taken care of
!                     ! is now allowed as comment sign in a restart file
!     40.13, Oct. 01: error message removed, command MODE not required any more
!     40.31, Oct. 03: small changes
!     40.31, Dec. 03: appending number to file name i.c. of
!                     parallel computing
!     40.41, Sep. 04: small changes
!     40.41, Oct. 04: common blocks replaced by modules, include files removed
!
!  2. Purpose
!
!     process command INIT and compute initial state of the wave field
!
!  4. Argument variables
!
! i   SPCSIG: Relative frequencies in computational domain in sigma-space 30.72
! i   XCGRID: Coordinates of computational grid in x-direction            30.72
! i   YCGRID: Coordinates of computational grid in y-direction            30.72
!
      REAL    SPCSIG(MSC)                                                 30.72
      REAL    XCGRID(MXC,MYC),    YCGRID(MXC,MYC)                         30.72
      REAL      :: KMUDR (MCGRD,MSC)                                     !40.61mud
      REAL      :: KMUDI (MCGRD,MSC)                                     !40.61mud

!
!  8. Subroutines used
!
      LOGICAL :: STPNOW, EQCSTR                                           40.03
!
! 13. Source text
!
!
      INTEGER   KGRPNT(MXC,MYC)                                           40.00
      CHARACTER RLINE *80                                                 40.00
      CHARACTER FILENMMUD*(LENFNM)
      LOGICAL   EQREAL                                                    40.41
      SAVE      IENT
      DATA      IENT /0/
      CALL STRACE (IENT, 'RESTOREM')
! ============================================================
!       initialize using spectra from a HOTFILE                           40.00
!        CALL INCSTR ('FNAME', FILENM, 'REQ', ' ')
      FILENMMUD = 'MUDFile' ! for release use 'FNAME' as basis ?
!       --- append node number to FILENM in case of parallel computing    40.31
!        IF ( PARLL ) THEN                                                40.31
!           ILPOS = INDEX ( FILENM, ' ' )-1                               40.31
!           WRITE(FILENM(ILPOS+1:ILPOS+4),33) INODE                       40.31
!  33       FORMAT('-',I3.3)                                              40.31
!        END IF                                                           40.31
        NREF = 0 ! new file of type:'ONSU/F'=
        IERR = 0 ! New Formatted file
        CALL FOR (NREF, FILENMMUD, 'OF', IERR)
        IF (STPNOW()) RETURN                                              34.01
 100    READ (NREF, 102) RLINE
 102    FORMAT (A)                                                        40.00
        IF (RLINE(1:4).NE.'SWAN') CALL MSGERR (3, FILENM//
     &        ' is not a correct restart file')
 110    READ (NREF, 102) RLINE
        IF (RLINE(1:1).EQ.COMID .OR. RLINE(1:1).EQ.'!') GOTO 110          40.13
        IF (EQCSTR(RLINE,'TIME')) THEN
          READ (NREF, *) IIOPT
          IF (ITEST.GE.50) WRITE (PRTEST, 122) IIOPT                      40.03
 122      FORMAT (' time coding option:', I2)
          READ (NREF, 102) RLINE
!         in stationary mode, warning
          IF (NSTATM.EQ.0) CALL MSGERR (1,
     &                  'Time info in hotfile ignored')                   40.03
        ELSE
          IIOPT = -1
          IF (NSTATM.EQ.1) CALL MSGERR (1,
     &                  'No time info in hotfile')                        40.03
        ENDIF
        IF (EQCSTR(RLINE,'LOCA') .OR. EQCSTR(RLINE,'LONLAT')) THEN        40.13
          READ (NREF, *) NUMPTS ! MXC, MYC ! recently added to subroutine backup
          IF (NUMPTS.NE.MXC*MYC) THEN
            CALL MSGERR (2,
     &      'grid on restart file differs from one in CGRID command')     40.00
            WRITE (PRINTF, 123) MXC*MYC, NUMPTS
 123        FORMAT (1X, I6, ' points in comp.grid; on file:', I6)         40.03
          ENDIF
          IF (ITEST.GE.50) WRITE (PRTEST, 124) NUMPTS                     40.03
 124      FORMAT (1X, I6, '  output locations')
          DO IP = 1, NUMPTS
            READ (NREF, *)
          ENDDO
          READ (NREF, 102) RLINE
        ENDIF
        IF (EQCSTR(RLINE(2:5),'FREQ')) THEN                               40.03
          READ (NREF, *) NUMFRE
          IF (NUMFRE.NE.MSC) CALL MSGERR (2,
     &    'grid on restart file differs from one in CGRID command')       40.00
          IF (ITEST.GE.50) WRITE (PRTEST, 126) NUMFRE                     40.03
 126      FORMAT (1X, I6, '  frequencies')
          DO IP = 1, NUMFRE
            READ (NREF, *)
          ENDDO
          READ (NREF, 102) RLINE
        ENDIF
! skip directions
        READ (NREF, *) NQUA ! should be 2
        IF (NQUA.NE.2) CALL MSGERR (2, 'NQUA>1: incorrect MUDFile     ')  40.00
!      KREAL
        READ (NREF, 102) RLINE
        IF (ITEST.GE.50) WRITE (PRTEST, 130) RLINE                        40.03
        READ (NREF, 102) RLINE                                            40.00
        READ (NREF, 102) RLINE                                            40.00
!      KIMAG
        READ (NREF, 102) RLINE
        IF (ITEST.GE.50) WRITE (PRTEST, 130) RLINE                        40.03
        READ (NREF, 102) RLINE                                            40.00
        READ (NREF, 102) RLINE                                            40.00

 130    FORMAT (1X, 'quantity: ', A)
!
!       reading of heading is completed, read time if nonstationary
!
        IF (IIOPT.GE.0) THEN
          READ (NREF, 102) RLINE                                          40.00
          CALL DTRETI (RLINE(1:18), IIOPT, TIMCO)                         40.00
          WRITE (PRINTF, 210) RLINE(1:18)
 210      FORMAT (' initial condition read for time: ', A)
        ENDIF
!
        DO 290 IX = 1, MXC
          DO 280 IY = 1, MYC
            READ (NREF, 102) RLINE ! location code
            INDX = KGRPNT(IX,IY)
            IF (INDX.EQ.1) THEN
              IF (RLINE(1:6).NE.'NODATA') CALL MSGERR (2,
     &              'valid spectrum for non-existing grid point')
              WRITE (PRINTF, *) IX-1, IY-1
            ELSE
              IF (EQCSTR(RLINE,'NODATA') .OR. EQCSTR(RLINE,'ZERO')) THEN
                DO IS = 1, MSC
                    KMUDR(INDX,IS) = 0
				  KMUDI(INDX,IS) = 0
                ENDDO
              ELSE
                DO IS = 1, MSC
!                 Read wave numbers from file
                  READ (NREF, *) KMUDR(INDX,IS), KMUDI(INDX,IS)
                ENDDO
              ENDIF
            ENDIF
 280      CONTINUE
 290    CONTINUE
        CLOSE (NREF)
      RETURN
!     end of subr restorem
      END
