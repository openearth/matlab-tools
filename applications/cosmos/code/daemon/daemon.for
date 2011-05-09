      program daemon

      USE DFPORT
      character*256 string,tmpdir,statnm,workdir,str2,uname*20,flstat*4
      character*256 host,jobdir,acname
      character dat*8,tim*10
      logical exists,weekend
      integer*4 res,errnum,itim(3)
      integer counter      
c     Check if Delft3D licencemanager can be reached
c     ------------------------------------------------------------------
c      inquire(file='j:\flexlm\bin\lmdelft.exe',exist=exists)
c      if (.not. exists) then
c         stop ' j-disk not connected,. please adapt logon script'
c      endif

c     Check working houra
c     ------------------------------------------------------------------
      write(*,*)'When are you working (so I will not use your PC):'
      write(*,*)'1. Never, I am on holidays'
      write(*,*)'2. Workdays between 8 and 19 hrs'
      write(*,*)'3. Workdays between 8 and 23 hrs'
      write(*,*)'4. All days between 8 and 19 hrs'
      write(*,*)'5. All days between 8 and 23 hrs'
      write(*,'(a\)')' Choose an option: '
      read(*,*)iopt
      if (iopt.ge.4) then
         weekend=.false.
      else
         weekend=.true.
      endif
      if (iopt.eq.1) then
        it1=25
        it2=-1
      else
        it1=8
        if (iopt.eq.2.or.iopt.eq.4) then
           it2=19
        else
           it2=23
        endif
      endif

c     Set file unit numbers
c     ------------------------------------------------------------------     
      iact=11
      istat=12
      counter=0   
c     Check if %temp%\status exists; delete if so
c     ------------------------------------------------------------------
      call getenv('temp',tmpdir)
      write(statnm,'(2a)')trim(tmpdir),'\status'
      inquire(file=statnm,exist=exists)
      if (exists) then
         res=system('del ' // trim(statnm))       
      endif
c     call getenv('USERNAME',uname)

c     Obtain hostname (computername)
c     ------------------------------------------------------------------
      call gthost(host)

c     Check time and date and write message to users.log
c     ------------------------------------------------------------------
      call date_and_time(dat,tim)
      str2=' '
      write(str2,'(2a,1x,a,1x,a4,1x,i2,1x,a)')
     &     'echo ',trim(host),dat,tim,iopt,' >>users.log'
      res=system(str2)

c     Read ini file
      open(200,file='daemon.ini')
         read(200,'(a)')jobdir
	close(200)  


c     Give feedback and instructions to user
c     ------------------------------------------------------------------
      write(*,*)'Welcome ',trim(host)
      write(*,'(a,i2)')' You have chosen option ',iopt
      write(*,*)'Please leave this window and your PC on.'
      write(*,*)'You can minimise this window if you like.'
      write(*,*)'Thanks for your cooperation!'     

c     Start loop
c     ------------------------------------------------------------------
100   continue

c     Read status if exists, otherwise set to 'idle'
c     ------------------------------------------------------------------
      inquire(file=statnm,exist=exists)
      if (exists) then
         open(istat,file=statnm, shared)
         read(istat,'(a)')flstat
         close(istat)
      else
         open(istat,file=statnm, shared)
         flstat='idle'
         write(istat,'(a)')flstat
         close(istat)
      endif

      if (flstat.eq.'idle') then
      
c        Check if time and day are outside working hours
c        ---------------------------------------------------------------
         call ITIME(itim)
         ihour=itim(1)
         iday=mod(RTC()/86400.,7.)+1
c        iday   1   2   3   4   5   6   7
c        day  thu fri sat sun mon tue wed
         if (ihour.lt.it1-1 .or.ihour.gt.it2.or.
     &      ((iday.eq.3 .or. iday.eq.4).and.weekend) ) then

c           See if file'action' exists and read string
c           ------------------------------------------------------------

            do k = 1,10000

               acname=' '
               write(acname,'(a,a,i0.4)')trim(jobdir),'action.',k

               inquire(file=acname,exist=exists)

               if (exists) then 

                  str2=' '
                  write(str2,'(a,a,a)')'move ',trim(acname),              
     &               ' action.bat'
                  res=system(str2)

                  str2=' '
                  write(str2,'(a,a,a)')'call action.bat'
                  res=system(str2)

                  str2=' '
                  write(str2,'(a,a,a)')'del action.bat'
                  res=system(str2)
               
c                 Write message to action.his
c                 ---------------------------------------------------------
                  call date_and_time(dat,tim)
                  str2=' '
                  write(str2,'(2a,1x,a,1x,a4,1x,1a)')
     &              'echo ',trim(host),dat,tim,' >>action.his'
                  res=system(str2)

c              Stop if message is 'stop'
c              ---------------------------------------------------------
c               if (string(1:4).eq.'stop') stop

                  write(*,*)'Waiting for action ...'

                  exit            

               endif
            enddo
         endif
      endif
      
c     Sleep for 10 seconds
c     ------------------------------------------------------------------
      if (counter==0) then
         write(*,*)'Waiting for action ...'
         counter=counter+1
      endif

      call sleep(10)
      
      goto 100

99    continue
      close(iact)
      call sleep(1)
      goto 100      
        
      end

c     ------------------------------------------------------------------
      subroutine gthost (host)
      character*256 string,line,host

      ier=SYSTEM('winipcfg /batch /all hostinfo')

      itry=1
4     open(11,file='hostinfo',status ='old',err=5,iostat=ier)     
      goto 6
5     call sleep(1)
        itry=itry+1
        if (itry.gt.10) goto 25
      goto 4

6     read(11,'(a)')line
      read(11,'(a)')line
      read(11,'(a)')line
      read(11,'(a)')line
      close(11,status='delete',err=99)

      host=' '
      do 10 ic=1,256
         if (line(ic:ic).eq.':') then
            do 20 i=ic+2,255
               if (line(i:i+1).eq.'nl') then
                  host=line(ic+2:i+1)
                  goto 30
               endif
20          continue               
         endif
10    continue

c     no hostname ending at 'nl'
25    host='unknown'
       
30    continue
      return

99    stop 'error closing hostinfo'

      end
