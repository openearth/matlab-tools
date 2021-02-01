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
%This function reads csv files containing Rijkswaterstaat data and gives as output a structure
%with the data. If adding a new file type, this needs to be arranged in function get_file_data.
%
%INPUT:
%   -fpath: path to the file to read [char]
%
%OUTPUT:
%   -

function rws_data=read_csv_data(fpath,varargin)

%% PARSE

parin=inputParser;

flg_debug=0;

addOptional(parin,'flg_debug',flg_debug);

parse(parin,varargin{:});

flg_debug=parin.Results.flg_debug;

%% READ DATA

file_type=get_file_type(fpath);

[fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid]=get_file_data(file_type);

switch file_type
    case {1,2,3,4,6}
        %locations in rows
        vardata=read_data_1(file_type,fpath,'flg_debug',flg_debug);
    case 5
        %locations in columns
        vardata=read_data_2(file_type,fpath,'flg_debug',flg_debug);
        
        idx_waarheid=2; %we have used this index to indicate each of the locations. 
    otherwise
        error('Specify file type')
end

%% SAVE

nloc=size(vardata,1);

rws_data=struct('location',[],'x',[],'y',[],'raai',[],'grootheid',[],'parameter',[],'eenheid',[],'time',[],'waarde',[],'source',[]);

for kloc=1:nloc

    %% convert

    %convert time format 
    if isnan(idx_time)
        time_aux=datetime(vardata{kloc,1}(:,idx_tijd),'inputFormat',fmt_tijd)-datetime(vardata{kloc,1}(1,idx_tijd),'inputFormat',fmt_tijd);
        time_mea=datetime(vardata{kloc,1}(:,idx_datum),'inputFormat',fmt_datum)+time_aux;
    else
        time_mea=datetime(vardata{kloc,1}(:,idx_time),'InputFormat',fmt_time);
    end

    time_mea.TimeZone=tzone;

    %convert variable
    mea=cellfun(@(x)undutchify(x),vardata{kloc,1}(:,idx_waarheid),'UniformOutput',false);   
    mea=cell2mat(mea);

    %put in cronological order
    [time_mea,idx_sort]=sort(time_mea);
    mea=mea(idx_sort,:);

    %% variables to save

        %location
    if isnan(idx_location)
        error('No location')
    else
        location=vardata{kloc,2}{idx_location};
    end
        %x
    if isnan(idx_x)
        x=NaN;
    else
        x=undutchify(vardata{kloc,2}{idx_x});
    end
        %y
    if isnan(idx_y)
        y=NaN;
    else
        y=undutchify(vardata{kloc,2}{idx_y});
    end
        %raai
    if isnan(idx_raai)
        raai=NaN;
    else
        raai=undutchify(vardata{kloc,2}{idx_raai});
    end
        %unit
    if isnan(eenheid)
        if isnan(idx_eenheid)
            error('A unit must be given');
        else
            eenheid=vardata{kloc,2}{idx_eenheid};
        end
    end
        %quantity
    if isnan(grootheid)
        if isnan(idx_grootheid)
            if strcmp(eenheid,'m3/s')
                grootheid='Q';
            else
                error('A parameter must be given')
            end
        else
            grootheid=vardata{kloc,2}{idx_grootheid};
        end
    end
        %parameter
    if isnan(idx_parameter)
        if strcmp(grootheid,'CONCTTE')
            param='Cl'; %ASSUMPTION: if nothing is said, it is salt. 
        else
            param='';
        end
    else
        param=vardata{kloc,2}{idx_parameter};
    end
        %epsg
    if isnan(epsg)
        if isnan(idx_epsg)
    %         epsg=NaN;
        else
            epsg=str2double(vardata{kloc,2}{idx_epsg});
        end
    end
        %reference
    if isempty(hoedanigheid)
        if isnan(idx_hoedanigheid)
            hoedanigheid='';
        else
            hoedanigheid=vardata{kloc,2}{idx_hoedanigheid};
    %         hoedanigheid=hoedanigheid(~isspace(ref));
        end
    else

    end


    %% convert output

    %convert all coordinates to RD New
    epsg_rd=28992;
    if ~isnan(epsg)
        if abs(epsg-epsg_rd)>0.5 
            [x,y]=convertCoordinates(x,y,'CS1.code',epsg,'CS2.code',epsg_rd);
        end
    end

    %units
    switch eenheid
        case 'm'

        case 'cm'
            mea=mea./100;
            eenheid='m';
    end

    %quantity
    switch grootheid
        case {'CONCTTE'}
            switch eenheid
                case {'ppm'}
                    eenheid='mg/l';
            end
        case {'WATHTE','Q'}

    end

    %reference
    switch grootheid
        case {'CONCTTE','Q'}
            if strcmp(hoedanigheid,'NVT')
                hoedanigheid='';
            end
        case {'WATHTE'}
            if strcmp(hoedanigheid,'NVT')
                hoedanigheid='NAP'; %ASSUMPTION
            end        
    end
    if contains(eenheid,hoedanigheid)
        hoedanigheid='';
    end
    eenheid=strcat(eenheid,hoedanigheid);

    %filter
    %It may be possible to do this for at least waterinfo data (type 6) by making use of flag 'KWALITEITSOORDEEL_CODE' (Normale waarde vs. nothing)
    switch grootheid        
        case {'Q','WATHTE'}
            limsf=[-1e6,1e6];
        otherwise
            limsf=[-inf,inf];
    end
    mea(mea<limsf(1)|mea>limsf(2))=NaN;

    %% create structure

    rws_data(kloc).raai=raai;
    rws_data(kloc).x=x;
    rws_data(kloc).y=y;
    rws_data(kloc).epsg=epsg;
    rws_data(kloc).location=location;
    rws_data(kloc).eenheid=eenheid;
    rws_data(kloc).parameter=param;
    rws_data(kloc).grootheid=grootheid;
    rws_data(kloc).source=fpath;
    rws_data(kloc).time=time_mea;
    rws_data(kloc).waarde=mea;

