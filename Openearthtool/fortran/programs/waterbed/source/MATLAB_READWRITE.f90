	MODULE MATLAB_IO

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!        Bram van Prooijen
!        b.c.vanprooijen@tudelft.nl
!	   +31(0)15 2784070   
!        Faculty of Civil Engineering and Geosciences
!        department of Hydraulic Engineering
!	   PO Box 5048
!        2600 GA Delft
!        The Netherlands
!
!	this module is heavily based on        
!		http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/apiref/bqoqnz0.html
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




	CONTAINS


	SUBROUTINE rdmat2real(matname,matrix,mmax,nmax,keyw)
!c
!c     I/O  variables
!c
      CHARACTER*(*)     matname, keyw 
      INTEGER*4         mmax,    nmax
	INTEGER*4         cmmax,   cnmax,comax	
        REAL            matrix(nmax,mmax)
        REAL*8            dummatrix(nmax,mmax)
!c
!c Matlab call variables
!c
      INTEGER*4         matOpen,      matClose, &
                       mxCreateFull, mxCreateString
!C
!C Local variables
!C     
      INTEGER*4         mp, pa
!C
!C Check if matname exist and open new or existing file
!C
      mp=matOpen(matname,'r')
      IF (mp .eq. 0) THEN
			 WRITE(6,*) 'Can''t open file : ',matname 	  
			STOP
      ENDIF                  
!C    
!C Create, write and free from memory  
!C
      pa = matGetMatrix ( mp ,keyw)
        
		write(*,*) 'pa=',pa   
      
	IF (pa .eq. 0 ) THEN
	  WRITE(*,*) 'Variable ',keyw,' not present '
	  STOP
	ENDIF
	IF (mxIsNumeric(pa) .eq. 0 ) THEN
	  WRITE(*,*) 'Variable ',keyw,' not numeric data'
	  STOP
	ENDIF
	     
      
	cmmax=mxGetM(pa)
	cnmax=mxGetN(pa)
     
	call mxCopyPtrToReal8(MxgetPr(pa),dummatrix,cmmax*cnmax)      

	matrix=REAL(dummatrix)
      
!C     
!C Close matfile
!C

        CALL mxDestroyArray(pa)

      status = matClose(mp)
      IF (status .ne. 0) THEN
         WRITE(6,*) 'Error closing MAT-file : ', matname
         STOP
      ENDIF

!	RETURN

      END SUBROUTINE rdmat2real
	
	!
	!
	!
	!
	!
	!

	
	
	
	SUBROUTINE wrreal2matf(matname,matrix,nmax,mmax,keyw)

      CHARACTER*(*)     matname, keyw 
      INTEGER*4         mmax,    nmax
      REAL*8            matrix(nmax,mmax)

! Matlab call variables
      INTEGER*4         matOpen,      matClose
      INTEGER*4         mxCreateFull, mxCreateString

! Local variables
      INTEGER*4         mp, pa

! Check if matname exist and open new or existing file
      mp=matOpen(matname,'u')
      IF (mp .eq. 0) THEN
         mp=matOpen(matname,'w')
         WRITE(*,*) 'New File : ',matname
      ENDIF                  
    
! Create, write and free from memory  
      pa = mxCreateFull(nmax,mmax,0)
      CALL mxSetName(pa,keyw)
      CALL mxCopyReal8ToPtr(matrix, mxGetPr(pa), nmax*mmax)
      CALL matPutMatrix(mp, pa)
      CALL mxFreeMatrix(pa)
     
! Close matfile
      status = matClose(mp)
      IF (status .ne. 0) THEN
         WRITE(6,*) 'Error closing MAT-file : ', matname
         STOP
      ENDIF

      END SUBROUTINE wrreal2matf


















	END MODULE MATLAB_IO


