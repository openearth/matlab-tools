function opt=muppet_setDefaultDatasetProperties(varargin)

opt.combineddataset=0;

opt.parameter=[];
opt.datatype=[];

opt.x=[];
opt.y=[];
opt.z=[];
opt.xz=[];
opt.yz=[];
opt.zz=[];

% M
opt.m=[];

% N
opt.n=[];

% K
opt.k=[];

% Times
opt.timestep=[];
opt.block=[];
opt.time=[];

% Stations
opt.station=[];

% Domain
opt.domain=[];

% Subfield
opt.subfield=[];

opt.xcoordinate=[];
opt.ycoordinate=[];

opt.component=[];

% File
opt.fid=[];

% Parameters
opt.nrparameters=0;

% Delft3D
opt.lgafile=[];

% GUI
opt.adjustname=1;
opt.parametertimesequal=0;
opt.parameterstationsequal=0;
opt.paramaterxequal=0;
opt.paramateryequal=0;
opt.paramaterzequal=0;