end %kloc

end %read_csv_data

%%
%% FUNCTIONS
%%

function vardata=read_data_2(file_type,fpath,varargin)

%% parse

parin=inputParser;

flg_debug=0;

addOptional(parin,'flg_debug',flg_debug);

parse(parin,varargin{:});

flg_debug=parin.Results.flg_debug;

%% header
fid=fopen(fpath,'r');
fline=fgetl(fid); %first line

%% file type data

[fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid]=get_file_data(file_type);
tok_header=regexp(fline,fdelim,'split');
idx_var_once=find_str_in_cell(tok_header,var_once);
idx_var_time=find_str_in_cell(tok_header,var_time);    
% idx_var_loc =find_str_in_cell(tok_header,var_loc );

nv=2;
nloc=numel(idx_waarheid);

%% read

%preallocate
npreall=10000;
vardata=cell(nloc,2); 
    %{kloc,1}=info changing with time; 
    %{kloc,2}=info constant per location; 
for kloc=1:nloc
    vardata{kloc,1}=cell(npreall,nv);
end
keep_going=true;

%first line outside loop to get location
kl=1; %line counter
ks=kl; %time counter

while ~feof(fid) && keep_going
    %get info
    fline=fgetl(fid); 
    tok=regexp(fline,fdelim,'split');
    
    %save
    for kloc=1:nloc
        vardata{kloc,1}(ks,:)=tok([idx_var_time(1),idx_var_time(idx_waarheid(kloc))]); %first index is time
    end
    
    %update
    kl=kl+1;
    ks=kl;
    
    %check if needed to preallocate more
    if ks==size(vardata{kloc,1},1)
        for kloc=1:nloc
            vardata{kloc,1}=cat(1,vardata{kloc,1},cell(npreall,nv));
        end
    end

    %debug
    if flg_debug && kl==10
        keep_going=false;
    end
    
    %display
