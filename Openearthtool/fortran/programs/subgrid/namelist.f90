module namelist


! declaration of input variables integer ios
integer ios


!initialconditions


!boundaryconditions

      !physicalconstants
      real               g                           !gravitational acceleration [m2/s]

      !computationalconstants
      real               theta                       !implicity factor [-]
    real               dt                          !timestep [s]
    integer            ntmax                       !number of timesteps




    =100000;ttide=4000.d0

      !times
      integer            year,month,day,igmt         !initial time
      integer            nend ,ncycle                !number of timesteps [-]
      real               dt                          !time step [s]
      real               tdamp                       !timescale starting-up boundary condition [s]

      !postproces
      character(len=1)   tdimmap                     !time dimension ('s','m','h','d')
      real               t0map                       !postprocessing starting time
      real               dtmap                       !postprocessing timestep
      real               tendmap                     !postprocessing stop time
      character(len=300) timeseries_fname            !output nodes
      character(len=300) qprofile_fname              !qprofile nodes

      !discharge
      character(len=30)  :: selectdischarge
      real               :: xq0,yq0,uq0,vq0,q0

      !concentration
      character(len=30)  :: selectconcentration,siltation_type
      character(len=230) :: sedrel_fname
      real               :: xsedrel,ysedrel,usedrel,vsedrel,msedrel
      real               :: merosion1,rho0,rho_slib,tau_c1,ws,delta_slib1,kswaves
      real               :: merosion2,d50_2,tau_c2,a_bed,delta_slib2

      !shipinput
      character(len=30)  :: selectship
      real                  lship,wship,dshipmax,x0ship,y0ship,tship0,tshipdamp,ushipknots

      !morphology
      character(len=30)  :: selectmorphology,sedtrans_type
      real               :: morphology_factor,alpha_eh,rho_rel,d50

      save

      contains

      subroutine readinputfile      ! all input variables
!----------------------------------------------------------------------------
!      programmer:  robert jan labeur, gerard dam, bas les, bram van
prooijen !      date      :  28-07-2004      !declaration of the
global variables !      call declaration          !module ???

!      package   :  finel2d_2 !      version   :  1.00 !
company   :  svasek hydraulics
!----------------------------------------------------------------------------

      !set name inputscript
      call getarg(1,fininpfname)

    bc_timeseriesfname=''
    bc_harmonicfname=''


      !set namelists
      namelist /initialconditions/meshfname,z_init_fname,h_init_fname,
     &     u_init_fname,v_init_fname,c_init_fname,pslib1_init_fname,pslib2_init_fname,salt_init_fname
      namelist /boundaryconditions/bc_code,bc_h,bc_vel,bc_harmonicfname,bc_timeseriesfname
    namelist /physicalconstants/grav,latitude,visc0,beta,schmidt,delta0
      namelist /bottomfriction/bf_type,bf_fname,gamma
      namelist /extraforces/cd_wind,uw_timeseriesfname,z_groin_fname,wavesfname
      namelist /computationalconstants/theta,method,upw,bicg_error,bicg_max_iter
      namelist /times/year,month,day,igmt,nend,ncycle,dt,tdamp
      namelist /postproces/tdimmap,t0map,dtmap,tendmap,timeseries_fname,qprofile_fname
      namelist /discharge/selectdischarge,xq0,yq0,uq0,vq0,q0
      namelist /concentration/selectconcentration,siltation_type,sedrel_fname,xsedrel,ysedrel,usedrel,vsedrel,
     &     msedrel,rho0,rho_slib,ws,kswaves,merosion1,tau_c1,delta_slib1,merosion2,tau_c2,delta_slib2,d50_2,a_bed
      namelist /shipinput/selectship,lship,wship,dshipmax,x0ship,y0ship,tship0,tshipdamp,ushipknots
      namelist /morphology/selectmorphology,sedtrans_type,alpha_eh,rho_rel,d50,morphology_factor

      ! read the items of the inputfile
      open (unit=11,file=fininpfname          ,iostat=ios,action='read')
      read (unit=11,nml=initialconditions     ,iostat=ios)
      read (unit=11,nml=boundaryconditions    ,iostat=ios)
      read (unit=11,nml=physicalconstants     ,iostat=ios)
      read (unit=11,nml=bottomfriction        ,iostat=ios)
      read (unit=11,nml=extraforces           ,iostat=ios)
      read (unit=11,nml=computationalconstants,iostat=ios)
      read (unit=11,nml=times                 ,iostat=ios)
      read (unit=11,nml=postproces            ,iostat=ios)
      read (unit=11,nml=discharge             ,iostat=ios)
      read (unit=11,nml=concentration         ,iostat=ios)
      read (unit=11,nml=shipinput             ,iostat=ios)
      read (unit=11,nml=morphology            ,iostat=ios)
      close(unit=11)

      ! necessary defaults
      ncycle=max(ncycle,1)

     write(*,*) 'bc_code=',bc_code
     write(*,*) 'bc_timeseriesfname(3)',bc_timeseriesfname(3)
     write(*,*) 'bc_timeseriesfname',bc_timeseriesfname
     write(*,*) 'grav=',grav
       write(*,*) 'bf_fname=',bf_fname
       write(*,*) 'bf_type=',bf_type
       write(*,*) 'delta0=',delta0



      end subroutine readinputfile

      end module namelist
