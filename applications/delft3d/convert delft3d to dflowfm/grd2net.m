warning off all;
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

% Read paths and modelname from screen
modelid                     = get(handles.listbox1,'Value');
modelentry                  = get(handles.listbox1,'String');
modelshort                  = modelentry(modelid,:);
modelshort(modelshort==' ') = [];
modelshort(end-3:end)       = [];

% Check net file (block analogue to previous block for ext-files)
netfileread = get(handles.edit6,'String');
netfileread(netfileread==' ') = [];
if isempty(netfileread);
    errordlg('The net-file name has not been assigned','Error');
    return;
end
if length(netfileread)>6;
    if strcmp(netfileread(end-6:end),'_net.nc');
        netfile    = netfileread(1:end-7);
    else
        netfile    = netfileread;
    end
else
    netfile = netfileread;
end

% Set file names
ddgrid      = [pathin,'/',modelshort,'.grd'];
netfile     = [pathout,'/',netfile,'_net.nc'];

% Read the sizes of the grid (more robust than OET-tools)
fid         = fopen(ddgrid,'r');
for i=1:10;
    tline   = fgetl(fid);
    if length(tline) >= 4;
        if strcmp(tline(1:4),' ETA');
            startgrid   = i-2;  
            break;
        end
    end
end
fclose(fid);
fid         = fopen(ddgrid,'r');
for i=1:startgrid;
    tline   = fgetl(fid);
end
MN          = str2num(tline);
M           = MN(1);
N           = MN(2);
fclose(fid);

% Choose option
optie       = 2;

% Read the grid: own style
if optie == 1;
    fid         = fopen(ddgrid,'r');
    etarij      = 0;
    eta         = zeros(M,N);
    J           = ceil(M/5);
    for i=1:startgrid+1;
        tline   = fgetl(fid);
    end
    for k=1:2;
        for i=1:N;
            for j=1:J;
                tline            = fgetl(fid);
                if strcmp(tline(1:4),'ETA=');
                    teller       = str2num(tline(6:10));
                end
                leeseta          = str2num(tline(13:end));
                etarij           = [etarij leeseta];
                if j==J;
                    etarij(1)    = [];
                    eta(:,i,k)   = etarij;
                    etarij       = 0;
                end
            end
        end
    end
    xh              = eta(:,:,1);
    yh              = eta(:,:,2);
    xh(xh==0)       = NaN;
    yh(yh==0)       = NaN; 
end

% Read the grid: OET-style
if optie == 2;
    G           = delft3d_io_grd('read',ddgrid);
    xh          = G.cor.x;
    yh          = G.cor.y;
    
    % Transpose the grid (x and y) if the sizes do not match with read M and N (the latter match with the bnd!)
    if size(xh,1)~=M+1 & size(xh,2)~=N+1 & size(yh,1)~=M+1 & size(yh,2)~=N+1;
        xh = xh';
        yh = yh';
    end
end

% Write net-file
dflowfm.writeNet(netfile,xh,yh);

% Message
msgbox('The net file has been written.','Message');