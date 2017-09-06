function factor=timeFactor(fromTunit,toTunit)

tunits={'S','M','H','D','Y'};
factors=[60 60 24 365.25];

if ~ismember(fromTunit,tunits) || ~ismember(toTunit,tunits)
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
