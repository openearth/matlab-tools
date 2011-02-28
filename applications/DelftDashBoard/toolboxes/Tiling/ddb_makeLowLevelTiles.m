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

for i=1:nnx
    for j=1:nny
        
        disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
        
        xmin = x0(k)+(i-1)*nx*dx;
        ymin = y0(k)+(j-1)*ny*dy;
        xmax = xmin+(nx-1)*dx;
        ymax = ymin+(ny-1)*dy;
        
        xx=xmin:dx:xmax;
        yy=ymin:dy:ymax;
        
        i1=(i-1)*nx+1;
        i2=i*nx;
%        i2=min(i2,ncols);
        j1=(j-1)*ny+1;
        j2=j*ny;
%        j2=min(j2,nrows);
        
        zz=nan(ny,nx);
        
        %         if pbyp
        %             % Read data piece by piece
        %             %                        [x,y,z]=readArcInfo(fname1,'columns',[j1 j2],'rows',[i1 i2],'x',xx,'y',yy);
        %             [x,y,zz]=readArcInfo(fname1,'x',xx,'y',yy);
        %             %                        zz(1:(j2-j1+1),1:(i2-i1+1))=single(z);
        %         else
        %             zz(1:(j2-j1+1),1:(i2-i1+1))=single(z(j1:j2,i1:i2));
        %         end
        
        ifile=find(abs(xmn-xmin)<1e-5 & abs(ymn-ymin)<1e-5);
        if ~isempty(ifile)
            
            i1=round((xmin-xmn(ifile))/dx);
            j1=round((ymin-ymn(ifile))/dy);
            try
            zz=nc_varget(ncfiles{ifile},'depth',[j1 i1],[ny nx]);
            catch
            shite=100    
            end
            if ~isnan(max(max(zz)))
                %                    zz(1:(j2-j1+1),1:(i2-i1+1))=single(z(j1:j2,i1:i2));
                zz=single(zz);
                zz=zz';
                fname=[dr 'zl' num2str(k,'%0.2i') '\' dataname '.zl01.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                nc_grid_createNCfile2(fname,xx,yy,zz,OPT);
            end
        end
        
    end
end
