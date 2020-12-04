%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%201123

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

    %% who am I?
[ret,name]=system('hostname');
if ispc
    path_drive_p='p:\';
elseif isunix
    if contains(name,'bullx') %cartesius
        path_drive_p='/projects/0/hisigem/';
    else %h6
        path_drive_p='/p/';
    end     
else
    error('adapt the paths')
end

    %% input
flg.repo=1; %repository location: 1=local on C; 2=on p

path_oet_c='c:\Users\chavarri\checkouts\openearthtools_matlab\oetsettings.m';
path_oet_p=fullfile(path_drive_p,'11205258-016-kpp2020rmm-3d','E_Software_Scripts','repositories','openearthtools_matlab','oetsettings.m');
    
    %% add paths

if exist('oetsettings','file')~=2
    switch flg.repo
        case 1
            fprintf('Using repository at %s \n',path_oet_c)
            path_oet=path_oet_c;
        case 2
            fprintf('Using repository at %s \n',path_oet_p)
            path_oet=path_oet_p;
        otherwise
            error('ups...')
    end
    fprintf('Start adding repository \n');
    run(path_oet);
else
    path_oet=which('oetsettings');
    fprintf('Using repository at %s \n',path_oet_c)
end

%% INPUT
