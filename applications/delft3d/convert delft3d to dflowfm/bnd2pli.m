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

% Name bnd-file
bndid                       = get(handles.listbox2,'Value');
bndentry                    = get(handles.listbox2,'String');
bndshort                    = bndentry(bndid,:);
bndshort(bndshort==' ')     = [];
bndshort(end-3:end)         = [];

% Set file names
ddgrid      = [pathin,'/',modelshort,'.grd'];
ddbound     = [pathin,'/',bndshort  ,'.bnd'];

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
    for m = 2:M;
        for n = 2:N;
            xc(m,n) = 0.25.*(xh(m,n)+xh(m-1,n)+xh(m,n-1)+xh(m-1,n-1));
            yc(m,n) = 0.25.*(yh(m,n)+yh(m-1,n)+yh(m,n-1)+yh(m-1,n-1));
        end
    end
    fclose all;
    
    % Extrapolatie boundaries: boundary conditions given at cell centers
    xc(1  , : ) = 2.*xc(2  , : ) - xc(3  , : );
    yc(1  , : ) = 2.*yc(2  , : ) - yc(3  , : );
    xc( : ,1  ) = 2.*xc( : ,2  ) - xc( : ,3  );
    yc( : ,1  ) = 2.*yc( : ,2  ) - yc( : ,3  );
    xc(M+1, : ) = 2.*xc(M  , : ) - xc(M-1, : );
    yc(M+1, : ) = 2.*yc(M  , : ) - yc(M-1, : );
    xc( : ,N+1) = 2.*xc( : ,N  ) - xc( : ,N-1);
    yc( : ,N+1) = 2.*yc( : ,N  ) - yc( : ,N-1);
    
end

% Read the grid: OET-style
if optie == 2;
    G           = delft3d_io_grd('read',ddgrid);
    xc          = G.cend.x;
    yc          = G.cend.y;
    
    % Transpose the grid (x and y) if the sizes do not match with read M and N (the latter match with the bnd!)
    if size(xc,1)~=M+1 & size(xc,2)~=N+1 & size(yc,1)~=M+1 & size(yc,2)~=N+1;
        xc = xc';
        yc = yc';
    end
    
    % Extrapolate boundaries: boundary conditions given at cell centers
    xc(1  , : ) = 2.*xc(2  , : ) - xc(3  , : );
    yc(1  , : ) = 2.*yc(2  , : ) - yc(3  , : );
    xc( : ,1  ) = 2.*xc( : ,2  ) - xc( : ,3  );
    yc( : ,1  ) = 2.*yc( : ,2  ) - yc( : ,3  );
    xc(M+1, : ) = 2.*xc(M  , : ) - xc(M-1, : );
    yc(M+1, : ) = 2.*yc(M  , : ) - yc(M-1, : );
    xc( : ,N+1) = 2.*xc( : ,N  ) - xc( : ,N-1);
    yc( : ,N+1) = 2.*yc( : ,N  ) - yc( : ,N-1);

end

% Read the boundary file
D           = delft3d_io_bnd('read',ddbound);
mbnd        = D.m;
nbnd        = D.n;
bndname     = D.DATA.name;
bndtype     = D.DATA.bndtype;
datatype    = D.DATA.datatype;
if max(mbnd(:))>M+1 | max(nbnd(:))>N+1;
    errordlg('Check if the bnd-file matches with the grd-file.','Error');
    return;
end

% Determine (x,y)-values of boundary points
for i=1:size(mbnd,1);
    for j=1:size(mbnd,2);
        xb(i,j) = xc(mbnd(i,j),nbnd(i,j));
        yb(i,j) = yc(mbnd(i,j),nbnd(i,j));
    end
end

% Reshape the boundary locations into polyline files
p           = 1;                      % is number of points in the polyline
q           = 1;                      % is number of polylines
for i=1:size(xb,1);
    if i>1;
        if ((mbnd(i,1)==mbnd(i-1,1) & mbnd(i,1)==mbnd(i-1,2)) | ...
            (nbnd(i,1)==nbnd(i-1,1) & nbnd(i,1)==nbnd(i-1,2)));
            p      = p+2;
        else
            p      = 1;
            q      = q+1;
        end
    end
    xpol(p  ,q)    = xb(i,1);         % choose point A as polyline point
    xpol(p+1,q)    = xb(i,2);         % choose point B as polyline point
    ypol(p  ,q)    = yb(i,1);         % choose point A as polyline point
    ypol(p+1,q)    = yb(i,2);         % choose point B as polyline point
