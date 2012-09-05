function tp=muppet_findDataShape(dataset)

m=dataset.m;
n=dataset.n;
k=dataset.k;
timestep=dataset.timestep;

if isempty(m)
    m=1;
end
if isempty(n)
    n=1;
end
if isempty(k)
    k=1;
end
if isempty(timestep)
    timestep=1;
end

if ~isempty(dataset.station)
    % Data from station
    if timestep==0 || length(timestep)>1
        % Time varying
        if k==0 || length(k)>1
            tp='timestackstation';
        else
            tp='timeseriesstation';
        end
    else
        % Profile
        tp='profilestation';
    end
else
    % Data from matrix
    if timestep==0 || length(timestep)>1
        % Time-varying
        if m==0 || length(m)>1
            tp='timestackm';
        elseif n==0 || length(n)>1
            tp='timestackn';
        elseif k==0 || length(k)>1
            tp='timestackk';
        else
            tp='timeseries';
        end            
    else
        % Constant
        if m==0 || length(m)>1
            if n==0 || length(n)>1
                tp='map2d';
            elseif k==0 || length(k)>1
                tp='crossection2dm';
            else
                tp='crossection1dm';
            end
        elseif n==0 || length(n)>1
            if k==0 || length(k)>1
                tp='crossection2dn';
            else
                tp='crossection1dn';
            end
        else
            tp='profile';
        end
    end
end
