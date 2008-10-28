%BCT2BCA_TEST     test script for BCT2BCA
%
%See also: BCA2BCT, BCT2BCA 

H.components  = {'K1','O1','P1','Q1','K2','M2','N2','S2'};
H.latitude    = 52; % eps; %52;
H.plot        = 0;
H.pause       = 0;
H.output      = 'none';
H.residue     = ['.\bct2bca_test\TMP_cas_residue_'   ,num2str(H.latitude),'noa0.bct'];
H.prediction  = ['.\bct2bca_test\TMP_cas_prediction_',num2str(H.latitude),'noa0.bct'];

%% Analyse raw time series with a strong meteo tide
%% -------------------------

H.A0          = 0;
bct2bca('.\bct2bca_test\TMP_cas.bct',...
       ['.\bct2bca_test\bct2bca_',num2str(H.latitude),'noa0.bca'],...
        '.\bct2bca_test\bca.bnd',H);

%% Analyse raw time series with a strong meteo tide
%% -------------------------

H.A0          = 1;
bct2bca('.\bct2bca_test\TMP_cas.bct',...
       ['.\bct2bca_test\bct2bca_',num2str(H.latitude),'.bca'],...
        '.\bct2bca_test\bca.bnd',H);


%% Now analyse predicted water levels and test whether the residual is zero
%% -------------------------

H.residue    =['.\bct2bca_test\TMP_cas_residue_of_prediction_'   ,num2str(H.latitude),'.bct'];
H.prediction =['.\bct2bca_test\TMP_cas_prediction_of_prediction_',num2str(H.latitude),'.bct'];
        

H.A0          = 0;
bct2bca(['.\bct2bca_test\TMP_cas_prediction_'   ,num2str(H.latitude),'noa0.bct'],...
        ['.\bct2bca_test\bct2bca_of_prediction_',num2str(H.latitude),'noa0.bca'],...
        '.\bct2bca_test\bca.bnd',H);        
        
H.A0          = 1;
bct2bca(['.\bct2bca_test\TMP_cas_prediction_'   ,num2str(H.latitude),'.bct'],...
        ['.\bct2bca_test\bct2bca_of_prediction_',num2str(H.latitude),'.bca'],...
        '.\bct2bca_test\bca.bnd',H);        
                