end

% Write the pli-files (separate file for each boundary)
tellerhalf   = 1;
teller       = 1;
filenameall  = [pathout,'/',modelshort,'_all.pli'];
fidall       = fopen(filenameall,'wt');
for i=1:q;
    name               = [modelshort,'_',num2str(i,'%0.2d')];
	filename           = [pathout,'/',name,'.pli'];
    filenamesal        = [pathout,'/',name,'_sal.pli'];
	xpolsq             = xpol(:,i);
	ypolsq             = ypol(:,i);
	xpolsq(xpolsq==0)  = [];
	ypolsq(ypolsq==0)  = [];
	wripol(:,1)        = xpolsq';
	wripol(:,2)        = ypolsq';
	fid                = fopen(filename   ,'wt');
    fidsal             = fopen(filenamesal,'wt');
	fprintf(fid   ,[name,'\n']);
    fprintf(fidsal,[name,'\n']);
    fprintf(fidall,[name,'\n']);
	fprintf(fid   ,['\t',num2str(size(wripol,1),'%6.0f'),'      2\n']);
	fprintf(fidsal,['\t',num2str(size(wripol,1),'%6.0f'),'      2\n']);
    fprintf(fidall,['\t',num2str(size(wripol,1),'%6.0f'),'      2\n']);
	for j=1:size(wripol,1);
        if strcmp(D.DATA(teller).datatype,'A');
            extrastr   = [D.DATA(teller).labelA,'\t',D.DATA(teller).labelB];
        else
            extrastr   = [''];
        end
        bndname        = D.DATA(teller).name;
        bndname(bndname==' ')  = [];
        writestr       = ['\t',num2str(wripol(j,1),'%1.17e'),'\t',...
                               num2str(wripol(j,2),'%1.17e'),'\t',...
                               bndname                      ,'\t',...
                               D.DATA(teller).bndtype       ,' ' ,...
                               D.DATA(teller).datatype      ,'\t',...
                               extrastr,                                '\n'];
        writestrsal    = ['\t',num2str(wripol(j,1),'%1.17e'),'\t',...
                               num2str(wripol(j,2),'%1.17e'),'\t',...
                               bndname,                                 '\n'];
	    fprintf(fid   ,writestr   );
        fprintf(fidsal,writestrsal);
        fprintf(fidall,writestr   );
        tellerhalf     = tellerhalf + 0.5;
		teller         = floor(tellerhalf);
    end
	clear wripol;
	fclose(fid);
    fclose(fidsal);
end
fclose(fidall);

% List the pli-files
outputdir           = get(handles.edit2,'String');
list                = ls(outputdir);
list(1:2,:)         = [];
teller              = 1;
tellersal           = 1;
for i=1:size(list,1);
    file            = list(i,:);
    file(file==' ') = [];
    if length(file)>7;
        if strcmp(file(end-7:end),'_sal.pli') == 1 & strcmp(file(end-7:end),'_all.pli') == 0;
            salfile(tellersal,:)   = [list(i,:),'    '];
            tellersal              = tellersal + 1;
        else
            if strcmp(file(end-3:end),'.pli') == 1 & strcmp(file(end-7:end),'_all.pli') == 0;
                plifile(teller,:)  = [list(i,:),'    '];
                teller             = teller + 1;
            end
        end
    end
end

% Write pli-file into the listbox
set(handles.listbox13,'String', plifile          );    % for bct-files
set(handles.listbox8 ,'String', plifile          );    % for bca-files
set(handles.listbox15,'String', plifile          );    % for bct-files
set(handles.listbox10,'String',[         salfile]);    % for bcc-files
set(handles.listbox5 ,'String',[plifile; salfile]);    % for ext-file

% Message
msgbox('Polylines have succesfully been generated.','Message');