%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 06:18:42 +0200 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_general_structures.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_general_structures.m $
%

function struct=D3D_pillars(path_pillars,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_rkm','');

parse(parin,varargin{:})

fpath_rkm=parin.Results.fpath_rkm;

%% CALC

struct=D3D_io_input('read',path_pillars);
nstruct=numel(struct);
for kstruct=1:nstruct
%     gen_struct(kgs).name=pli.name;
    struct(kstruct).xy_pli=struct(kstruct).xy; %coherent with <D3D_general_structures>
    struct(kstruct).xy=mean(struct(kstruct).xy_pli(:,1:2),1);
    if ~isempty(fpath_rkm)
        struct(kstruct).rkm=convert2rkm(fpath_rkm,struct(kstruct).xy,'TolMinDist',2000);
    end
end
