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
%       -'eta'      : bed elevation
%       -'deta'     : bed elevation change
%
%       -'dist'     : distance
%       -'dist_prof': distance along section
%       -'dist_mouth': distance from mouth
%
%       -'etaw'     : water level
%       -'h'        : flow depth
%
%       -'sal'      : salinity
%       -'cl'       : chloride
%
%       -'umag'     : velocity magnitude
%
%       -'x'        : x-coordinate
%       -'y'        : y-coordinate
%
%       -'Q'        : water discharge
%
%       -'t'        : time
%
%   -un: factor for unit conversion from SI
%
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': spanish

function [lab,str_var,str_un]=labels4all(var,un,lan)

switch lower(var)
    case {'eta','etab'}
        switch lan
            case 'en'
                str_var='elevation';
            case 'nl'
                str_var='hoogte';
            case 'es'
                str_var='elevación';
        end
        un_type='L';
    case {'detab'}
        switch lan
            case 'en'
                str_var='bed elevation change';
            case 'nl'
                str_var='bodemverandering';
            case 'es'
                str_var='';
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
    case {'etaw' 'waterlevel'}
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
    case 'sal'
        switch lan
            case 'en'
                str_var='salinity';
            case 'nl'
                str_var='saliniteit';
            case 'es'
                str_var='salinidad';
        end
        un_type='-';
    case 'cl'
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloruro';
        end
        un_type='-';
    case 'umag'
        switch lan
            case 'en'
                str_var='velocity magnitude';
            case 'nl'
                error('add')
                str_var='chloride';
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
    otherwise
         error('this is missing')
end %var

%% UNIT

switch un_type
    case 'Lref'
        switch un
            case 1
                str_un=' [m+NAP]';
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
        switch var
            case 'sal'
                str_un=' [psu]';
            case 'cl'
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
end %un_type
        
lab=strcat(str_var,str_un);

end %function