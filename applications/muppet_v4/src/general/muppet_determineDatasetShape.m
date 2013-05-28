function dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k)

sz=dataset.size;
quantity=dataset.quantity;

% Determines shape matrix of selected dataset

shpmat=[0 0 0 0 0];
% Time
if sz(1)>0
    if isempty(timestep) || length(timestep)>1
        % Multiple time steps
        shpmat(1)=2;
    else
        % One time step
        shpmat(1)=1;
    end
end
% Stations
if sz(2)>0
    if isempty(istation) || length(istation)>1
        shpmat(2)=2;
    else
        shpmat(2)=1;
    end
end
% M
if sz(3)>0
    if isempty(m) || length(m)>1
        shpmat(3)=2;
    else
        shpmat(3)=1;
    end
end
% N
if sz(4)>0
    if isempty(n) || length(n)>1
        shpmat(4)=2;
    else
        shpmat(4)=1;
    end
end
% K
if sz(5)>0
    if isempty(k) || length(k)>1
        shpmat(5)=2;
    else
        shpmat(5)=1;
    end
end

% Determines shape of required dataset
if sz(2)>0
    % Data from station
    if length(timestep)>1
        % Time varying
        if length(k)>1
            shp='timestack';
            plane='tz';
            ndim=2;
        elseif length(m)>1 || length(n)>1
            shp='timestack';
            plane='tx';
            ndim=2;
        else
            shp='timeseries';
            plane='tv';
            ndim=1;
        end
    else
        % Profile
        shp='profile';
        plane='vz';
        ndim=1;
    end
else
    % Data from matrix
    if length(timestep)>1
        % Time-varying
        if length(m)>1
            shp='timestack';
            plane='tx';
            ndim=2;
        elseif length(n)>1
            shp='timestack';
            plane='tx';
            ndim=2;
        elseif length(k)>1
            shp='timestack';
            plane='tz';
            ndim=1;
        else
            shp='timeseries';
            plane='tv';
            ndim=1;
        end
    else
        % Constant
        if length(m)>1
            if length(n)>1
                shp='map';
                plane='xy';
                ndim=2;
            elseif length(k)>1
                shp='crosssection2d';
                plane='xz';
                ndim=2;
            else
                switch quantity
                    case{'location'}
                        shp='crosssection1d';
                        plane='xy';
                        ndim=1;
                    otherwise
                        shp='crosssection1d';
                        plane='xv';
                        ndim=1;
                end
            end
        elseif length(n)>1
            if length(k)>1
                shp='crosssection2d';
                plane='xz';
                ndim=2;
            else
                switch quantity
                    case{'location'}
                        shp='crosssection1d';
                        plane='xy';
                        ndim=1;
                    otherwise
                        shp='crosssection1d';
                        plane='xv';
                        ndim=1;
                end
            end
        else
            switch quantity
                case{'location'}
                    shp='point';
                    plane='xy';
                    ndim=1;
                otherwise
                    shp='profile';
                    plane='vz';
                    ndim=1;
            end
        end
    end
end

dataset.plane=plane;
dataset.ndim=ndim;

