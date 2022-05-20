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
%% PATH DEFINITIONS

source_path = pwd; 
paths_auxiliary         = fullfile(source_path,'..',filesep,'auxiliary');
paths_fcn               = fullfile(source_path,'..',filesep,'fcn');
paths_input_generation  = fullfile(source_path,'..',filesep,'input_generation');
paths_grid              = fullfile(source_path,'..',filesep,'grid');
paths_convert           = fullfile(source_path,'..',filesep,'convert_d3d_fm');
% paths_postprocessing    = fullfile(source_path,'..',filesep,'postprocessing');

% addpath('C:\Users\chavarri\surfdrive\projects\00_codes\matlab_functions\')

%% ADD PATHS

%paths to add if they are not already added
paths2add{1,1}=paths_fcn;
paths2add{2,1}=paths_input_generation;       
paths2add{3,1}=paths_auxiliary;
paths2add{4,1}=paths_grid;
paths2add{5,1}=paths_convert;

paths_inmatlab=regexp(path,pathsep,'split');
for kp=1:numel(paths2add)
    if ispc  % Windows is not case-sensitive
      onPath=any(strcmpi(paths2add{kp,1},paths_inmatlab));
    else
      onPath=any(strcmp(paths2add{kp,1},paths_inmatlab));
    end
    if onPath==0
        addpath(paths2add{kp,1});
    end
end