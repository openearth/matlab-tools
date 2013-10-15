function spiderweb_coordinate_converter(spw_file,epsg_code_in,epsg_code_out,varargin)
%SPIDERWEB_COORDINATE_CONVERTER
%
% spiderweb_coordinate_converter converts Delft3D spiderweb wind files
% to different coordinate systems with help from the OET function 
% ConvertCoordinates.
%
% Supported types of coordinate systems are 'projected' (x,y) and 
% 'Geographic 2D' (lon,lat)
% 
%      spiderweb_coordinate_converter(spw_file,epsg_code_in,epsg_code_out)
%
% In which
%
%    spw_file      = String defining the name or location of a spw file
%    epsg_code_in  = Epsg code (number) defining the coordinate system of 
%                    the input spw file
%    epsg_code_out = Epsg code (number) defining the coordinate system for
%                    the output spw file
%
% spiderweb_coordinate_converter converts spw_file with its coordinate
% system defined by epsg_code_in to a spw file with its coordinate system
% defined by epsg_code_out.
%
% To get a list of all possible epsg codes, simply call a fourth argument
% 'epsg codes', it does not matter what the first 3 variables are,
% they are ignored and no conversion is carried out. Also have a look at 
% <a href="http://www.epsg-registry.org">www.epsg-registry.org</a> or call EPSG=load('EPSG.mat') for more info on epsg codes
%
%
% Example 1:
%
%      spiderweb_coordinate_converter('D:\model\test.spw',4326,32631);
% Or e.g.:
%      spiderweb_coordinate_converter('test_WGS_84_UTM_zone_31N.spw',32631,4326);
%
% Note that code 4326 is 'WGS 84' and code 32631 is 'WGS 84 / UTM zone 31N'    
%
%
% Example 2:
%
%      spiderweb_coordinate_converter(0,0,0,'epsg codes');
%
% Supplies a list of all possible epsg codes for spiderweb_coordinate_converter
%
% See also: ConvertCoordinates, EPSG.mat

% Freek Scheel
% Deltares
% +31 (0)88 335 8241
% freek.scheel@deltares.nl
%
% Please contact me if bugs are encountered

