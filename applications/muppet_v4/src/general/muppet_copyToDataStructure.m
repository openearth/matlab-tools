function dataset=muppet_copyToDataStructure(dataset,d)

% Determines x coordinate (if necessary)
% Copies data from structure d to dataset structure

%% Plot component
% Compute y value for cross sections
plotcoordinate=[];

switch dataset.plane
    case{'xv','xz','tx'}
%if (shpmat(3)==1 && shpmat(4)>1) || (shpmat(3)>1 && shpmat(4)==1) 
        switch(lower(dataset.plotcoordinate))
            case{'xcoordinate'}
                x=squeeze(d.X);
            case{'ycoordinate'}
                x=squeeze(d.Y);
            case{'pathdistance'}
                x=pathdistance(squeeze(d.X),squeeze(d.Y));
            case{'revpathdistance'}
                x=pathdistance(squeeze(d.X),squeeze(d.Y));
                x=x(end:-1:1);
        end
        plotcoordinate=x;
end

% Set empty values
dataset.x=[];
dataset.x=[];
dataset.y=[];
dataset.z=[];
dataset.xz=[];
dataset.yz=[];
dataset.zz=[];
dataset.u=[];
dataset.v=[];
dataset.w=[];

% 7 planes
% 4 quantities (or more)
% 3 dimensions

switch dataset.plane
    
    case{'xy'}
        % map (top view)
        dataset.x=d.X;
        dataset.y=d.Y;
        if isfield(d,'Units')
            switch d.XUnits
                case{'deg'}
                    dataset.coordinatesystem.name='WGS 84';
                    dataset.coordinatesystem.type='geographic';
            end
        end
        switch dataset.quantity
            case{'scalar','boolean'}
                dataset.z=d.Val;
            case{'grid'}
                dataset.xdam=d.XDam;
                dataset.ydam=d.YDam;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    
    case{'xv'}
        % cross-section 1d
        dataset.x=plotcoordinate;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    
    case{'xz'}
        % cross-section 2d
        dataset.x=plotcoordinate;
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end

    case{'tv'}
        % time series
        dataset.x=d.Time;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end

    case{'tx'}
        % time stack (horizontal)
        [dataset.x,dataset.y]=meshgrid(d.Time,plotcoordinate);
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val';
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end

    case{'tz'}
        % time stack (vertical)
        [dataset.x,dataset.y]=meshgrid(d.Time,d.Z);
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
        

end
