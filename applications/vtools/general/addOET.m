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
%Add OpenEarthTools to Matlab path if these are not already available.
%
%INPUT:
%
%OUTPUT:
%

function addOET(varargin)

%% PARSE

if nargin==0 %we assume it is called with `run` (i.e., no variables can be passed)
    path_v_gen=pwd; %when doing `run`, it does `cd` to where it is called
    if evalin('caller', 'exist(''fdir_d3d'',''var'')')
        path_d3d_co=evalin('caller','fdir_d3d');
    else
        path_d3d_co='c:\checkouts\delft3d';
    end
elseif nargin==1
    path_v_gen=varargin{1,1};
    path_d3d_co='c:\checkouts\delft3d';
elseif nargin==2
    path_d3d_co=varargin{1,1};
else
    error('Incorrect number of input')
end

%linux
if isunix %we assume that if Linux we are in the p-drive. !!DANGER
    path_v_gen=strrep(strrep(strcat('/',strrep(path_v_gen,'P:','p:')),':',''),'\','/');
    path_d3d_co=strrep(strrep(strcat('/',strrep(path_d3d_co,'P:','p:')),':',''),'\','/');
end

%% ADD

if exist('oetsettings','file')~=2
    
    %% parse

    fdir_oet=fullfile(path_v_gen,'../','../','../');
    fdir_oet=strrep(fdir_oet,'\','/');
    path_oet=fullfile(fdir_oet,'oetsettings.m');

    %% modify path
    
    %when running in Cartesius, the path needed to be modified. 
    %if necessary, uncomment and clean this part of the code
    %making it general enough
    
%     switch path_oet(1)
%         case 'p'
%     end
% 
%     [~,name]=system('hostname');
%     if ispc
%     %     path_drive_p='p:\';
%     elseif isunix        
%         if contains(name,'bullx') %cartesius
%             path_oet(1:3)='';
%             path_oet=fullfile('/projects/0/hisigem/',path_oet);
%         end
%     else
%         error('adapt the paths')
%     end

    %% add repository
    
    fprintf('Start adding repository at %s \n',path_oet);
    run(path_oet);

    %% remove quickplot from OET folder
    path_qp=fullfile(fdir_oet,'applications','delft3d_matlab');
    rmpath(path_qp);

    %% add path qp from <src> delft3d


    %e.g.: 'c:\checkouts\delft3d\src\tools_lgpl\matlab\quickplot\progsrc\'
    path_qp_src=fullfile(path_d3d_co,'src','tools_lgpl','matlab','quickplot','progsrc');
    if isfolder(path_qp_src)==0
        warning('Folder with QuickPlot from Delft3D source not available here: %s',path_qp_src);
        fprintf('Using QuickPlot in OpenEarthTools repository (old).\n')
    else
        addpath(path_qp_src);
        fprintf('Using QuickPlot repository at %s \n',path_qp_src)
    end

else
    path_oet=which('oetsettings');
end

%%

fprintf('Using repository at %s \n',path_oet)

end %function

