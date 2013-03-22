fclose all; 
clc       ;

% Check if the directories have been set
pathin      = get(handles.edit1,'String');
pathout     = get(handles.edit2,'String');
if isempty(pathin);
    errordlg('The input directory has not been assigned','Error');
    return;
end
if isempty(pathout);
    errordlg('The output directory has not been assigned','Error');
    return;
end
if exist(pathin,'dir')==0;
    errordlg('The input directory does not exist.','Error');
    return;
end
if exist(pathout,'dir')==0;
    errordlg('The output directory does not exist.','Error');
    return;
end

% Name bca-file
bchid                    = get(handles.listbox14,'Value');
bchentry                 = get(handles.listbox14,'String');
bchshort                 = bchentry(bchid,:);
bchshort(bchshort==' ')  = [];
bchshort(end-3:end)      = [];
ddbch                    = [pathin,'/',bchshort,'.bch'];

% Name pli-file
pliid       = get(handles.listbox15,'Value');
aantpli     = length(pliid);
for i=1:aantpli;
    plientry                     = get(handles.listbox15,'String');
    plishortls                   = plientry(pliid(i),:);
    plishortls(plishortls==' ')  = [];
    plishortls(end-3:end)        = [];
    plishort(i,:)                = plishortls;
end
plibasis          = plishort(1,1:end-3);

% Check number of points for all polylines
I                 = size(plientry,1);
for i=1:I;
    pliname       = plientry(i,:);
    pliname(pliname==' ') = [];
    pliname       = [pathout,'/',pliname];
    fid           = fopen(pliname,'r');
    tline         = fgetl(fid);
    tline         = str2num(fgetl(fid));
    aantpunt(i,1) = i;
    aantpunt(i,2) = tline(1);
end
fclose all;

% Read the bch-file (comparable style as existent OET-files)
fid               = fopen(ddbch,'r');
j                 = 1;
I                 = 1e8;
tline             = fgetl(fid);
freqs             = str2num(tline);
for i=1:length(freqs);
    BCH.data(i).freq             = freqs(i);
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
for k=2:K;
    if isempty(BCH.data(k).freq);
        break;
    else
        freq(k-1) = BCH.data(k).freq;
    end
end
for i=1:size(BCH.data(1).amp,2)/2;
    meanA(i)      = BCH.data(i).mean;
    ampA(i,:)     = BCH.data(i).amp(:);
    phiA(i,:)     = BCH.data(i).phi(:);
end
j                 = 1;
for i=size(BCH.data(1).amp,2)/2+1:size(BCH.data(1).amp,2);
    meanB(j)      = BCH.data(i).mean;
    ampB(j,:)     = BCH.data(i).amp(:);
    phiB(j,:)     = BCH.data(i).phi(:);
    j             = j + 1;
end

% Assign data from the read structure to polylines
for i=1:aantpli;
    I             = pliid(i);
    J             = aantpunt(aantpunt(:,1)==I,2);
    if I>1;
        nulpunt   = sum(aantpunt(1:I-1,2));
    else
        nulpunt   = 0;
    end
    for j=1:2:J;
        namecmpA     = [pathout,'/',plibasis,'_',num2str(I,'%0.2d'),'_',num2str(j  ,'%0.4d'),'.cmp'];
        namecmpB     = [pathout,'/',plibasis,'_',num2str(I,'%0.2d'),'_',num2str(j+1,'%0.4d'),'.cmp'];
        fidA         = fopen(namecmpA,'wt');
        fidB         = fopen(namecmpB,'wt');
        for k=1:length(freq);
            if freq(k)~=0;
                period(k)  = 60*2*pi/freq(k);
            else
                period(k)  = 0.0;
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
    end
end
fclose all;

% Message
msgbox('Component files have succesfully been generated.','Message');