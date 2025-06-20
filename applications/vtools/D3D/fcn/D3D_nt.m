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
%

function nt=D3D_nt(fpath_res,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'res_type','map');

parse(parin,varargin{:});

res_type=parin.Results.res_type;

%% 

if isfolder(fpath_res)
    fdir_output=fullfile(fpath_res,'output');
    nf=D3D_SMT_nf(fdir_output);
    nt=0;
    for kf=0:1:nf
        fdir_loc=D3D_SMT_dir_output_loc(fdir_output,kf);       
        simdef.D3D.dire_sim=fdir_loc;
        simdef=D3D_simpath(simdef); %very expensive... 
        fpath_nc=simdef.file.(res_type);
        nt=nt+D3D_nt_single(fpath_nc,res_type);
        % fprintf('%d\n',kf)
    end
else
    nt=D3D_nt_single(fpath_res,res_type);    
end %is

end %function