%     fprintf('line %d \n',kl)
end
fclose(fid);

for kloc=1:nloc
    vardata{kloc,1}=vardata{kloc,1}(1:ks-1,:);
    vardata{kloc,2}=tok_header(idx_var_once(idx_location(kloc)));
end

vardata=cellfun(@(X)strrep(X,'"',''),vardata,'UniformOutput',false);

end %function

%%

function vardata=read_data_1(file_type,fpath,varargin)

%% parse

parin=inputParser;

flg_debug=0;

addOptional(parin,'flg_debug',flg_debug);

parse(parin,varargin{:});

flg_debug=parin.Results.flg_debug;

%% header
fid=fopen(fpath,'r');
fline=fgetl(fid); %first line

%% file type data

[fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg]=get_file_data(file_type);
tok_header=regexp(fline,fdelim,'split');
idx_var_once=find_str_in_cell(tok_header,var_once);
idx_var_time=find_str_in_cell(tok_header,var_time);    
idx_var_loc =find_str_in_cell(tok_header,var_loc );

nv=numel(idx_var_time);

%% read

%preallocate
npreall=10000;
nlocpreall=10;
vardata=cell(nlocpreall,2); 
    %{kloc,1}=info changing with time; 
    %{kloc,2}=info constant per location; 
vardata{1,1}=cell(npreall,nv);
keep_going=true;

%first line outside loop to get location
kl=1; %line counter
kloc=1; %location counter
ks=1; %time counter

    %get info
    fline=fgetl(fid); 
    tok=regexp(fline,fdelim,'split');
    
    %check location change
    locname_tm1=tok(idx_var_loc); %t-1
    
    %save time
    vardata{kloc,1}(ks,:)=tok(idx_var_time);
    
    %save constant
    vardata{kloc,2}=tok(idx_var_once);
    
    %update
    kl=kl+1;

while ~feof(fid) && keep_going
    %get info
    fline=fgetl(fid); 
    tok=regexp(fline,fdelim,'split');
    
    %check location change
    locname_t=tok(idx_var_loc);
    if ~strcmp(locname_t,locname_tm1)
        %schrink finished location
        vardata{kloc,1}=vardata{kloc,1}(1:ks-1,:); 
        
        %update
        locname_tm1=locname_t;
        kloc=kloc+1;
        ks=1;
        
        %new constants
        vardata{kloc,2}=tok(idx_var_once);
    else
        ks=ks+1;
    end
    
    %save
    vardata{kloc,1}(ks,:)=tok(idx_var_time);
    
    %update
    kl=kl+1;
    
    %check if needed to preallocate more
    if kloc==size(vardata,1)
        vardata=cat(1,vardata,cell(nlocpreall,2));
    end
    if ks==size(vardata{kloc,1},1)
        vardata{kloc,1}=cat(1,vardata{kloc,1},cell(npreall,nv));
    end

    %debug
    if flg_debug && kl==10
        keep_going=false;
    end
    
    %display
%     fprintf('line %d \n',kl)
end
fclose(fid);
vardata{kloc,1}=vardata{kloc,1}(1:ks-1,:);
vardata=vardata(1:kloc,:);

vardata=cellfun(@(X)strrep(X,'"',''),vardata,'UniformOutput',false);

end %function

%%

function [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_parameter,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg,idx_hoedanigheid,hoedanigheid]=get_file_data(file_type)

idx_grootheid=NaN;
grootheid=NaN;
idx_eenheid=NaN;
eenheid=NaN;
idx_epsg=NaN;
idx_raai=NaN;
idx_x=NaN;
idx_y=NaN;
idx_parameter=NaN;
idx_time=NaN; %date+time
fmt_time='';
idx_datum=NaN; %date
fmt_datum='';
idx_tijd=NaN; %time
fmt_tijd='';
epsg=NaN;
idx_hoedanigheid=NaN;
hoedanigheid='';

