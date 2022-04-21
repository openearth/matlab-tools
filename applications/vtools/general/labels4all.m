%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%labels
%
%INPUT
%   -var: variable to generate label
%       -'eta'       : elevation
%
%       -'etab'      : bed elevation
%       -'detab'     : bed elevation change
%
%       -'dist'      : distance
%       -'dist_prof' : distance along section
%       -'dist_mouth': distance from mouth
%
%       -{'etaw','WATHTE'}     : water level
%       -'h'        : flow depth
%
%       -'sal'      : salinity [psu]
%       -{'cl','CONCTTE'}       : chloride [mg/l]
%       -'salm2'    : mass of salt per unit surface [kg/m^2]
%       -'cl_surf'  : surface chloride [mg/l]
%
%       -'umag'     : velocity magnitude
%
%       -'x'        : x-coordinate
%       -'y'        : y-coordinate
%
%       -'Q'        : water discharge
%       -'Qcum'     : cumulative water discharge
%       -'qsp'      : specific water discharge
%
%       -'tide'     : tide
%       -'surge'    : surge
%
%       -'t'        : time
%       -'tshift'   : time shift
%
%       -'corr'     : correlation coefficient
%
%       -'dd'       : wind direction
%       -'fh'       : wind speed
%
%       -'simulation' : simulation
%       -'measurement': measurment
%       -'mea'      : measured
%       -'sim'      : computed
%
%       -'original' : original
%       -'modified' : modified
%
%       -'dg'       : geometric mean grain size
%       -'dm'       : arithmetic mean grain size
%
%       -'vicouv'   : horizontal viscosity
%
%       -'at'       : at
%
%
%   -un: factor for unit conversion from SI
%
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': spanish

function [lab,str_var,str_un,str_diff,str_background]=labels4all(var,un,lan,varargin)

%%

parin=inputParser;

addOptional(parin,'Lref','+NAP');

parse(parin,varargin{:});

Lref=parin.Results.Lref;

%%

