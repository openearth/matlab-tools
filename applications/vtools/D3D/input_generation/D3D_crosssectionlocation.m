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

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

dire_sim=simdef.D3D.dire_sim;
csl=simdef.csl;  

ncsd=numel(csl);
fields_csl=fields(csl);
nfields=numel(fields_csl);

%% FILE

kl=1;
%%
data{kl,1}=        '[General]'; kl=kl+1;
data{kl,1}=        '   fileVersion           = 1.01'; kl=kl+1;
data{kl,1}=        '   fileType              = crossLoc'; kl=kl+1;
%%
for kcsd=1:ncsd
%     nlevels=csl(kcsd).numLevels;
    
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[CrossSection]'; kl=kl+1;
    for kfields=1:nfields
        if ischar(csl(kcsd).(fields_csl{kfields}))
            switch fields_csl{kfields}
                case {'id','branchId','definitionId'}
                    data{kl,1}=sprintf('   %s = #%s# ',fields_csl{kfields},csl(kcsd).(fields_csl{kfields})); kl=kl+1;
                otherwise
                    data{kl,1}=sprintf('   %s = %s ',fields_csl{kfields},csl(kcsd).(fields_csl{kfields})); kl=kl+1;
            end
        else %double
%             if numel(csl(kcsd).(fields_csl{kfields}))>1
%                 aux_str=repmat('%f ',1,nlevels);
%                 aux_str2=sprintf('   %s = %s ',fields_csl{kfields},aux_str);
%                 data{kl,1}=sprintf(aux_str2,csl(kcsd).(fields_csl{kfields})); kl=kl+1;
%             else
                data{kl,1}=sprintf('   %s = %f ',fields_csl{kfields},csl(kcsd).(fields_csl{kfields})); kl=kl+1;
%             end
            
        end
    end
end

%% WRITE

file_name=fullfile(dire_sim,'CrossSectionLocations.ini');
writetxt(file_name,data,'check_existing',check_existing)
