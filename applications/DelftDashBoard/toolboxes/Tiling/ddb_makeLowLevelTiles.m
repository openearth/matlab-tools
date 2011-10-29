function ddb_makeLowLevelTiles(dr,dataname,ncfiles,dxk,dyk,nnxk,nnyk,nxk,nyk,x0,y0,OPT)

for i=1:length(ncfiles)
    x=nc_varget(ncfiles{i},'lon');
    y=nc_varget(ncfiles{i},'lat');
    xmn(i)=x(1);
    xmx(i)=x(end);
    ymn(i)=y(1);
    ymx(i)=y(end);
end

k=1; % Lowest level

if ~exist([dr 'zl' num2str(k,'%0.2i')],'dir')
    mkdir([dr 'zl' num2str(k,'%0.2i')]);
end

dx=dxk(k);
dy=dyk(k);
nnx=nnxk(k);
nny=nnyk(k);
nx=nxk(k);
ny=nyk(k);

%for i=1:nnx
for i=694:nnx
    for j=1:nny
        
        disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
        
        xmin = x0(k)+(i-1)*nx*dx;
        ymin = y0(k)+(j-1)*ny*dy;
        xmax = xmin+(nx-1)*dx;
        ymax = ymin+(ny-1)*dy;
        
        xx=xmin:dx:xmax;
        yy=ymin:dy:ymax;
                
        ifile=find(xmn<=xmin+1e-5 & xmx>=xmin & ymn<=ymin+1e-5 & ymx>=ymin);
        
        if ~isempty(ifile)
            i1=round((xmin-xmn(ifile))/dx);
            j1=round((ymin-ymn(ifile))/dy);
%                zz=nc_varget(ncfiles{ifile},'depth',[j1 i1],[ny nx]);
                zz=nc_varget(ncfiles{ifile},'depth',[i1 j1],[nx ny]);
%                zz=double(zz);
%                zz(zz<-9998&zz>-10000)=NaN;
%            if ~isnan(max(max(zz)))
            if ~isempty(find(zz~=-9999, 1))
%                zz=single(zz);
%                zz=zz';
                fname=[dr 'zl' num2str(k,'%0.2i') '\' dataname '.zl01.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                nc_grid_createNCfile2(fname,xx,yy,zz,OPT);
            end
        end
        
    end
end
