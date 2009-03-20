function [x2,y2,err]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,CoordinateSystems,ConvTrans,varargin)
%CONVERTCOORDINATES   transformation between coordinate systems
%
% [x2,y2,err]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,CoordinateSystems,ConvTrans,varargin)
%
% Example:
%
% [x,y]=ConvertCoordinates(5,52,'WGS 84','geo','WGS 84 / UTM zone 31N','xy',CoordinateSystems,Operations)
%
% where x,y the values of the coordinates to be transformed.
%       tp* is the type of coordinates to be transformed ('xy' or 'geo')
%       cs* is the name of the coordinate system (field coord_ref_sys_name in CoordinateSystems)
%           which can be selected from CoordinateSystems with SELECTCOORDINATESYSTEM
%       CoordinateSystems struct with data returned by GetCoordinateSystems
%       Operations struct with operatiobns returned by GetCoordinateSystems
%
%See also: SuperTrans = GetCoordinateSystems > SelectCoordinateSystem > ConvertCoordinates

%load('CoordinateSystems.mat');
%load('Operations.mat');
%[x,y]=ConvertCoordinates(5,52,'WGS 84','geo','WGS 84 / UTM zone 31N','xy',CoordinateSystems,Operations)

err=[];

switch tp1,
    case{'xy'}
        i1=findstrinstruct(CoordinateSystems,'coord_ref_sys_name',cs1,'coord_ref_sys_kind','projected');
    case{'geo'}
        i1=findstrinstruct(CoordinateSystems,'coord_ref_sys_name',cs1,'coord_ref_sys_kind','geographic 2D');
        x1=pi*x1/180;
        y1=pi*y1/180;
end
switch tp2,
    case{'xy'}
        i2=findstrinstruct(CoordinateSystems,'coord_ref_sys_name',cs2,'coord_ref_sys_kind','projected');
    case{'geo'}
        i2=findstrinstruct(CoordinateSystems,'coord_ref_sys_name',cs2,'coord_ref_sys_kind','geographic 2D');
end

crs1=CoordinateSystems(i1);
crs2=CoordinateSystems(i2);

ell1=CoordinateSystems(i1).ellipsoid;
if ~isnumeric(ell1.inv_flattening)
    ell1.inv_flattening=ell1.semi_major_axis/(ell1.semi_major_axis-ell1.semi_minor_axis);
end

ell2=CoordinateSystems(i2).ellipsoid;
if ~isnumeric(ell2.inv_flattening)
    ell2.inv_flattening=ell2.semi_major_axis/(ell2.semi_major_axis-ell2.semi_minor_axis);
end

if strcmp(tp1,'xy')
    % Coordinate conversion
    if ~isempty(crs1.projection_conv_code)
        projection_conv_code=crs1.projection_conv_code;
    end
    j=findinstruct(ConvTrans,'coord_op_code',projection_conv_code);
    conv        = ConvTrans(j);
    trfcode     = conv.coord_op_method_code;
    pars        = ConvTrans(j).parameters;
    [x1,y1,err] = ConvertCoords(x1,y1,ell1,trfcode,pars,2);
end

if crs1.source_geogcrs_code~=crs2.source_geogcrs_code
    
    %% Datum Transformation
    
    if ~isempty(varargin)
        
        %% User-defined datum transformation
        
        transcodes     = [NaN NaN];
        ireverse       = [NaN NaN];
        crscode_interm = NaN;

        opname1        = varargin{1};
        ii1            = findstrinstruct(ConvTrans,'coord_op_name',opname1);
        transcodes(1)  = ConvTrans(ii1).coord_op_code;

        if ConvTrans(ii1).source_crs_code~=crs1.source_geogcrs_code
            ireverse1=-1;
        else
            ireverse1=1;
        end        

        if length(varargin)>1
            opname2       = varargin{2};
            ii2           = findstrinstruct(ConvTrans,'coord_op_name',opname2);
            transcodes(2) = ConvTrans(ii2).coord_op_code;
            if ConvTrans(ii2).source_crs_code~=crs2.source_geogcrs_code
                ireverse2 = 1;
                crscode_interm=ConvTrans(ii2).target_crs_code;
            else
                ireverse2 = -1;
                crscode_interm=ConvTrans(ii2).source_crs_code;
            end
        end
        
    else

        %% Default datum transformation

        [transcodes1,transnames1,ireverse1,idef1,transcodes2,transnames2,ireverse2,idef2,crscode_interm]= ...
            FindTransformationOptions(crs1.source_geogcrs_code,crs2.source_geogcrs_code, ...
            CoordinateSystems,ConvTrans);

        if ~isnan(idef1)
            transcodes(1)=transcodes1(idef1);
        else
            transcodes(1)=NaN;
        end
        if ~isnan(idef2)
            transcodes(2)=transcodes1(idef2);
        else
            transcodes(2)=NaN;
        end

    end
    
    if ~isnan(crscode_interm)
        ii=findinstruct(CoordinateSystems,'coord_ref_sys_code',crscode_interm);
        ell2a=CoordinateSystems(ii).ellipsoid;
    else
        ell2a=ell2;
    end
        
    if ~isnan(transcodes(1))
        ii      = findinstruct(ConvTrans,'coord_op_code',transcodes(1));
        pars    = ConvTrans(ii).parameters;
        trfcode = ConvTrans(ii).coord_op_method_code;
        [x1,y1] = TransformDatum(x1,y1,ell1,ell2a,trfcode,pars,ireverse1);
    end

    if ~isnan(transcodes(2))
        ii      = findinstruct(ConvTrans,'coord_op_code',transcodes(2));
        pars    = ConvTrans(ii).parameters;
        trfcode = ConvTrans(ii).coord_op_method_code;
        [x1,y1] = TransformDatum(x1,y1,ell2a,ell2,trfcode,pars,ireverse2);
    end
    
end

if strcmp(tp2,'xy')
    % Coordinate conversion
    if ~isempty(crs2.projection_conv_code)
        projection_conv_code=crs2.projection_conv_code;
    end
    j           = findinstruct(ConvTrans,'coord_op_code',projection_conv_code);
    conv        = ConvTrans(j);
    trfcode     = conv.coord_op_method_code;
    pars        = ConvTrans(j).parameters;
    [x1,y1,err] = ConvertCoords(x1,y1,ell2,trfcode,pars,1);
end

if strcmp(tp2,'geo')
    x2=180*x1/pi;
    y2=180*y1/pi;
else
    x2=x1;
    y2=y1;
end

clear x1 y1
