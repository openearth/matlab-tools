function grd=ddb_plotCurvilinearGrid(x,y,varargin)

col=[0 0 0];

% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'color'}
                col=varargin{i+1};
        end
    end
end

grd1=plot(x,y,'k');
set(grd1,'Color',col);
set(grd1,'HitTest','off');
grd2=plot(x',y','k');
set(grd2,'Color',col);
set(grd2,'HitTest','off');
grd=[grd1;grd2];
