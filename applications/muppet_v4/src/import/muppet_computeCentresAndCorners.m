function dataset=muppet_computeCentresAndCorners(dataset)

% Determine cell centres/corners
switch dataset.type

    case{'scalar2dxy','scalar2dxz'}

        dataset.xz=dataset.x;
        dataset.yz=dataset.y;
        dataset.zz=dataset.z;
                
        if strcmpi(dataset.location,'z')

            % When data is stored in cell centres, load coordinates of cell corners (x and y)
            % and compute values z on cell corners (used for shading and contour plots)
            % When this is not possible (coordinates of cell corners are
            % not available), xz, yz and zz are empty
            % patch plots will (by definition) be shifted by half a grid cell
            
            % First try load the grid          
            xg=[];
            yg=[];

            % xg and yg must be the same size as x and y! In Delft3D it
            % includes the dummy row
            
            % xz, yz and zz must also be the same size!
            
            %% Grid
            if isfield(dataset.fid,'SubType')
                switch dataset.fid.SubType
                    case{'Delft3D-trim'}
                        grd=qpread(dataset.fid,'morphologic grid','griddata',dataset.m,dataset.n);
                        xg=grd.X;
                        yg=grd.Y;                        
                end
            end

            if ~isempty(xg)
                dataset.x=xg;
                dataset.y=yg;
                z(1,:,:)=dataset.zz(1:end-1,1:end-1);
                z(2,:,:)=dataset.zz(2:end,1:end-1);
                z(3,:,:)=dataset.zz(2:end,2:end);
                z(4,:,:)=dataset.zz(1:end-1,2:end);
                z=squeeze(nanmean(z,1));
                dataset.z=zeros(size(dataset.z));
                dataset.z(dataset.z==0)=NaN;
                dataset.z(1:end-1,1:end-1)=z;
                % Also shift zz, so that it will plot properly with pcolor
                % and shading flat
                zz=dataset.zz(2:end,2:end);
                dataset.zz=zeros(size(dataset.zz));
                dataset.zz(dataset.zz==0)=NaN;
                dataset.zz(1:end-1,1:end-1)=zz;
            end
                   
        else
            % When data is stored in cell corners, xz, yz and zz are empty
            % patch plots will (by definition) be shifted by half a grid cell
        end
        
    case{'scalar2duxy'}
        % Read net
        if isempty(dataset.G)
            dataset.G = dflowfm.readNet(dataset.filename,'quiet',1);
        end
end