if length(varargin)==1
    if strcmp(varargin,'epsg codes')==1
        EPSG = load('EPSG');
        inds = sort([find(strcmp(EPSG.coordinate_reference_system.coord_ref_sys_kind,'projected')==1) find(strcmp(EPSG.coordinate_reference_system.coord_ref_sys_kind,'geographic 2D')==1)]');
        disp([repmat('Epsg code = ',size(inds,1),1) num2str(EPSG.coordinate_reference_system.coord_ref_sys_code(inds)') repmat(' --> Projection = ',size(inds,1),1) char({EPSG.coordinate_reference_system.coord_ref_sys_kind{inds}}') repmat(' --> Name = ',size(inds,1),1) char({EPSG.coordinate_reference_system.coord_ref_sys_name{inds}}')])
        return
    else
        error('Unknow 4th input parameter, script has ended')
    end
elseif length(varargin)>1
    error('too many input parameters')
end

if isstr(spw_file)~=1
    error('Please specify the location of the spw file using a string')
end

if ~isnumeric(epsg_code_in)
    error('Please specify epsg_code_in using a number')
elseif (~(min(size(epsg_code_in))==max(size(epsg_code_in)))) | (max(size(epsg_code_in))>1) | isnan(epsg_code_in)
    error('Please specify epsg_code_in using a single number')
end

if ~isnumeric(epsg_code_out)
    error('Please specify epsg_code_out using a number')
elseif (~(min(size(epsg_code_out))==max(size(epsg_code_out)))) | (max(size(epsg_code_out))>1) | isnan(epsg_code_out)
    error('Please specify epsg_code_out using a single number')
end

if isempty(strfind(spw_file,filesep))
    spw_file = [pwd filesep spw_file];
end

if exist(spw_file)~=2
    error('Spiderweb file not found, please check...')
end

disp(' ');

EPSG = load('EPSG');

try
    coord_in  = EPSG.coordinate_reference_system.coord_ref_sys_name{1,find(EPSG.coordinate_reference_system.coord_ref_sys_code==epsg_code_in)};
catch
    error('Unknown epsg input code');
end

try
    coord_out = EPSG.coordinate_reference_system.coord_ref_sys_name{1,find(EPSG.coordinate_reference_system.coord_ref_sys_code==epsg_code_out)};
catch
    error('Unknown epsg output code');
end

coord_in_type  = EPSG.coordinate_reference_system.coord_ref_sys_kind{1,find(EPSG.coordinate_reference_system.coord_ref_sys_code==epsg_code_in)};
coord_out_type = EPSG.coordinate_reference_system.coord_ref_sys_kind{1,find(EPSG.coordinate_reference_system.coord_ref_sys_code==epsg_code_out)};

if ~((strcmp(coord_in_type,'projected') | strcmp(coord_in_type,'geographic 2D')) & (strcmp(coord_out_type,'projected') | strcmp(coord_out_type,'geographic 2D')))
    error('Only ''projected'' or ''geographic 2D'' systems are supported, please specify other coordinate systems');
end

disp(['Converting spiderweb ''' spw_file((max(strfind(spw_file,filesep))+1):end) ''' from ''' coord_in ''' to ''' coord_out '''...']);
disp(' ');

spw_file_contents = textread(spw_file,'%s','delimiter','\n');
spw_file_contents_new = spw_file_contents;

x_inds = find(strncmp(spw_file_contents,'x_spw_eye',9)==1);
y_inds = find(strncmp(spw_file_contents,'y_spw_eye',9)==1);

grid_unit_ind = find(strncmp(spw_file_contents,'grid_unit',9)==1);

if length(x_inds)~=length(y_inds)
    error('Inconsistency in spw-file')
elseif length(x_inds)==0
    error('No data found in spiderweb using keyword x_spw_eye and y_spw_eye, please check the spiderweb file');
end

if length(grid_unit_ind)>1
    error('Keyword grid_unit was found more than once, please check the spiderweb file');
elseif length(grid_unit_ind)==0
    error('No data found in spiderweb using keyword grid_unit, please check the spiderweb file');
end

for ii=1:length(x_inds)
    x_locs_in(ii,1) = str2double(spw_file_contents{x_inds(ii)}(1,cell2mat(strfind(spw_file_contents(x_inds(ii),1),'='))+1:end));
    y_locs_in(ii,1) = str2double(spw_file_contents{y_inds(ii)}(1,cell2mat(strfind(spw_file_contents(y_inds(ii),1),'='))+1:end));
end

[x_locs_out,y_locs_out]=convertCoordinates(x_locs_in,y_locs_in,'CS1.code',epsg_code_in,'CS2.code',epsg_code_out);

for ii=1:length(x_inds)
    spw_file_contents_new{x_inds(ii)} = [spw_file_contents{x_inds(ii)}(1,1:cell2mat(strfind(spw_file_contents(x_inds(ii),1),'='))) ' ' num2str(x_locs_out(ii,1))];
    spw_file_contents_new{y_inds(ii)} = [spw_file_contents{y_inds(ii)}(1,1:cell2mat(strfind(spw_file_contents(y_inds(ii),1),'='))) ' ' num2str(y_locs_out(ii,1))];
end

if strcmp(coord_in_type,coord_out_type)==0
    if strcmp(coord_out_type,'geographic 2D')
        spw_file_contents_new{grid_unit_ind} = [spw_file_contents{grid_unit_ind}(1:strfind(spw_file_contents{grid_unit_ind},'=')) ' degree'];
    elseif strcmp(coord_out_type,'projected')
        spw_file_contents_new{grid_unit_ind} = [spw_file_contents{grid_unit_ind}(1:strfind(spw_file_contents{grid_unit_ind},'=')) ' m'];
    else
        error('The type of output coordinate system is not supported');
    end
end

disp(['Succesfully converted spiderweb file to ' coord_out_type ' coordinate system ''' coord_out '''...'])
disp(' ');
fid = fopen([spw_file(1:(max(strfind(spw_file,filesep)))) spw_file((max(strfind(spw_file,filesep))+1):end-4) '_to_' strrep(strrep(strrep(strrep(coord_out,' ','_'),'/',''),'\',''),'__','_') '.spw'],'w+');

disp('Please wait,');
disp(['Writing results to spiderweb file ''' spw_file((max(strfind(spw_file,filesep))+1):end-4) '_to_' strrep(strrep(strrep(strrep(coord_out,' ','_'),'/',''),'\',''),'__','_') '.spw...'''])
disp(' ');

fprintf(fid,'%s\n',spw_file_contents_new{:});

fclose(fid);

disp('Done! Succesfully stored the spiderweb file');
disp(['File can be found in ''' spw_file(1:(max(strfind(spw_file,filesep)))) '''']);

end