function varstruct = nccreateVarstruct_crs(EPSGcode,varargin)
%NCCREATEVARSTRUCT  Subsidiary of nccreateSchema to create cf compliant crs variable
OPT = nccreateVarstruct;
OPT.Name     = 'crs';
OPT.Datatype = 'int16';

OPT = setproperty(OPT,varargin);

Attributes = get_Attributes_from_epsgcode(EPSGcode);
OPT.Attributes = [OPT.Attributes Attributes];
varstruct = nccreateVarstruct(OPT);


function Attributes = get_Attributes_from_epsgcode(EPSGcode)
[~,~,OPT] = convertCoordinates([],[],'persistent','CS1.code',EPSGcode,'CS2.code',4326);

Attributes = [];
if isequal(OPT.datum_trans,'no transformation required');
    Attributes.grid_mapping_name  = 'latitude_longitude';
else
    Attributes.grid_mapping_name  = strrep(lower(OPT.proj_conv1.method.name),' ','_');
end
Attributes.semi_major_axis    = OPT.CS1.ellips.semi_major_axis;
Attributes.semi_minor_axis    = OPT.CS1.ellips.semi_minor_axis;
Attributes.inverse_flattening = OPT.CS1.ellips.inv_flattening;

if isequal(OPT.datum_trans,'no transformation required');
else
    for ii = 1:length(OPT.proj_conv1.param.name)
        attname = OPT.proj_conv1.param.name{ii};
        attname = lower(attname);
        attname = strrep(attname,' ','_');
        attname = strrep(attname,'natural','projection');
        Attributes.(attname)= OPT.proj_conv1.param.value(ii);
    end
end

Attributes.proj4_params   = epsg_proj4(EPSGcode);
Attributes.esri_pe_string = epsg_wkt(EPSGcode);
Attributes.EPSG_code      = sprintf('EPSG:%d',EPSGcode);

Attributes = reshape([fieldnames(Attributes) struct2cell(Attributes)]',1,[]);

