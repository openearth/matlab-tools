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
%   -varname: variable to generate label
%
%   -un: factor for unit conversion from SI
%
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': spanish

function [lab,str_var,str_un,str_diff,str_background,str_std,str_diff_back,str_fil,str_rel,str_perc,str_dom]=labels4all(varname,un,lan,varargin)

%%

parin=inputParser;

addOptional(parin,'Lref','+NAP');
addOptional(parin,'frac',1);

parse(parin,varargin{:});

Lref=parin.Results.Lref;
frac=parin.Results.frac;

%% using files

var2key=readtable('labels4all_variable_to_key.csv','TextType','string');
translations=readtable('labels4all_translation_keys.csv','TextType','string');
[str_var,un_type,found]=get_translation(varname,lan,var2key,translations);
str_var=add_fraction(str_var,frac);

%% using switch case (old)

if ~found
    [str_var, un_type]=switch_label4all(varname,lan,frac);
end

%% UNIT

str_un=str_unit(un_type,un,lan,Lref,varname);
        
%% LABEL 

lab=strcat(str_var,str_un);

%string unit no ref
switch un_type
    case 'Lref'
        str_un_nr=str_unit('L',un,lan,Lref,varname);
    otherwise
        str_un_nr=str_un;
end
 
%difference
switch lan
    case 'en'
        str_d='difference in';
    case 'nl'
        str_d='verschil in';
    case 'es'
        str_d='diferencia de';
end
str_diff=sprintf('%s %s%s',str_d,str_var,str_un_nr);

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

%standard deviation
 switch lan
    case 'en'
        str_s='standard deviation';
    case 'nl'
        str_s='standaardafwijking';
    case 'es'
        str_s='desviación estándar';
 end
str_std=sprintf('%s %s%s',str_s,str_var,str_un_nr);

 %difference above background
str_diff_back=sprintf('%s %s %s%s',str_d,str_var,str_b,str_un_nr);

 %filtered
 switch lan
    case 'en'
        str_f='filtered';
    case 'nl'
        str_f='gefilterd';
    case 'es'
        str_f='filtrado de';
 end
str_fil=sprintf('%s %s %s',str_f,str_var,str_un_nr);

%relative
 switch lan
    case 'en'
        str_f='relative';
    case 'nl'
        str_f='relatieve';
    case 'es'
        str_f='relativo';
 end
str_rel=sprintf('%s %s %s',str_f,str_var,'[-]');

%percentage
switch lan
    case 'en'
        str_d='difference in';
    case 'nl'
        str_d='verschil in';
    case 'es'
        str_d='diferencia de';
end
str_perc=sprintf('%s %s %s',str_d,str_var,'[%]');

%dominant
switch lan
case 'en'
    str_f='dominant';
case 'nl'
    str_f='dominant';
case 'es'
    str_f='dominante';
end
str_dom=sprintf('%s %s %s',str_f,str_var,str_un_nr);

end %function

%%
%% FUNCTIONS
%% 

%%

function str_un=str_unit(un_type,un,lan,Lref,val)

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
    case 'L3'
        switch un
            case 1
                str_un=' [m^3]';
%             case 1/1000
%                 str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case '-'
        switch lower(val)
            case 'sal'
                str_un=' [psu]';
            case {'cl','conctte','cl_surf','cl_bottom'}
                str_un= ' [mg/l]'; 
%             case {'detab_ds'}
%                 str_un=' [-]'; 
            otherwise
                str_un=' [-]';
        end
    case 'L/T'
        switch un
            case 1
                str_un=' [m/s]';
            otherwise
                error('this factor is missing')
        end
    case {'T','1/T'}
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
        if strcmp(un_type,'1/T')
            str_un=strrep(str_un,']','^-1]');
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
                str_un=' [º N]';
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
    case 'M'
        switch un
            case 1
                str_un=' [kg]';
            otherwise
                error('this factor is missing')
        end
    case 'M/T'
        switch un
            case 1
                str_un=' [kg/s]';
            otherwise
                error('this factor is missing')
        end
    case 'M/T2/L'
        switch un
            case 1
                str_un=' [Pa]';
            otherwise
                error('this factor is missing')
        end
    case 'L1/2/T'
        switch un
            case 1
                str_un=' [m^{1/2}/s]';
            otherwise
                error('this factor is missing')
        end
    case 'L2'
        switch un
            case 1
                str_un=' [m^2]';
            otherwise
                error('this factor is missing')
        end
    case 'M/T/L'
        switch un
            case 1
                str_un=' [Pa s]';
            otherwise
                error('this factor is missing')
        end
    case 'degC'
        switch un
            case 1
                str_un=' [deg C]';
            otherwise
                error('this factor is missing')
        end
    case '?'
        str_un=' [?]';
    otherwise
        error('This unit is missing')
end %un_type

end %function

%%

function [str_var, un_type, found] = get_translation(varname, lan, var2key, translations)

varname=lower(varname);

%find which unique key is associated to the variable name
rowKey=find(var2key.variable==varname,1);

if isempty(rowKey)
    %we assume the variable name is the unique key
    key=varname;
else
    %get unique key
    key=var2key.key(rowKey);
end

%find the string associated to the unique key
rowTrans=find(translations.key==key,1);

if isempty(rowTrans)
    %there is no unique key associated to the varname. Output as it.
    str_var=varname;
    un_type="?";
    found=false;
else
    %get the string for the unique key
    str_var=translations{rowTrans, lan};
    un_type=translations.un_type(rowTrans);
    found=true;
end

end %function

%% 

function str_var=add_fraction(str_var,frac)

str_var=sprintf(str_var,frac);

end