switch lower(var)
    case 'eta'
        switch lan
            case 'en'
                str_var='elevation';
            case 'nl'
                str_var='hoogte';
            case 'es'
                str_var='elevación';
        end
        un_type='L';
    case 'etab'
        switch lan
            case 'en'
                str_var='bed elevation';
            case 'nl'
                str_var='bodemhoogte';
            case 'es'
                str_var='elevación del lecho';
        end
        un_type='L';
    case {'detab'}
        switch lan
            case 'en'
                str_var='bed elevation change';
            case 'nl'
                str_var='bodemverandering';
            case 'es'
                str_var='cambio en la elevación del lecho';
        end
        un_type='L';
    case 'dist'
        switch lan
            case 'en'
                str_var='distance';
            case 'nl'
                str_var='afstand';
            case 'es'
                str_var='distancia';
        end
        un_type='L'; 
    case 'dist_prof'
        switch lan
            case 'en'
                str_var='distance along section';
            case 'nl'
                str_var='afstand langs gevaren track';
            case 'es'
                str_var='distancia a lo largo de la sección';
        end
        un_type='L'; 
    case 'dist_mouth'
        switch lan
            case 'en'
                str_var='distance from mouth';
            case 'nl'
                str_var='afstand van de riviermonding';
            case 'es'
                str_var='distancia a la desembocadura';
        end
        un_type='L'; 
    case {'etaw','waterlevel','wathte'}
        switch lan
            case 'en'
                str_var='Water level';
            case 'nl'
                str_var='Waterstand';
            case 'es'
                str_var='Nivel del agua';
        end
        un_type='Lref'; 
     case 'tide'
        switch lan
            case 'en'
                str_var='Tide';
            case 'nl'
                str_var='Getij';
            case 'es'
                str_var='Marea';
        end
        un_type='L'; 
    case 'surge'
        switch lan
            case 'en'
                str_var='Surge';
            case 'nl'
                str_var='Opzet';
            case 'es'
                str_var='marejada ciclónica';
        end
        un_type='L';
    case 'plotted period'
        switch lan
            case 'en'
                str_var='plotted period';
            case 'nl'
                str_var='weegegeven periode';
            case 'es'
                str_var='período trazado';
        end
        un_type='-';
    case 'entire period'
        switch lan
            case 'en'
                str_var='entire period';
            case 'nl'
                str_var='gehele periode';
            case 'es'
                str_var='todo el período';
        end
        un_type='-';
    case 'h'
        switch lan
            case 'en'
                str_var='depth';
            case 'nl'
                str_var='diepte';
            case 'es'
                str_var='profundidad';
        end
        un_type='L';
    case {'sal'}
        switch lan
            case 'en'
                str_var='salinity';
            case 'nl'
                str_var='saliniteit';
            case 'es'
                str_var='salinidad';
        end
        un_type='-';
    case {'cl','conctte'}
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloruro';
        end
        un_type='-';
    case {'cl_surf'}
        switch lan
            case 'en'
                str_var='surface chloride';
            case 'nl'
                str_var='chloride aan wateroppervlak';
            case 'es'
                str_var='cloruro en la superficie';
        end
        un_type='-';
    case {'salm2'}
        switch lan
            case 'en'
                str_var='salt';
            case 'nl'
                str_var='zout';
            case 'es'
                str_var='sal';
        end
        un_type='M/L2';
    case {'clm2'}
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloro';
        end
        un_type='M/L2';
    case 'umag'
        switch lan
            case 'en'
                str_var='velocity magnitude';
            case 'nl'
                str_var='snelheidsgrootte';
            case 'es'
                str_var='magnitud de la velocidad';
        end
        un_type='L/T';
    case 'x'
        switch lan
            case 'en'
                str_var='x-coordinate';
            case 'nl'
                str_var='x-coordinaat';
            case 'es'
                str_var='coordenada x';
        end
        un_type='L';
    case 'y'
        switch lan
            case 'en'
                str_var='y-coordinate';
            case 'nl'
                str_var='y-coordinaat';
            case 'es'
                str_var='coordenada y';
        end
        un_type='L';
    case 'simulation'
        switch lan
            case 'en'
                str_var='Simulation';
            case 'nl'
                str_var='Berekening';
            case 'es'
                str_var='Simulación';
        end
        un_type='-';
    case 'measurement'
         switch lan
            case 'en'
                str_var='Measurement';
            case 'nl'
                str_var='Meting';
            case 'es'
                str_var='Medición';
         end
         un_type='-';
    case 'original'
         switch lan
            case 'en'
                str_var='original';
            case 'nl'
                str_var='origineel';
            case 'es'
                str_var='original';
         end
         un_type='-';
    case 'modified'
         switch lan
            case 'en'
                str_var='modified';
            case 'nl'
                str_var='gewijzigd';
            case 'es'
                str_var='modificado';
         end
         un_type='-';
     case 'difference'
         switch lan
            case 'en'
                str_var='Difference';
            case 'nl'
                str_var='Verschil';
            case 'es'
                str_var='Diferencia';
         end
         un_type='-';
     case 'q'
         switch lan
            case 'en'
                str_var='discharge';
            case 'nl'
                str_var='afvoer';
            case 'es'
                str_var='caudal';
         end
         un_type='L3/T';
     case 'qcum'
         switch lan
            case 'en'
                str_var='cumulative discharge';
            case 'nl'
                str_var='cumulatieve afvoer';
            case 'es'
                str_var='caudal acumulado';
         end
         un_type='L3/T';
     case 'qsp'
         switch lan
            case 'en'
                str_var='specific discharge';
            case 'nl'
                str_var='specifieke afvoer';
            case 'es'
                str_var='caudal específico';
         end
         un_type='L2/T';
%%
     case 't'
         switch lan
            case 'en'
                str_var='time';
            case 'nl'
                str_var='tijd';
            case 'es'
                str_var='tiempo';
         end
         un_type='T';
    case 'tshift'
         switch lan
            case 'en'
                str_var='time shift';
            case 'nl'
                str_var='tijdsverschuiving';
            case 'es'
                str_var='diferencia de tiempo';
         end
         un_type='-';
