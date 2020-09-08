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
%bat parallel file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.D3D.home = full path to the folder where Delft3D is located [string] e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
%
%OUTPUT:
%   -a .bat compatible with D3D is created in file_name

function D3D_bat_parallel(file)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
home=simdef.D3D.home;

%% FILE

%no edit
data{1, 1}='@ echo off';
data{2, 1}='set argfile=config_flow2d3d.xml';
data{3, 1}='set ARCH=win32';

%edit
data{4, 1}=sprintf('set home=%s',home);

%no edit
data{5, 1}='set exedir=%home%\%ARCH%\flow2d3d\bin';
data{6, 1}='set PATH=%exedir%;%PATH%';
data{7, 1}='%exedir%\d_hydro.exe %argfile%';
data{8, 1}=':end';
% data{9, 1}='pause'; %uncomment will wait for input after simulation has finished

%% WRITE

file_name=fullfile(dire_sim,'run_flow2d3d.bat');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s\n',data{kl,1});
end

fclose(fileID_out);