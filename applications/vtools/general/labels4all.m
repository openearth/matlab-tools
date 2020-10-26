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
%       -'dist'     : distance
%       -'dist_prof': distance along section
%       -'etaw'     : water level
%       -'h'        : flow depth
%       -'sal'      : salinity
%       -'cl'       : chloride
%       -'umag'     : velocity magnitude
%       -'x'        : x-coordinate
%       -'y'        : y-coordinate
%
%   -un: factor for unit conversion from SI
%
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': spanish

function lab=labels4all(var,un,lan)

switch lower(var)
    case {'eta','etab'}
        switch lan
            case 'en'
                str_var='elevation';
            case 'nl'
                error('write')
            case 'es'
                str_var='elevación';
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
    case {'etaw' 'waterlevel'}
        switch lan
            case 'en'
                str_var='Water level';
            case 'nl'
                str_var='Waterstand';
            case 'es'
                str_var='Nivel del agua';
        end
        un_type='L'; 
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
    otherwise
         error('this is missing')
end %var

%% UNIT

switch un_type
    case 'L'
        switch un
            case 1
                str_un=' [m]';
            case 1/1000
                str_un=' [km]';
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
end %un_type
        
lab=strcat(str_var,str_un);

end %function