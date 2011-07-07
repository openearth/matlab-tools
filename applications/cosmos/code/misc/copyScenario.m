clear all;close all;
hm=ReadOMSConfigFile;

Continents{1}='northamerica';
Continents{2}='centralamerica';
Continents{3}='southamerica';
Continents{4}='asia';
Continents{5}='europe';
Continents{6}='africa';
Continents{7}='australia';
Continents{8}='world';

scenori='forecasts';
scennew='jan2010';

MakeDir([hm.MainDir 'scenarios'],scennew);
scendir=[hm.MainDir 'scenarios\' scennew '\'];

oridir=[hm.MainDir 'scenarios\' scenori '\'];

MakeDir(scendir,'observations');
copyfile([oridir 'observations'],[scendir 'observations']);

MakeDir(scendir,'joblist');

% MakeDir(scendir,'meteo','gfs1p0');
MakeDir(scendir,'meteo','gfs1p0');
MakeDir(scendir,'meteo','nam');
% MakeDir(scendir,'meteo','hirlam');
% MakeDir(scendir,'meteo','wrf');

for i=1:8
    MakeDir(scendir,'models',Continents{i});
end

for i=1:8
    cnt=Continents{i};
    lst=dir([oridir 'models\' cnt]);
    for j=1:length(lst)
        switch lst(j).name
            case{'.','..'}
            otherwise
                model=lst(j).name;
                MakeDir([scendir 'models\' cnt],model);
                MakeDir([scendir 'models\' cnt '\' model],'input');
                MakeDir([scendir 'models\' cnt '\' model],'archive');
                MakeDir([scendir 'models\' cnt '\' model],'restart');
                MakeDir([scendir 'models\' cnt '\' model],'lastrun');
                MakeDir([scendir 'models\' cnt '\' model],'nesting');
                copyfile([oridir 'models\' cnt '\' model '\' model '.xml'],[scendir 'models\' cnt '\' model]);
                copyfile([oridir 'models\' cnt '\' model '\input\*'],[scendir 'models\' cnt '\' model '\input']);
                [success,message,messageid] = copyfile([oridir 'models\' cnt '\' model '\nesting\*'],[scendir 'models\' cnt '\' model '\nesting']);
        end
    end
end
