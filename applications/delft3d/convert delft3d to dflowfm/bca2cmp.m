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
bcaid                    = get(handles.listbox7,'Value');
bcaentry                 = get(handles.listbox7,'String');
bcashort                 = bcaentry(bcaid,:);
bcashort(bcashort==' ')  = [];
bcashort(end-3:end)      = [];
ddbca                    = [pathin,'/',bcashort,'.bca'];

% Name pli-file
pliid       = get(handles.listbox8,'Value');
aantpli     = length(pliid);
for i=1:aantpli;
    plientry                     = get(handles.listbox8,'String');
    plishortls                   = plientry(pliid(i),:);
    plishortls(plishortls==' ')  = [];
    plishortls(end-3:end)        = [];
    plishort(i,:)                = plishortls;
end
plibasis          = plishort(1,1:end-3);

% Read location names from pli-file
teller            = 1;
for i=1:aantpli;
    plifile       = [pathout,'/',plishort(i,:),'.pli'];
    fid2          = fopen(plifile,'r');
    tline         = fgetl(fid2);
    tline         = fgetl(fid2);
    tlinenum      = str2num(tline);
    J             = tlinenum(1);
    for j=1:2:J;
        tline             = fgetl(fid2);
        tline             = fgetl(fid2);
        tline             = textscan(tline,'%s%s%s%s%s%s%s');
        loc{teller}       = tline{6};
        loc{teller+1}     = tline{7};
        perm(teller,1)    = str2num(plishort(i,end-1:end));
        perm(teller+1,1)  = str2num(plishort(i,end-1:end));
        perm(teller,2)    = j;
        perm(teller+1,2)  = j+1;
        teller            = teller + 2;
    end
end
fclose all;

% Read the bca-file
bcadata     = delft3d_io_bca('read',ddbca);

% Fill the cmp-files
for teller=1:length(loc);
    for i=1:length(bcadata.DATA);
        if strcmp(loc{teller},bcadata.DATA(i).label);
            namecmp          = [pathout,'/',plibasis,'_',num2str(perm(teller,1),'%0.2d'),'_',num2str(perm(teller,2),'%0.4d'),'.cmp'];
            namecmp          = fopen(namecmp,'wt');
            fprintf(namecmp,['* COLUMNN=3','\n']);
            fprintf(namecmp,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
            fprintf(namecmp,['* COLUMN2=Amplitude (ISO)','\n']);
            fprintf(namecmp,['* COLUMN3=Phase (deg)','\n']);
            for j=1:length(bcadata.DATA(i).names);
                information  = [cell2mat(bcadata.DATA(i).names(j))     ,'    ', ...
                                num2str(bcadata.DATA(i).amp(j),'%7.7f'),'    ', ...
                                num2str(bcadata.DATA(i).phi(j),'%7.7f') ];
                fprintf(namecmp,[information,'\n']);
            end
            fclose(namecmp);
        end
        continue;
    end
end

% Message
msgbox('Component files have succesfully been generated.','Message');