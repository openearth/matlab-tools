function mdf = simona2mdf_output(S,mdf, varargin)

% simona2mdf_output : gets output tmes from the siminp tree

OPT.nesthd_path = getenv('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});


siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'SDSOUTPUT'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.SDSOUTPUT')
    output       = siminp_struc.ParsedTree.SDSOUTPUT;
else
    return
end

% Maps
if ~isempty(output.MAPS)
    mdf.flmap(1) = output.MAPS.TFMAPS;
    mdf.flmap(2) = output.MAPS.TIMAPS;
    mdf.flmap(3) = output.MAPS.TLMAPS;
end
% Histories
if ~isempty(output.HISTORIES)
    mdf.flhis(1) = mdf.tstart;
    mdf.flhis(2) = output.HISTORIES.TIHISTORIES;
    mdf.flhis(3) = mdf.tstop;
end
% Restart
if ~isempty(output.RESTART)
    mdf.flrst = output.RESTART.TIRESTART;
end

