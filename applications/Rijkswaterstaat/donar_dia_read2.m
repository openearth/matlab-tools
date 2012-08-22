function [result] = donar_dia2nc(sourcename,targetpath,cellstr_fields)
%DONAR_DIA_READ  read donar *.dia file into struct (BETA)
%   STRUCT - DONAR_DIA_READ(FNAME,NUMCOL,CELLSTR_FIELDS) reads and harvest
%   the information from a donar *.dia file. FNAME is a string with the
%   absolute path to the file. NUMCOL is an integer with the number of
%   columns in the file. CELLSTR_FIELDS is a string cell array with the
%   names of the fields as found in the file from left to right.
%
%   (!) There are two key words that should be used in the
%   cellstr_fields: 
%       'datestring': The fnuction will use this field to generate a matlab
%                   datenum.
%       'timestring': The function will use this field to generate a matlab
%                   datenum.
%
%   ABSENCE OF THIS TWO KEYWORDS WILL RESULT IN NO MATLAB DATENUM
%   GENERATION
%
%   D = donar_dia_read('f:\R\DenHelderJaar2008Debietdia.dia',{'LocationE','LocationN','id','dateString','timeString','variable'});
%  
% with the fields ;datenum' + 'value' and the following (unprocessed) meta-info fields.
%
% Written by Ivan Garcia: garcia_in@deltares.nl, based on the script
% written by Bas Hoonhout

    warning('beta')
    
    numcol = length(cellstr_fields);
    fid   = fopen(sourcename);
    theformat = '%s';

    % Create an appropriate reading format. textscan(...,'%f%f%f%s',...) if
    % three columns, for instance (last one sotres '/0').
    for i=numcol:-1:1,
        if strcmpi(cellstr_fields{i},'datestring') || strcmpi(cellstr_fields{i},'timestring')
            theformat = ['%f',theformat];
        else
            theformat = ['%f',theformat];
        end
    end
    
    % The dia file that I am dealing with 
    iStuk = 1;
    iHdr = 1;
    
    while 1
        temp        = textscan(fid,theformat,'delimiter',';:'); % ';' inside tuples and '/0:' between tuples
        
        if isempty(temp{1})

            temp = read_hdr(fid);
            if ~isstruct(temp), 
                numhdr = iHdr-1;
                numstuk = iStuk-1;
                clear iHdr iStuck;
                break;
            else
                result(iHdr) = temp;
                iHdr = iHdr + 1;
            end
            
        else
            
            stuk(iStuk).values = cell2mat(temp(1:end-1));
            iStuk = iStuk + 1;
        end   
    end
    
    if numstuk ~=  numhdr, warning('The number of headers and data batches are disimilar.');  end
    
    [~,theIndTime] = find(ismember(cellstr_fields,{'datestring','timestring'}));
    [~,theInd] = find(~ismember(cellstr_fields,{'datestring','timestring'}));
    
    for istuk = 1:numstuk
            
        if length(theIndTime)==2
            stuk(istuk).values(:,end+1) = time2datenum(stuk(istuk).values(:,theIndTime(1)),stuk(istuk).values(:,theIndTime(2)));
        elseif length(theIndTime)==1
            stuk(istuk).values(:,end+1) = time2datenum(stuk(istuk).values{theIndTime(1)});
        else
            warning('No matlab datenum variable generated')
        end
        
        stuk(istuk).values = sortrows(stuk(istuk).values,size(stuk(istuk).values,2));
        for icol=theInd, result(istuk).(cellstr_fields{icol}) = stuk(istuk).values(:,icol); end
        result(istuk).datenum = stuk(istuk).values(:,end);
        
        result(istuk).sourcename = sourcename;
        result(istuk).targetpath = targetpath;
        D = dia2stdStruct(result(istuk));
        struct2nc(D);
    end
    
    
    
    fclose(fid);
end

function [result] = read_hdr(file_id)
    
    rec   = fgetl(file_id);
    if rec == -1, result = -1; return; end
        
    result.CMT = {};
    
    
    while ~strcmpi(rec(1:5),'[wrd]')

       numcol = length(strfind(rec,';'));
       theformat = '%s';

       for i=1:numcol, 
           theformat = ['%s',theformat];
       end
       
       if strcmp(rec(1),'[')
       else
       
          theinfo = textscan(rec,theformat,'delimiter',';');
          thefield = code2name(theinfo{1},'dia','fields');
          if ~isnan(thefield),             result.(key) = val;          end
       end

       rec   = fgetl(file_id);

    end
    
    %error
end

function [D] = dia2stdStruct(thestruct)

    D.ncpath = thestruct.targetpath;
    
    D.source.institution = 'Rijkswaterstaat';
    D.source.url = 'http://live.waterbase.nl/metis/cgi-bin/mivd.pl?action';
    D.source.email = 'helpdeskwater@rws.nl';
    D.source.filename = thestruct.sourcename;
    D.source.version = '';
    
    a = textscan((thestruct.GBD),'%s%s','delimiter',';');
    D.source.station_code = a{1}{1};
    D.source.station_name = a{2}{1};
    
    a = textscan((thestruct.PAR),'%s%s%s','delimiter',';');
    D.source.variable_code = a{2}{1};
    D.source.variable_name = code2name(a{2}{1},'standar','name');
    
    a = textscan((thestruct.VAT),'%s%s','delimiter',';');
    D.source.device_code = a{1}{1};
    D.source.device_name = a{2}{1};

    D.source.comment = '';

    D.tranf2nc.institution = 'Deltares';
    D.tranf2nc.author  = 'Ivan Garcia';
    D.tranf2nc.script  = 'donar_dia_read2.m';
    D.tranf2nc.version = '';
    D.tranf2nc.comment = 'Beta version, ongoing developments on the script';

    D.general.title = '';
    D.general.terms_for_use = 'These data can be used freely for research purposes provided that the source is acknowledged';
    D.general.disclaimer  = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';

    a = textscan((thestruct.GBD),'%s%s','delimiter',';');
    D.data.station_id  = a{1}{1};
    D.data.station_name = a{2}{1};
    
    D.data.name = '';
    D.data.units = thestruct.EHD;
    D.data.datenum = thestruct.datenum;
    D.data.timezone = 'UTC';
    
    a = textscan((thestruct.LOC),'%s%s%s%s%s%s','delimiter',';');
    %D.data.coorsystem_name = a{4}{1};
    %D.data.coorsystem_code = a{1}{1};
    D.data.coorsystem_name = 'wgs84';
    D.data.coorsystem_code = 4326;
        
    D.data.lat = thestruct.LocationN;
    D.data.lon = thestruct.LocationE;
    D.data.value = thestruct.variable;
    D.data.value_std = [];
    D.data.z = 0;
    
    D.ncfile = [D.data.station_name,'_',D.source.variable_name,'_',datestr(min(thestruct.datenum),'yyyymmddTHHMMSS'),'-',datestr(max(thestruct.datenum),'yyyymmddTHHMMSS'),'.nc'];
    D.ncfile = strrep(D.ncfile,'  ','_');
    D.ncfile = strrep(D.ncfile,'(','');
    D.ncfile = strrep(D.ncfile,')','');
end