%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17172 $
%$Date: 2021-04-10 21:47:54 +0200 (Sat, 10 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_main_plot.m 17172 2021-04-10 19:47:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_plot.m $
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

sed_file='C:\Users\chavarri\temporal\210503_VOW\03_simulations\02_flume\01_input\sed\blom03.sed';
dk=0.001:0.001:0.1;

%% CALC

sed.SedimentFileInformation.FileCreatedBy='V';
sed.SedimentFileInformation.FileCreationDate=datestr(datetime('now'));
sed.SedimentFileInformation.FileVersion='02.00';

sed.SedimentOverall.Cref=1.6e3;
sed.SedimentOverall.IopSus=0;

nf=numel(dk);
for kf=1:nf
    
    sed.(sprintf('Sediment%d',kf)).Name=sprintf('Sediment%d',kf);
    sed.(sprintf('Sediment%d',kf)).SedTyp='bedload';
    sed.(sprintf('Sediment%d',kf)).RhoSol=2650;
    sed.(sprintf('Sediment%d',kf)).CDryB=1590;
    sed.(sprintf('Sediment%d',kf)).IniSedThick=1;
    sed.(sprintf('Sediment%d',kf)).FacDSS=1;
    
    sed.(sprintf('Sediment%d',kf)).SedDia=dk(kf);
    
    sed.(sprintf('Sediment%d',kf)).TraFrm=4;
    sed.(sprintf('Sediment%d',kf)).Acal=8;
    sed.(sprintf('Sediment%d',kf)).PowerB=0;
    sed.(sprintf('Sediment%d',kf)).PowerC=1.5;
    sed.(sprintf('Sediment%d',kf)).RipFac=1;
    sed.(sprintf('Sediment%d',kf)).ThetaC=0.047;
    
end

D3D_io_input('write',sed_file,sed);
