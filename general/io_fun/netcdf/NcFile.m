classdef NcFile < handle
    %NETCDFFILE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also NetCDFFile.NetCDFFile
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2011 Deltares
    %       Pieter van Geer
    %
    %       pieter.vangeer@deltares.nl
    %
    %       Rotterdamseweg 185
    %       2629 HD Delft
    %       P.O. 177
    %       2600 MH Delft
    %
    %   This library is free software: you can redistribute it and/or
    %   modify it under the terms of the GNU Lesser General Public
    %   License as published by the Free Software Foundation, either
    %   version 2.1 of the License, or (at your option) any later version.
    %
    %   This library is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %   Lesser General Public License for more details.
    %
    %   You should have received a copy of the GNU Lesser General Public
    %   License along with this library. If not, see <http://www.gnu.org/licenses/>.
    %   --------------------------------------------------------------------
    
    % This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
    % OpenEarthTools is an online collaboration to share and manage data and
    % programming tools in an open source, version controlled environment.
    % Sign up to recieve regular updates of this function, and to contribute
    % your own tools.
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 30 Sep 2011
    % Created with Matlab version: 7.12.0.635 (R2011a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        FileName;
        Format;
    end
    properties (Dependent = true)
        Attributes;
        Dimensions;
        Variables;
    end
    
    properties (Hidden = true)
       Verbose = true; 
    end
    properties (Hidden = true, SetAccess = private)
       attributes;
       dimensions;
       variables;
    end
    
    %% Methods
    methods
        %% Constructor
        function this = NcFile(url, varargin)
            %NETCDFFILE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = NetCDFFile(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "NetCDFFile"
            %
            %   Example
            %   NetCDFFile
            %
            %   See also NcFile
            
            %% Check url
            if nargin < 1 || ~ischar(url)
                error('NcFile:InvalidPath','Could not find or create an nc file. Please specify a valid filename as first input argument');
            end
            
            %% Retrieve verbose settings from input
            id = strncmpi(varargin,'verbose',4);
            if ~isempty(id)
                this.Verbose = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Set url
            this.seturl(url,varargin{:});
            
            %% Get info
            this.setinfo();
        end
        
        %% Get methods
        function value = get.Attributes(this)
            if ~isempty(this.attributes)
                value = this.attributes;
                return;
            end
            
            info = nc_info(this.FileName);
            this.attributes = info.Attribute;
        end
        function value = get.Dimensions(this)
            if ~isempty(this.dimensions)
                value = this.dimensions;
                return;
            end
            
            info = nc_info(this.FileName);
            this.dimensions = NcDimension(this.FileName,info.Dimension);
        end
        function value = get.Variables(this)
            if ~isempty(this.variables)
                value = this.variables;
                return;
            end
            
            info = nc_info(this.FileName);
            this.variables = NcVariable(this.FileName,info.Dataset,this.Dimensions);
        end
        
        %% Retrieve methods
        function variable = getvariable(this,name)
            for i = 1:length(this.Variables)
                if strcmp(this.Variables(i).Name,name)
                    variable = this.Variables(i);
                    return;
                end
            end
            error('NcFile:NoVariable',['No variable with such a name (' name ')']);
        end
        function dimension = getdimension(this,name)
            dimension = this.Dimensions(ismember({this.Dimensions.Name}',name));
            if isempty(dimension)
                error('NcFile:NoDimension',['No dimension with such a name (' name ')']);
            end
        end
        function attributeValue = getattributevalue(this,name)
            attribute = this.Attributes(ismember(({this.Attributes.Name}'),name));
            if isempty(attribute)
                error('NcFile:NoAttribute',['No attribute with such a name (' name ')']);
            end
            attributeValue = attribute.Value;
        end
    end
    methods (Hidden = true)
        function this = seturl(this,url,varargin)
            %% Try to find file or url
            urlConnection = urlreadwrite('NetCDFFile',url);
            urlConnectionSuccessfull = (~isempty(urlConnection) && ~isempty(urlConnection.getContentType));
            if urlConnectionSuccessfull || exist(url,'file')
                this.FileName = url;
                return;
            end

            if ~urlConnectionSuccessfull && strncmpi(url,'http',4)
                error('NetCDFFile:InvalidUrl',['The specified file location (' url ') appears to be an url, but was not valid']);
            end
                
            %% CReate file
            try 
                nc_create_empty(url,varargin{:});
                this.FileName = url;
                if this.Verbose
                    display(['Created a new NetCDF file at location: ' this.FileName]);
                end
                
            catch me
                error('NetCDFFile:InvalidFileName',['The specified file (' url ') could not be created']);
            end 
        end
        function this = setinfo(this)
            info = nc_info(this.FileName);
            this.Format = info.Format;
            this.attributes = info.Attribute;
            this.dimensions = NcDimension(this.FileName,info.Dimension);
            this.variables = NcVariable(this.FileName,info.Dataset,this.dimensions);
        end
    end
end

%% Private functions
function [urlConnection,errorid,errormsg] = urlreadwrite(fcn,urlChar)
%URLREADWRITE A helper function for URLREAD and URLWRITE.

%   Matthew J. Simoneau, June 2005
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision$ $Date$

% Default output arguments.
urlConnection = [];
errorid = '';
errormsg = '';

% Determine the protocol (before the ":").
protocol = urlChar(1:find(urlChar==':', 1,'first' )-1);

% Try to use the native handler, not the ice.* classes.
switch protocol
    case 'http'
        try
            handler = sun.net.www.protocol.http.Handler;
        catch exception %#ok
            handler = [];
        end
    case 'https'
        try
            handler = sun.net.www.protocol.https.Handler;
        catch exception %#ok
            handler = [];
        end
    otherwise
        handler = [];
end

% Create the URL object.
try
    if isempty(handler)
        url = java.net.URL(urlChar);
    else
        url = java.net.URL([],urlChar,handler);
    end
catch exception %#ok
    errorid = ['MATLAB:' fcn ':InvalidUrl'];
    errormsg = 'Either this URL could not be parsed or the protocol is not supported.';
    return
end

% Get the proxy information using MathWorks facilities for unified proxy
% preference settings.
mwtcp = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create();
proxy = mwtcp.getProxy(); 


% Open a connection to the URL.
if isempty(proxy)
    urlConnection = url.openConnection;
else
    urlConnection = url.openConnection(proxy);
end
end