switch file_type
    case 1
        %"Meetpunt.identificatie" ;"geometriepunt.x_rd";"geometriepunt.y_rd";"Grootheid.code";"Typering.code";"Parameter.groep";"Parameter.code";"Parameter.omschrijving";"Eenheid.code";"Hoedanigheid.code";"Compartiment.code";"Begindatum";"Begintijd";"Numeriekewaarde";"NumeriekeWaarde.nl";"Kwaliteitsoordeel.code";"kwaliteitsoordeel.omschrijving"
        %"433-036-00021_kwaliteit";107520              ;445821              ;"CONCTTE"       ;""             ;"ChemischeStof"  ;"Cl"            ;"Chloride"              ;"mg/l"        ;"NVT"              ;"OW"               ;2018-01-01  ;00:00:00   ;183              ;183                 ;0                       ;""
        %"MPN-527"                ;105872.22           ;444168.82           ;"WATHTE"        ;""             ;"Grootheid"      ;""              ;"Waterhoogte"           ;"mNAP"        ;"NAP"              ;"OW"               ;2018-01-01  ;00:00:00   ;0.193            ;0,193               ;0                       ;""
        %variables to save once
%         var_once={'"Meetpunt.identificatie"','"geometriepunt.x_rd"','"geometriepunt.y_rd"','"Grootheid.code"','"Typering.code"','"Parameter.groep"','"Parameter.code"','"Parameter.omschrijving"','"Eenheid.code"','"Hoedanigheid.code"','"Compartiment.code"'};
        var_once={'"Meetpunt.identificatie"','"geometriepunt.x_rd"','"geometriepunt.y_rd"','"Parameter.code"','"Eenheid.code"','"Grootheid.code"','"Hoedanigheid.code"'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        epsg=28992; %assumption
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_hoedanigheid=7;
        
        %variables to save with time
        var_time={'"Begindatum"','"Begintijd"','"Numeriekewaarde"'};
        idx_datum=1;
        fmt_datum='yyyy-MM-dd';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'"Meetpunt.identificatie"'};
        
        fdelim=';';
        tzone='+0000'; %File <"Overzicht data Hollandsche IJssel_v18-01-2021.xlsx" > specifies that this set is in UTC.
    case 2
        % Datum              ,Serie                                                                                               ,Waarde   ,Eenheid,
        % "1-1-2018 00:00:00","GOUDA ADCP_3237-K_GOUDA ADCP-debietmeter - KW323711 - Q[m3/s][NVT][OW] - Debiet CAW [m3/s] - 15min","15.5958","m3/s"
        
        %variables to save once
        var_once={'Serie','Eenheid'};
        idx_location=1;
        idx_eenheid=2;
        
        %variables to save with time
        var_time={'Datum','Waarde'};
        idx_time=1;
        fmt_time='dd-MM-yyyy HH:mm:ss';
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
        var_loc={'Serie'};
        
        fdelim=',';
        tzone='Europe/Amsterdam'; %File <"Overzicht data Hollandsche IJssel_v18-01-2021.xlsx" > specifies that this set is in local time.
    case 3
