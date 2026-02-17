function series = nesthd_uvcFill(series,varargin)

%  nesthd_uvcFill, fills series above water level or below bed  with first resp. last value
%
%% Initialise
kmax        = size(series,3);
noTims      = size(series,1);
noStat      = size(series,2);
OPT.noValue = NaN;
OPT         = setproperty(OPT,varargin);

%% Fill missing values
for iTime = 1: noTims
    for iStat = 1: noStat
        if isnan(OPT.noValue)
            index = ~isnan(series(iTime,iStat,:));
            index = find(index > 0);
        else
           index = find(series(iTime,iStat,:) ~= OPT.noValue);
        end
        
        if ~isempty(index)
            for k= 1: index(1) - 1
                series(iTime,iStat,k) = series(iTime,iStat,index(1));
            end
            
            for k=index(end) + 1: kmax
                series(iTime,iStat,k) = series(iTime,iStat,index(end));
            end
        end
    end
end

