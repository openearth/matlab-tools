function print2a4(fname,varargin)
%PRINT2A4    Print figure to A4 paper size.
%
% print2a4(fname)
% print2a4(fname,PaperOrientation)
% print2a4(fname,PaperOrientation,Tall_Wide)
% print2a4(fname,PaperOrientation,Tall_Wide,resolution)
% print2a4(fname,PaperOrientation,Tall_Wide,resolution,OverWriteAppend)
%
% PaperOrientation = 'h<orizontal>' = 'L<andscape>' or
%                    'v<ertical>'   = 'P<ortrait>' (default) 
% Tall_Wide        = 'w<ide>' (default) or 't<all>'
% resolution       = '-r200' (default) or 200 (screen: 93:1089x766, 87:1019 x 716)
% OverWriteAppend  = 'o<verwrite>' or 'c<ancel>' or 'p<rompt>' (default)
%
%               +-------+                                        
%               |    h,t|                                        
%  +----------+ |Hor    |                                          
%  | ^up   v,t| |Tall   |                                          
%  | Vert     | |       |                                         
%  | Tall     | |< up   |                                         
%  +----------+ +-------+                                         
%                                                       
%               +-------+                                      
%               |^ up   |                                      
%  +----------+ |Vert   |                                                   
%  |Hor    h,w| |Wide   |                                                  
%  |Wide      | |       |                                                  
%  |< up      | |    v,w|                                                  
%  +----------+ +-------+
%                                                    
% where print2a4('tst','v','t') matches a screen best
% where print2a4('tst','h','t') matches landscape figure on portrait printer best
%       print2a4('tst','v','w') matches upright A4 best (report)
%       ptint2a4('tst','v','w','o') overwrites the image created with the previous line
%
%See also: PRINT, PRINT2SCREENSIZE, PRINT2A4OVERWRITE

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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
   
   %% where overwrite_append can be 
   %  'o' = overwrite
   %  'c' = cancel
   %  'p' = prompt (default, after which o/a/c can be chosen)
   %  'a' = append (no recommended as HDF is VERY inefficient 
   %                due to disk space fragmentation when appending data.)
   
   PaperOrientation = 'Portrait';
   if nargin>1
       if ~isempty(varargin{1})
       PaperOrientation = varargin{1};
       if     lower(PaperOrientation(1))=='h' || ...
             lower(PaperOrientation(1))=='l'
          PaperOrientation = 'Landscape';
       elseif lower(PaperOrientation(1))=='v' || ...
             lower(PaperOrientation(1))=='p'
          PaperOrientation = 'Portrait';
       end
       end
   end

   % A4 paper
   Longside    = 20.9; % [cm] Minus
   Shortside   = 29.7; % [cm]
   if nargin>2
      if ~isempty(varargin{2})
      Tall_Wide = varargin{2};
      if     lower(Tall_Wide(1))=='w'
          % A4 paper
         Longside    = 20.9; % [cm] Minus 
         Shortside   = 29.7; % [cm]
      elseif lower(Tall_Wide(1))=='t'
         % A4 paper
         Longside    = 29.7; % [cm] Minus 
         Shortside   = 20.9; % [cm]
      else
          error(['''w<ide>'' or ''t<all>'' not ',Tall_Wide])
      end
      end
   end
   
   resolution        = '-r200';
   if nargin > 3
       if ~isempty(varargin{3})
       resolution = varargin{3};
       if isnumeric(resolution)
       resolution = ['-r',num2str(round(resolution))];
       end
       end
   end

   overwrite_append  = 'p'; % prompt
   if nargin > 3
       if ~isempty(varargin{4})
       overwrite_append = lower(varargin{4}(1));
       if ~ismember(overwrite_append,{'o','c','p'})
          error(['Invalid overwrite property: ' varargin{4}]);
       end
       end
   end

   %% Paper settings

   set(gcf,...
       'PaperType'       ,'A4',...
       'PaperUnits'      ,'centimeters',...
       'PaperPosition'   ,[0 0 Longside Shortside],...
       'PaperOrientation',PaperOrientation)

   [fileexist,action]=filecheck(fullfile(filepathstr(fname),[filename(fname),'.png']),overwrite_append);
   if strcmpi(action,'o')
      mkpath(filepathstr(fname))
      print('-dpng'  ,fname,resolution);
   end

%% EOF