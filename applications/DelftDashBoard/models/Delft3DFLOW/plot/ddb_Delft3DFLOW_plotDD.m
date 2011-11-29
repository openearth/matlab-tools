function handles = ddb_Delft3DFLOW_plotDD(handles, opt, varargin)
%DDB_DELFT3DFLOW_PLOTDD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_Delft3DFLOW_plotDD(handles, opt, varargin)
%
%   Input:
%   handles  =
%   opt      =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_Delft3DFLOW_plotDD
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

vis=1;
act=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                act=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old dd boundaries
        if isfield(handles.Model(imd),'DDplotHandles')
            if ~isempty(handles.Model(imd).DDplotHandles)
                try
                    delete(handles.Model(imd).DDplotHandles);
                end
            end
        end
        
        % Plot new boundaries
        ddbound=handles.Model(imd).DDBoundaries;
        if ~isempty(ddbound)
            handles.Model(imd).DDplotHandles=[];
            for i=1:length(ddbound)
                z=zeros(size(ddbound(i).x))+1000;
                plt=plot(ddbound(i).x,ddbound(i).y);
                set(plt,'LineWidth',3,'Color',[1 0.5 0],'Tag','ddboundaries');
                handles.Model(imd).DDplotHandles(i)=plt;
            end
        end
        
    case{'delete'}
        
        % Delete old dd boundaries
        if isfield(handles.Model(imd),'DDplotHandles')
            if ~isempty(handles.Model(imd).DDplotHandles)
                try
                    delete(handles.Model(imd).DDplotHandles);
                end
            end
        end
        
    case{'update'}
        if isfield(handles.Model(imd),'DDplotHandles')
            if ~isempty(handles.Model(imd).DDplotHandles)
                try
                    if act
                        set(handles.Model(imd).DDplotHandles,'Visible','on');
                    else
                        set(handles.Model(imd).DDplotHandles,'Visible','off');
                    end
                end
            end
        end
end

