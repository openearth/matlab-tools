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
%
%   -un: factor for unit conversion from SI
%
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': spanish

function lab=labels4all(var,un,lan)

switch var
    case 'eta'
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
        un_type=1; %[L]
     case 'surge'
        switch lan
            case 'en'
                str_var='Surge';
            case 'nl'
                str_var='Opzet';
            case 'es'
                str_var='marejada ciclónica';
        end
        un_type=1; %[L]
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
    otherwise
        error('this is missing')
end %var

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
            otherwise
                error('this is missing')
        end
end %un_type
        
lab=strcat(str_var,str_un);

end %function