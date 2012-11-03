function tp=muppet_findDataShape(sz,timestep,istation,m,n,k)

if sz(2)>0
    % Data from station
    if length(timestep)>1
        % Time varying
        if length(k)>1
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
    if length(timestep)>1
        % Time-varying
        if length(m)>1
            tp='timestackm';
        elseif length(n)>1
            tp='timestackn';
        elseif length(k)>1
            tp='timestackk';
        else
            tp='timeseries';
        end            
    else
        % Constant
        if length(m)>1
            if length(n)>1
                tp='map2d';
            elseif length(k)>1
                tp='crossection2dm';
            else
                tp='crossection1dm';
            end
        elseif length(n)>1
            if length(k)>1
                tp='crossection2dn';
            else
                tp='crossection1dn';
            end
        else
            tp='profile';
        end
    end
end
