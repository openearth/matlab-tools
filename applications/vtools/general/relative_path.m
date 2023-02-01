%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18680 $
%$Date: 2023-01-30 13:29:13 +0100 (Mon, 30 Jan 2023) $
%$Author: chavarri $
%$Id: D3D_ext.m 18680 2023-01-30 12:29:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_ext.m $
%
%Write path of <fpath_file> relative to <fpath_dir>

function fpath_rel=relative_path(fpath_file,fpath_dir)

% fpath_file='p:\dflowfm\projects\2022_improve_exner\04_documents\04_test_01\co\01_figures\morfac_test\MF_10_12.png';
% fpath_file='p:\dflowfm\projects\2022_improve_exner\06_simulations\02_runs\r612\MF_10_12.png';
% fpath_file='p:\dflowfm\projects\2022_improve_exner\06_simulations\02_runs\MF_10_12.png';
% fpath_dir ='p:\dflowfm\projects\2022_improve_exner\06_simulations\02_runs\r612\';

if strcmp(fpath_dir(end),'/') || strcmp(fpath_dir(end),'\')
    fpath_dir(end)='';
end

tok_file=regexp(fpath_file,filesep,'split');
tok_dir =regexp(fpath_dir ,filesep,'split');

%% find last common ancestor
ndir=numel(tok_dir);
common=true;
kdir=0;
while common
    kdir=kdir+1;
    if kdir==ndir
        common=false; %it is in the same folder
        kdir=kdir+1; %for idx_up to be 0
    else
        common=strcmp(tok_file{1,kdir},tok_dir{1,kdir});
    end
end
idx_comm=kdir;
idx_up=ndir-idx_comm+1; 

%go up
if idx_up==0
    str_up='./';
else
    str_up=repmat('../',1,idx_up);
end
%go down
str_down=fullfile(tok_file{idx_comm:end});

fpath_rel=fullfile(str_up,str_down);
strrep(fpath_rel,'\','/'); %regardless of the system, write linux bars, as these are read correctly by D3D

end %function