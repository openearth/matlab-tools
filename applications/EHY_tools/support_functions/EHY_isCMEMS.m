function TF = EHY_isCMEMS(fname)
%% TF = EHY_isCMEMS(fname)
% Returns logical (TRUE or FALSE) if the provided file (fname) is a CMEMS-file
% This is needed as CMEMS-files are handled as Delft3D FM-files, but
% sometimes it is useful to know if this is really the case
TF = false;

[~,~,ext] = fileparts(fname);

if strcmp(ext,'.nc')
    infonc = ncinfo(fname);
    if ~isempty(infonc.Attributes)
        ind = strmatch('institution',{infonc.Attributes.Name},'exact');
        if ~isempty(ind) && ~isempty(findstr(lower('MERCATOR OCEAN'),lower(infonc.Attributes(ind).Value)))
            TF = true;
        end
    end
    
    if isfield(infonc.Attributes, 'Value')
        AttrValues = {infonc.Attributes.Value};
        for i = 1:length(AttrValues)
            if (ischar(AttrValues{i})); 
                if contains(lower((AttrValues{i})),'cmems','IgnoreCase', true)
                    TF = true;
                    break
                end
            end
        end
    end
end
