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

%% Options
XMLmat='off';

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
    if ~isempty(regexpi(ptype,'physical'))
        chapter='Physics';
    elseif ~isempty(regexpi(ptype,'(grid|initial)'))
        chapter='Domain';
    elseif ~isempty(regexpi(ptype,'time'))
        chapter='Time';    
    elseif ~isempty(regexpi(ptype,'(wave|roller)'))
        chapter='Waves';
    elseif ~isempty(regexpi(ptype,'(flow|coriolis|wind|tide|discharge)'))
        chapter='Flow';
    elseif ~isempty(regexpi(ptype,'sediment')) && isempty(regexpi(ptype,'q3d'))
        chapter='Sediment';
    elseif ~isempty(regexpi(ptype,'(morphology|bed\s)'))
        chapter='Morphology';
    elseif ~isempty(regexpi(ptype,'(output|drifter)'))
        chapter='Output';    
    else
        chapter='Additional';
    end 
    if ~isfield(Par.(chapter),ptypevar);
        temp=struct('longname',ptype,'variables',struct());
        Par.(chapter).(ptypevar)=temp;
    end
    vname = genvarname(params_array(i).name,{'vname','ptypevar','Par','params_array','i','chapter'});
    Par.(chapter).(ptypevar).variables.(vname)=params_array(i);
end

% remove useless information from Par
fields=fieldnames(Par.Additional);
for i=1:length(fields)
    if isfield(Par.Additional.(fields{i}),'longname') & ...
                 regexpi(Par.Additional.(fields{i}).longname,'not read in params.txt')
        Par.Additional=rmfield(Par.Additional,fields{i});
    end
end

%% write XML master file

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
% HS.elements.element.tabs(2).tab.callback='ddb_editXBeachDescription';
HS.elements.element.tabs(2).tab.elements='XBeach.description.xml';
fields=fieldnames(Par);
for i=1:length(fields)
    HS.elements.element.tabs(i+2).tab.tag=Par.(fields{i}).longname;
    HS.elements.element.tabs(i+2).tab.tabstring=Par.(fields{i}).longname;
    HS.elements.element.tabs(i+2).tab.elements=['XBeach.' fields{i} '.xml'];
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
xml_save('XBeach.xml',HS,XMLmat);

%% Write XML Toolbox file


%% Write XML description file
DES=struct;
DES.element.tag='editdescription';
DES.element.style='edit';
DES.element.position=[45 10 500 140];
DES.element.variable.name='Description';
DES.element.variable.type='string';
DES.element.tooltipstring='Project description (optional)';
DES.element.nrlines=10;
DES.element.text='Description (max. 10 lines)';
DES.element.textposition='above-left';

xml_save('XBeach.description.xml',DES,XMLmat);

%% Write XML Physics etc. files
index=fieldnames(Par);
for i=1:length(index)
    S=struct;
    S.longname=Par.(index{i}).longname;
    S.element.style='tabpanel';
    S.element.tag=Par.(index{i}).longname;
    S.element.position=[10 10 1200 140];
    POS = {[100  113 100 20];
           [100  88  100 20];
           [100  63  100 20];
           [100  38  100 20];
           [100  13  100 20];
           [400 113 100 20];
           [400 88  100 20];
           [400 63  100 20];
           [400 38  100 20];
           [400 13  100 20];
           [700 113 100 20];
           [700 88  100 20];
           [700 63  100 20];
           [700 38  100 20];
           [700 13  100 20];
           [1000 113 100 20];
           [1000 88  100 20];
           [1000 63  100 20];
           [1000 38  100 20];
           [1000 13  100 20];};
    index2=fieldnames(Par.(index{i}));count=0;
    for ii=1:length(index2)
        if ~strcmpi(index2{ii},'longname')
%             Make tabs in upper layer
            count=count+1;
            S.element.tabs(count).tab.tag=Par.(index{i}).(index2{ii}).longname;
            S.element.tabs(count).tab.tabstring=Par.(index{i}).(index2{ii}).longname;
            % make internal for this part
            index3=fieldnames(Par.(index{i}).(index2{ii}).variables);
            count2=0;
            Sub=struct;
            Sub(1).element.tag='test';% fill with bogus
            Sub(1).element.style='text';
            Sub(1).element.text='empty';
            Sub(1).element.position=POS{1}(1:2);
            for iii=1:length(index3)
                % is this an advanced and is it read in XBeach?
                if Par.(index{i}).(index2{ii}).variables.(index3{iii}).advanced==0 && ...
                   Par.(index{i}).(index2{ii}).variables.(index3{iii}).noinstances>0
                    % element number
                    count2=count2+1;
                    % element tag
                    Sub(count2).element.tag=index3{iii};
                    % element type
                    switch Par.(index{i}).(index2{ii}).variables.(index3{iii}).type(1:4)
                        case 'real'
                            % easy: always an edit field
                             Sub(count2).element.style='edit';
                             Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                             Sub(count2).element.position=POS{count2};
                             Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                             Sub(count2).element.variable.type='real';
                        case 'inte'
                            % is this an on/off switch, or an integer
                            % number?
                            minval=Par.(index{i}).(index2{ii}).variables.(index3{iii}).minval{1};
                            maxval=Par.(index{i}).(index2{ii}).variables.(index3{iii}).maxval{1};
                            if minval==0 && maxval==1
                                Sub(count2).element.style='checkbox';
                                Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                                Sub(count2).element.position=POS{count2}(1:2);
                            else
                                Sub(count2).element.style='edit';
                                Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                                Sub(count2).element.position=POS{count2};
                            end
                            Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                            Sub(count2).element.variable.type='integer';
                        case 'char'
                            % is this a file select option, or a listbox
                            % option?
                            if isempty(Par.(index{i}).(index2{ii}).variables.(index3{iii}).allowed{1})
                                % file
                                Sub(count2).element.style='pushselectfile';
                                Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                                Sub(count2).element.position=POS{count2};
                                Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                                Sub(count2).element.variable.type='character';
                            else
                                % option
                                Sub(count2).element.style='edit';
                                Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                                Sub(count2).element.position=POS{count2};
                                Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                                Sub(count2).element.variable.type='character';
                            end
                            
                        otherwise
                           Sub(count2).element.style='text';
                           Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                           Sub(count2).element.position=POS{count2}(1:2);
                    end
%                     
                    
                end
            end
            S.element.tabs(count).tab.elements=['XBeach.' index{i} '.' index2{ii} '.xml'];
            xml_save(['XBeach.' index{i} '.' index2{ii} '.xml'],Sub,XMLmat);                    
        end
    end
    xml_save(['XBeach.' index{i} '.xml'],S,XMLmat);
end
%             Sub=struct;
%             Sub.longname=Par.(index{i}).(index2{ii}).longname;
            

