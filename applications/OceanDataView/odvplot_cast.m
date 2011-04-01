function odvplot_cast(D,varargin)
%ODVPLOT_CAST   plot profile view (parameter,z) of ODV file read by ODVREAD (still test project)
%
%   D = odvread(fname)
%
%   odvplot_cast(D)
%
% Example plot function that shows vertical profiles of temperature, salinity, fluorescence.
% It throws a pop-up to indicate which columns to plot.
%
% Works only for profile data, i.e. when D.cast = 1;
%
% Properties can be set with odvplot_cast(D,<keyword,value>)
% call odvplot_cast() with out arguments to get a list of properties.
%
% Note that SeaDataNet also is supposed to suppy netCDF files 
% (instead of these ODV files which are far easier to process (with snctools).
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView, snctools

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl	
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
% $HeadURL
% $Keywords:

   % TO DO: allows automatic choice based on various SDN name parts
   OPT.variable  = '';%'P011::PSALPR02'; % char or numeric: nerc vocab string (P011::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   OPT.z         = 'PRESPS01';
   OPT.index.var = 12;  % plot first non meta-data column if not specified
   OPT.index.z   = [];  % plot last      meta-data column if not specified
   OPT.vc        = 'gshhs_c.nc'; % http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc
   OPT.lon       = [];
   OPT.lat       = [];
   OPT.clim      = [];
   OPT.overlay   = 0;

   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);
   
%% get landboundary

   if isempty(OPT.lon) & isempty(OPT.lat)
   try
      OPT.lon       = nc_varget(OPT.vc,'lon');
      OPT.lat       = nc_varget(OPT.vc,'lat');
   end
   end

%% find column to plot based on sdn_standard_name

   if isempty(OPT.variable)
      [OPT.index.var, ok] = listdlg('ListString', {D.sdn_long_name{10:2:end}} ,...
                          'SelectionMode', 'multiple', ...
                           'InitialValue', [2 3],... % first is likely pressure so suggest 2 others
                           'PromptString', 'Select a set of variables to plot as x-vertex', ....
                                   'Name', 'Selection of x-variable');
      OPT.index.var = OPT.index.var*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D.sdn_standard_name)
         if any(strfind(D.sdn_standard_name{i},OPT.variable))
            OPT.index.var = i;
            break
         end
      end
      if OPT.index.var==0
         error([OPT.variable,' not found.'])
         return
      end
   end
   
%% find column to use as vertical axis

   if isempty(OPT.index.z)
      [OPT.index.z, ok] = listdlg('ListString', {D.sdn_long_name{10:2:end}} ,...
                           'InitialValue', 1,... % first is likely pressure so suggest it
                           'PromptString', 'Select the single variable to ue as y/z-vertex (depth, pressure, ...)', ....
                                   'Name', 'Selection of y/z-variable');
      OPT.index.z = OPT.index.z*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D.sdn_standard_name)
         if any(strfind(D.sdn_standard_name{i},OPT.z));
            OPT.index.z = i;
            break
         end
      end
   end
   
%% plot

   nvar = length(OPT.index.var);
   AX = subplot_meshgrid(nvar+1,1,[.04 repmat(0,[1 nvar-1]) .04 .04],[.1]);
   
   if D.cast==1
   
    for ivar=1:nvar
     axes(AX(ivar)); cla %subplot(1,4,1)
       var.x = str2num(char(D.rawdata{OPT.index.var(ivar),:}));
       var.y = str2num(char(D.rawdata{OPT.index.z        ,:}));
       if ~isempty(var.x)
        plot  (var.x,var.y,'.-')
        set   (gca,'ydir','reverse')
        xlabel([D.local_name{OPT.index.var(ivar)},' [',D.local_units{OPT.index.var(ivar)},']'])
        grid on
        hold on
        plot(xlim,[D.data.bot_depth D.data.bot_depth],'r')
        hold off
        box on
        %if nvar > 1
        % XTickLabel = cellstr(get(AX(ivar),'XTickLabel'));
        % XTickLabel{end} = '';
        % set(AX(ivar),'XTickLabel',XTickLabel);
        %end
        if ~odd(ivar)
         set(gca,'XAxisLocation','top')
        end
        if ivar==1
         ylabel([D.local_name{OPT.index.z        },' [',D.local_units{OPT.index.z        },']'])
        else
         set(gca,'YTickLabel',{})
        end
       else
        cla
        noaxis(AX(ivar))
       end
   
    end

   end       
       
    axes(AX(nvar+1)); cla %subplot(1,4,4)
    
       plot(D.data.longitude,D.data.latitude,'ro')
       hold on
       plot(D.data.longitude,D.data.latitude,'r.')
       axis      tight
       
       plot(OPT.lon,OPT.lat,'k')
       axislat   (52)
       grid       on
       tickmap   ('ll','texttype','text')
       box        on
       hold       off
       
%% add meta-data 

   if OPT.overlay
      AX(nvar+2) = axes('position',get(AX(1),'position'));
      axes(AX(nvar+2)); cla %subplot(1,4,4)
      noaxis(AX(nvar+2))
   else
     axes(AX(1))
   end
       % text rather than titles per subplot, because subplots can be empty
       if D.cast
          txt = ['Cruise: ',D.data.cruise{1},...
                  '   -   Station: ',mktex(D.data.station{1}),' (',num2str(D.data.latitude(1)),'\circE, ',num2str(D.data.longitude(1)),'\circN)',...
                  '   -   ',datestr(D.data.datenum(1),31)];
       else
          txt = ['Cruise: ',D.data.cruise{1}];
       end
       text (0,1,txt,...
                  'units','normalized',...
                  'horizontalalignment','left',...
                  'verticalalignment','bottom')
    %axes(AX(1));
       
%% EOF       
