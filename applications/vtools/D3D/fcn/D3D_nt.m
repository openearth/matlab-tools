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
        % fprintf('DEBUG: fpath_res %s \n',fpath_res)
        % fprintf('DEBUG: fdir_output %s \n',fdir_output)
    nf=D3D_SMT_nf(fdir_output);

    %Original exact implementation. We loop through all the files and count the number of time steps in each file. This is slow, but it is the only way to get the exact number of time steps.
    %
    % nt=0;
    % for kf=0:1:nf
    %     fdir_loc=D3D_SMT_dir_output_loc(fdir_output,kf);       
    %         % fprintf('DEBUG: fdir_loc %s \n',fdir_loc)
    %     simdef.D3D.dire_sim=fdir_loc;
    %     simdef=D3D_simpath(simdef,'overwrite',0); 
    %     fpath_nc=simdef.file.(res_type);
    %         % fprintf('DEBUG: Processing %s \n',fpath_nc)
    %     nt=nt+D3D_nt_single(fpath_nc,res_type);
    %         % fprintf('%d\n',kf)
    % end

    %Smart speedup implementation. We assume that all the files have the same number of time steps, and we multiply the number of time steps in the first file by the number of files. This is much faster, but it is not guaranteed to be correct if the number of time steps is not the same in all files.
    kf=0;
    fdir_loc=D3D_SMT_dir_output_loc(fdir_output,kf);       
    simdef.D3D.dire_sim=fdir_loc;
    simdef=D3D_simpath(simdef,'overwrite',0); 
    fpath_nc=simdef.file.(res_type);
    nt=D3D_nt_single(fpath_nc,res_type);
    nt=(nf+1)*nt;
else
    nt=D3D_nt_single(fpath_res,res_type);    
end %is

end %function