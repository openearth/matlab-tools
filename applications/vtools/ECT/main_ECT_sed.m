%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18286 $
%$Date: 2022-08-09 13:35:55 +0200 (Tue, 09 Aug 2022) $
%$Author: chavarri $
%$Id: main_ECT.m 18286 2022-08-09 11:35:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/main_ECT.m $
%

%% PREAMBLE

clear
clc
fclose all;
close all

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn) 

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
