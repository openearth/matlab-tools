function handles=ddb_makeDDModel(handles,id1,id2,runid)

wb = waitbox('Generating Subdomain ...');pause(0.1);

% grd1new=id1;
% fid=fopen([id0 '.mdf']);
% counter=0;
% while ~feof(fid)
%     counter=counter+1;
%     regel{counter}=fgetl(fid);
%     key=lower(deblank(regel{counter}(1:6)));
%     switch key
%         case{'mnkmax'},
%             [m1,n1,kmax1] = strread(regel{counter}(9:end));
%         case{'filcco'},
%             filgrd = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filgrd'},
%             filenc = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filrgh'},
%             filrgh = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'fildep'},
%             fildep = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'fildry'},
%             fildry = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filtd'},
%             filthd = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filbnd'},
%             filbnd = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filsta'},
%             filobs = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filcrs'},
%             filcrs = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'filsrc'},
%             filsrc = char(strread(regel{counter}(10:end),'%s','delimiter','#'));
%         case{'flhis'},
%             [his1,his2,his3] = strread(regel{counter}(8:end));
%     end
% end
% fclose(fid);
%
% [x0,y0,enc1]=ddb_wlgrid('read',filgrd);
%
% if exist('fildep')
%     dep0=ddb_wldep('read',fildep,size(x0)+1);
% end

% Create fine grid and bathymetry

runid1=handles.Model(handles.ActiveModel.Nr).Input(id1).Runid;
runid2=runid;

kmax1=handles.Model(handles.ActiveModel.Nr).Input(id1).KMax;

%handles=ddb_initialize(handles,'flow',id2,runid);

handles.Model(handles.ActiveModel.Nr).Input(id2)=handles.Model(handles.ActiveModel.Nr).Input(id1);
handles=ddb_initializeFlowInput(handles,id2,runid,'ini');

refm=handles.Toolbox(tb).Input.MRefinement;
refn=handles.Toolbox(tb).Input.NRefinement;

m1=handles.Toolbox(tb).Input.FirstCornerPointM;
n1=handles.Toolbox(tb).Input.FirstCornerPointN;
m2=handles.Toolbox(tb).Input.SecondCornerPointM;
n2=handles.Toolbox(tb).Input.SecondCornerPointN;
mmin=min(m1,m2);mmax=max(m1,m2);
nmin=min(n1,n2);nmax=max(n1,n2);


% Grid

x0=handles.Model(handles.ActiveModel.Nr).Input(id1).GridX;
y0=handles.Model(handles.ActiveModel.Nr).Input(id1).GridY;

x2coarse=x0(mmin:mmax,nmin:nmax);
y2coarse=y0(mmin:mmax,nmin:nmax);

[x2,y2,mcut,ncut]=ddb_refineD3DGrid(x2coarse,y2coarse,refm,refn);
enc2=ddb_enclosure('extract',x2,y2);
grd2=[runid '.grd'];

ddb_wlgrid('write',grd2,x2,y2,enc2,handles.ScreenParameters.CoordinateSystem.Type);
handles.Model(handles.ActiveModel.Nr).Input(id2).GrdFile=[runid '.grd'];
handles.Model(handles.ActiveModel.Nr).Input(id2).EncFile=[runid '.enc'];
handles.Model(handles.ActiveModel.Nr).Input(id2).GridX=x2;
handles.Model(handles.ActiveModel.Nr).Input(id2).GridY=y2;
handles.Model(handles.ActiveModel.Nr).Input(id2).MMax=size(x2,1)+1;
handles.Model(handles.ActiveModel.Nr).Input(id2).NMax=size(x2,2)+1;
handles.Model(handles.ActiveModel.Nr).Input(id2).KMax=kmax1;
handles.ActiveDomain=id2;
handles=ddb_determineKCS(handles);
handles.ActiveDomain=id1;

% Bathymetry

if isfield(handles.Model(handles.ActiveModel.Nr).Input(id1),'Depth') && size(handles.Model(handles.ActiveModel.Nr).Input(id1).Depth,1)>1
    %     dep2coarse=handles.Model(handles.ActiveModel.Nr).Input(id1).Depth(mmin:mmax,nmin:nmax);
    %     x2coarse(isnan(x2coarse))=0;
    %     y2coarse(isnan(y2coarse))=0;
    %     dep2coarse(isnan(dep2coarse))=0;
    %     dep2tmp=griddata(x2coarse,y2coarse,dep2coarse,x2,y2);
    %     %dep2=zeros(size(x2)+1);
    %     %dep2(dep2==0)=NaN;
    %     %dep2(1:end-1,1:end-1)=dep2tmp;
    %     handles.Model(handles.ActiveModel.Nr).Input(id2).Depth=dep2tmp;
    %     ddb_wldep('write',[runid '.dep'],dep2tmp);
    xx=handles.GUIData.x;
    yy=handles.GUIData.y;
    zz=handles.GUIData.z;
    
    x20=x2;
    y20=y2;
    
    x2(isnan(x2))=0;
    y2(isnan(y2))=0;

    z=interp2(xx,yy,zz,x2,y2);
    handles.Model(handles.ActiveModel.Nr).Input(id2).Depth=z;
    ddb_wldep('write',[runid '.dep'],z);
    handles.Model(handles.ActiveModel.Nr).Input(id2).DepFile=[runid '.dep'];
    
    x2=x20;
    y2=y20;
    
