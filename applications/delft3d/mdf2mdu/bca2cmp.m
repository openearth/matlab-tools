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
fid1        = fopen(ddbca,'r');
I           = 1e8;
J           = 1e2;
teller      = 1;
tellerA     = 1;
tellerB     = 2;
tline       = fgetl(fid1);
for i=1:I;
    if tline < 0;
        break;
    end
    tline   = textscan(tline,'%s%f%f');
    if isempty(tline{2}) & isempty(tline{3});
        location             = tline{1};
        if strcmp(location,loc{teller});
            namecmp          = [pathout,'/',plibasis,'_',num2str(perm(teller,1),'%0.2d'),'_',num2str(perm(teller,2),'%0.4d'),'.cmp'];
            namecmp          = fopen(namecmp,'w');
            for j=1:J;   
                tline        = fgetl(fid1);
                if tline < 0;
                    break;
                end
                test         = textscan(tline,'%s%f%f');
                if isempty(test{2}) & isempty(test{3});
                    break;
                end
                information  = tline;
                fprintf(namecmp,[information,'\n']);
            end
            teller           = teller + 1;
            if teller > size(perm,1);
                break;
            end
            fclose(namecmp);
        else
            tline   = fgetl(fid1);
            if tline < 0;
                break;
            end
        end
    else
        tline       = fgetl(fid1);
        if tline < 0;
            break;
        end
    end
end
fclose all;

% Message
msgbox('Component files have succesfully been generated.','Message');