%%
    case 'corr'
         switch lan
            case 'en'
                str_var='correlation coefficient';
            case 'nl'
                str_var='correlatiecoëfficiënt';
            case 'es'
                str_var='coeficiente de correlación';
         end
         un_type='-';
    case 'dd'
         switch lan
            case 'en'
                str_var='wind direction';
            case 'nl'
                str_var='windrichting';
            case 'es'
                str_var='dirección del viento';
         end
         un_type='degrees';
    case 'fh'
         switch lan
            case 'en'
                str_var='wind speed';
            case 'nl'
                str_var='windsnelheid';
            case 'es'
                str_var='velocidad del viento';
         end
         un_type='L/T';
    case 'mea'
         switch lan
            case 'en'
                str_var='measured';
            case 'nl'
                str_var='gemeten';
            case 'es'
                str_var='medido';
         end
         un_type='-';
    case 'sim'
         switch lan
            case 'en'
                str_var='computed';
            case 'nl'
                str_var='berekend';
            case 'es'
                str_var='computado';
         end
         un_type='-';
    case 'dg'
         switch lan
            case 'en'
                str_var='geometric mean grain size';
            case 'nl'
                str_var='geometrische gemiddelde korrelgrootte';
            case 'es'
                str_var='media geométrica del tamaño de grano';
         end
         un_type='L';
    case 'dm'
         switch lan
            case 'en'
                str_var='arithmetic mean grain size';
            case 'nl'
                str_var='rekenkundig gemiddelde korrelgrootte';
            case 'es'
                str_var='media aritmética del tamaño de grano';
         end
         un_type='L';
    case 'vicouv'
         switch lan
            case 'en'
                str_var='horizontal eddy viscosity';
            case 'nl'
                str_var='horizontale wervelviscositeit:';
            case 'es'
                str_var='viscosidad de turbulencia horizontal';
         end
         un_type='L2/T';
    case 'at'
         switch lan
            case 'en'
                str_var='at';
            case 'nl'
                str_var='te';
            case 'es'
                str_var='en';
         end
         un_type='-';
    otherwise
         error('this is missing')
end %var

%% UNIT

switch un_type
    case 'Lref'
        switch un
            case 1
                str_un=sprintf(' [m%s]',Lref);
            case 1/1000
                str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case 'L'
        switch un
            case 1
                str_un=' [m]';
            case 1/1000
                str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case 'L3/T'
        switch un
            case 1
                str_un=' [m^3/s]';
%             case 1/1000
%                 str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case '-'
        switch lower(var)
            case 'sal'
                str_un=' [psu]';
            case {'cl','conctte','cl_surf'}
                str_un= ' [mg/l]'; 
            otherwise
                str_un = '';
        end
    case 'L/T'
        switch un
            case 1
                str_un=' [m/s]';
            otherwise
                error('this factor is missing')
        end
    case 'T'
        switch un
            case 1
                str_un=' [s]';
            case 1/60
                str_un=' [min]';
            case 1/3600
                str_un=' [h]';
            case 1/3600/24
                switch lan
                    case 'en'
                        str_un=' [day]';
                    case 'nl'
                        str_un=' [dag]';
                end
            case 1/3600/24/365
                switch lan
                    case 'en'
                        str_un=' [year]';
                    case 'nl'
                        str_un=' [jaar]';
                end
            otherwise
                error('this factor is missing')
        end
    case 'L2/T'
        switch un
            case 1
                str_un=' [m^2/s]';
            otherwise
                error('this factor is missing')
        end
    case 'degrees'
        switch un
            case 1
                str_un=' [o]';
            otherwise
                error('this factor is missing')
        end
    case 'M/L2'
        switch un
            case 1
                str_un=' [kg/m^2]';
            otherwise
                error('this factor is missing')
        end
end %un_type
        
%% LABEL 

lab=strcat(str_var,str_un);

%difference
switch lan
    case 'en'
        str_d='difference in';
    case 'nl'
        str_d='verschil in';
    case 'es'
        str_d='diferencia de';
end
str_diff=sprintf('%s %s',str_d,lab);

%background
 switch lan
    case 'en'
        str_b='above background';
    case 'nl'
        str_b='boven achtergrond';
    case 'es'
        str_b='sobre ambiente';
 end
str_background=sprintf('%s %s%s',str_var,str_b,str_un);

end %function