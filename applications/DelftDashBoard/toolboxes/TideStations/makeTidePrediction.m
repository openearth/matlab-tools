function wl=makeTidePrediction(tim,components,amplitudes,phases,latitude,varargin)

timeZone=0;
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'timezone'}
                timeZone=varargin{i+1};                
        end
    end
end

const=t_getconsts;
k=0;
for i=1:length(amplitudes)
    cmp=components{i};
    cmp = delft3d_name2t_tide(cmp);
    if length(cmp)>4
        cmp=cmp(1:4);
    end
    name=[cmp repmat(' ',1,4-length(cmp))];
    ju=strmatch(name,const.name);
    if isempty(ju)
        disp(['Could not find ' name ' - Component skipped.']);
    else
        k=k+1;
        names(k,:)=name;
        freq(k,1)=const.freq(ju);
        tidecon(k,1)=amplitudes(i);
        tidecon(k,2)=0;
        % convert time zone
        if timeZone~=0
            phases(i)=phases(i)+360*timeZone*const.freq(ju);
            phases(i)=mod(phases(i),360);
        end
        tidecon(k,3)=phases(i);
        tidecon(k,4)=0;    
    end
end
wl=t_predic(tim,names,freq,tidecon,latitude);

