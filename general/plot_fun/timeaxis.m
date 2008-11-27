function varargout = timeaxis(tlim,varargin)
%TIMEAXIS   sets lim and tick for a time axis
%
% timeaxis(ttick)        % tlim is a vector (can be irregular)
% timeaxis(ttick,[])     % same
% timeaxis(tlim ,nt)     % tlim is a 2 element vector
%                        % nt is the number if INTERVALS
% timeaxis(tlim ,nt,fmt) % see datestr for fmt format options
%                        % default 0. For character formats use a cellstring.
%                        % [] for grid lines at tlim, but no labels
%                        % (e.g. for upper panel of 2 stacked timeplots).
%
% timeaxis(tlim,nt,fmt,<keyword,value>) where <keyword,value> pairs are:
%  * 'ax'    'x','y','z'
%  * 'type'  'datestr' (default)
%            'tick'    (only WL)
%            'text'    removes all ticklabels and draws tick as text,
%                      NOTE: Text has fixed y position, so set ylim before timaxis.
%                      If fmt is an array, every fmt option
%                      is drawn as a separate text line.
%                      h = timeaxis(tlim ,nt,fmt) returns handles 
%                      in case of type = 'text'.
%
%  * tick     0 plots datetexts centered at the ticks (default)
%            -2 plots datetexts centered at the ticks
%               and skips first and last (only when type='text')
%            -1 plots datetexts left aligned at the ticks
%               and skips last ticks since that will not be 
%               in tha axis range (only when type='text').
%
%              +--------+--------+--------+
%              |may_6   |may_7   |may_8   |may_9    tick = -1
%            may_6    may_7    may_8    may_9       tick =  0 
%              |      may_7    may_8      |         tick = -2
%              +--------+--------+--------+
%
% Examples:
%
% timeaxis(datenum(1998,3,[1 31])  ,[10],1);           %  same as
% timeaxis(datenum(1998,3,[1:3:31]),[]  ,1);           %  same effect as
% timeaxis(datenum(1998,3,[1:6:31]),[]  ,[1],'text',0);
%
% G.J. de Boer
%
% See also: datestr, datenum, datetick, tick

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

%% Input
%% ----------------------

   nt            = [];
   if nargin>1
       nt            = varargin{1};
   end    

   datestrformat = 1;
   if nargin>2
       datestrformat = varargin{2};
       if iscell(datestrformat)
          if isnumeric(datestrformat{1})
          else
             datestrformat = char(datestrformat);
          end
       end
   end    

%% Options
%% ----------------------
   
   OPT.ax             = 'x';
   OPT.type           = 'datestr';
   OPT.plot_last_tick = 0;
   if nargin > 3
      i                  = 3;
      %% remaining number of arguments is always even now
      while i<=nargin-1,
          switch lower ( varargin{i  })
          % all keywords lower case
          case 'ax'  ;i=i+1;OPT.ax             = varargin{i};
          case 'tick';i=i+1;OPT.plot_last_tick = varargin{i};
          case 'type';i=i+1;OPT.type           = varargin{i};
          otherwise
            error(sprintf('Invalid string argument (caps?): "%s".',...
            varargin{i}));
          end
          i=i+1;
      end   
   end

%% Limits
%% ----------------------

   %t0    = tlim(1);
   %t1    = tlim(end);

   if isempty(nt)
      ttick = tlim; % can be irregular
   elseif length(tlim)==2
      ttick = linspace(tlim(1),tlim(end),(nt+1));
   else
      error('either specify nt, or pass a time vector longer than 2 not both.')
   end

  %set(gca,'xlim',[t0 t1]);
   set(gca,[OPT.ax,'lim'],ttick([1 end]));

%% Options
%% ----------------------

if strcmp(OPT.type,'tick')

   tick(gca,OPT.ax,ttick,'date',datestrformat)

elseif strcmp(OPT.type,'datestr')

   set(gca,[OPT.ax,'tick'     ],ttick);
   if ~(isempty(datestrformat) | ...
         strcmp(datestrformat,'')) % because matlab 6 cannot deal with '' format for empty
   set(gca,[OPT.ax,'ticklabel'],datestr(ttick,datestrformat));
   % datestrformat same for all values, except when you use (OPT.type,'text')
   else
   set(gca,[OPT.ax,'ticklabel'],repmat({''},1,length(ttick)));
   end

elseif strcmp(OPT.type,'text')

   set(gca,[OPT.ax,'lim'],ttick([1 end]));

   if OPT.plot_last_tick      == 0
      horizontalalignment = 'center';
   elseif OPT.plot_last_tick  == -2
      horizontalalignment = 'center';
      ttick               =  ttick(2:end-1);
   elseif OPT.plot_last_tick  == -1
      horizontalalignment = 'left';
      ttick               =  ttick(1:end-1);
   else
      error('tick should be -2, -1 or 0.')
   end

   set(gca,[OPT.ax,'tick'     ],ttick);
   set(gca,[OPT.ax,'ticklabel'],{});
   
   for i=1:length(ttick)
      txt = [];
      if ischar(datestrformat)
          datestrformat = cellstr(datestrformat);
      end
      if isnumeric(datestrformat)
          for j=1:length(datestrformat)
             %if     j==1
             %  %txt = strvcat(txt,['\lceil',datestr(ttick(i),datestrformat(j))]);
             %   txt = strvcat(txt,[' ',datestr(ttick(i),datestrformat(j))]);
             %elseif j==length(datestrformat)
             %   txt = strvcat(txt,['\lfloor',datestr(ttick(i),datestrformat(j))]);
             %else
             %   txt = strvcat(txt,[' ',datestr(ttick(i),datestrformat(j))]);
             %end
             txt = strvcat(txt,[datestr(ttick(i),datestrformat(j))]);
          end
      elseif iscell(datestrformat)
          for j=1:length(datestrformat)
             if ~isempty(datestrformat{j}) | ...
                  strcmp(datestrformat{j},'') % because matlab 6 cannot deal with '' format for empty
             txt = strvcat(txt,[datestr(ttick(i),datestrformat{j})]);
             else
             txt = strvcat(txt,'');
             end
          end
      end
      if strcmp(lower(OPT.ax),'x')
      Handles(i) = text(ttick(i),ylim1(1),txt,'verticalalignment'  ,'top',...
                                             'horizontalalignment',horizontalalignment);
      elseif strcmp(lower(OPT.ax),'y')
      Handles(i) = text(xlim1(1),ttick(i),txt,'verticalalignment'  ,'bottom',...
                                             'horizontalalignment',horizontalalignment,...
                                             'rotation'           ,90);
      end
   end
   
   if nargout==1
      varargout = {Handles};
   end
   
end

%% EOF