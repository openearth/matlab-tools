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

function gen_struct=D3D_general_structures(path_struct,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_rkm','');

parse(parin,varargin{:})

fpath_rkm=parin.Results.fpath_rkm;

%% CALC

path_struct_folder=fileparts(path_struct);
structures=D3D_io_input('read',path_struct);
structures_fieldnames=fieldnames(structures);
nstruct=numel(structures_fieldnames);
kgs=0;
gen_struct=struct('name',[],'xy',[],'xy_pli',[],'rkm',[],'type',[]);
for kstruct=1:nstruct
    if strcmp(structures.(structures_fieldnames{kstruct}).type,'generalstructure')
        path_genstruc_pli=fullfile(path_struct_folder,structures.(structures_fieldnames{kstruct}).polylinefile);
        kgs=kgs+1;
        pli=D3D_io_input('read',path_genstruc_pli);

        gen_struct(kgs).name=pli.name;
        gen_struct(kgs).xy_pli=pli.xy;
        gen_struct(kgs).xy=mean(gen_struct(kgs).xy_pli,1);
        if ~isempty(fpath_rkm)
            gen_struct(kgs).rkm=convert2rkm(fpath_rkm,gen_struct(kgs).xy);
        end
    end
end