end

% Adjustment original grid

x1=x0;
y1=y0;
x1(mmin+1:mmax-1,nmin+1:nmax-1)=NaN;
y1(mmin+1:mmax-1,nmin+1:nmax-1)=NaN;

sz1=size(x1);
sz2=size(x2);
iac1=zeros(sz1);
iac2=zeros(sz2);
iac1(isfinite(x1))=1;
iac2(isfinite(x2))=1;

% sides
% bottom
for i=mmin+1:mmax-1
    isn=0;
    if nmin==1
        isn=1;
    elseif ~iac1(i,nmin-1)
        isn=1;
    end
    if isn
        iac1(i,nmin)=0;
        x1(i,nmin)=NaN;
        y1(i,nmin)=NaN;
    end
end
% top
for i=mmin+1:mmax-1
    isn=0;
    if nmax==sz1(2)
        isn=1;
    elseif ~iac1(i,nmax+1)
        isn=1;
    end
    if isn
        iac1(i,nmax)=0;
        x1(i,nmax)=NaN;
        y1(i,nmax)=NaN;
    end
end
% left
for j=nmin+1:nmax-1
    isn=0;
    if mmin==1
        isn=1;
    elseif ~iac1(mmin-1,j)
        isn=1;
    end
    if isn
        iac1(mmin,j)=0;
        x1(mmin,j)=NaN;
        y1(mmin,j)=NaN;
    end
end
% right
for j=nmin+1:nmax-1
    isn=0;
    if mmax==sz1(1)
        isn=1;
    elseif ~iac1(mmax+1,j)
        isn=1;
    end
    if isn
        iac1(mmax,j)=0;
        x1(mmax,j)=NaN;
        y1(mmax,j)=NaN;
    end
end

enc1=ddb_enclosure('extract',x1,y1);
ii=findstr(handles.Model(handles.ActiveModel.Nr).Input(id1).GrdFile,'.grd');
str=handles.Model(handles.ActiveModel.Nr).Input(id1).GrdFile(1:ii-1);
oldgrd=handles.Model(handles.ActiveModel.Nr).Input(id1).GrdFile;
ddb_wlgrid('write',[handles.Model(handles.ActiveModel.Nr).Input(id1).GrdFile(1:ii-1) '_new.grd'],x1,y1,enc1,handles.ScreenParameters.CoordinateSystem.Type);
handles.Model(handles.ActiveModel.Nr).Input(id1).GrdFile=[str '_new.grd'];
handles.Model(handles.ActiveModel.Nr).Input(id1).EncFile=[str '_new.enc'];
handles.Model(handles.ActiveModel.Nr).Input(id1).GridX=x1;
handles.Model(handles.ActiveModel.Nr).Input(id1).GridY=y1;
handles=ddb_determineKCS(handles);

% Attribute Files
handles.Model(handles.ActiveModel.Nr).Input(id2).NrObservationPoints=0;
handles.Model(handles.ActiveModel.Nr).Input(id2).ObsFile='';
handles.Model(handles.ActiveModel.Nr).Input(id2).ObservationPoints=[];

handles.Model(handles.ActiveModel.Nr).Input(id2).NrObservationPoints=0;
handles.Model(handles.ActiveModel.Nr).Input(id2).OpenBoundaries=[];

handles.Model(handles.ActiveModel.Nr).Input(id2).NrDryPoints=0;
handles.Model(handles.ActiveModel.Nr).Input(id2).DryPoints=[];

handles.Model(handles.ActiveModel.Nr).Input(id2).NrThinDams=0;
handles.Model(handles.ActiveModel.Nr).Input(id2).ThinDams=[];

% if exist('filobs')
%     nobs=ddb_obs2obs(filgrd,filobs,grd2,[fname2 '.obs']);
% end
if handles.Model(handles.ActiveModel.Nr).Input(id1).NrDryPoints>0
    ndry=ddb_dry2dry(oldgrd,handles.Model(handles.ActiveModel.Nr).Input(id1).DryFile,handles.Model(handles.ActiveModel.Nr).Input(id2).GrdFile,[runid2 '.dry']);
    if ndry>0
        handles.Model(handles.ActiveModel.Nr).Input(id2).DryFile=[runid2 '.dry'];
        handles.Model(handles.ActiveModel.Nr).Input(id2).NrDryPoints=ndry;
        handles.ActiveDomain=id2;
        handles=ddb_readDryFile(handles);
        handles.ActiveDomain=id1;        
    end
