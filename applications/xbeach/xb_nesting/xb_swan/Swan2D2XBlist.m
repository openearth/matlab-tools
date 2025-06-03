function Swan2D2XBlist(fname,starttime,stoptime,step,dtbc)
% Function to convert 2D Swan spectra time series files to a format that is
% acceptable for XBeach boundary condtion input. This function does not
% interpolate the SWAN data in time. 
%
% Syntax:       Swan2D2XBlist(fname,starttime,stoptime,interval,dtbc)
%
% Input:   fname      - Name of SWAN 2D spectra time series file
%                       No default.
%          starttime  - Start reading SWAN spectra from this time onwards.
%                       If starttime does not correspond to a specific
%                       spectral output time, the first spectrum to be read
%                       will be the first spectrum beyond starttime in
%                       time. starttime should be specified in Matlab
%                       numerical time, i.e. 
%                       starttime=datenum('2000-02-25 15:00','yyyy-mm-dd HH:MM')
%                       Default = 0.
%          stoptime   - Stop reading SWAN spectra from this time onwards.
%                       If stoptime corresponds to a specific
%                       spectral output time, the spectrum at stoptime will
%                       be included in the XBeach boundary condition.
%                       stoptime should be specified in Matlab numerical
%                       time, i.e.
%                       starttime=datenum('2000-02-28 11:00','yyyy-mm-dd HH:MM').
%                       Default = 767375
%          step       - Step through spectra from starttime to stoptime
%                       with stepsize = step. Step = 1 means all SWAN
%                       spectra are converted to XBeach spectra. Step = 2
%                       means every second SWAN spectrum is converted. Step
%                       = 3 means every third spectrum is converted, etc.
%                       Default = 1
%          dtbc       - Required dtbc for XBeach (in seconds). 
%                       Default = 2.
%
% Output:  - swanlist.txt file containing the list of SWAN files required
%            for XBeach, including the values of rt and dtbc
%          - one swan *.sp2 file for each spectrum needed for XBeach

% Default values
if ~exist('starttime','var')
    starttime=0;
end
if ~exist('stoptime','var')
    stoptime=Inf; %datenum('31-12-2100','dd-mm-yyyy');
end
if ~exist('step','var')
    step=1;
end
if ~exist('dtbc','var')
    dtbc=2;
end

% Check file length
fid=fopen(fname,'r');
fseek(fid, 0, 'eof');
filesize = ftell(fid);
frewind(fid);

% Make empty containers
headerstr={};
varstr={};

% Collect header data
hd=1;
count=0;
nfreqreached=0;
while hd==1
    count=count+1;
    line=fgetl(fid);
    if nfreqreached==1
        endnum=findstr(line,'number');
        nfreq=str2num(line(1:endnum-1));
        nfreqreached=0;
    end
    if ~isempty(findstr(line,'FREQ'));
        nfreqreached=1;
    end
    if ~isempty(findstr(line,'exception value'));
        hd=0;
    end
    headerstr{count}=line;
end

% Collect spectra data
count=0;
countf=0;
startno=0;
stopno=0;
indexXB=0;
fpos = ftell(fid);
while fpos<filesize
    count=count+1;
    date=fgetl(fid);
    factorstr=fgetl(fid);
    if ~strcmpi(strtrim(factorstr),'ZERO')
        factornum=fgetl(fid);
        for j=1:nfreq
            vdstr{j}=fgetl(fid);
        end
        
        % Check to see if time >= starttime
        if (datenum(date(1:15),'yyyymmdd.HHMMSS')>=starttime && countf==0)
            indexXB=count:step:filesize;
        end
        
        % Check to see if time > stoptime
        if (datenum(date(1:15),'yyyymmdd.HHMMSS')>stoptime)
            break
        end
        
        % Check to see if this sepctrum should be included in XBeach
        if any(indexXB==count)
            countf=countf+1;
            fnameif=['swan2d_' strtrim(date(1:15)) '.sp2'];
            fnlist{countf}=fnameif;
            datemat(countf)=datenum(date(1:15),'yyyymmdd.HHMMSS');
            if countf==1
                datemat0=datemat(1);
            end
            datemat(countf)=(datemat(countf)-datemat0)*24*3600;
            
            fidif=fopen(fnameif,'w');
            
            for hdi=1:length(headerstr)
                fprintf(fidif,'%s\n',headerstr{hdi});
            end
            fprintf(fidif,'%s\n',date);
            fprintf(fidif,'%s\n',factorstr);
            fprintf(fidif,'%s\n',factornum);
            for vdi=1:nfreq
                fprintf(fidif,'%s\n',vdstr{vdi});
            end
            fclose(fidif);
        end
    end
    fpos = ftell(fid);
end
    
% Write XBeach boundary condition list file   
fidl=fopen('swanlist.txt','w');
fprintf(fidl,'%s\n','FILELIST');
for i=1:countf
    if i<countf
        fprintf(fidl,'% 14.2f % 5.2f %s\n',datemat(i+1)-datemat(i),dtbc,fnlist{i});
    else
        fprintf(fidl,'% 14.2f % 5.2f %s\n',datemat(i)-datemat(i-1),dtbc,fnlist{i});
    end
end
fclose(fidl);
fclose(fid);
    
    
    
    
    