%        "";"Date"    ;"Time"  ;"P"    ;"T"  ;"EGV";"G";"loc"                         ;"K_18_t"        ;"cl"            ;"D_T"              ;"raai";"zomertijd"
%       "1";2020-05-26;12:10:00;1607,31;18,08;0,636;636;" LEK_981_200713102930_V8523 ";634,897163168224;110,867149947533;2020-05-26 12:10:00;"981" ;2020-05-26 11:10:00

        %variables to save once
        var_once={'"loc"','"raai"'};
        idx_location=1;
        idx_raai=2;
        
        grootheid='CONCTTE'; %assing, as they are not in head
        eenheid='mg/l'; %assing, as they are not in head
        
        %variables to save with time
        var_time={'"zomertijd"','"cl"'};
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
        var_loc={'"loc"'};
        
        fdelim=';';
        tzone='+02:00'; %we get the summertime and add the UTC shift to be sure. 
        
    case 4
        % "";"Date";"Time";"P";"T";"EGV";"G";"loc";"K_18_t";"cl";"D_T";"wintertijd"
        % "1";2020-07-24;09:10:00;1568,883;21,58;0,668;668;"GROEN-18";618,991985292716;106,745759214351;2020-07-24 09:10:00;2020-07-24 08:10:00

        %variables to save once
        var_once={'"loc"'};
        idx_location=1;

        grootheid='CONCTTE'; %assing, as they are not in head
        eenheid='mg/l'; %assing, as they are not in head
            
        %variables to save with time
        var_time={'"wintertijd"','"cl"'};
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        idx_waarheid=2;
        
        %variable with location, to check for different places in same file.
        var_loc={'"loc"'};
        
        fdelim=';';
        tzone='+01:00'; %we get the wintertime and add the UTC shift to be sure. 
    case 5
    %     "";"D_T";"972";"977";"979";"982";"983.5";"985";"986";"989";"GROEN-18";"GROEN-26";"ROOD-12";"ROOD-6";"ROOD-9"
    %     "1";2020-09-04 09:00:00;NA;NA;NA;NA;NA;119,369608158169;NA;236,661232888235;200,15535414911;NA;199,37711013335;164,142701624404;173,556143951793
        %variables to save once
        var_once={'"972"','"977"','"979"','"982"','"983.5"','"985"','"986"','"989"','"GROEN-18"','"GROEN-26"','"ROOD-12"','"ROOD-6"','"ROOD-9"'}; 
        idx_location=1:1:numel(var_once);

        grootheid='CONCTTE'; %assing, as they are not in head
        eenheid='mg/l'; %assing, as they are not in head
        
        %variables to save with time
        var_time={'"D_T"','"972"','"977"','"979"','"982"','"983.5"','"985"','"986"','"989"','"GROEN-18"','"GROEN-26"','"ROOD-12"','"ROOD-6"','"ROOD-9"'};
        idx_time=1;
        fmt_time='yyyy-MM-dd HH:mm:ss';
        idx_waarheid=2:1:14;
        
        %variable with location, to check for different places in same file.
        var_loc={''};
        
        fdelim=';';
        tzone='+02:00'; %we assume it is local time
    case 6
        %MONSTER_IDENTIFICATIE;MEETPUNT_IDENTIFICATIE;TYPERING_OMSCHRIJVING;TYPERING_CODE;GROOTHEID_OMSCHRIJVING;GROOTHEID_ CODE;PARAMETER_OMSCHRIJVING;PARAMETER_ CODE;EENHEID_CODE;HOEDANIGHEID_OMSCHRIJVING     ;HOEDANIGHEID_CODE;COMPARTIMENT_OMSCHRIJVING;COMPARTIMENT_CODE;WAARDEBEWERKINGSMETHODE_OMSCHRIJVING;WAARDEBEWERKINGSMETHODE_CODE;WAARDEBEPALINGSMETHODE_OMSCHRIJVING                              ;WAARDEBEPALINGSMETHODE_CODE    ;BEMONSTERINGSSOORT_OMSCHRIJVING;BEMONSTERINGSSOORT_CODE;WAARNEMINGDATUM;WAARNEMINGTIJD;LIMIETSYMBOOL;NUMERIEKEWAARDE;ALFANUMERIEKEWAARDE;KWALITEITSOORDEEL_CODE;STATUSWAARDE   ;OPDRACHTGEVENDE_INSTANTIE;MEETAPPARAAT_OMSCHRIJVING;MEETAPPARAAT_CODE;BEMONSTERINGSAPPARAAT_OMSCHRIJVING;BEMONSTERINGSAPPARAAT_CODE;PLAATSBEPALINGSAPPARAAT_OMSCHRIJVING;PLAATSBEPALINGSAPPARAAT_CODE;BEMONSTERINGSHOOGTE;REFERENTIEVLAK;EPSG ;X               ;Y               ;ORGAAN_OMSCHRIJVING;ORGAAN_CODE;TAXON_NAME
