function varargout = Dispersion_Relations_shell(varargin)
%DISPERSION_RELATIONS_SHELL   wrapper for DOS executable
%
%    Struct_out = DISPERSION_RELATIONS_SHELL(Struct_in,<keyword,value>)
%
% where Struct_in has fields with names as in the argument list below 
% (which contains either T or omega (all lower case except T):
%
%    Struct_out = Dispersion_Relations_shell(T,omega,hw,hm,rhow,rhom,nuw,num,<keyword,value>)
%
% where you can leave either T or omega empty = [];
%
% The output file fname.out can be read with DISPERSION_RELATIONS_SHELL_READ.
%
% Implemented <keyword,value> paris are:
%
%   * basename   the base name of the ASCII input/output file, if not specified or []
%                a random temporary filenames will be generated (default []).
%   * overwrite  what to do with any exisiting in/output file (default 'p')
%                'o' = overwrite (default when file does not exist)
%                'c' = cancel,    leads to error when no output arguments
%                'p' = prompt    (default when file does exist, after which o/c can be chosen)
%   * keep       set 1 to keep in/output files, 0 to delete them (default 1)
%   * exe        give the full filename of the executable
%
%See also: GADE_1958, WAVEDISPERSION, DISPERSION_RELATIONS_SHELL_READ

%% TO DO: make *.dll with individual Dispersion_Relations functions
%% TO DO: replicate single evalue elements
%% TO DO: allow to overwrite files
%% TO DO: auto delete files if no name was specified

% Uses:
% * gettmpfilename
% * filecheck
% * fgetl_no_comment_line (DISPERSION_RELATIONS_SHELL_READ)

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl	
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

filepathstr(which(mfilename))

%% Initialize
%------------------------

   OPT.basename  = [];
   OPT.overwrite = 'p';
   OPT.keep      = 1;
   OPT.exe       = 'F:\checkouts\swanmud\source\40.51A.gerben\SWANW\dr\Release\dr.exe';

%% Input
%------------------------

   if isnumeric(varargin{1}) %nargin > 1
      S.T         = varargin{1};
      S.omega     = varargin{2};
      if isempty(S.T) & ~isempty(S.omega)
      S.T         = 2*pi./S.omega;
      end
      if isempty(S.omega) & ~isempty(S.T)
      S.omega     = 2*pi./S.T    ;
      end
      S.hw        = varargin{3};
      S.hm        = varargin{4};
      S.rhow      = varargin{5};
      S.rhom      = varargin{6};
      S.nuw       = varargin{7};
      S.num       = varargin{8};
      nargin_read = 8;
   elseif isstruct(varargin{1}) %S = varargin{1};
      S           = varargin{1};
      if ~isfield(S,'omega');S.omega = 2*pi./S.T    ;end
      if ~isfield(S,'T'    );S.T     = 2*pi./S.omega;end
      nargin_read = 1;
   end
   
%% <Keyword, value> pairs
%------------------------

   OPT = setProperty(OPT,varargin{nargin_read+1:end});
   
%% File name
%------------------------

   if isempty(OPT.basename) % does by definition ot exist
      file_in   = gettmpfilename(pwd,'Dispersion_Relations_shell','.in' );mode(1) = 'o';
      file_arg  = gettmpfilename(pwd,'Dispersion_Relations_shell','.arg');mode(2) = 'o';
      file_out  = gettmpfilename(pwd,'Dispersion_Relations_shell','.out');mode(3) = 'o';
   else
      file_in   = [OPT.basename,'.in '];[FILEexists{1},mode(1)] = filecheck(file_in ,OPT.overwrite);
      file_arg  = [OPT.basename,'.arg'];[FILEexists{2},mode(2)] = filecheck(file_arg,OPT.overwrite);
      file_out  = [OPT.basename,'.out'];[FILEexists{3},mode(3)] = filecheck(file_out,OPT.overwrite);
   end
   
%% Check files
%------------------------
   if ~strcmpi(mode,'ooo')
       error(['Some files already exist of ',OPT.basename,'.in *.arg *.out']);
   end

%% Create input file
%------------------------

   fid_in   = fopen(file_in,'w');

   fprintf(fid_in,'%s\n',['% tmp file for calling Dispersion_Relations_shell.exe']);
   fprintf(fid_in,'%s\n',['% created on :',datestr(now)]);
   fprintf(fid_in,'%s\n',['% created by : Dispersion_Relations_shell.m']);
   
   fprintf(fid_in,'%s\n',['% created by : Dispersion_Relations_shell.m']);
   fprintf(fid_in,'%s\n',['% created by : Dispersion_Relations_shell.m']);
   
   fprintf(fid_in,'%s\n',['%         T      Omega          Hw         Hm       Rhow       Rhom        nuw        num  ']);
   fprintf(fid_in,'%s\n',['%        [s]    [rad/s]        [m]        [m]     [kg/m3]    [kg/m3]     [m2/s]     [m2/s]']);
   
   % length columns original_numer_of_dimensions dimensions 
   fprintf(fid_in,'%s\n',num2str([length(S.T(:)) 8 length(size(S.T))+1 size(S.T) 8])); % reshape to 1D, but add reshape information after that
   
   for ival=1:length(S.T(:));  % reshape to 1D
   
   fprintf(fid_in,'%s\n',num2str([    S.T(ival)...
                                  S.omega(ival)...
                                     S.hw(ival)...
                                     S.hm(ival)...
                                   S.rhow(ival)...
                                   S.rhom(ival)...
                                    S.nuw(ival)...
                                    S.num(ival)]));
   end

   fclose(fid_in);

%% call Dispersion_Relations_shell.exe
%------------------------

   fid_arg  = fopen(file_arg,'w');
   
   fprintf(fid_arg,'%s\n',file_in );
   fprintf(fid_arg,'%s\n',file_out);
   
   fclose(fid_arg);
   
   if ispc
      system([OPT.exe,' < ',file_arg]);
   else
      error('not implementecd for lunix/unix');
   end
   
   if ~OPT.keep
      delete(file_arg);
      delete(file_in) ;
   end

%% Read output file
%------------------------

   S = Dispersion_Relations_shell_read(file_out);
   
%% Reshape to more dimensional (same as input)
%------------------------

   S.kguo      = reshape(S.kguo  ,size(S.T));
   S.kgade     = reshape(S.kgade ,size(S.T));
   S.ksv       = reshape(S.ksv   ,size(S.T));
   S.kdewit    = reshape(S.kdewit,size(S.T));
   S.kdelft    = reshape(S.kdelft,size(S.T));
   S.kdalr     = reshape(S.kdalr ,size(S.T));
   S.kng       = reshape(S.kng   ,size(S.T));   
   
%% Clean up
%------------------------

   if ~OPT.keep
      delete(file_out)
   end
   
%% Output
%% ----------------------

   if nargout==1
      varargout = {S};
   end

%% EOF   