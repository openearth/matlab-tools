function schema = nccreateSchema(dimstruct,varstruct,varargin)
%NCCREATESCHEMA  Build a schema to use with matlab native ncwriteschema
%
%   Create dimstruct and varstruct with nccreatevarstruct and
%   nccreatedimstruct
%
%   Syntax:
%   schema = nccreateSchema(dimstruct,varstruct,varargin)
%
%   Input:
%   dimstruct  = Create dimstruct nccreateDimstruct
%   varstruct  = Create dimstruct nccreateVarstruct
%
%   Output:
%   schema     = a netcdf file schema that can be used directly as input for
%                ncwriteschema
%
%   Example:
%
%     % Create an nc with a subgroup
%     % First define dimstruct and varstruct
%     dimstruct        = nccreateDimstruct('Name','x','Length',10);
%     dimstruct(end+1) = nccreateDimstruct('Name','y','Length',10);
%     dimstruct(end+1) = nccreateDimstruct('Name','t','Unlimited',true);
%     varstruct        = nccreateVarstruct('Name','x','Dimensions',{'x'},'scale_factor',10,'Attributes',{'asdasd',1,'asd',2});
%     varstruct(end+1) = nccreateVarstruct('Name','y','Dimensions',{'y'},'Attributes',{'asdasd',1,'asd',2});
%     varstruct(end+1) = nccreateVarstruct('Name','t','Dimensions',{'t'});
%     varstruct(end+1) = nccreateVarstruct('Name','z','Dimensions',{'x','y','t'},'DeflateLevel',2);
%     
%     % put these in a schema
%     schema = nccreateSchema(dimstruct,varstruct,...
%         'Attributes',{'Filetype','Testfile'},'Format','netcdf4');
%     
%     % craete a new dimstruct and varstruct to be used as a subgroup in the
%     % nc file
%     dimstruct   = nccreateDimstruct('Name','x','Length',10);
%     varstruct   = nccreateVarstruct('Name','x','Dimensions',{'x'},'scale_factor',10,'Attributes',{'asdasd',1,'asd',2});
%     
%     groupschema = nccreateSchema(dimstruct,varstruct,...
%         'Attributes',{'Filetype','Testfile'},'Format','netcdf4','Name','group1');
%     
%     schema.Groups = groupschema;
%     
%     % write the nc file with matlab native command
%     ncwriteschema('temp.nc',schema)
%     
%     % read and display schema from nc file
%     var2evalstr(ncinfo('temp.nc'))
%     
%
%   See also: ncwriteschema, nccreateDimstruct, nccreatevarstruct
% 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Mar 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

schema.Filename     = '';
schema.Name         = '/';
schema.Dimensions   = struct;
schema.Variables    = struct;
schema.Attributes   = {};
schema.Groups       = [];
schema.Format       = 'netcdf4'; % netcdf4 or classic

schema = setproperty(schema,varargin);

%% check format
assert(any(strcmpi(schema.Format,{'netcdf4','classic'})),'Format must be either ''netcdf4'' or ''classic''')

%% process dimstruct
% check input
for ii = 1:length(dimstruct)
    dimstruct(ii) = nccreateDimstruct(dimstruct(ii));
end
dimnames = {dimstruct.Name};

% hack to deal with multiple unlimited dimensions
if sum([dimstruct.Unlimited]) > 1
    [dimstruct([dimstruct.Unlimited]).Length]    = deal(inf);
    [dimstruct([dimstruct.Unlimited]).Unlimited] = deal(false);
end
% end of hack

%% process varstruct
% check input
for ii = 1:length(varstruct)
    varstruct(ii) = nccreateVarstruct(varstruct(ii));
end

for ii = 1:length(varstruct)
    % parse dimensions
    for jj = 1:length(varstruct(ii).Dimensions)
        if ischar(varstruct(ii).Dimensions{jj})
            dimid = find(strcmp(dimnames,varstruct(ii).Dimensions{jj}),1);
            if isempty(dimid)
                error('Dimension with name %s not found in dimstruct',varstruct(ii).Dimensions{jj});
            end
            varstruct(ii).Dimensions{jj} = dimid;
        end
    end
    varstruct(ii).Size       = [dimstruct([varstruct(ii).Dimensions{:}]).Length];
    varstruct(ii).Dimensions =  dimstruct([varstruct(ii).Dimensions{:}]);
    
    % parse fill value and check datatype
    varstruct(ii).FillValue  = parseFillValue(...
        varstruct(ii).FillValue,...
        varstruct(ii).Datatype,...
        schema.Format);
    
    % parse atributes
    varstruct(ii).Attributes = parseAttributes(...
        varstruct(ii).Attributes,...
        varstruct(ii).FillValue,...
        varstruct(ii).scale_factor,...
        varstruct(ii).add_offset);
end
varstruct = rmfield(varstruct,{'scale_factor','add_offset'});

schema.Dimensions = dimstruct;
schema.Variables  = varstruct;

schema.Attributes = parseAttributes(schema.Attributes,[],[],[]);

if strcmpi(schema.Format,'classic')
    % netcdf classic format does not support these parameters, so empty them
    [schema.Variables.ChunkSize]    = deal([]);
    [schema.Variables.DeflateLevel] = deal([]);
end

function FillValue = parseFillValue(FillValue,Datatype,Format)
switch lower(Format)
    case 'classic'
        datatypenames = {
            'char'     'NC_FILL_CHAR'
            'double'   'NC_FILL_DOUBLE'
            'single'   'NC_FILL_FLOAT'
            'int8'     'NC_FILL_BYTE'
            'int16'    'NC_FILL_SHORT'
            'int32'    'NC_FILL_INT'
            };
        
        n = strcmpi(Datatype,datatypenames(:,1));
        
        if ~any(n)
            error('Datatype %s is not a valid type. Valid types are:\n%s',Datatype,sprintf('    %s\n',datatypenames{:,1}));
        end
        
        % set _FillValue to empty as it is not supported by netcdf classic
        FillValue = cast([],Datatype);
        
    case 'netcdf4'
        datatypenames = {
            'char'     'NC_FILL_CHAR'
            'double'   'NC_FILL_DOUBLE'
            'single'   'NC_FILL_FLOAT'
            'int8'     'NC_FILL_BYTE'
            'int16'    'NC_FILL_SHORT'
            'int32'    'NC_FILL_INT'
            'int64'    'NC_FILL_INT64'
            'uint8'    'NC_FILL_UBYTE'
            'uint16'   'NC_FILL_USHORT'
            'uint32'   'NC_FILL_UINT'
            'uint64'   'NC_FILL_UINT64'
            };
        
        n = strcmpi(Datatype,datatypenames(:,1));
        
        if ~any(n)
            error('Datatype %s is not a valid type. Valid types are:\n%s',Datatype,sprintf('    %s\n',datatypenames{:,1}));
        end
        
        if isequal(FillValue,'auto')
            FillValue = netcdf.getConstant(datatypenames{n,2});
        end
end
function Attributes = parseAttributes(Attributes,FillValue,scale_factor,add_offset)

if ~isempty(add_offset)
    Attributes = [{'add_offset' add_offset} Attributes];
end
if ~isempty(scale_factor)
    Attributes = [{'scale_factor' scale_factor} Attributes];
end
if ~isempty(FillValue)
    Attributes = [{'_FillValue' FillValue} Attributes];
end
if isempty(Attributes)
    Attributes = [];
else
    Attributes = struct('Name',Attributes(1:2:end),'Value',Attributes(2:2:end));
end

