%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18391 $
%$Date: 2022-09-27 13:13:00 +0200 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_simpath.m 18391 2022-09-27 11:13:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath.m $
%

function struct_all=D3D_read_structures(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_rkm','');

parse(parin,varargin{:})

fpath_rkm=parin.Results.fpath_rkm;

%% CALC

if isfield(simdef(1).file,'struct') && ~isempty(simdef(1).file.struct)
    gen_struct=D3D_general_structures(simdef(1).file.struct,'fpath_rkm',fpath_rkm);
    %general structure saved as type 1
    aux=num2cell(ones(numel(gen_struct),1));
    [gen_struct.type]=aux{:};
else
    gen_struct=struct('xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

if isfield(simdef(1).file,'pillars') && ~isempty(simdef(1).file.pillars)
    pillars=D3D_pillars(simdef.file.pillars,'fpath_rkm',fpath_rkm);
    %pillars saved as type 2
    aux=num2cell(2*ones(numel(pillars),1));
    [pillars.type]=aux{:};
else 
    gen_struct=struct('xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

%I have not checked the case there is only one of the two. Check that preallocation is correct
struct_all=[pillars,gen_struct];

end %function