end
% if exist('filthd')
%     nthd=ddb_thd2thd(filgrd,filthd,grd2,[fname2 '.thd']);
% end
% if exist('filcrs')
%     ncrs=ddb_crs2crs(filgrd,filcrs,grd2,[fname2 '.crs']);
% end
% if exist('filsrc')
%     nsrc=ddb_src2src(filgrd,filsrc,grd2,[fname2 '.src']);
% end
nsrc=0;
%nbnd=ddb_bnd2bnd(filgrd,filbnd,grd2,[fname2 '.bnd']);
nbnd=0;

% % Write mdf file coarse model
%
% fid = fopen([id1 '.mdf'],'wt');
% for i=1:length(regel)
%     key=lower(deblank(regel{i}(1:6)));
%     switch key
%         case{'filcco'},
%             str=['Filcco= #' grd1new '.grd#'];
%         case{'filgrd'},
%             str=['Filgrd= #' grd1new '.enc#'];
%         otherwise,
%             str=regel{i};
%     end
%     fprintf(fid,'%s\n',str);
% end
% fclose(fid);
%
% % Write mdf file fine model
%
% fid = fopen([id2 '.mdf'],'wt');
% for i=1:length(regel)
%     key=lower(deblank(regel{i}(1:6)));
%     switch key
%         case{'mnkmax'},
%             str=['MNKmax= ' num2str(mmax2) ' ' num2str(nmax2) ' ' num2str(kmax2)];
%         case{'filcco'},
%             str=['Filcco= #' fname2 '.grd#'];
%         case{'filgrd'},
%             str=['Filgrd= #' fname2 '.enc#'];
%         case{'fildep'},
%             str=['Fildep= #' fname2 '.dep#'];
%         case{'fildry'},
%             if ndry>0
%                 str=['Fildry= #' fname2 '.dry#'];
%             else
%                 str=['Fildry= ##'];
%             end
%         case{'filtd'},
%             if nthd>0
%                 str=['Filtd=  #' fname2 '.thd#'];
%             else
%                 str=['Filtd=  ##'];
%             end
%         case{'filbnd'},
%             if nbnd>0
%                 str=['Filbnd= #' fname2 '.bnd#'];
%             else
%                 str=['Filbnd= ##'];
%             end
%         case{'filsta'},
%             if nobs>0
%                 str=['Filsta= #' fname2 '.obs#'];
%             else
%                 str=['Filsta= ##'];
%             end
%         case{'filcrs'},
%             if ncrs>0
%                 str=['Filcrs= #' fname2 '.crs#'];
%             else
%                 str=['Filcrs= ##'];
%             end
%         case{'filsrc'},
%             if nsrc>0
%                 str=['Filsrc= #' fname2 '.src#'];
%             else
%                 str=['Filsrc= ##'];
%             end
%         case{'fildis'},
%             if nsrc>0
%                 str=regel{i};
%             else
%                 str=['Fildis= ##'];
%             end
%         case{'flhis'},
%             if nobs>0
%                 str=regel{i};
%             else
%                 str=['Flhis =  ',num2str(his1,'%16.7e'),' ',num2str(0,'%4.0f'),' ',num2str(his3,'%16.7e')];
%             end
%         otherwise,
%             str=regel{i};
%     end
%     fprintf(fid,'%s\n',str);
% end
% fclose(fid);
%

% Find DD boundaries

nddb=0;

% lower
k=0;
iff=0;
i=mmin;
j=nmin;
j2=1;
if j>1
    while i<=mmax
        k=k+1;
        i2=(k-1)*refm+1-mcut;
        if i2>0
            if iac1(i,j) && iac1(i,j-1) && iac2(i2,j2) && iff==0
                nddb=nddb+1;
                disp('lower');
                ifd(nddb)=1;
                ifirstm1(nddb)=i;
                ifirstm2(nddb)=i2;
                ifirstn1(nddb)=j;
                ifirstn2(nddb)=j2;
                iff=1;
            elseif iac1(i,j) && iac1(i,j-1) && iac2(i2,j2) && iff==1
                ilastm1(nddb)=i;
                ilastm2(nddb)=i2;
                ilastn1(nddb)=j;
                ilastn2(nddb)=j2;
            elseif (~iac1(i,j) || ~iac2(i2,j2)) && iff==1
                iff=0;
            end
        end
        i=i+1;
    end
end

% upper
k=0;
iff=0;
i=mmin;
j=nmax;
j2=size(x2,2);

