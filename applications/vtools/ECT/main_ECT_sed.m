%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

%% PREAMBLE

clear
clc
fclose all;
close all

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';

% fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

    %% input to function

% path_input='input_ECT_2D.m';
path_input='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\220517_improve_exner\input_ECT_2D.m';

in_2D.fig.fig_print=1;
in_2D.fig.fig_name='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\220517_improve_exner\domain';

hp=0:-0.1:-1;
La=linspace(0.05,0.5,11);

np=numel(hp);

%% CALL

run(path_input);

ECT_input.flg.hiding=2;
ECT_input.flg.anl=2;
ECT_input.sedTrans=[8,1.5,0.047];
% ECT_input.Fa1=[0.5];
% ECT_input.Fa1=[0.25];
ECT_input.Fi1=ECT_input.Fa1;

eigen=NaN(np,2);

for kp=1:np
    
ECT_input.hiding=hp(kp);
ECT_input.hiding=0;
ECT_input.La=La(kp);
% ECT_input.La=0.05;

in_2D.flg=ECT_input.flg;

[ECT_matrices,sed_trans]=call_ECT(ECT_input);

eigen(kp,:)=eig(ECT_matrices.Ax);

end

%%

figure
hold on
% plot(hp,eigen(:,1)./eigen(:,2))
plot(La,eigen(:,1)./eigen(:,2))
% xlabel('hiding parameter [-]')
xlabel('active layer thickness [m]')
ylabel('ratio of eigenvalues [-]')

figure
hold on
% plot(hp,eigen)
plot(La,eigen)
% xlabel('hiding parameter [-]')
xlabel('active layer thickness [m]')
ylabel('eigenvalues [-]')
