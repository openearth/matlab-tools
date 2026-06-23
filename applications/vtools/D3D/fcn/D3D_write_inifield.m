%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Writes a Delft3D FM iniField file (.ini) with [Initial] and [Parameter] blocks.
%
%INPUT
%   fname   - output file path (string)
%   stru_in - struct array; each element represents one block.
%             The block type ([Initial] or [Parameter]) is determined
%             automatically from the quantity field.
%
%             Quantities written as [Parameter]:
%               frictionCoefficient, horizontalEddyViscosityCoefficient,
%               horizontalEddyDiffusivityCoefficient, backgroundVertical,
%               EddyDiffusivityCoefficient, advectionType, bedLevelType,
%               stemDiameter, stemHeight, stemDensity, SecchiDepth,
%               linearFrictionCoefficient, internalTidesFrictionCoefficient
%
%             All other quantities are written as [Initial].
%
%             Struct fields correspond to iniField keywords (all optional
%             except quantity, dataFile, dataFileType, interpolationMethod):
%               quantity, dataFile, dataFileType, interpolationMethod,
%               operand, averagingType, averagingRelSize, averagingNumMin,
%               averagingPercentile, extrapolationMethod, locationType,
%               value, frictionType, tracerFallVelocity, tracerDecayTime

function D3D_write_inifield(fname, stru_in)

PARAMETER_QUANTITIES={ ...
    'frictionCoefficient',                  ...
    'horizontalEddyViscosityCoefficient',   ...
    'horizontalEddyDiffusivityCoefficient', ...
    'backgroundVertical',                   ...
    'EddyDiffusivityCoefficient',           ...
    'advectionType',                        ...
    'bedLevelType',                         ...
    'stemDiameter',                         ...
    'stemHeight',                           ...
    'stemDensity',                          ...
    'SecchiDepth',                          ...
    'linearFrictionCoefficient',            ...
    'internalTidesFrictionCoefficient'};

% Field order matches the iniField specification table.
% Format codes: 's' = string, 'd' = double, 'i' = integer
FIELD_ORDER={ ...
    'quantity'            ,'s'; ...
    'dataFile'            ,'s'; ...
    'dataFileType'        ,'s'; ...
    'interpolationMethod' ,'s'; ...
    'operand'             ,'s'; ...
    'averagingType'       ,'s'; ...
    'averagingRelSize'    ,'d'; ...
    'averagingNumMin'     ,'i'; ...
    'averagingPercentile' ,'d'; ...
    'extrapolationMethod' ,'s'; ...
    'locationType'        ,'s'; ...
    'value'               ,'d'; ...
    'frictionType'        ,'s'; ...
    'tracerFallVelocity'  ,'d'; ...
    'tracerDecayTime'     ,'d'};

% Open file using write_local_and_copy pattern
[fid,fname_local]=write_local_and_copy('open',fname,'overwrite',true);

% Write [General] block
fprintf(fid,'[General]\n');
fprintf(fid,'fileVersion = 2.00\n');
fprintf(fid,'fileType = iniField\n');

for k=1:numel(stru_in)
    s=stru_in(k);

    % Determine block type from quantity
    qty='';
    if isfield(s,'quantity') && ~isempty(s.quantity)
        qty=s.quantity;
    end
    if ismember(qty, PARAMETER_QUANTITIES)
        block_header='[Parameter]';
    else
        block_header='[Initial]';
    end

    fprintf(fid,'\n%s\n', block_header);

    % Write all non-empty fields in defined order
    for kf=1:size(FIELD_ORDER,1)
        fieldname_k=FIELD_ORDER{kf,1};
        ftype=FIELD_ORDER{kf,2};
        if isfield(s, fieldname_k) && ~isempty(s.(fieldname_k))
            val=s.(fieldname_k);
            switch ftype
                case 's'
                    fprintf(fid,'%s = %s\n', fieldname_k, val);
                case 'd'
                    fprintf(fid,'%s = %g\n', fieldname_k, val);
                case 'i'
                    fprintf(fid,'%s = %d\n', fieldname_k, val);
            end
        end
    end
end

% Close file and copy to destination
write_local_and_copy('close',fid,fname_local,fname);


end %D3D_write_inifield
