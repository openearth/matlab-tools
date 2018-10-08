function datenums=EHY_getmodeldata_getDatenumsFromOutputfile(outputfile)
infonc      = ncinfo(outputfile);

% - to enhance speed, reconstruct time array from start time, numel and interval
ncVarInd    = strmatch('time',{infonc.Variables.Name},'exact');
ncAttrInd    = strmatch('units',{infonc.Variables(ncVarInd).Attributes.Name},'exact');
nr_times    = infonc.Variables(ncVarInd).Size;
seconds_int = ncread(outputfile, 'time', 1, 3);
interval    = seconds_int(3)-seconds_int(2);
seconds     = [seconds_int(1) seconds_int(2) + interval*[0:nr_times-2] ]';
days        = seconds / (24*60*60);
attri       = infonc.Variables(ncVarInd).Attributes(ncAttrInd).Value;
itdate      = attri(15:end);
datenums    = datenum(itdate, 'yyyy-mm-dd HH:MM:SS')+days;

end