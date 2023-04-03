%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17472 $
%$Date: 2021-09-01 16:25:14 +0200 (Wed, 01 Sep 2021) $
%$Author: chavarri $
%$Id: main_ECT.m 17472 2021-09-01 14:25:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/main_ECT.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn) 

%% INPUT

fpath_his='c:\Users\chavarri\temporal\220129_greenwheels\history.csv';

%dim 1=tarif
%dim 2=[fixed cost [eur/month],time cost [eur/h],distance cost [eur/km]];
%dim 3=car type

cost_tim(1,:,1)=[0,6,0.34];
cost_tim(2,:,1)=[10,4,0.29];
cost_tim(3,:,1)=[25,3,0.24];

cost_tim(1,:,2)=[0,7.5,0.39];
cost_tim(2,:,2)=[10,5.5,0.34];
cost_tim(3,:,2)=[25,4.5,0.29];

%% READ

his_raw_c=readcell(fpath_his);
his_raw_m=readmatrix(fpath_his);

t0_datet=datetime(his_raw_c(:,1),'InputFormat','dd-MM-yyyy HH:mm');
tf_datet=datetime(his_raw_c(:,2),'InputFormat','dd-MM-yyyy HH:mm');
km=his_raw_m(:,3);
car_type=his_raw_m(:,4);
trip_type=his_raw_m(:,5);

%% CALC

%% ad-hoc remove trips

%%
bol_get=year(t0_datet)>2020&year(t0_datet)<2022&trip_type==1;
tim_h=hours(tf_datet-t0_datet);

nt=size(cost_tim,1);

tim_h_loc=tim_h(bol_get);
km_loc=km(bol_get);
car_type_loc=car_type(bol_get);
nu=numel(tim_h_loc);

C_fix=NaN(nt,1);
C_tim=NaN(nt,nu);
C_dis=NaN(nt,nu);
for kt=1:nt
    C_fix(kt)=cost_tim(kt,1,1)*12;
for ku=1:nu
    C_tim(kt,ku)=cost_tim(kt,2,car_type_loc(ku)).*tim_h_loc(ku);
    C_dis(kt,ku)=cost_tim(kt,3,car_type_loc(ku)).*km_loc(ku);
end

end %ku

C_trip=C_tim+C_dis;
C_tim_tot=sum(C_tim,2);
C_dis_tot=sum(C_dis,2);
C_tot=C_fix+C_dis_tot+C_tim_tot;
C=[C_fix,C_tim_tot,C_dis_tot];

%% PLOT

X = categorical({'soms','regelmatig','vaak'});
X = reordercats(X,{'soms','regelmatig','vaak'});
% Y = [10 21 33 52];


figure
hold on
bar(X,C,'stacked')
legend('fixed','time','distance')
ylabel('euro')