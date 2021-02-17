function handles=ddb_shorelines_initialize_domain(handles)

handles.model.shorelines.domain.runid='tst';

handles.model.shorelines.domain.handle=[];
handles.model.shorelines.domain.LDBcoastline='';
handles.model.shorelines.domain.x_mc=[];
handles.model.shorelines.domain.y_mc=[];
handles.model.shorelines.domain.ds0=100;
handles.model.shorelines.domain.d=10;

handles.model.shorelines.domain.wave_opt='mean_and_spreading';
handles.model.shorelines.domain.Hso=1.;
handles.model.shorelines.domain.tper=7;
handles.model.shorelines.domain.phiw0=270;
handles.model.shorelines.domain.spread=60;

handles.model.shorelines.domain.wavetrans_opt='none';
handles.model.shorelines.domain.ddeep=30;
handles.model.shorelines.domain.dnearshore=8;
handles.model.shorelines.domain.phif=[];
handles.model.shorelines.domain.surf_width_w=500;

handles.model.shorelines.domain.transport_opt='CERC';
handles.model.shorelines.domain.b=1.e6;
handles.model.shorelines.domain.qscal=1;
handles.model.shorelines.domain.d50=.2e-3;
handles.model.shorelines.domain.porosity=0.4;
handles.model.shorelines.domain.tanbeta=0.03;
handles.model.shorelines.domain.Pswell=20;
handles.model.shorelines.domain.rhow=1025;
handles.model.shorelines.domain.rhos=2650;
handles.model.shorelines.domain.alpha=1.8;
handles.model.shorelines.domain.gamma=0.72;

handles.model.shorelines.domain.spit_opt='off';
handles.model.shorelines.domain.spit_width=200;
handles.model.shorelines.domain.spit_headwidth=200;
handles.model.shorelines.domain.OWscale=0.1;
handles.model.shorelines.domain.Dsf=handles.model.shorelines.domain.d*0.8;
handles.model.shorelines.domain.Dsb=1*handles.model.shorelines.domain.Dsf;
handles.model.shorelines.domain.Bheight=2;
handles.model.shorelines.domain.channel_opt='off';
handles.model.shorelines.domain.channel_width=500;
handles.model.shorelines.domain.channel_fac=0.08;
handles.model.shorelines.domain.nrstructures=0;
handles.model.shorelines.domain.activestructure=1;
handles.model.shorelines.domain.structurenames={''};
handles.model.shorelines.domain.LDBstructures='';
handles.model.shorelines.domain.structures(1).name='';
handles.model.shorelines.domain.structures(1).x=[];
handles.model.shorelines.domain.structures(1).y=[];
handles.model.shorelines.domain.structures(1).length=[];
handles.model.shorelines.domain.structures(1).transmission=[];

handles.model.shorelines.domain.nrnourishments=0;
handles.model.shorelines.domain.activenourishment=1;
handles.model.shorelines.domain.nourishmentnames={''};
handles.model.shorelines.domain.LDBnourish='';
handles.model.shorelines.domain.nourishments(1).name='';
handles.model.shorelines.domain.nourishments(1).x=[];
handles.model.shorelines.domain.nourishments(1).y=[];
handles.model.shorelines.domain.nourishments(1).length=[];
handles.model.shorelines.domain.nourishments(1).transmission=[];
handles.model.shorelines.domain.nourishments(1).tstart=datenum(floor(now));
handles.model.shorelines.domain.nourishments(1).tend=datenum(floor(now))+61;
handles.model.shorelines.domain.nourishments(1).volume=[];
handles.model.shorelines.domain.nourishments(1).rate=[];
handles.model.shorelines.domain.nourishments(1).nourlength=[];

handles.model.shorelines.domain.nrchannels=0;
handles.model.shorelines.domain.activechannel=1;
handles.model.shorelines.domain.channelnames={''};
handles.model.shorelines.domain.LDBchannels='';
handles.model.shorelines.domain.channels(1).name='';
handles.model.shorelines.domain.channels(1).x=[];
handles.model.shorelines.domain.channels(1).y=[];
handles.model.shorelines.domain.channels(1).length=[];
handles.model.shorelines.domain.channels(1).channel_width=[];
handles.model.shorelines.domain.channels(1).channel_fac=[];

% I just made this stuff up ...
handles.model.shorelines.domain.tstart=datenum(floor(now));
handles.model.shorelines.domain.tstop =datenum(floor(now))+365;
handles.model.shorelines.domain.tref=handles.model.shorelines.domain.tstart;
handles.model.shorelines.domain.phys_opt='opt2';
handles.model.shorelines.domain.option1_value=0.2;
handles.model.shorelines.domain.option2_value=0.3;
handles.model.shorelines.domain.option3_value=0.4;
handles.model.shorelines.domain.num_opt='circle';
handles.model.shorelines.domain.num_option1_value=2000;
handles.model.shorelines.domain.num_option2_value=2000;
handles.model.shorelines.domain.num_option3_value=1000;
handles.model.shorelines.domain.output_timestep=100;
handles.model.shorelines.domain.morphology=1;
handles.model.shorelines.domain.theta=0.5;
handles.model.shorelines.domain.boundary.file='';
