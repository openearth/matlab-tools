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
BCH.data(1).freq  = freqs(1);
BCH.data(2).freq  = freqs(2);
tline             = fgetl(fid);
for i=1:I;
    tline         = fgetl(fid);
    if isempty(str2num(tline));
        J                    = j - 1;
        for j=1:J;
            tline            = fgetl(fid);
            phase            = str2num(tline);
            BCH.data(j).phi  = phase;
        end
        break;
    else
        amplitude            = str2num(tline);
        BCH.data(j).mean     = amplitude(1);
        BCH.data(j).amp      = amplitude(2);
        j                    = j + 1;
    end
end
fclose all;

% Rearrange the structure
freq              = BCH.data(2).freq;
for i=1:length(BCH.data)/2;
    meanA(i)      = BCH.data(i).mean;
    ampA(i)       = BCH.data(i).amp;
    phiA(i)       = BCH.data(i).phi;
end
j                 = 1;
for i=length(BCH.data)/2+1:length(BCH.data);
    meanB(j)      = BCH.data(i).mean;
    ampB(j)       = BCH.data(i).amp;
    phiB(j)       = BCH.data(i).phi;
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
        if freq~=0;
            period   = 60*2*pi/freq;
        else
            period   = 0.0;
        end
        dp           = (nulpunt + (j+1))/2;
        basisA       = [num2str(0.0           ,'%7.7f'),'    ', ...
                        num2str(meanA(dp)     ,'%7.7f'),'    ', ...
                        num2str(0.0           ,'%7.7f')            ];
        basisB       = [num2str(0.0           ,'%7.7f'),'    ', ...
                        num2str(meanB(dp)     ,'%7.7f'),'    ', ...
                        num2str(0.0           ,'%7.7f')            ];
        infoA        = [num2str(period        ,'%7.7f'),'    ', ...
                        num2str(ampA(dp)      ,'%7.7f'),'    ', ...
                        num2str(phiA(dp)      ,'%7.7f')            ];
        infoB        = [num2str(period        ,'%7.7f'),'    ', ...
                        num2str(ampB(dp)      ,'%7.7f'),'    ', ...
                        num2str(phiB(dp)      ,'%7.7f')            ];
        fprintf(fidA,['* COLUMNN=3','\n']);
        fprintf(fidA,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
        fprintf(fidA,['* COLUMN2=Amplitude (ISO)','\n']);
        fprintf(fidA,['* COLUMN3=Phase (deg)','\n']);
        fprintf(fidA,[basisA,'\n']);
        fprintf(fidA,[infoA ,'\n']);
        fprintf(fidB,['* COLUMNN=3','\n']);
        fprintf(fidB,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
        fprintf(fidB,['* COLUMN2=Amplitude (ISO)','\n']);
        fprintf(fidB,['* COLUMN3=Phase (deg)','\n']);
        fprintf(fidB,[basisB,'\n']);
        fprintf(fidB,[infoB ,'\n']);
    end
end
fclose all;

% Message
msgbox('Component files have succesfully been generated.','Message');