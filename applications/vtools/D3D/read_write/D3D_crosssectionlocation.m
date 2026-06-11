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
%write cross-section locations file

%INPUT:
%   -simdef.D3D.dire_sim = path to the folder where to write the file [string]
%   -simdef.csl = structure with cross-sectional info as it must be written (check by reading using S3_read_crosssectiondefinitions)
%
%OUTPUT:
%   -       
%
%NOTES:
%   -

function D3D_crosssectionlocation(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'check_existing',true)
addOptional(parin,'overwrite',false)
addOptional(parin,'fname','CrossSectionLocations.ini')

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;
overwrite=parin.Results.overwrite;
fname=parin.Results.fname;

overwrite=overwrite || ~check_existing;

%% RENAME

dire_sim=simdef.D3D.dire_sim;
csl=simdef.csl;  

ncsd=numel(csl);
[accepted_fields,required_fields]=get_csl_schema();

%% FILE

fname_destiny=fullfile(dire_sim,fname);
[fid,fname_local]=write_local_and_copy('open',fname_destiny,'overwrite',overwrite);

fprintf(fid,'%s\r\n','[General]');
fprintf(fid,'%s\r\n','   fileVersion           = 1.01');
fprintf(fid,'%s\r\n','   fileType              = crossLoc');

for kcsd=1:ncsd
    validate_required_fields(csl(kcsd),required_fields,kcsd);

    fprintf(fid,'%s\r\n','');
    fprintf(fid,'%s\r\n','[CrossSection]');
    for kfields=1:numel(accepted_fields)
        fkey=accepted_fields{kfields};
        if ~isfield(csl(kcsd),fkey)
            continue
        end
        fval=csl(kcsd).(fkey);
        if isempty(fval)
            continue
        end

        if isstring(fval)
            if isscalar(fval)
                fval=char(fval);
            else
                error('Cross-section location %d field %s must be scalar string/char.',kcsd,fkey)
            end
        end

        if ischar(fval)
            fprintf(fid,'   %s = %s \r\n',fkey,fval);
        elseif isnumeric(fval) || islogical(fval)
            if numel(fval)~=1
                error('Cross-section location %d field %s must be scalar numeric.',kcsd,fkey)
            end
            if isinteger_precision(double(fval))
                fprintf(fid,'   %s = %d \r\n',fkey,fval);
            else
                fprintf(fid,'   %s = %f \r\n',fkey,fval);
            end
        else
            error('Cross-section location %d field %s has unsupported class %s.',kcsd,fkey,class(fval))
        end
    end
end

write_local_and_copy('close',fid,fname_local,fname_destiny)

end %function

%% =========================================================================

function [accepted_fields,required_fields]=get_csl_schema()
%GET_CSL_SCHEMA  Accepted and required fields for crossLoc blocks.

accepted_fields={'id','branchId','chainage','shift','definitionId'};
required_fields={'id','branchId','chainage','definitionId'};

end %function get_csl_schema

%% =========================================================================

function validate_required_fields(csl_item,required_fields,kcsd)
%VALIDATE_REQUIRED_FIELDS  Ensure required fields exist and are non-empty.

missing=cell(0,1);
for k=1:numel(required_fields)
    fkey=required_fields{k};
    if ~isfield(csl_item,fkey) || isempty(csl_item.(fkey))
        missing{end+1,1}=fkey; %#ok<AGROW>
    end
end

if ~isempty(missing)
    error('Cross-section location %d missing required fields: %s', ...
        kcsd,strjoin(missing,', '))
end

end %function validate_required_fields
