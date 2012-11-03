function opt=muppet_setDefaultParameterProperties(opt)

% Store information about dimensions of different parameters

opt.name='';
opt.datatype='unknown';
opt.active=1;
opt.quantity='';

opt.dimflag=[0 0 0 0 0];
opt.size=[0 0 0 0 0];

opt.times=[];

opt.stations={''};

opt.nrdomains=0;
opt.domains={''};

opt.nrsubfields=0;
opt.subfields={''};

opt.nrblocks=0;

opt.timename='time';
opt.xname='x';
opt.yname='y';
opt.zname='z';
opt.valname='val';
opt.uname='u';
opt.vname='v';
opt.wname='w';
opt.uamplitudename='amplitude_u';
opt.vamplitudename='amplitude_v';
opt.uphasename='phase_u';
opt.vphasename='phase_v';

% % % Grid
% % opt.x=[];
% % opt.y=[];
% % opt.z=[];
% % 
% % % M
% % opt.m=[];
% % opt.previousm=1;
% % opt.mtext='';
% % opt.mmaxtext='';
% % opt.selectallm=0;
% % 
% % % N
% % opt.n=[];
% % opt.previousn=1;
% % opt.ntext='';
% % opt.nmaxtext='';
% % opt.selectalln=0;
% % 
% % % K
% % opt.k=[];
% % opt.previousk=1;
% % opt.ktext='';
% % opt.kmaxtext='';
% % opt.selectallk=0;
% 
% % Times
% % opt.timestep=[];
% % opt.time=[];
% % opt.previoustimestep=1;
% % opt.timestepsfromlist=1;
% % opt.timesteptext='';
% % opt.tmaxtext='';
% % opt.showtimes=1;
% % opt.selectalltimes=0;
% % opt.block=[];
% opt.times=[];
% opt.timelist={''};
% 
% % Stations
% %opt.station=[];
% opt.stations={''};
% %opt.stationnumber=1;
% %opt.previousstationnumber=1;
% %opt.stations={''};
% %opt.stationfromlist=1;
% %opt.selectallstations=0;
% 
% % Domains
% opt.nrdomains=0;
% opt.domains={''};
% %opt.domainnumber=1;
% %opt.domain='';
% 
% % Subfields
% opt.nrsubfields=0;
% opt.subfields={''};
% %opt.subfieldnumber=1;
% %opt.subfield='';
% 
% %opt.xcoordinate=[];
% %opt.previousxcoordinate='pathdistance';
% %opt.ycoordinate=[];
% 
% %opt.component=[];
% %opt.quantity='magnitude';
% 
% opt.dimflag=[0 0 0 0 0];
% opt.size=[0 0 0 0 0];
% 
% opt.nrblocks=0;
% %opt.nrquantities=1;
