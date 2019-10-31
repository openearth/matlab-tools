function factor=timeFactor(fromTunit,toTunit)
%% factor=timeFactor(fromTunit,toTunit)
%
% This function calculates the factor that you can apply in a multiplication
% to get from 'fromTunit' to 'toTunit'
%
% Example1: factor = timeFactor('M','S') [=60]
% Example2: factor = timeFactor('D','M') [=1440]
% Example3: factor = timeFactor('S','M') [=1/60=0.0166..]
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

tunits={'S','M','H','D','Y'};
factors=[60 60 24 365.25];

if length(fromTunit)>1; fromTunit = fromTunit(1); end
if length(toTunit)>1;   toTunit   = toTunit(1);   end

if ~ismember(lower(fromTunit),lower(tunits)) || ~ismember(lower(toTunit),lower(tunits))
   error(['fromTunit and toTunit have to be: ' strtrim(sprintf('%s ',tunits{1:end-1})) ' or ' tunits{end}]) 
end

ind1=strmatch(lower(fromTunit),lower(tunits));
ind2=strmatch(lower(toTunit),lower(tunits));

if ind1<ind2
    factor=1/prod(factors(ind1:ind2-1));
elseif ind1>ind2
    factor=prod(factors(ind2:ind1-1));
elseif ind1==ind2
    factor=1;
end
