function [x,y]=ddb_getShoreline(handles,xl,yl,ires)

iac=strmatch(lower(handles.screenParameters.shoreline),lower(handles.shorelines.longName),'exact');
ldb=handles.shorelines.shoreline(iac);

name=ldb.name;

switch lower(ldb.type)
    case{'netcdftiles'}

        zoomstr=ldb.zoomLevel(ires).zoomString;
        
        x0=ldb.zoomLevel(ires).x0;
        y0=ldb.zoomLevel(ires).y0;
        ntilesx=ldb.zoomLevel(ires).ntilesx;
        ntilesy=ldb.zoomLevel(ires).ntilesy;
        dx=ldb.zoomLevel(ires).dx;
        dy=ldb.zoomLevel(ires).dy;

        xx=x0:dx:x0+(ntilesx-1)*dx;
        yy=y0:dy:y0+(ntilesy-1)*dy;
        
        ix1=find(xx<xl(1),1,'last');
        if isempty(ix1)
            ix1=1;
        end
        ix2=find(xx>xl(2),1,'first');
        if ~isempty(ix2)
            ix2=max(1,ix2-1);
        else
            ix2=length(xx);
        end
        iy1=find(yy<yl(1),1,'last');
        if isempty(iy1)
            iy1=1;
        end
        iy2=find(yy>yl(2),1,'first');
        if ~isempty(iy2)
            iy2=max(1,iy2-1);
        else
            iy2=length(yy);
        end

        iopendap=0;
        if strcmpi(ldb.URL(1:4),'http')
            % OpenDAP
            iopendap=1;
            remotedir=[ldb.URL '/' zoomstr '/'];
            localdir=[handles.shorelineDir name '\' zoomstr '\'];
        else
            % Local
            localdir=[ldb.URL '\' zoomstr '\'];
            remotedir=localdir;
        end

        x=[];
        y=[];
        for i=ix1:ix2
            for j=iy1:iy2

                iav=find(ldb.zoomLevel(ires).iAvailable==i & ldb.zoomLevel(ires).jAvailable==j, 1);
                    
                if ~isempty(iav)
                    
                    filename=[name '.' zoomstr '.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                    
                    if iopendap
                        if ldb.useCache
                            % First check if file is available locally
                            if ~exist([localdir filename],'file')
                                if ~exist(localdir,'dir')
                                    mkdir(localdir);
                                end
                                try
                                    urlwrite([remotedir filename],[localdir filename]);
                                end
                            end
                            ncfile=[localdir filename];
                        else
                            ncfile=[remotedir filename];
                        end
                    else
                        ncfile=[localdir filename];
                    end
                    
                    if iopendap && ~ldb.useCache
                        try
                            xy=nc_varget(ncfile,'xy');
                            x=[x xy(1,:) NaN];
                            y=[y xy(2,:) NaN];
                        end
                    else
                        if exist(ncfile,'file')
                            xy=nc_varget(ncfile,'xy');
                            x=[x xy(1,:) NaN];
                            y=[y xy(2,:) NaN];
                        end
                    end
                end

            end
        end
        x=double(x);
        y=double(y);
end
