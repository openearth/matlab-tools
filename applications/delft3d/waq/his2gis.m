
%% HIS2GIS (northsea modelling)
%%% Reads substances from TBNT runs and outputs csv tabels with concentrations for each tagged substance and area
%%% Author: Dr M Chatelain
%%% Update: 11-11-11
%%% 
%%% load his files, identify tagged substances and perform yearly/seasonaly averaged
%%% per area, per station, and per year for the OSPAR runs. write output in tables
%%% (stations x areas) in a GIS format (comma separated values)
%%%
%%% 1) define the correct path to the data (>PREPARATION>>PATH)
%%% 2) define the user variables, i.e. the combinations of substances (>USER VARIABLES)

tic
% clear all; %hold off; close all;

%% PREPARATION
disp('preparation');

%%% path
maindir='d:\Netwerk\Internationaal\KnowSeas_EU\nzbgem_backup\'; %%% main path
% maindir='p:\z4351-ospar07\Knowseas_2011\Postprocessing\nzbgem_backup\'; %%% main path
localdir='d:\Netwerk\Internationaal\KnowSeas_EU\nzbgem_postproc\Tag_Area_Data\'; %%% local path
% localdir='p:\z4351-ospar07\Knowseas_2011\Postprocessing\matlab'; %%% local path
runid='KH';

%%% global parameters
listofaveraged=char('year','winter','spring','summer','fall');
nbaveraged=size(listofaveraged,1); listofaveragedcell=cellstr(listofaveraged);
vectwinter=[1:9,49:52]; vectspring=10:22; vectsummer=23:35; vectfall=36:48; vectyear=1:52; %%% output per week
vectseason=[vectwinter;vectspring;vectsummer;vectfall];

%%% lists of areas, years, stations, and substances
listofareas=char('BE','FR','GM','NL1','NL2','UK1','UK2','CH','NA','ATM');
nbareas=size(listofareas,1); listofareascell=cellstr(listofareas);
listofyears=char('96','97','98','99','00','01','02');
nbyears=size(listofyears,1); listofyearscell=cellstr(listofyears);
listofyearslg=char('1996','1997','1998','1999','2000','2001','2002');
listofyearslgcell=cellstr(listofyearslg);
listofstations=char('Noordzee','UKC6','UKO5','NO2','DO1','DC1','UKC5','UKC4','DO2','UKC3','UKO4','NLO3','GO3','DWD1','UKO3','GO2','NLO2','DWD2','UKC2','UKO2','GO1','GC1',...
    'UKC1','GWD1','UKO1','NLO1','UKC7','BO1','FO1','UKC8','BC1','NLC1','NLC2','NLC3','UKC9','FC2','FC1','GWD2','NLWD');
nbstations=size(listofstations,1); listofstationscell=cellstr(listofstations);
listofsubstances=char('DetN-r','DetP-r','NH4-r','NO3-r','PO4-r','DIN_E-N-r','DIN_N-N-r','DIN_P-N-r','MDI_E-N-r','MDI_N-N-r','MDI_P-N-r','MFL_E-N-r','MFL_N-N-r',...
    'MFL_P-N-r','PHA_E-N-r','PHA_N-N-r','PHA_P-N-r','DIN_E-P-r','DIN_N-P-r','DIN_P-P-r','MDI_E-P-r','MDI_N-P-r','MDI_P-P-r','MFL_E-P-r','MFL_N-P-r','MFL_P-P-r',...
    'PHA_E-P-r','PHA_N-P-r','PHA_P-P-r','DetNS1-r','DetPS1-r');
nbsubstances=size(listofsubstances,1); listofsubstancescell=cellstr(listofsubstances);

%% USER VARIABLES
disp('user variables');
%%% define the desired combination of substances
%%% (=variables) from listofsubstances
myvariablesnames=char('TNr','AlgNr','OrgNr','NO3r','NH4r','DetNS1r','TPr','AlgPr','OrgPr','PO4r'); %% nb: no spaces in the names!
nbmyvariables=size(myvariablesnames,1); myvariablesnamescell=cellstr(myvariablesnames);
var1=[1,3,4,6:17]; %%% TNr
var2=6:17; %%% AlgNr
var3=[1,6:17]; %%% OrgNr
var4=4; %%% NO3r
var5=3; %%% NH4r
var6=30; %%% DetNS1r
var7=[2,5,18:29]; %%% TPr
var8=18:29; %%% AlgPr
var9=[2,18:29]; %%% OrgPr
var10=5; %%% PO4r

file=fopen('subscript1.m','w'); %%% define the list of my variables
fprintf(file,'\nlistofmyvariables=[');
for ii=1:nbmyvariables-1
    fprintf(file,'var%i,zeros(1,nbsubstances-length(var%i));',ii,ii);
end
fprintf(file,'var%i,zeros(1,nbsubstances-length(var%i))]'';',nbmyvariables,nbmyvariables);
fprintf(file,'\nlengthmyvariables=[');
for ii=1:nbmyvariables-1
    fprintf(file,'length(var%i);',ii);
