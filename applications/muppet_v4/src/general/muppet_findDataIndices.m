function [timestep,istation,m,n,k]=muppet_findDataIndices(dataset)

% Time can be defined by timestep and by actual time
if isempty(dataset.time) && ~isempty(dataset.timestep)
    % time step
    timestep=dataset.timestep;
elseif ~isempty(dataset.time) && isempty(dataset.timestep)
    % time
    timestep=find(abs(dataset.times-dataset.time)<1/864000);
elseif isempty(dataset.time) && isempty(dataset.timestep)
    % both empty
    if dataset.size(1)>0
        timestep=1:dataset.size(1);
    else
        timestep=1;
    end
else
    % this should never happen
    timestep=dataset.timestep;
end

% Station
if ~isempty(dataset.station)
    istation=strmatch(dataset.station,dataset.stations,'exact');
else
    istation=1:dataset.size(2);
end

% M
if isempty(dataset.m)
    if dataset.size(3)>0
        m=1:dataset.size(3);
    else
        m=1;
    end
else
    m=dataset.m;
end

% N
if isempty(dataset.n)
    if dataset.size(4)>0
        n=1:dataset.size(4);
    else
        n=1;
    end
else
    n=dataset.n;
end

% K
if isempty(dataset.k)
    if dataset.size(5)>0
        k=1:dataset.size(5);
    else
        k=1;
    end
else
    k=dataset.k;
end
