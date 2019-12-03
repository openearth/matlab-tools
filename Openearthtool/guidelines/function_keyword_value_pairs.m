function varargout = FUNTION_NAME(varargin)
%FUNTION_NAME   Concise 1-line function description (will appear in list of functions)
%
%                   Input arguments:
%
% [..]            = FUNCTION_KEYWORD_VALUE_PAIRS(x)
% [..]            = FUNCTION_KEYWORD_VALUE_PAIRS(x,<keyword,value>)
% [..]            = FUNCTION_KEYWORD_VALUE_PAIRS(x,OPT)
% [..]            = FUNCTION_KEYWORD_VALUE_PAIRS(x,'function')
%
%                   Output arguments:
%
%  y              = FUNCTION_KEYWORD_VALUE_PAIRS(x,...)
% [y,status]      = FUNCTION_KEYWORD_VALUE_PAIRS(x,...)
% [y,status,OPT]  = FUNCTION_KEYWORD_VALUE_PAIRS(x,...)
%
% OPT             = FUNCTION_KEYWORD_VALUE_PAIRS
%                   returns default settings
%
% See also: KEYWORD_VALUE, OTHER_FUNTION_NAME, 

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

   %% It is recocmmended to add all settings as keywords, so 
   %% (1) in the calling routine it is clear what every optional argument means.
   %% (2) the order of the arguments does not matter
   %% (3) it is infinately extendable with more arguments
   %% (4) it has the touch and feel of the objects (the function) with properties (the arguments).
   %%
   %% Avoid passing a list of 1's andf 0's as optional arguments!!
   %%
   %% Insde the function all keywords are collected in a struct (here called OPT)
   %% (a) for easy debugging.
   %% (b) to be able to easily set and retrieve all default settings
   %% (c) to allow for passing all properties on one struct argument
   %%
   %% ----------------------

      %% Set defaults for keywords
      %% ----------------------
      
      OPT.keyword1 = 1;   
      OPT.keyword2 = 'a';
      OPT.keyword3 = 2;
      OPT.keyword4 = [5 6 7];
      OPT.keyword5 = {1};
      OPT.keyword6 = NaN;
      OPT.keywordn = [];
      
      %% Return defaults
      %% ----------------------

      if nargin==0
         varargout = {OPT};
         return
      end
      
      %% Cycle keywords in input argument list to overwrite default values.
      %% Align code lines as much as possible to allow for block editing in textpad.
      %% Only start <keyword,value> pairs after the REQUIRED arguments. 
      %% ----------------------
      
      x      = varargin{1};
      iargin = 2;
      
      while iargin<=nargin,
        if isstruct(varargin{iargin})
           OPT = mergestructs('overwrite',OPT,varargin{iargin});
        elseif ischar(varargin{iargin}),
          switch lower(varargin{iargin})
          case 'keyword1' ;iargin=iargin+1;OPT.keyword1  = varargin{iargin};
          case 'keyword2' ;iargin=iargin+1;OPT.keyword2  = varargin{iargin};
          case 'keyword3' ;iargin=iargin+1;OPT.keyword2  = varargin{iargin};
          case 'keyword4' ;iargin=iargin+1;OPT.keyword2  = varargin{iargin};
          case 'keyword5' ;iargin=iargin+1;OPT.keyword2  = varargin{iargin};
          case 'keyword6' ;iargin=iargin+1;OPT.keyword2  = varargin{iargin};
          case 'keywordn' ;iargin=iargin+1;OPT.keywordn  = varargin{iargin};
          otherwise
             error(['Invalid string argument: ',varargin{iargin}]);
          end
        end;
        iargin=iargin+1;
      end; 
      
   %% Devide the function into separate blocks seperated 
   %% by descriptive comment lines with double %%.
   %% Align your code as much as possible whenever possible
   %% to allow for block editing in textpad,
   %% and easier visual comprehesnsion.
   %% ----------------------
   
   try
      y      = x.^OPT.keyword1;
      status = 0;
   catch
      status = -1;
   end
      
   %% Catch known errors, and return an error code status with 
   %% values like -1, -2, -3 if the function failed. Return status=0
   %% when the function was succesfull. This allows higher level routines 
   %% to report the error back to the user.
   %% ----------------------
   
   if nargout<2
      varargout = {y};
   elseif nargout==2
      varargout = {y,status};
   elseif nargout==3
      varargout = {y,status,OPT};
   end      

%% EOF function_keyword_value_pairs      