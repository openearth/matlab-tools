function ddb_xbeachsource2XML
%DDB_XBEACHSOURCE2XML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_xbeachsource2XML
%
%   Input:

%
%
%
%
%   Example
%   ddb_xbeachsource2XML
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl	
%
%       Rotterdamseweg 185
%       Delft
%       The Netherlands
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
% Created: 13 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%


%% Read XBeach source code
% normal input
[par params_array] = xb_get_params;

% rearrange to format for DDB
Par=struct('Physics',struct,...
           'Domain',struct',...
           'Time',struct,...
           'Waves',struct,...
           'Flow',struct,...
           'Sediment',struct,...
           'Morphology',struct,...
           'Output',struct,...
           'Additional',struct);
Par.Physics.longname='Model physics';
Par.Domain.longname='Model domain';
Par.Time.longname='Model time parameters';
Par.Waves.longname='Wave input';
Par.Flow.longname='Flow input';
Par.Sediment.longname='Sediment input';
Par.Morphology.longname='Morphology input';
Par.Output.longname='Output options';
Par.Additional.longname='Additional options';

for i=1:length(params_array)
    ptype=params_array(i).partype;
    ptypevar=genvarname(ptype,{'ptype','ptypevar','Par','params_array','i'});
    if regexpi(ptype,'physical')
        chapter='Physics';
    elseif regexpi(ptype,'(grid|initial)')
        chapter='Domain';
    elseif regexpi(ptype,'time')
        chapter='Time';    
    elseif regexpi(ptype,'(wave|roller)')
        chapter='Waves';
    elseif regexpi(ptype,'(flow|coriolis|wind|tide|discharge)')
        chapter='Flow';
    elseif regexpi(ptype,'sediment')
        chapter='Sediment';
    elseif regexpi(ptype,'(morphology|bed\s)')
        chapter='Morphology';
    elseif regexpi(ptype,'(output|drifter)')
        chapter='Output';    
    else
        chapter='Additional';
    end 
    if ~isfield(Par.(chapter),ptypevar);
        temp=struct('fullname',ptype,'variables',struct());
        Par.(chapter).(ptypevar)=temp;
    end
    vname = genvarname(params_array(i).name,{'vname','ptypevar','Par','params_array','i','chapter'});
    Par.(chapter).(ptypevar).variables.(vname)=params_array(i);
end

% remove useless information from Par
fields=fieldnames(Par.Additional);
for i=1:length(fields)
    if isfield(Par.Additional.(fields{i}),'fullname') & ...
                 regexpi(Par.Additional.(fields{i}).fullname,'not read in params.txt')
        Par.Additional=rmfield(Par.Additional,fields{i});
    end
end

%% write XML sections file

HS = struct;
HS.model='XBeach';
HS.longname='XBeach';
HS.elements.element.style='tabpanel';
HS.elements.element.tag='XBeach';
HS.elements.element.position=[10 10 900 700];
HS.elements.element.tabs(1).tab.tag='Toolbox';
HS.elements.element.tabs(1).tab.tabstring='Toolbox';
HS.elements.element.tabs(1).tab.callback='ddb_selectToolbox';
HS.elements.element.tabs(2).tab.tag='Description';
HS.elements.element.tabs(2).tab.tabstring='Description';
HS.elements.element.tabs(2).tab.callback='ddb_editXBeachDescription';
fields=fieldnames(Par);
for i=1:length(fields)
    HS.elements.element.tabs(i+2).tab.tag=Par.(fields{i}).longname;
    HS.elements.element.tabs(i+2).tab.tabstring=Par.(fields{i}).longname;
    HS.elements.element.tabs(i+2).tab.callback='ddb_editXBeachDescription';
end
HS.menu.menuopenfile.menuitem.string='Open Params File';
HS.menu.menuopenfile.menuitem.callback='ddb_editXBeachDescription';
HS.menu.menuopenfile.menuitem.option='open';
HS.menu.menusavefile(1).menuitem.string='Save Params File';
HS.menu.menusavefile(1).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(1).menuitem.option='save';
HS.menu.menusavefile(2).menuitem.string='Save Params File As ...';
HS.menu.menusavefile(2).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(2).menuitem.option='save';
HS.menu.menusavefile(3).menuitem.string='Save All';
HS.menu.menusavefile(3).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(3).menuitem.option='save';
HS.menu.menusavefile(4).menuitem.string='Save All As ...';
HS.menu.menusavefile(4).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(4).menuitem.option='save';

% save to file
xml_save('XBeach.xml',HS,'off');