end
fprintf(file,'length(var%i)];',nbmyvariables);
fclose(file);
cd(localdir); run subscript1 %%% run subscript1

%% CALCULATIONS
disp('calculations');
%%% initialisation
outputdata=zeros(nbstations,nbaveraged,nbmyvariables,nbareas,nbyears); %%% output matrix data
listofmystations=zeros(nbstations,1); %%% chosen stations
listofmysubstances=zeros(nbsubstances,1); %%% chosen substances

%%% main loop
for kk=1:nbyears %%% loop over the years
    for jj=1:nbareas %%% loop over the areas

foldername=[runid,listofyears(kk,:),listofareas(jj,:)]; %%%% name of the new folder
cd(maindir); cd(foldername); %%%% change path to new folder
struct=delwaq('open','TBNT.HIS'); %%%% load data

if kk==1 && jj==1 %% choose stations and substances (to do only once)
    stationsnames=struct.SegmentName; %%% all stations in the his file
    substancesnames=struct.SubsName; %%% all substances in the his file

    for ii=1:nbstations %%% find my stations
        listofmystations(ii)=strmatch(listofstationscell(ii),stationsnames,'exact');
    end
    
    for ii=1:nbsubstances %%% find my substances
        listofmysubstances(ii)=strmatch(listofsubstancescell(ii),substancesnames,'exact');
    end
    
end

[~,data]=delwaq('read',struct,listofmysubstances,listofmystations,0); %%% read data

for mm=1:nbmyvariables
    tempdata=sum(data(listofmyvariables(1:lengthmyvariables(mm),mm),:,:),1); %%% my variables (sum over substances) data
   
    outputdata(:,1,mm,jj,kk)=mean(tempdata(:,:,vectyear),3)'; %%% time (yearly-averaged) data
    for ll=2:nbaveraged %%% time (seasonally-averaged) data
        outputdata(:,ll,mm,jj,kk)=mean(tempdata(:,:,vectseason(ll-1,:)),3)';
    end
    
    clear tempdata %%% cleaning
end

clear struct data %%% cleaning
    end
end

%% WRITING OUTPUT
disp('writing output');
%%% write subscript to change file name where data is stored
cd(localdir);
file=fopen('subscript2.m','w');

for ll=1:nbaveraged %%% loop over the averaged
    fprintf(file,'ll=%i;\n',ll);
    fprintf(file,'\nsubfoldername=listofaveraged(ll,1:size(listofaveragedcell{ll},2));'); %%% subfolder name
    fprintf(file,'\ncd(localdir); '); %%% path to localdir
    fprintf(file,'\nmkdir(subfoldername);\n'); %%% create subfolder (comment if already exists) 
    fprintf(file,'cd(subfoldername);'); %%% path to the subfolder

    for mm=1:nbmyvariables %%% loop over my variables
        for kk=1:nbyears %%% loop over the years

    fprintf(file,'kk=%i; mm=%i;\n',kk,mm);
    fprintf(file,'\nfid=fopen(''%s_%s_%s.csv'',''w'');',listofyearslgcell{kk}, ...
    myvariablesnamescell{mm},listofaveragedcell{ll}); %%% open file with name=year_myvariable_averaged.csv)

    fprintf(file,'\nfprintf(fid,''area'');');
    fprintf(file,'\nfor jj=1:nbareas'); %%% loop over the areas
    fprintf(file,'\nfprintf(fid,'',%%s'',listofareascell{jj});'); %%% name of the areas
    fprintf(file,'\nend');

    fprintf(file,'\nfor ii=1:nbstations'); %%% loop over the stations
    fprintf(file,'\nfprintf(fid,''\\n%%s'',listofstationscell{ii});'); %%% name of the stations
    fprintf(file,'\nfor jj=1:nbareas'); %%% loop over the areas
    fprintf(file,'\nfprintf(fid,'',%%1.6f'',outputdata(ii,ll,mm,jj,kk));'); %%% data
    fprintf(file,'\nend');
    fprintf(file,'\nend');

    fprintf(file,'\nfclose(fid);\n\n'); %%% close the file

        end
    end
end
fclose(file); %%% close the file
cd(localdir); run subscript2; %%% run subscript2
toc

%% FIGURE
disp('figure');
%%% outputdata(nbstations,nbaveraged,nbmyvariables,nbareas,nbyears)
nstation=1; naveraged=2; nmyvariable=3; narea=4; nyear=5;

%%% fig1: per averaged and per area (ex=PO4r at NorthSea station in 2001)
order=[naveraged narea nstation nmyvariable nyear];
dataplot=permute(outputdata,order); %% permutation of the data

bar(dataplot(:,:,1,10,6),'stacked'); axis([0 6 0 0.03]);
ylabel(myvariablesnamescell{10});
legend(listofareas,'location','eastoutside');
set(gca,'xticklabel',listofaveraged);
        
%% CLEANING
cd(localdir); delete subscript1.m subscript2.m
clear *dir f* list* *name* nb* *my* var* vect*
       