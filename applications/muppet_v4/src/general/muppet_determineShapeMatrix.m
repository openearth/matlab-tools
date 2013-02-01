function shpmat=muppet_determineShapeMatrix(sz,timestep,istation,m,n,k)

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
