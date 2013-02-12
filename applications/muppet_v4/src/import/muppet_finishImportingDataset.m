function dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k)
% Generic import function for different file types

% Determine shape of selected data
dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k);

% Squeeze d
d=muppet_squeezeDataset(d);

% Determine component
[dataset,d]=muppet_determineDatasetComponent(dataset,d);

% Copy data to dataset structure
dataset=muppet_copyToDataStructure(dataset,d);

%% Determine cell centres/corners
dataset.xz=dataset.x;
dataset.yz=dataset.y;
dataset.zz=dataset.z;

dataset.type=[dataset.quantity num2str(dataset.ndim) 'd' dataset.plane];

%% Set time-varying or constant
dataset=muppet_setDatasetVaryingOrConstant(dataset,timestep);