if j<sz1(2)
    while i<=mmax
        k=k+1;
        i2=(k-1)*refm+1-mcut;
        if i2>0
            if iac1(i,j) && iac1(i,j+1) && iac2(i2,j2) && iff==0
                nddb=nddb+1;
                disp('upper');
                ifd(nddb)=2;
                ifirstm1(nddb)=i;
                ifirstm2(nddb)=i2;
                ifirstn1(nddb)=j;
                ifirstn2(nddb)=j2;
                iff=1;
            elseif iac1(i,j) && iac1(i,j+1) && iac2(i2,j2) && iff==1
                ilastm1(nddb)=i;
                ilastm2(nddb)=i2;
                ilastn1(nddb)=j;
                ilastn2(nddb)=j2;
            elseif (~iac1(i,j) || ~iac2(i2,j2)) && iff==1
                iff=0;
            end
        end
        i=i+1;
    end
end

% left
k=0;
iff=0;
j=nmin;
i2=1;
i=mmin;
if i>1
    while j<=nmax
        k=k+1;
        j2=(k-1)*refn+1-ncut;
        if j2>0
            if iac1(i,j) && iac1(i-1,j) && iac2(i2,j2) && iff==0
                nddb=nddb+1;
                disp('left');
                ifd(nddb)=1;
                ifirstm1(nddb)=i;
                ifirstm2(nddb)=i2;
                ifirstn1(nddb)=j;
                ifirstn2(nddb)=j2;
                iff=1;
            elseif iac1(i,j) && iac1(i-1,j) && iac2(i2,j2) && iff==1
                ilastm1(nddb)=i;
                ilastm2(nddb)=i2;
                ilastn1(nddb)=j;
                ilastn2(nddb)=j2;
            elseif (~iac1(i,j) || ~iac2(i2,j2)) && iff==1
                iff=0;
            end
        end
        j=j+1;
    end
end

% right
k=0;
iff=0;
j=nmin;
i=mmax;
i2=size(x2,1);
if i<sz1(1)
    while j<=nmax
        k=k+1
        i2;
        j2=(k-1)*refn+1-ncut;
        i
        j
        ia1a=iac1(i,j);
        ia1b=iac1(i+1,j);
        ia1c=iac1(i,j+1)
        x1(i,j)
        x1(i+1,j)
        x1(i,j+1)
        ia2=iac2(i2,j2);
        ia1c=iac1(i,j+1)
        iff;
%         shite
        if j2>0
            if iac1(i,j) && iac1(i+1,j) && iac1(i+1,j+1) && iac2(i2,j2) && iff==0
                nddb=nddb+1
                disp('right')
                ifd(nddb)=2;
                ifirstm1(nddb)=i;
                ifirstm2(nddb)=i2;
                ifirstn1(nddb)=j;
                ifirstn2(nddb)=j2;
                iff=1;
            elseif iac1(i,j) && iac1(i+1,j) &&  iac2(i2,j2) && iff==1
                ilastm1(nddb)=i;
                ilastm2(nddb)=i2;
                ilastn1(nddb)=j;
                ilastn2(nddb)=j2;
            elseif (~iac1(i,j) || ~iac2(i2,j2)) && iff==1
                iff=0;
            end
        end
        j=j+1;
    end
end


% Write DDBOUND file

fid = fopen(['ddbound'],'wt');
% ifirstm1
% ilastm1
% ifirstn1
% ilastn1
% ifirstm2
% ilastm2
% ifirstn2
% ilastn2
% nddb
for i=1:nddb
% i

    if ifd(i)==1
        fprintf(fid,'%s %8i %8i %8i %8i %s %8i %8i %8i %8i\n',[runid1,'.mdf'],ifirstm1(i),ifirstn1(i),ilastm1(i),ilastn1(i),[runid2,'.mdf'],ifirstm2(i),ifirstn2(i),ilastm2(i),ilastn2(i));
    else

        fprintf(fid,'%s %8i %8i %8i %8i %s %8i %8i %8i %8i\n',[runid2,'.mdf'],ifirstm2(i),ifirstn2(i),ilastm2(i),ilastn2(i),[runid1,'.mdf'],ifirstm1(i),ifirstn1(i),ilastm1(i),ilastn1(i));
    end
end
fclose(fid);


% Write run batch file

fid = fopen(['rundd.bat'],'wt');
fprintf(fid,'%s\n',['echo ',runid1,' > runid']);
fprintf(fid,'%s\n','c:\delft3d\w32\flow\bin\tdatom.exe');
fprintf(fid,'%s\n',['echo ',runid2,' > runid']);
fprintf(fid,'%s\n','c:\delft3d\w32\flow\bin\tdatom.exe');

fprintf(fid,'%s\n','c:\delft3d\w32\flow\bin\trisim.exe ddbound');
fclose(fid);

close(wb);

