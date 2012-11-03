function opt=muppet_setDefaultParameterDimensions(opt)

opt.active=1;
% 
% % Grid
% opt.x=[];
% opt.y=[];
% opt.z=[];
% 
% % M
% opt.m=[];
% opt.nrm=0;
% opt.previousm=1;
% opt.mtext='';
% opt.mmaxtext='';
% opt.selectallm=0;
% 
% % N
% opt.n=[];
% opt.nrn=0;
% opt.previousn=1;
% opt.ntext='';
% opt.nmaxtext='';
% opt.selectalln=0;
% 
% % K
% opt.k=[];
% opt.nrk=0;
% opt.previousk=1;
% opt.ktext='';
% opt.kmaxtext='';
% opt.selectallk=0;
% 
% % Times
% opt.timestep=[];
% opt.nrt=0;
% opt.times=[];
% opt.previoustimestep=1;
% opt.timestepsfromlist=1;
% opt.timesteptext='';
% opt.tmaxtext='';
% opt.showtimes=1;
% opt.selectalltimes=0;
% %opt.datetime=[];
% %opt.block=[];
% opt.timelist={''};
% %opt.time=[];
% 
% % Stations
% opt.station=[];
% opt.nrstations=0;
% opt.stations={''};
% opt.stationnumber=1;
% opt.previousstationnumber=1;
% opt.stations={''};
% opt.stationfromlist=1;
% opt.selectallstations=0;
% 
% % Domains
% opt.nrdomains=0;
% opt.domains={''};
% opt.domainnumber=1;
% opt.domain='';
% 
% % Subfields
% opt.nrsubfields=0;
% opt.subfields={''};
% opt.subfieldnumber=1;
% opt.subfield='';
% 
% opt.xcoordinate=[];
% opt.previousxcoordinate='pathdistance';
% opt.ycoordinate=[];
% 
% opt.component=[];
% opt.quantity='magnitude';

opt.nrblocks=0;
opt.blocks={''};
opt.nrdomains=0;
opt.domains={''};
opt.nrsubfields=0;
opt.subfields={''};
opt.stations={''};
opt.dimflag=[0 0 0 0 0];
opt.size=[0 0 0 0 0];
opt.nrquantities=1;
opt.quantities={'scalar'};