%                             ;Lobith                ;                     ;             ;Debiet                ;Q              ;                      ;               ;m3/s        ;                              ;                 ;Oppervlaktewater         ;OW               ;                                    ;                            ;Debiet uit Q-f relatie                                           ;other:F216                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;3072,2         ;                   ;Normale waarde        ;Ongecontroleerd;ONXXREG_AFVOER           ;                         ;                 ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;713748,798641064;5748949,04523234;                   ;           ;           
%                             ;Krimpen a/d IJssel    ;                     ;             ;Waterhoogte           ;WATHTE         ;                      ;               ;cm          ;t.o.v. Normaal Amsterdams Peil;NAP              ;Oppervlaktewater         ;OW               ;                                    ;                            ;Rekenkundig gemiddelde waarde over vorige 5 en volgende 5 minuten;other:F007                     ;Rechtstreekse meting           ;01                     ;01-01-2020     ;00:00:00      ;             ;-4             ;                   ;Normale waarde        ;Ongecontroleerd;RIKZMON_WAT              ;Vlotter                  ;127              ;                                  ;                          ;                                    ;                            ;-999999999         ;NVT           ;25831;608561,131040599;5752923,14544908;;;
        %variables to save once
        var_once={'MEETPUNT_IDENTIFICATIE','X','Y','PARAMETER_ CODE','EENHEID_CODE','GROOTHEID_ CODE','EPSG','HOEDANIGHEID_CODE'};
        idx_location=1;
        idx_x=2;
        idx_y=3;
        idx_parameter=4;
        idx_eenheid=5;
        idx_grootheid=6;
        idx_epsg=7;
        idx_hoedanigheid=8;
        
        %variables to save with time
        var_time={'WAARNEMINGDATUM','WAARNEMINGTIJD','NUMERIEKEWAARDE'};
        idx_datum=1;
        fmt_datum='dd-MM-yyy';
        idx_tijd=2;
        fmt_tijd='HH:mm:ss';
        idx_waarheid=3;
        
        %variable with location, to check for different places in same file.
        var_loc={'MEETPUNT_IDENTIFICATIE'};
        
        fdelim=';';
        tzone='+01:00'; %waterinfo in CET
    otherwise
        error('You are asking for an inexisteng file type')

end %file_type

end %get_vars

%%

function file_type=get_file_type(fpath)

%% open and header

fid=fopen(fpath,'r');
fline=fgetl(fid); %first line
fclose(fid);

%% loop 
file_type=1;
keep_searching=true;
while keep_searching
    [fdelim,var_once,var_time,idx_waarheid,idx_location,idx_x,idx_y,idx_grootheid,idx_eenheid,idx_param,tzone,idx_raai,var_loc,grootheid,eenheid,idx_epsg,idx_datum,idx_tijd,idx_time,fmt_time,fmt_datum,fmt_tijd,epsg]=get_file_data(file_type);
    tok_header=regexp(fline,fdelim,'split');
    idx_var_once=find_str_in_cell(tok_header,var_once);
    idx_var_time=find_str_in_cell(tok_header,var_time);    
    idx_var_loc =find_str_in_cell(tok_header,var_loc );
    %it is possible to make it in one expression, but it gets unreadable
    if ~isempty(var_once{1,1}) 
        if any(isnan(idx_var_once))  || numel(var_once)~=numel(idx_var_once) || any(isnan(idx_var_time)) || numel(var_time)~=numel(idx_var_time)
            file_type=file_type+1;
        else
            keep_searching=false;
        end
    else
        if any(isnan(idx_var_time)) || numel(var_time)~=numel(idx_var_time)
            file_type=file_type+1;
        else
            keep_searching=false;
        end
    end
end %keep_searching

end %get_file_type

