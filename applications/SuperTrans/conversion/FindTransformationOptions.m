function [transcodes1,transnames1,ireverse1,idef1,transcodes2,transnames2,ireverse2,idef2,crscode_interm]=FindTransformationOptions(cs1code,cs2code,CoordinateSystems,Operations)
%FINDTRANSFORMATIONOPTIONS  find transformation options
%
% [transcodes1,transnames1,...
%  ireverse1  ,idef1,...
%  transcodes2,transnames2,...
%  ireverse2  ,idef2,crscode_interm]=FindTransformationOptions(cs1code,cs2code,CoordinateSystems,Operations)
%
%See also:

transcodes1    = NaN;
transnames1    = '';
ireverse1      = NaN;
idef1          = NaN;

transcodes2    = NaN;
transnames2    = '';
ireverse2      = NaN;
idef2          = NaN;

crscode_interm = NaN;

ok=0;

% Try first option
[icodes,names,id]=findoptions(cs1code,cs2code,Operations);
if ~isempty(icodes) & ~isempty(id)
    transcodes1 = icodes;
    transnames1 = names;
    ireverse1   = zeros(length(icodes),1)+1;
    idef1       = id;
    ok          = 1;
end

if ~ok
    % Try second option
    [icodes,names,id]=findoptions(cs2code,cs1code,Operations);
    if ~isempty(icodes) & ~isempty(id)
        transcodes1 = icodes;
        transnames1 = names;
        ireverse1   = zeros(length(icodes),1)-1;
        idef1       = id;
        ok          = 1;
    end
end

if ~ok

    ok2=0;
    % Try intermediate option (first convert to WGS84)
    [icodes,names,id]=findoptions(cs1code,4326,Operations);
    if ~isempty(icodes) & ~isempty(id)
        codes1 = icodes;
        names1 = names;
        id1    = id;
        ok2    = 1;
    end

    % Then from WGS84 to code2
    if ok2
        ok2=0;
        [icodes,names,id]=findoptions(cs2code,4326,Operations);
        if ~isempty(icodes) & ~isempty(id)
            codes2 = icodes;
            names2 = names;
            id2    = id;
            ok2    = 1;
        end
    end

    if ok2
        transcodes1   = codes1;
        transcodes2   = codes2;
        transnames1   = names1;
        transnames2   = names2;
        ireverse1     = zeros(length(transcodes1),1)+1;
        ireverse2     = zeros(length(transcodes2),1)-1;
        crscode_interm= 4326;
        idef1         = id1;
        idef2         = id2;
    end

end


function [icodes,names,idef]=findoptions(cs1code,cs2code,Operations)
icodes=[];
names='';
idef=[];
j=findinstruct(Operations,'source_crs_code',cs1code,'target_crs_code',cs2code);
if ~isempty(j)
    var0=0;
    for k=1:length(j)
        jj=j(k);
        switch Operations(jj).coord_op_method_code,
            case{9603,9606,9607}
                icodes(k)=Operations(jj).coord_op_code;
                names{k}=Operations(jj).coord_op_name;
                if Operations(jj).coord_op_variant>var0
                    var0=Operations(jj).coord_op_variant;
                    idef=k;
                end
        end
    end
end
