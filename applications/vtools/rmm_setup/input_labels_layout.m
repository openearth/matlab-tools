%This creates the conversion table between the names in SOBEK-3 and in the
%data by RWS
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%200610
%
%add paths to OET tools:
%   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
%   run(setproperty)
%add paths to RIV tools:
%   https://repos.deltares.nl/repos/RIVmodels/rivtools/trunk/matlab
%   run(rivsettings)

%% EXPLANATION

    %% input example
    
% kl=kl+1;
% var{kl,1}='H';
% labels_data{kl,1}='HOEKVHLD';
% labels_s3{kl,1}='Maasmond';
% function_s3(kl,1)=1;
% function_param_s3(kl,1)=-20;
% function_sre(kl,1)=1;
% function_param_sre(kl,1)=-20;

    %% description
    
%name of the location in the data given by RWS:
% labels_data{kl,1}='HOEKVHLD';

%node id in the SOBEK-3 model:
% labels_s3{kl,1}='Maasmond';

%function to be applied in SOBEK-3:
%   0 = nothing
%   1 = time shift
% function_s3(kl,1)=1;

%parameter to apply to the function:
%   for function 1: time shift in minutes (positive is to shift the time series to the future)
% function_param_s3(kl,1)=-20;

%node id in the SOBEK-RE model:
%Attention! not the name, but the id. E.g.:
%NODE id 'P_1' nm 'Maasmond' px 62730.0 py 445440.0 node
%the id is 'P_1' and not 'Maasmond'. 
%This is done for consistency with the SOBEK-3, where we also provide node
%id. 
% labels_sre{kl,1}='P_1';

%idem as for SOBEK-3
% function_sre(kl,1)=1;

%idem as for SOBEK-3
% function_param_sre(kl,1)=-20;

%variable to take at this location (in case data is redundant). In
%principle, it should not be necessary. However, there may be water level
%information associated to both 'HOEKVHLD' and 'MAASMD' and salinity
%information at 'MAASMD'.
%   -'Q' = water discharge (also lateral)
%   -'H' = water level
%   -'Cl' = salinity
%   -'-' = not necessary
% var{kl,1}='H';

%% INPUT

kl=0;

kl=kl+1;
var{kl,1}='H';
labels_data{kl,1}='HOEKVHLD';
labels_s3{kl,1}='Maasmond';
function_s3(kl,1)=1;
function_param_s3(kl,1)=-20;
labels_sre{kl,1}='P_1';
function_sre(kl,1)=1;
function_param_sre(kl,1)=-20;

kl=kl+1;
var{kl,1}='-';
labels_data{kl,1}='HARVT10';
labels_s3{kl,1}='HARVT10';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_91';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='-';
labels_data{kl,1}='HARVT10';
labels_s3{kl,1}='Bokkegat_buiten';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_92';
function_sre(kl,1)=1;
function_param_sre(kl,1)=+20;

kl=kl+1;
var{kl,1}='-';
labels_data{kl,1}='HAGSBVN';
labels_s3{kl,1}='Hagestein';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_P_007';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='H';
labels_data{kl,1}='MEGDP';
labels_s3{kl,1}='BovenLith';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='015';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='Q';
labels_data{kl,1}='TIELWL';
labels_s3{kl,1}='BovenTiel';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_P_003';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='Cl';
labels_data{kl,1}='EIJSDPTN';
labels_s3{kl,1}='BovenLith';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='015';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='Cl';
labels_data{kl,1}='LOBPTN';
labels_s3{kl,1}='BovenTiel';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_P_003';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='Cl';
labels_data{kl,1}='MAASMD'; %{'HOEKVHLRTOVR'}
labels_s3{kl,1}='Maasmond';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_1';
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='-';
labels_data{kl,1}='RAKZ';
labels_s3{kl,1}='ModelVolkerakLateraal';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_P_5686147'; 
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;

kl=kl+1;
var{kl,1}='-';
labels_data{kl,1}='BGGouda';
labels_s3{kl,1}='Gouda';
function_s3(kl,1)=0;
function_param_s3(kl,1)=0;
labels_sre{kl,1}='P_21639'; 
function_sre(kl,1)=0;
function_param_sre(kl,1)=0;


%% INPUT RTC

%the long name of the component when importing into the SOBEK-3 GUI is
%understandable. However, we use the id for consistency. 
aux_labels_sre_rtc={
'7154338'
'7154339'
'7154340'
'7154341'
'7154342'
'7154343'
'7154344'
'7154345'
'7154346'
'7154347'
'7154348'
'7154349'
'7154350'
'7154351'
'7154353'
'7154354'
'7154355'
};

% for kl=1:1 %debug option
for kl=1:17
labels_data_rtc{kl,1}=sprintf('HVS%02d',kl);
labels_s3_rtc{kl,1}=sprintf('HVSL_%02d',kl);
labels_sre_rtc{kl,1}=aux_labels_sre_rtc{kl,1};
end

