function dataset=muppet_setDefaultDatasetProperties(dataset)

%% General
dataset.name='';
dataset.filename='';
dataset.filetype='';
dataset.combineddataset=0;
dataset.runid=[];

%% Data
dataset.x=[];
dataset.y=[];
dataset.z=[];
dataset.xz=[];
dataset.yz=[];
dataset.zz=[];
dataset.u=[];
dataset.v=[];
dataset.w=[];
dataset.times=[];

%% Options
dataset.parameter='';
dataset.ucomponent='';
dataset.vcomponent='';
dataset.m=[];
dataset.n=[];
dataset.k=[];
dataset.timestep=[];
dataset.block=[];
dataset.time=[];
dataset.station=[];
dataset.domain=[];
dataset.subfield=[];
dataset.xcoordinate='pathdistance';
dataset.ycoordinate=[];
dataset.quantity=[];
dataset.component=[];
dataset.tc='c';
dataset.nrquantities=1;

% % GUI
% dataset.adjustname=1;
% dataset.parametertimesequal=0;
% dataset.parameterstationsequal=0;
% dataset.paramaterxequal=0;
% dataset.paramateryequal=0;
% dataset.paramaterzequal=0;
