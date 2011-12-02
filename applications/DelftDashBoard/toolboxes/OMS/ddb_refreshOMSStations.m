function ddb_refreshOMSStations(handles)
%DDB_REFRESHOMSSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_refreshOMSStations(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_refreshOMSStations
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
iac=handles.Toolbox(tb).ActiveStation;

omsparameters={'hs','tp','wavdir','wl'};

set(handles.GUIHandles.ListOMSStations,'Value',iac);

if handles.Toolbox(tb).NrStations==0
    for i=1:length(omsparameters)
        set(handles.GUIHandles.PlotCmp(i),'Value',0,'Enable','off');
        set(handles.GUIHandles.PlotObs(i),'Value',0,'Enable','off');
        set(handles.GUIHandles.PlotPrd(i),'Value',0,'Enable','off');
        set(handles.GUIHandles.ObsSrc(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.ObsID(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.PrdSrc(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.PrdID(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    end
    set(handles.GUIHandles.StoreSP2,'Value',0,'Enable','off');
    set(handles.GUIHandles.SP2id,'String','','BackgroundColor',[0.8 0.8 0.8],'Enable','off');
    set(handles.GUIHandles.SelectType,'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
end

if handles.Toolbox(tb).NrStations>0
    for i=1:length(omsparameters)
        set(handles.GUIHandles.PlotCmp(i),'Value',handles.Toolbox(tb).Stations(iac).Parameters(i).PlotCmp,'Enable','on');
        set(handles.GUIHandles.PlotObs(i),'Value',handles.Toolbox(tb).Stations(iac).Parameters(i).PlotObs,'Enable','on');
        set(handles.GUIHandles.PlotPrd(i),'Value',handles.Toolbox(tb).Stations(iac).Parameters(i).PlotPrd,'Enable','on');
        if handles.Toolbox(tb).Stations(iac).Parameters(i).PlotObs
            set(handles.GUIHandles.ObsSrc(i),'String',handles.Toolbox(tb).Stations(iac).Parameters(i).ObsSrc,'Enable','on','BackgroundColor',[1 1 1]);
            set(handles.GUIHandles.ObsID(i), 'String',handles.Toolbox(tb).Stations(iac).Parameters(i).ObsID, 'Enable','on','BackgroundColor',[1 1 1]);
        else
            set(handles.GUIHandles.ObsSrc(i),'String','','BackgroundColor',[0.8 0.8 0.8],'Enable','off');
            set(handles.GUIHandles.ObsID(i), 'String','', 'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
        end
        if handles.Toolbox(tb).Stations(iac).Parameters(i).PlotPrd
            set(handles.GUIHandles.PrdSrc(i),'String',handles.Toolbox(tb).Stations(iac).Parameters(i).PrdSrc,'Enable','on','BackgroundColor',[1 1 1]);
            set(handles.GUIHandles.PrdID(i), 'String',handles.Toolbox(tb).Stations(iac).Parameters(i).PrdID, 'Enable','on','BackgroundColor',[1 1 1]);
        else
            set(handles.GUIHandles.PrdSrc(i),'String','','BackgroundColor',[0.8 0.8 0.8],'Enable','off');
            set(handles.GUIHandles.PrdID(i), 'String','', 'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
        end
    end
    
    set(handles.GUIHandles.StoreSP2,'Value',handles.Toolbox(tb).Stations(iac).StoreSP2,'Enable','on');
    set(handles.GUIHandles.SP2id,'String',handles.Toolbox(tb).Stations(iac).SP2id);
    if handles.Toolbox(tb).Stations(iac).StoreSP2
        set(handles.GUIHandles.SP2id,'BackgroundColor',[1 1 1],'Enable','on');
    else
        set(handles.GUIHandles.SP2id,'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
    end
    
    str=get(handles.GUIHandles.SelectType,'String');
    ii=strmatch(handles.Toolbox(tb).Stations(iac).Type,str,'exact');
    set(handles.GUIHandles.SelectType,'Value',ii,'BackgroundColor',[1 1 1],'Enable','on');
    
end



