function [rid,names,x,y]=getWW3points(hm,m)

Model=hm.Models(m);

rid=[];
x=[];
y=[];

%% Observation points

n=Model.NrStations;

imod=0;

if n>0
    imod=imod+1;
    rid{imod}=Model.Runid;
    names{imod}=Model.Name;
    ip=0;
    for k=1:n
        ip=ip+1;
        x{imod}(ip)=Model.Stations(k).Location(1);
        y{imod}(ip)=Model.Stations(k).Location(2);
    end
end

%% Nesting points

n=length(Model.NestedWaveModels);

for j=1:n
    i=Model.NestedWaveModels(j);

    % A model is nested in this WAVEWATCH III model

    if ~strcmpi(hm.Models(i).Type,'ww3') && hm.Models(i).Priority>0

        % And it's not a WAVEWATCH III model

        locfile=[hm.Models(i).Dir 'nesting' filesep Model.Name '.loc'];

        if ~exist(locfile,'file') && strcmpi(hm.Models(i).Type,'delft3dflowwave') 
            % Find boundary points nested grid
            grdname=[hm.Models(i).Dir 'input' filesep hm.Models(i).Name '_swn.grd'];
            [xg,yg,enc]=wlgrid('read',grdname);
            nstep=10;
            [xb,yb]=getGridOuterCoordinates(xg,yg,nstep);

            x0=Model.XOri;
            y0=Model.YOri;
            nx=Model.nX;
            ny=Model.nY;
            dx=Model.dX;
            dy=Model.dY;

            depname=[Model.Dir filesep 'input' filesep Model.Name '.bot'];
            
            if ~strcmpi(hm.Models(i).CoordinateSystem,Model.CoordinateSystem) || ~strcmpi(hm.Models(i).CoordinateSystemType,Model.CoordinateSystemType)
                [xb,yb]=convertCoordinates(xb,yb,'persistent','CS1.name',hm.Models(i).CoordinateSystem,'CS1.type',hm.Models(i).CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            end
        
            [xb,yb]=checkNestDepthsWW3(depname,x0,y0,nx,ny,dx,dy,xb,yb);
            
            d=[xb yb];
            % Check for points on land
            save(locfile,'d','-ascii');
        end

        pnts=load(locfile);
        np=size(pnts,1);

%         if ~strcmpi(hm.Models(i).CoordinateSystem,Model.CoordinateSystem) || ~strcmpi(hm.Models(i).CoordinateSystemType,Model.CoordinateSystemType)
%             % Convert coordinates
%             xx=pnts(:,1);
%             yy=pnts(:,2);
%             [xx,yy]=ConvertCoordinates(xx,yy,'persistent','CS1.name',hm.Models(i).CoordinateSystem,'CS1.type',hm.Models(i).CoordinateSystemType,'CS2.name',Model.CoordinateSystem,'CS2.type',Model.CoordinateSystemType);
%             pnts(:,1)=xx;
%             pnts(:,2)=yy;
%         end

        imod=imod+1;
        rid{imod}=hm.Models(i).Runid;
        names{imod}=hm.Models(i).Name;

        ip=0;
        for k=1:np
            ip=ip+1;
            x{imod}(ip)=pnts(k,1);
            y{imod}(ip)=pnts(k,2);
        end
    end

end
