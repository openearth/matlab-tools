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

%% CHECK

is_OET=false;
if exist('oetsettings','file')==2
    is_OET=true;
    path_oet=which('oetsettings');
    fprintf('Using OET repository at %s \n',path_oet)
end

is_qp=false;
if exist('d3d_qp','file')==2
    is_qp=true;
    path_qp=which('d3d_qp');
    fprintf('Using QP repository at %s \n',path_qp)
end

if is_OET && is_qp
    return
end

%% PARSE

if nargin==0 %we assume it is called with `run` (i.e., no variables can be passed)

    %Path to folder where <addOET.m> resides
    %when doing `run`, it does `cd` to where it is called.
    path_v_gen=pwd; 

    %Path to the folder where the source code of Delft3D resides or where
    %the GitHub repository is checked out.
    if evalin('caller', 'exist(''fdir_d3d'',''var'')')
        path_d3d_co=evalin('caller','fdir_d3d');
    else
        path_d3d_co='';
    end
end

%linux
if isunix %we assume that if Linux we are in the p-drive. !!DANGER
    path_v_gen=linuxify(path_v_gen);
    path_d3d_co=linuxify(path_d3d_co);
end

%% OET

if ~is_OET
    
    %% paths

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

    %% disp
    fprintf('Using OET repository at %s \n',path_oet)
end

%% QUICKPLOT

if ~is_qp

    %e.g.: 'c:\checkouts\delft3d\src\tools_lgpl\matlab\quickplot\progsrc\'
    path_qp_src=fullfile(path_d3d_co,'src','tools_lgpl','matlab','quickplot','progsrc');
    if isfolder(path_qp_src)==0
        % warning('Folder with QuickPlot from Delft3D source not available here: %s',path_qp_src);
        % fprintf('Using QuickPlot in OpenEarthTools repository (old).\n')
    else
        addpath(path_qp_src);
        fprintf('Using QuickPlot repository at %s \n',path_d3d_co)
    end

end

end %function

%%
%% FUNCTIONS
%%

%%

function path_lin=linuxify(path_win)

if strcmp(path_win(2),':') %windows path
    path_win=small_p(path_win);
    path_lin=strcat('/',path_win);
    path_lin=strrep(path_lin,':','');
    path_lin=strrep(path_lin,'\','/');
else
    path_lin=path_win;
end

is_gui_mode = usejava('desktop') && usejava('awt');
if is_gui_mode
   clipboard("copy",path_lin);
end

end %function

%%
%% FUNCTIONS
%%

function path_dir=small_p(path_dir)

path_dir=strrep(path_dir,'P:','p:');

end %function