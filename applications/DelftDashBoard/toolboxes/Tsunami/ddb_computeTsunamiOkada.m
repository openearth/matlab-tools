function [xg,yg,zg]=ddb_computeTsunamiOkada(xs,ys,depth,dip,width,lngth,sliprake,slip,strike,varargin)

xg=[];
yg=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'xg'}
                xg=varargin{ii+1};
            case{'yg'}
                yg=varargin{ii+1};
        end
    end
end

xl=2*lngth;
yl=xl;
dx=1;
[xg,yg] = meshgrid(-xl:dx:xl,-yl:dx:yl);
[uE,uN,zg] = okada85(xg,yg,depth,strike,dip,lngth,width,sliprake,slip,0);
xg=xg*1000+xs;
yg=yg*1000+ys;
