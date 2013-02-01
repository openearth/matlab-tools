function dataset=muppet_copyToDataStructure(dataset,d,shpmat)

%% Plot component
% Compute y value for cross sections
plotcoordinate=[];
if (shpmat(3)==1 && shpmat(4)>1) || (shpmat(3)>1 && shpmat(4)==1) 
        switch(lower(dataset.xcoordinate))
            case{'x'}
                x=squeeze(d.X);
            case{'y'}
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

for ii=1:5    
    shpstr(ii)=num2str(shpmat(ii));
end
switch shpstr
    case{'21000','21001','20110','20111'}
        dataset.type='timeseries';
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
    case{'21002','20112'}
        dataset.type='timestack';
        dataset.x=d.Time;
        dataset.y=d.Z;
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
    case{'11002','10112'}
        % Profile
        dataset.type='xy';
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.x=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    case{'20212','20122'}
        dataset.type='timestack';
        dataset.x=d.Time;
        dataset.y=plotcoordinate;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'10220','10221','00220','00221'}
        dataset.type='map2d';
        dataset.x=d.X;
        dataset.y=d.Y;
        switch d.XUnits
            case{'deg'}
                dataset.coordinatesystem.name='WGS 84';
                dataset.coordinatesystem.type='geographic';
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
    case{'10212','10122','00212','00122'}
        dataset.type='crossection2d';
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
    case{'10210','10120','00210','00120','10211','10121','00211','00121'}
        dataset.type='crossection1d';
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
end
