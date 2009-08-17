function varargout=SelectCoordinateSystem(CoordinateSystems,tp,varargin)
%SELECTCOORDINATESYSTEM   GUI to pick xy or loglat coordinate system from database
%
% [CS,ok]=SelectCoordinateSystem(CoordinateSystems,tp,<cs0>)
%
% launches GUI from which you can select a CoordinateSystem where:
% tp is the type of coordinates to be transformed 
%           ('cartesian' or 'xy' for projected Eastings/Northings, otherwise Latitude/Longitude)
% CS is the field coord_ref_sys_name of the selection made from the CoordinateSystems 
%           struct that was returned by GETCOORDINATESYSTEMS. (e.g.)
% cs0 is the coordinate system that is pre-selected in
%           in the GUI (default 'Amersfoort / RD New')
%
% Note that a coordinate system can also be selected manually, to facilitate
% batch processing, for example
%
%    index = findinstruct   (CoordinateSystems,'coord_ref_sys_code',28992)
%    index = findstrinstruct(CoordinateSystems,'coord_ref_sys_name','Amersfoort / RD New')
%    CS    = CoordinateSystems(index).coord_ref_sys_name
%
%See also: SuperTrans = GetCoordinateSystems > SelectCoordinateSystem > ConvertCoordinates

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl	
%
%       Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:$

% 2009 mar 31: added documentation [Gerben de Boer]

   %% Initialize
   %------------------------------------------

   handles.ok=0;
   
   if nargin>2
      cs0=varargin{1};
   else
      cs0='Amersfoort / RD New';
   end
   handles.CS=cs0;
   
   %% Fill GUI list
   %------------------------------------------
   nproj=0;
   ngeo =0;
   for i=1:length(CoordinateSystems)
       switch lower(CoordinateSystems(i).coord_ref_sys_kind),
           case{'projected'}
               nproj                  = nproj+1;
               handles.CSProj(nproj)  = CoordinateSystems(i);
               handles.StrProj{nproj} = handles.CSProj(nproj).coord_ref_sys_name;
           case{'geographic 2d'}
               ngeo                   = ngeo+1;
               handles.CSGeo(ngeo)    = CoordinateSystems(i);
               handles.StrGeo{ngeo}   = handles.CSGeo(ngeo).coord_ref_sys_name;
       end
   end
   
   handles.Window   = MakeNewWindow('Select Coordinate System',[400 480]);
   handles.SelectCS = uicontrol(gcf,'Style','listbox','String','','Position', [ 30 70 340 390],'BackgroundColor',[1 1 1]);
   
   if strcmpi(tp,'cartesian') | strcmpi(tp,'xy') % same as ConvertCoordinates.m
       set(handles.SelectCS,'String',handles.StrProj);
       ii=strmatch(cs0,handles.StrProj,'exact');
   else
       set(handles.SelectCS,'String',handles.StrGeo);
       ii=strmatch(cs0,handles.StrGeo,'exact');
   end
   if ~isempty(ii)
       set(handles.SelectCS,'Value',ii);
   end
   
   handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK'    ,'Position', [ 320 30 50 20]);
   handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 260 30 50 20]);
   
   set(handles.PushOK,     'CallBack',{@PushOK_CallBack});
   set(handles.PushCancel, 'CallBack',{@PushCancel_CallBack});
   
   pause(0.2);
   
   guidata(gcf,handles);
   uiwait;
   handles=guidata(gcf);
   
   if handles.ok
       ok = 1;
       CS = handles.CS;
   else
       ok = 0;
       CS = cs0;
   end    
   close(gcf);
   
   if nargout==1
      varargout = {CS};
   else
      varargout = {CS,ok};
   end
   
   %%------------------------------------------
   function PushOK_CallBack(hObject,eventdata)
   handles    = guidata(gcf);
   str        = get(handles.SelectCS,'String');
   ii         = get(handles.SelectCS,'Value');
   handles.CS = str{ii};
   handles.ok = 1;
   guidata(gcf,handles);
   uiresume;
   
   %%------------------------------------------
   function PushCancel_CallBack(hObject,eventdata)
   uiresume;

%% EOF