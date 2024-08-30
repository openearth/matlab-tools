%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Call to <enloss.dll>

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

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

%% INPUT

d1=2; %distance between crest and downstream depth (always >0) [m].
crest_height=2; %crest height (downward negative) [m+AD]. `bup` in code.
v_us=1; %upstream velocity magnitude [m/s]. `vbov` in code.
h_us=10.1; %upstream flow depth [m]. `hunoweir` in code.
wsben=10; %downstream water level [m]. 
wsbov=10.1; %upstream water level [m+AD].
iflagweir=25; %flag for selecting fixed-weir scheme: 24=Tabellenboek; 25=Villemonte
crestl=3.0; %crest length (in direction parallel to the flow) [m].
rmpben=4.0; %downstream slope as rmpben:1 [H:V]. 
rmpbov=4.0; %upstream slope as rmpbov:1 [H:V]. 
veg=0.0; %vegetation friction.
VillemonteCD1=1; 
VillemonteCD2=10;
VillemonteCD3=0.5; %only if `testfixedweirs=2`
iflagcriteriumvol=1; %Flag to control the criterium for free-flowing (onvolkomen) and submerged (volkomen) conditions:
                     %1: Villemonte different than Tabellenboek (original)
                     %2: Both Villemonte and Tabellenboek with the criterium of Tabellenboek
iflaglossvol=1; %Flag to control the energy losses under free-flowing conditions:
                %1: Energy loss equal to water-level difference (original)
                %2: Energy loss equal to energy difference
testfixedweirs=1;  %1=default; 2=test new implementation with correct Carnot losses (Chavarrias23_6)
fpath_dll=fullfile(pwd,'../','fortran','x64','Release','enloss.dll');
fpath_h=fullfile(pwd,'../','header','enloss.h');
flg_obj=2; %matching function in implicit solver:
           %1: energy head
           %2: piezometric head (as in D3D)

%% COPY and LOAD
%dll and header in same folder

[~,dllname,ext]=fileparts(fpath_dll);
fpath_dll_loc=fullfile(pwd,sprintf('%s%s',dllname,ext));
copyfile_check(fpath_dll,fpath_dll_loc);

fpath_h_loc=fullfile(pwd,sprintf('%s.h',dllname));
copyfile_check(fpath_h,fpath_h_loc);

lib=loadlibrary(sprintf('%s.dll',dllname),sprintf('%s.h',dllname));

%% TEST
%Raw call to the functions. The solution is not in equilibrium. 

dte1=calllib(dllname,'fcn_enloss',d1,crest_height,v_us,h_us,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,testfixedweirs,VillemonteCD3);
volk=calllib(dllname,'fcn_volkomen',d1,crest_height,v_us,h_us,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,testfixedweirs,VillemonteCD3);

%% IMPLICIT SOLUTION
%Given the downstream water level and the constant discharge, what is the
%upstream water level that matches the nergy head loss given by the fixed weir. 

q=v_us*h_us;
[dte2,volk2,E_us,E_ds,wsbov,u_us,qc_v]=fcn_enloss(dllname,d1,crest_height,wsben,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,q,flg_obj,testfixedweirs,VillemonteCD3);

%% UNLOAD

unloadlibrary(dllname)
