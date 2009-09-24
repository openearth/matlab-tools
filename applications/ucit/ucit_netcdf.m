function varargout = ucit_netcdf(varargin)
%UCIT   gui-based utility for the McToolbox
%
% UCIT loads a GUI for coastal analysis.
%
%See also: 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

   % $Id$ 
   % $Date$
   % $Author$
   % $Revision$
   

%% Open the UCIT console
% ------------------------
   fig = UCIT_makeUCITConsole; set(fig,'visible','off')
 
   %% Use system color scheme for figure:
   set(fig,'name','UCIT 2.0 - Universal Coastal Intelligence Toolkit (based on NetCDF)')
   set(fig,'Units','normalized')
   set(fig,'Position', UCIT_getPlotPosition('LR'))
   
   %% Generate a structure of handles to pass to callbacks, and store it. 
   handles = guihandles(fig);
   guidata(fig, handles);
   
   if nargout > 0
       varargout{1} = fig;
   end
   
   
   %% Initialise datafields 
   %% reset all 4 popup values for both types (1: transects, 2: grids)
   UCIT_DC_resetValuesOnPopup(1,1,1,1,1,1)
   UCIT_DC_resetValuesOnPopup(2,1,1,1,1,1)
   UCIT_DC_resetValuesOnPopup(3,1,1,1,1,1)
   UCIT_DC_resetValuesOnPopup(4,1,1,1,1,1)
   
   %% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   disp('finding available transect data ...')
   
       UCIT_DC_loadRelevantInfo2Popup(1,1)
   
   
   %% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   disp('finding available grid data ...')
   try
       UCIT_DC_loadRelevantInfo2Popup(2,1)
   end
   
   %% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   disp('finding available line data ...')
   try
       UCIT_DC_loadRelevantInfo2Popup(3,1)
   end
   
   %% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   disp('finding available point data ...')
   try
       UCIT_DC_loadRelevantInfo2Popup(4,1)
   end
   
   set(fig,'visible','on');
   
   % change icon   
   figure(fig);icon(101, get(fig,'name'), which('Deltares_logo_32x32.ico'));
   