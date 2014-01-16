%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bca file name has been specified (Delft3D)
filebch     = get(handles.edit13,'String');
filebch     = deblank2(filebch);
if ~isempty(filebch);
    filebch = [pathin,'\',filebch];
    if exist(filebch,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified bch file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The bch file name has not been specified.','Error');
    break;
end

% Catch the polyline names for the boundary conditions
readpli     = get(handles.listbox1,'String');

% Filter the salinity-plis out
clear filepli;
for i=1:length(readpli);
    pli     = readpli{i};
    if strcmpi(pli(end-7:end),'_sal.pli');
        continue
    else
        filepli(i,:)  = readpli{i};
    end
end

% Read the bch-file (comparable style as existent OET-files)
fid               = fopen(filebch,'r');
j                 = 1;
I                 = 1e8;
tline             = fgetl(fid);
freqs             = str2num(tline);
for i=1:length(freqs);
    BCH.data(i).freq                = freqs(i);
end
tline             = fgetl(fid);
for i=1:I;
    tline         = fgetl(fid);
    if isempty(str2num(tline));
        J                           = j - 1;
        for j=1:J;
            tline                   = fgetl(fid);
            phase                   = str2num(tline);
            for k=1:length(phase);
                BCH.data(j).phi(k)  = phase(k);
            end
        end
        break;
    else
        amplitude                   = str2num(tline);
        BCH.data(j).mean            = amplitude(1);
        for k=1:length(amplitude)-1;
            BCH.data(j).amp(k)      = amplitude(k+1);
        end
        j                           = j + 1;
    end
end
fclose all;

% Rearrange the structure
K                 = size(BCH.data,2);
I1                = j/2;
I2                = j  ;
for k=2:K;
    if isempty(BCH.data(k).freq);
        break;
    else
        freq(k-1) = BCH.data(k).freq;
    end
end
for i=1:I1;
    meanA(i,1)    = BCH.data(i).mean;
    ampA(i,:)     = BCH.data(i).amp(:);
    phiA(i,:)     = BCH.data(i).phi(:);
end
j                 = 1;
for i=I1+1:I2;
    meanB(j,1)    = BCH.data(i).mean;
    ampB(j,:)     = BCH.data(i).amp(:);
    phiB(j,:)     = BCH.data(i).phi(:);
    j             = j + 1;
end


%%% ACTUAL CONVERSION OF THE BCH DATA

% Loop over all the boundary pli-files
npli                      = size(filepli,1);
cnt                       = 1;
for i=1:npli;
    fid                   = fopen([pathout,'\',filepli(i,:)],'r');
    tline                 = fgetl(fid);
    tline                 = fgetl(fid);
    tlinenum              = str2num(tline);
    if i>1;
        nulpunt           = nulpunt + J;
    else
        nulpunt           = 0;
    end
    J                     = tlinenum(1);                  % number of pli-points
    for j=1:2:J;
        namecmpA          = [pathout,'\',filepli(i,1:end-4),'_',num2str(j  ,'%0.4d'),'.cmp'];
        namecmpB          = [pathout,'\',filepli(i,1:end-4),'_',num2str(j+1,'%0.4d'),'.cmp'];
        fidA              = fopen(namecmpA,'wt');
        fidB              = fopen(namecmpB,'wt');
        for k=1:length(freq);
            if freq(k)~=0;
                period(k) = 60*360/freq(k);
            else
                period(k) = 0.0;
            end
        end
        dp           = (nulpunt + (j+1))/2;
        fprintf(fidA,['* COLUMNN=3','\n']);
        fprintf(fidA,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
        fprintf(fidA,['* COLUMN2=Amplitude (ISO)','\n']);
        fprintf(fidA,['* COLUMN3=Phase (deg)','\n']);
        fprintf(fidB,['* COLUMNN=3','\n']);
        fprintf(fidB,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
        fprintf(fidB,['* COLUMN2=Amplitude (ISO)','\n']);
        fprintf(fidB,['* COLUMN3=Phase (deg)','\n']);
        basisA       = [num2str(0.0           ,'%7.7f'),'    ', ...
                        num2str(meanA(dp)     ,'%7.7f'),'    ', ...
                        num2str(0.0           ,'%7.7f')            ];
        fprintf(fidA,[basisA,'\n']);
        basisB       = [num2str(0.0           ,'%7.7f'),'    ', ...
                        num2str(meanB(dp)     ,'%7.7f'),'    ', ...
                        num2str(0.0           ,'%7.7f')            ];
        fprintf(fidB,[basisB,'\n']);
        for k=1:size(ampA,2);
            infoA    = [num2str(period(k)     ,'%7.7f'),'    ', ...
                        num2str(ampA(dp,k)    ,'%7.7f'),'    ', ...
                        num2str(phiA(dp,k)    ,'%7.7f')            ];
            fprintf(fidA,[infoA ,'\n']);
        end
        for k=1:size(ampB,2);
            infoB    = [num2str(period(k)     ,'%7.7f'),'    ', ...
                        num2str(ampB(dp,k)    ,'%7.7f'),'    ', ...
                        num2str(phiB(dp,k)    ,'%7.7f')            ];
            fprintf(fidB,[infoB ,'\n']);
        end
        allcmpfiles(cnt  ,:)   = [filepli(i,1:end-4),'_',num2str(j  ,'%0.4d'),'.cmp'];
        allcmpfiles(cnt+1,:)   = [filepli(i,1:end-4),'_',num2str(j+1,'%0.4d'),'.cmp'];
        cnt                    = cnt + 2;
    end
end
fclose all;

% Fill listbox with cmp files
if exist('allcmpfiles');
    set(handles.listbox4,'String',allcmpfiles);
    clear allcmpfiles;
end