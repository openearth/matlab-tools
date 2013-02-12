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
dataset.xcoordinate='';
dataset.ycoordinate='';
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
dataset.plotcoordinate='pathdistance';
dataset.xcoordinate=[];
dataset.ycoordinate=[];
dataset.quantity='scalar';
dataset.selectedquantity='scalar';
dataset.component=[];
dataset.tc='c';
dataset.nrquantities=1;

dataset.nrdomains=0;
dataset.domains={''};
dataset.nrsubfields=0;
dataset.subfields={''};

dataset.nrblocks=0;

dataset.polygonfile='';

dataset.adjustname=1;

dataset.nrquantities=1;
dataset.quantities={'scalar','vector2d','vector3d'};
dataset.selectedquantity='scalar';

dataset.selectcoordinates=0;

dataset.activeparameter=[];

