function varargout = swan_io_input(varargin)
%SWAN_IO_INPUT            read SWAN input file into struct.
%
%    DAT = swan_io_input(fname)
%    DAT = swan_io_input        %launches load GUI.
% 
% Reads an ASCII SWAN input file into a struct DAT with one field
% per keyword (all fieldnames lower case).
%
% For now only the following keywords are implemented 
% correctly. The other keywords still contain the raw ASCII records,
% merged over lines where continutation symbols ('_','&') are present.
% 
% Multiple fields for keywords are overwritten, except for 
% CURVE, GROUP, TABLE, BLOCK, SPEC.
%
% NOTE that the output parameter keywords are replaced with their short name equivalents.
%
% See also: SWAN_IO_SPECTRUM, SWAN_IO_TABLE, SWAN_IO_GRD, SWAN_IO_BOT, SWAN_DEFAULTS

%% Copyright
%   --------------------------------------------------------------------
%   Copyright (C) 2006-2010 Deltares
%       Gerben de Boer
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

%% Version
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%uses: mergestructs, iscommentline, fieldname, expressionsfromstring

% 2009 Jun 05: add fullfilename to spec field
% 2009 Jun 04: use new matlab code-cells syntax to divide code into 'chapters'
% 2008 Apr 17: add *.swn path when reading points FILE (which still is not fool-proof)
% 2008 Jul 01: allow for absence of SET NAUT/CART
% 2008 Jul 01: add number of meshes for all table types to quick & allow uniform calls of SWAN_TABLE
% 2008 Jul 10: interpret BOUND SHAPE line into struct
% 2008 Oct 20: add default value for set.pwtail and update according to GEN keywords
% 2009 Feb 05: use strtrim, use only 2 letter of keyword FRICtion, allow both presence and absence of continuation char (&) in PROJ keyword span.
% 2009 jul 20: in fgetlines_no_comment_line: make sure comment is treated as all data on a SWAN line (_& continuation) in between $ or after last (odd) $

%% Defaults

   DAT.set = swan_defaults; % sets DAT.set
   
%% No file name specified if even number of arguments
%  i.e. 2 or 4 input parameters

   if ~odd(nargin)
     [fname, pathname, filterindex] = uigetfile( ...
        {'*.swn;*.inp', 'SWAN spectrum files (*.swn;*.inp)'; ...
         '*.*'        ,'All Files (*.*)'}, ...
         'SWAN input file');
      
      if ~ischar(fname) % uigetfile cancelled
         DAT.filename     = [];
         iostat           = 0;
      else
         DAT.fullfilename = [pathname, fname];
         iostat           = 1;
      end

%% No file name specified if odd number of arguments

   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      DAT.fullfilename  = varargin{1};
      iostat            = 1;
   end
   
   [DAT.file.path DAT.file.name DAT.file.ext] = fileparts(DAT.fullfilename);   
   
%% Open file
      
   if iostat==1 %  0 when uigetfile was cancelled
                % -1 when uigetfile failed

%% check for file existence (1)
%  try to make absolute path, and find files in matlab path
   txt = which(DAT.fullfilename); 
   if ~isempty(txt)
      DAT.fullfilename = txt;
   end
   tmp = dir(DAT.fullfilename);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',DAT.fullfilename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      DAT.file.date     = tmp.date;
      DAT.file.bytes    = tmp.bytes;

%% check for file opening (2)

      sptfilenameshort = filename(DAT.fullfilename);
      
      fid       = fopen  (DAT.fullfilename,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',DAT.fullfilename])
         else
            iostat = -2;
         end
      
      elseif fid > 2

%% read file line by line

         rec = '';
         
         while ~feof(fid)
            
            %% this functions searches for all keywords
            %  until end of file:
            %  - So the order of keywords does not matter
            %  - the last item always overwrites any previous item.
            %  - addkeywor searhjces for keywords in the most expected order to 
            %    mimimize  the number of calls to addkeywors cycles (where the 
            %    maximum number of calls would be the number of keywords, and 
            %    the smallest number of calls only 1).
            
            [DAT,rec] = addkeyword(fid,DAT,rec);
            
         end
            
         iostat = fclose(fid);
         
      end % if fid <0
      
   end % if length(tmp)==0

end % if iostat (GUI)

DAT.read.with     = 'read by $Id$ by G.J. de Boer (WL | Delft Hydraulics)';
DAT.read.at       = datestr(now);
DAT.read.iostatus = iostat;

%% Function output

if nargout      ==0 | nargout==1
   varargout= {DAT};
elseif nargout==2
   varargout= {DAT, iostat};
end
   
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   function [DAT,rec] = addkeyword(fid,DAT,rec)
   
      OPT.dispwarnings = false;
      OPT.debug        = 0;
      OPT.disp         = false;

      foundkeyword = false;
      
      persistent N %N.frames N.groups N.ncurves N.rays N.isolines N.points N.tables N.blocks N.specs

            if isempty(rec)
               rec                = fgetlines_no_comment_line(fid);
            end
            
            if OPT.debug
               disp(rec)
            end

%% Read PROJECT (required)
            if strcmp(strtok(upper(rec(1:4))),'PROJ')
               quotes             = strfind(rec,'''');
               if ~isempty(quotes)
                  DAT.project.name   = rec(quotes(1)+1:quotes(2)-1);
                  DAT.project.nr     = rec(quotes(3)+1:quotes(4)-1);
                  quotes             = strfind(rec,'''');
               end

               %% tackle also cases where lines end with a continuation mark (&_)
               if length(quotes) > 4
               quotes = quotes(5:end);
               %else
               %rec                = fgetlines_no_comment_line(fid) % sometimes titles are absent
               %quotes             = strfind(rec,'''');
               end
               DAT.project.title1 = rec(quotes(1)+1:quotes(2)-1);
               
               %% tackle also cases where lines end with a continuation mark (&_)
               if length(quotes) > 2
               quotes = quotes(3:end);
               %else
               %rec                = fgetlines_no_comment_line(fid);
               %quotes             = strfind(rec,'''');
               end
               DAT.project.title2 = rec(quotes(1)+1:quotes(2)-1);
               
               %% tackle also cases where lines end with a continuation mark (&_)
               if length(quotes) > 2
               quotes = quotes(3:end);
               %else
               %rec                = fgetlines_no_comment_line(fid);
               %quotes             = strfind(rec,'''');
               end
               DAT.project.title3 = rec(quotes(1)+1:quotes(2)-1);
               
               rec        = fgetlines_no_comment_line(fid);

               foundkeyword = true;

            else
               if OPT.dispwarnings
                  disp('Warning: keyword PROJECT required')
               end
            end
            
%% Read SET (optional)
%  NOTE that SET can be called on several consecutive lines
            if strcmp(strtok(upper(rec)),'SET')
            
               [keyword,rest_of_rec] = strtok(strtrim(rec));
               
               ind1 = strfind(rest_of_rec,'NAUT');
               ind2 = strfind(rest_of_rec,'CART');
               if ~isempty(ind1)
                  DAT.set.naut = 1;
                  ind          = ind1;
               elseif ~isempty(ind2)
                  DAT.set.naut = 0;
                  ind          = ind2;
               else
                   ind = length(rest_of_rec)+1;
               end

               %% keywords before CART/NAUT
               %try
                   %if any(findstr(rest_of_rec,'='))
                   %OUT = expressionsfromstring(lower(rest_of_rec),...
                   %                 {'level' ,'nor'   ,'depmin'  ,'maxmes',...
                   %                  'maxerr','grav'  ,'rho'     ,'inrhog',...
                   %                  'hsrerr'},'empty',0);                   
                   %else
                   OUT = swan_keyword(lower(rest_of_rec),...
                                    {'level' ,'nor'   ,'depmin'  ,'maxmes',...
                                     'maxerr','grav'  ,'rho'     ,'inrhog',...
                                     'hsrerr'}); % TO DO make numeric, take care of missing keywords
                   %end
                   if ~isempty(OUT)
                   DAT.set      = mergestructs('overwrite',DAT.set,OUT);
                   end

                  %% keywords after CART/NAUT
                  [nautcart,rest_of_rec] = strtok(rest_of_rec(ind:end));
                   %if any(findstr(rest_of_rec,'='))
                   %OUT = expressionsfromstring(lower(rest_of_rec),...
                   %                 {'pwtail','froudmax','printf',...
                   %                  'prtest'},'empty',0);                   
                   %else
                   OUT = swan_keyword(lower(rest_of_rec),...
                                    {'pwtail','froudmax','printf',...
                                     'prtest'}); % TO DO make numeric, take care of missing keywords
                   %end
                   if ~isempty(OUT)
                   DAT.set      = mergestructs('overwrite',DAT.set,OUT);
                   end
               %catch
               %    DAT.set      = rest_of_rec;
               %end

               rec          = fgetlines_no_comment_line(fid);
               foundkeyword = true;
               
            end
            
%% Read MODE (optional)
            DAT.mode.stationary = 1; % default
            DAT.mode.dim        = 2; % default
            if strcmp(strtok(upper(rec)),'MODE')
              [keyword,rec] = strtok(rec);
              [keyword,rec] = strtok(rec);
               if     strcmp(keyword(1:3),'STA')
               DAT.mode.stationary = 1;
               elseif strcmp(keyword(1:5),'NONST')
               DAT.mode.stationary = 0;
               end
              [keyword,rec] = strtok(rec);
               if ~isempty(keyword)
                if     strcmp(keyword(1:4),'ONED')
                DAT.mode.dim        = 2;
                elseif strcmp(keyword(1:4),'TWOD')
                DAT.mode.dim        = 2;
                end
               end
               rec          = fgetlines_no_comment_line(fid);
               foundkeyword = true;
            end
            
            %  Read COORDinates (optional ? )
            %  ------------------------------------------
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,5,' '));
            if    strfind(keyword1(1:5),'COORD')==1
               %rec            = fgetlines_no_comment_line(fid)
               %[DAT.time]     = strread(rec,'%d');
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            else
               DAT.coordinates = [];
            end   

%% Read CGRID (required)  (overwrites previous)
            if strcmp(strtok(upper(rec)),'CGRID')
               if OPT.debug
                  disp('CGRID processing:')
               end              
              [keyword,rec]      = strtok(rec); % cgrid

               %% REGular or CURVilinear
               %  ------------------------------------------

              [keyword1,rec1] = strtok(rec);
               keyword1      = upper(pad(keyword1,6,' '));
               
               if ~isempty(str2num(keyword1))
                  rec1 = [keyword1,rec1];
                  keyword1 = 'REGular'; % default REG may be missing
               end
               
               if     strcmp(keyword1(1:4),'CURV')
               
               rec = rec1;

               %  CURVilinear (REGular)
               %  ------------------------------------------
               
                  DAT.cgrid.type       = 'curvilinear';
                  
                 [DAT.cgrid.mxc  ,rec] = strtok(rec);  DAT.cgrid.mxc   = str2num(DAT.cgrid.mxc  );
                 [DAT.cgrid.myc  ,rec] = strtok(rec);  DAT.cgrid.myc   = str2num(DAT.cgrid.myc  );
                 
                  keyword = strtok(rec); % extract EXC
                  if strcmp(upper(keyword(1:3)),'EXC')
                  [keyword,rec]=strtok(rec); % remove EXC
                  [DAT.cgrid.xexc ,rec] = strtok(rec);  DAT.cgrid.xexc  = str2num(DAT.cgrid.xexc );

                     keyword = strtok(rec);
                     if      strcmp(strtok(keyword(1:3)),'CIR')
                     DAT.cgrid.yexc = DAT.cgrid.xexc;
                     elseif  strcmp(strtok(keyword(1:3)),'SEC')                 
                     DAT.cgrid.yexc = DAT.cgrid.xexc;
                     else
                     [DAT.cgrid.yexc ,rec] = strtok(rec);  DAT.cgrid.yexc  = str2num(DAT.cgrid.yexc );
                     end

                  end
               
               elseif strcmp(keyword1(1:3),'REG') % sub-keyword REGular or no sub-keyword
                  
               %  REGular (CURVilinear)
               %  ------------------------------------------

                  DAT.cgrid.type       = 'regular';

                  if strcmp(strtok(upper(rec)),'REG')
                     [keyword,rec]=strtok(rec);
                  end
                  
                 [DAT.cgrid.xpc  ,rec] = strtok(rec);  DAT.cgrid.xpc   = str2num(DAT.cgrid.xpc  );
                 [DAT.cgrid.ypc  ,rec] = strtok(rec);  DAT.cgrid.ypc   = str2num(DAT.cgrid.ypc  );
                 [DAT.cgrid.alcp ,rec] = strtok(rec);  DAT.cgrid.alcp  = str2num(DAT.cgrid.alcp );
                 [DAT.cgrid.xlenc,rec] = strtok(rec);  DAT.cgrid.xlenc = str2num(DAT.cgrid.xlenc);
                 [DAT.cgrid.ylenc,rec] = strtok(rec);  DAT.cgrid.ylenc = str2num(DAT.cgrid.ylenc);
                 [DAT.cgrid.mxc  ,rec] = strtok(rec);  DAT.cgrid.mxc   = str2num(DAT.cgrid.mxc  );
                 [DAT.cgrid.myc  ,rec] = strtok(rec);  DAT.cgrid.myc   = str2num(DAT.cgrid.myc  );
                 
                  DAT.cgrid.x = linspace(DAT.cgrid.xpc,DAT.cgrid.xpc+DAT.cgrid.xlenc,DAT.cgrid.mxc+1);
                  DAT.cgrid.y = linspace(DAT.cgrid.ypc,DAT.cgrid.ypc+DAT.cgrid.ylenc,DAT.cgrid.myc+1);
                  
               % Calculate full grid if rotated

                  if ~(DAT.cgrid.alcp==0)
                     [DAT.cgrid.x,DAT.cgrid.y] = meshgrid(DAT.cgrid.x,DAT.cgrid.y);
                      DAT.cgrid.X = DAT.cgrid.x.*cosd(DAT.cgrid.alcp) - DAT.cgrid.x.*sind(DAT.cgrid.alcp);
                      DAT.cgrid.Y = DAT.cgrid.y.*sind(DAT.cgrid.alcp) + DAT.cgrid.y.*cosd(DAT.cgrid.alcp);
                      DAT.cgrid.x = linspace(DAT.cgrid.xpc,DAT.cgrid.xpc+DAT.cgrid.xlenc,DAT.cgrid.mxc+1);
                      DAT.cgrid.y = linspace(DAT.cgrid.ypc,DAT.cgrid.ypc+DAT.cgrid.ylenc,DAT.cgrid.myc+1);
                      % pcolorcorcen(SWN.cgrid.x,SWN.cgrid.y,SWN.cgrid.X)
                      % pcolorcorcen(SWN.cgrid.x,SWN.cgrid.y,SWN.cgrid.Y)                      
                  end

               elseif strcmp(keyword1(1:7),'UNSTRUC') % sub-keyword REGular or no sub-keyword
                  DAT.cgrid.type       = 'unstructured';
                  [keyword,rec]=strtok(rec);
               end
               
               %  CIRCle or SECTtor
               %  ------------------------------------------

               keyword = strtok(rec); % extract CIRC
               if     strcmp(strtok(keyword(1:3)),'CIR')
                  [keyword,rec]      = strtok(rec); % remove CIRC
                  DAT.cgrid.circle   = 1;
                  DAT.cgrid.sector   = 0;
                  keyword            = 'circle';
                  DAT.cgrid.dir1     = 0;
                  DAT.cgrid.dir2     = 360;
               elseif  strcmp(strtok(keyword(1:3)),'SEC')
                  [keyword,rec]      = strtok(rec); % SECT
                  DAT.cgrid.circle   = 0;
                  DAT.cgrid.sector   = 1;
                  keyword            = 'sector';
                 %[DAT.cgrid.sector.dir1,rec] = strtok(rec);  DAT.cgrid.sector.dir1  = str2num(DAT.cgrid.sector.dir1);
                 %[DAT.cgrid.sector.dir2,rec] = strtok(rec);  DAT.cgrid.sector.dir2  = str2num(DAT.cgrid.sector.dir2);
                  [DAT.cgrid.dir1,rec] = strtok(rec);  DAT.cgrid.dir1  = str2num(DAT.cgrid.dir1);
                  [DAT.cgrid.dir2,rec] = strtok(rec);  DAT.cgrid.dir2  = str2num(DAT.cgrid.dir2);
               end
               [DAT.cgrid.mdc  ,rec] = strtok(rec);  DAT.cgrid.mdc   = str2num(DAT.cgrid.mdc  );
               [DAT.cgrid.flow ,rec] = strtok(rec);  DAT.cgrid.flow  = str2num(DAT.cgrid.flow );
               [DAT.cgrid.fhigh,rec] = strtok(rec);  DAT.cgrid.fhigh = str2num(DAT.cgrid.fhigh);
               if ~isempty(rec)
               [DAT.cgrid.msc  ,rec] = strtok(rec);  DAT.cgrid.msc   = str2num(DAT.cgrid.msc  );
               DAT.cgrid.gamma       = 1 + (-1 + (DAT.cgrid.fhigh./DAT.cgrid.flow).^(1/DAT.cgrid.msc)); % resolution in sigma space
               else
               DAT.cgrid.gamma       = 1.1; % resolution in sigma space
               DAT.cgrid.msc         = 1+round(log10(DAT.cgrid.fhigh/DAT.cgrid.flow)./log10(DAT.cgrid.gamma));
               % 1.1 was initial guess, recalculate with rounded msc
               DAT.cgrid.gamma       = 1 + (-1 + (DAT.cgrid.fhigh./DAT.cgrid.flow).^(1/DAT.cgrid.msc)); % resolution in sigma space
               disp(['DAT.cgrid.msc calculated with gamma=1.1 and rounded to ',num2str(DAT.cgrid.msc),' from flow and fhigh, resulting in gamma=',num2str(DAT.cgrid.gamma)])
               disp('Equation for [msc] in manual in CGRID section is ambiguous, as that would give msc one smaller.')
               end
               
               DAT.cgrid.frequency   = DAT.cgrid.flow.*(DAT.cgrid.gamma).^[0:DAT.cgrid.msc];
               DAT.cgrid.period      = 1./DAT.cgrid.frequency;
               
               rec          = fgetlines_no_comment_line(fid);
               foundkeyword = true;
            else
               if OPT.dispwarnings
                  disp('Warning: keyword CGRID required')
               end
            end   
            
%% Read COORdinates (required if curvi-linear)
            if isfield(DAT,'cgrid')
               if strcmp(DAT.cgrid.type,'curvilinear') | ...
                  strcmp(DAT.cgrid.type,'unstructured')
                  keyword = pad(strtok(upper(rec)),4,' ');

                  if strcmp(keyword(1:4),'READ')
                      DAT.readcoor = rec;
                      rec          = fgetlines_no_comment_line(fid);
                  else
                     if OPT.dispwarnings
                        disp('Warning: keyword COOR READ required for curvilinear')
                     end
                  end
               end              
            end
            
%% Read INPgrid (required)
            j = 0;
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,3,' '));
            while strfind(keyword1(1:3),'INP')==1 % read all input grids
               j               = j+1;
               
% TO DO absence of quantity: indeitcla grid for all quantities
               
              [quantity,rec1]   = strtok(rec1);
               keyword1         = strtok(rec1);
               keyword1 = pad(keyword1,6,' ');
               if     strcmpi(keyword1(1:3),'REG')
               gridtype = 'REG';
              [keyword1,rec1]   = strtok(rec1);
               elseif strcmpi(keyword1(1:4),'CURV')
               gridtype = 'CURV';
              [keyword1,rec1]   = strtok(rec1);
               elseif strcmpi(keyword1(1:7),'UNSTRUC')
               gridtype = 'UNSTRUC';
              [keyword1,rec1]   = strtok(rec1);
               else
               gridtype = 'REG';
               end

               if strcmpi(gridtype,'REG')
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.xpinp  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.ypinp  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.alpinp = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.mxinp  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.myinp  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.dxinp  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.dyinp  = str2num(keyword1);
               elseif strcmpi(gridtype,'CURV')
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.stagrx  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.stagry  = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.mxinp   = str2num(keyword1);
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.myinp   = str2num(keyword1);
               end
               
              %% EXC is optional               
              if ~isempty(strtrim(rec1))
              [keyword1,rec1]   = strtok(rec1);
               if strcmpi(keyword1(1:3),'EXC')
              [keyword1,rec1]   = strtok(rec1);DAT.inpgrid{j}.exception = str2num(keyword1);
               end
               end
              
              [keyword1,rec1]   = strtok(rec1);
               if isempty(keyword1)
               DAT.inpgrid{j}.nonstationary  = 0;
               elseif strcmpi(keyword1(1:7),'NONSTAT')
               DAT.inpgrid{j}.nonstationary  = rec1;
% TO DO parse non-stationary
               end

%% Read READinp (required)
               rec             = fgetlines_no_comment_line(fid);
              [keyword1,rec1]  = strtok(rec);
               keyword1        = upper(pad(keyword1,3,' '));
               READINP         = true;           % in case or more input on same grid
               INPGRID         = DAT.inpgrid{j}; % in case or more input on same grid
               
               while READINP
                  if strfind(strtok(upper(rec)),'READ')==1
                     DAT.inpgrid{j}.quantity = quantity;
                     DAT.inpgrid{j}.gridtype = gridtype;

                    [DAT.inpgrid{j}.quantity,rec1]   = strtok(rec1);
                     if ~strcmpi(DAT.inpgrid{j}.quantity,quantity)
                       disp('possible READinp parameter mismatch')
                     end
                    [DAT.inpgrid{j}.fac      ,rec1]   = strtok(rec1);
                    [val1                    ,rec1]   = strtok(rec1);
                    if strcmpi(val1(1:4),'SERI')
                    [val1                    ,rec1]   = strtok(rec1);
                    DAT.inpgrid{j}.fname2 = val1(2:end-1); % remove '
                    else
                    DAT.inpgrid{j}.fname1 = val1(2:end-1); % remove '
                    end
                    [val1                    ,rec1]   = strtok(rec1);
                    DAT.inpgrid{j}.idla  = str2num(val1);
                    [val1                    ,rec1]   = strtok(rec1);
                    DAT.inpgrid{j}.nhedf = str2num(val1);

                    [val1                    ,rec1]   = strtok(rec1);
                    if     strcmpi(val1(1:3),'FRE')
                    DAT.inpgrid{j}.format  = val1;
                    elseif strcmpi(val1(1:3),'FOR')
                    DAT.inpgrid{j}.format  = val1;
                    elseif strcmpi(val1(1:3),'UNF')
                    DAT.inpgrid{j}.format  = val1;
                    else
                    DAT.inpgrid{j}.nhedt   = str2num(val1);
                       [val1                    ,rec1]   = strtok(rec1);
		    if     strcmpi(val1(1:3),'FRE')
		    DAT.inpgrid{j}.format  = val1;
		    elseif strcmpi(val1(1:3),'FOR')
		    DAT.inpgrid{j}.format  = val1;
   		    elseif strcmpi(val1(1:3),'UNF')
		    DAT.inpgrid{j}.format  = val1;
		    else
		    DAT.inpgrid{j}.nhedvec = str2num(val1);
		    [val1                    ,rec1]   = strtok(rec1);
		    DAT.inpgrid{j}.format  = val1;
		    end
                    end
                    if strcmpi(DAT.inpgrid{j}.format(1:3),'FOR')
                    warning('READinp ... format not fully implemented')
                    end

                  else
                     if OPT.dispwarnings
                        disp('Warning: keyword READ required for every INPGRID')
                     end
                  end                  
                  rec              = fgetlines_no_comment_line(fid);

                 [keyword1,rec1]  = strtok(rec);
                  keyword1        = upper(pad(keyword1,3,' '));
                  
                  if strfind(strtok(upper(rec)),'READ')==1
                    j               = j+1;
                    DAT.inpgrid{j}  = INPGRID;
                  else
                    READINP         = false;
               end
               end
               
               foundkeyword     = true;
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,3,' '));
            end
            
%% Read WIND
            if   strfind(strtok(upper(rec)),'WIND')==1
               if OPT.debug
                  disp('WIND')
               end
              [keyword,rec]    = strtok(rec);
              [value,rec]      = strtok(rec);
               DAT.wind.vel    = str2num(value);
              [value,rec]      = strtok(rec);
               DAT.wind.dir    = str2num(value);
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end              

            %  Read BOUNDary (required ?)
            %  ------------------------------------------
            
            j = 0;
            %keyword = strtok(upper(rec));
% GIVES PROBLEMS WHEN BOUNDary IS NOT PRESENT IN swn FILE
% use previous rec or check whetehr rec is empty next time
            while strfind(strtok(upper(rec)),'BOU')==1 | ...
                  strfind(strtok(upper(rec)),'BOUN')==1 | ...
                  strfind(strtok(upper(rec)),'BOUND')==1 | ...
                  strfind(strtok(upper(rec)),'BOUNDS')==1 | ...
                  strfind(strtok(upper(rec)),'BOUNDSP')==1 | ...
                  strfind(strtok(upper(rec)),'BOUNDSPE')==1 | ...
                  strfind(strtok(upper(rec)),'BOUNDSPEC')==1

               if OPT.debug
                  disp('BOUN')
               end 
               
              [keyword,rec] = strtok(rec); % remove BOUN
              [keyword,rec] = strtok(rec); % get next one

              %  SHAPe
              %  NOTE: can be reused
              %  ------------------------------------------
               if strcmp(keyword(1:4),'SHAP')

                [val,rec] = strtok(rec);
                 SHAPESPEC.spectrum = lower(val); % JONswap, PM, GAUSs, BIN

                 keyword1 = upper(pad(val,4,' '));

                 if     strcmpi(keyword1(1:3),'JON' )

                    SHAPESPEC.gamma   = 3.3; % default;
                   [val,rec] = strtok(rec);
                    keyword2     = upper(pad(val,3,' '));
                    if    ~strcmpi(keyword2(1:3),'PEAK' ) | ...
                          ~strcmpi(keyword2(1:3),'MEAN' )
                    SHAPESPEC.gamma   = str2num(val);
                    end
                 elseif strcmpi(keyword1(1:4),'GAUS')
                    
                    SHAPESPEC.sigfr   = []; % No default in manual;
                   [val,rec] = strtok(rec);
                    keyword2     = upper(pad(val,3,' '));
                    if    ~strcmpi(keyword2(1:3),'PEAK' ) | ...
                          ~strcmpi(keyword2(1:3),'MEAN' )
                    SHAPESPEC.sigfr   = str2num(val);
                    end

                 end
                  
                 SHAPESPEC.period   = lower(keyword);  % PEAK, MEAN

                %[keyword,rec] = strtok(rec); % remove DSPR
                %[keyword,rec] = strtok(rec);

                 SHAPESPEC.directional_distribution = lower(keyword); % POWER or DEGRees
                 
              %  SIDE vs SEGMent
              %  ------------------------------------------
               elseif     strcmp(keyword(1:4),'SIDE')
                  j                              = j+1;
                  if j==1
                  DAT.boundspec(j)               = SHAPESPEC;
                  else
                  DAT.boundspec(j)               = DAT.boundspec(j-1);
                  end
                  DAT.boundspec(j).specification = 'side';
                  [winddir ,rec] = strtok(rec);DAT.boundspec(j).winddir  = winddir;
                  [clockdir,rec] = strtok(rec);DAT.boundspec(j).clockdir = clockdir;
                  
               elseif strcmp(keyword(1:4),'SEGM')
                  j                              = j+1;
                  if j==1
                  DAT.boundspec(j)               = SHAPESPEC;
                  else
                  DAT.boundspec(j)               = DAT.boundspec(j-1);
                  end
                  DAT.boundspec(j).specification = 'segment';
                  [xy_ij,rec] = strtok(rec);
                  DAT.boundspec(j).segm.XYIJ = xy_ij;
                  if     strcmp(upper(xy_ij),'XY')
                     [x,rec]    = strtok(rec);DAT.boundspec(j).segm.x(1) = str2num(x);
                     [y,rec]    = strtok(rec);DAT.boundspec(j).segm.y(1) = str2num(y);
                     [x,rec]    = strtok(rec);DAT.boundspec(j).segm.x(2) = str2num(x);
                     [y,rec]    = strtok(rec);DAT.boundspec(j).segm.y(2) = str2num(y);
                  elseif strcmp(upper(xy_ij),'IJ')
                     [itxt,rec] = strtok(rec);DAT.boundspec(j).segm.i(1) = str2num(itxt);
                     [jtxt,rec] = strtok(rec);DAT.boundspec(j).segm.j(1) = str2num(jtxt);
                     [itxt,rec] = strtok(rec);DAT.boundspec(j).segm.i(2) = str2num(itxt);
                     [jtxt,rec] = strtok(rec);DAT.boundspec(j).segm.j(2) = str2num(jtxt);
                  end
                  
               end
               
               %  CONstant vs VARiable
               %  ------------------------------------------
               if     strcmp(keyword(1:4),'SIDE') | ...
                      strcmp(keyword(1:4),'SEGM')
                  [keyword,rec] = strtok(rec);
                  if     strcmp(keyword(1:3),'CON')
                     DAT.boundspec(j).constant_vs_variable = 'constant';
                     [keyword,rec] = strtok(rec);
                     if     strcmp(keyword(1:3),'PAR')
                        DAT.boundspec(j).parameter_vs_file = 'parameter';
                        [hs ,rec] = strtok(rec);hs  = str2num(hs );DAT.boundspec(j).hs  = hs ;
                        [per,rec] = strtok(rec);per = str2num(per);DAT.boundspec(j).per = per;
                        [ang,rec] = strtok(rec);ang = str2num(ang);DAT.boundspec(j).dir = ang;
                        [dd ,rec] = strtok(rec);dd  = str2num(dd );DAT.boundspec(j).dd  = dd ;
                     elseif strcmp(keyword(1:3),'FIL')
                        DAT.boundspec(j).parameter_vs_file = 'file';
                     end
                  elseif strcmp(keyword(1:3),'VAR')
                     DAT.boundspec(j).constant_vs_variable = 'variable';
                     [keyword,rec] = strtok(rec);
                     if     strcmp(keyword(1:3),'PAR')
                        DAT.boundspec(j).parameter_vs_file = 'parameter';
                     elseif strcmp(keyword(1:3),'FIL')
                        DAT.boundspec(j).parameter_vs_file = 'file';
                     end
                  end
               end

               rec             = fgetlines_no_comment_line(fid);
               keyword         = strtok(upper(rec));
               foundkeyword    = true;
               
            end            
            
%% Read INITial
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,4,' '));
            if   strfind(keyword1(1:4),'INIT')==1
               DAT.initial     = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end   
            
%% Read GEN1/GEN2/GEN3
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,4,' '));
            if   strfind(keyword1(1:4),'GEN1')==1
               DAT.gen1         = rec;
               rec              = fgetlines_no_comment_line(fid);
               foundkeyword     = true;
               %% Adapt default settings pwtail
               DAT.set.pwtail   = 5;
            end     

              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,4,' '));
            if   strfind(keyword1(1:4),'GEN2')==1
               DAT.gen2         = rec;
               rec              = fgetlines_no_comment_line(fid);
               foundkeyword     = true;
               %% Adapt default settings pwtail
               DAT.set.pwtail   = 5;
            end            

              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,4,' '));
            if   strfind(keyword1(1:4),'GEN3')==1
               DAT.gen3         = rec;
              
              %% Adapt default settings pwtail
              [keyword1,rec1]   = strtok(rec1);
               if isempty(keyword1);keyword1 = ' ';end
               keyword1         = upper(pad(keyword1,4,' '));
               if   strfind(keyword1(1:4),'JANS')==1
               DAT.set.pwtail   = 5;
               end
               rec              = fgetlines_no_comment_line(fid);
               foundkeyword     = true;
            end             
            
%% Read WCAP
            if strfind(strtok(upper(rec)),'WCAP')==1
               DAT.wcapping    = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end              
         
%% Read QUADrupl
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,4,' '));
            if strfind(keyword1(1:4),'QUAD')==1
               DAT.quadrupl    = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end              

%% Read MDIA LAMbda
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,4,' '));
            if strfind(keyword1(1:4),'MDIA')==1
               DAT.mdia        = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end 
            
%% Read BREaking
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,3,' '));
            if   strfind(keyword1(1:3),'BRE')==1
               keyword         = lower(strtok(upper(rec)));
               DAT.breaking    = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end               

%% Read FRICtion
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,8,' '));
            if strfind(keyword1(1:4),'FRIC')==1
            
               DAT.friction.expression  = 'JONSWAP';
               DAT.friction.coefficient = 'CONSTANT';

               keyword         = lower(strtok(upper(rec)));
              [val,rec] = strtok(rec);
              [val,rec] = strtok(rec);
               if length(val) > 3 % in case empty
               DAT.friction.expression = val;
               if     strcmpi(val(1:3),'JON')
                [DAT.friction.cfjon      ,rec] = strtok(rec);
                 DAT.friction.cfjon            = str2num(DAT.friction.cfjon);
                [DAT.friction.coefficient,rec] = strtok(rec);
               elseif strcmpi(val(1:3),'COL')
                 DAT.friction.cfw   = str2num(strtok(rec));
               elseif strcmpi(val(1:3),'MAD')
                 DAT.friction.kn    = str2num(strtok(rec));
               else
               end
               end
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end     
            
%% Read TRIAD
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,8,' '));
            if strfind(keyword1(1:3),'TRI')==1
               DAT.triad       = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end 
            
%% Read LIMiter
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,3,' '));
            if strfind(keyword1(1:3),'LIM')==1
               DAT.limiter     = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end  
            
%% Read OBSTacle
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,4,' '));
            if strfind(keyword1(1:4),'OBS')==1
               DAT.obstacle    = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end  
            
%% Read SETUP
            if strfind(strtok(upper(rec)),'SETUP')==1
               DAT.setup       = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end  
            
%% Read DIFFRac
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,5,' '));
            if strfind(keyword1(1:5),'DIFFR')==1
               DAT.diffrac     = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end  
            
%% Read OFF
            if strfind(strtok(upper(rec)),'OFF')==1
               DAT.off         = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end     

%% Read PROP
            if strfind(strtok(upper(rec)),'PROP')==1
               DAT.prop        = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end    
            
%% Read MUD
            if strfind(strtok(upper(rec)),'MUD')==1
               if OPT.debug
                  disp('MUD')
               end             
               DAT.mud.disperr = 0;
               DAT.mud.disperi = 0;
               DAT.mud.source  = 0;
               DAT.mud.cg      = 0;
               [~,rec] = strtok(rec);
               DAT.mud         = swan_keyword(rec,... % expressionsfromstring
                                {'alpha','rhom','rho0','nu','layer','disperr','disperi','source','cg','power'});
               rec             = fgetlines_no_comment_line(fid);
            %else
            %   %% make emtpy matrices
            %   DAT.mud        = expressionsfromstring('',...
            %                    {'rhom','nu','layer','alpha'});
               foundkeyword    = true;
            end    

            j=0;
%% Read NUMeric
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,3,' '));
            while strfind(keyword1(1:3),'NUM')==1
               j               = j+1;
               keyword         = lower(strtok(upper(rec1)));
               DAT.(keyword){j}= rec1;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
              [keyword1,rec1]   = strtok(rec);
               keyword1         = upper(pad(keyword1,3,' '));
            end 
            
%% Read FRAME (overwrites previous)
            if strfind(strtok(upper(rec)),'FRAME')==1
               DAT.frame       = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end  
            
%% Read GROUP (overwrites previous)
            if strfind(strtok(upper(rec)),'GROUP')==1
               if OPT.debug
                  disp('GROUP')
               end             
               if isfield(DAT,'group')
                  N.groups = length(DAT.group)+1;
               else                  
                  N.groups = 1;
               end

               [keyword                      ,rec] = strtok(rec);
               [DAT.group(N.groups).sname    ,rec] = strtok(rec);
               [keyword            ,rec]          = strtok(rec);
               if ~isempty(strfind(keyword,'SUBG'))
                DAT.group(N.groups).subgrid        = 1;
               [DAT.group(N.groups).ix1      ,rec] = strtok(rec);
               else
               DAT.group(N.groups).subgrid         = 0;
               DAT.group(N.groups).ix1             = keyword;
               end
               
               [DAT.group(N.groups).ix2      ,rec] = strtok(rec);
               [DAT.group(N.groups).iy1      ,rec] = strtok(rec);
               [DAT.group(N.groups).iy2      ,rec] = strtok(rec);
               
               DAT.group(N.groups).ix1 = str2num(DAT.group(N.groups).ix1);
               DAT.group(N.groups).ix2 = str2num(DAT.group(N.groups).ix2);
               DAT.group(N.groups).iy1 = str2num(DAT.group(N.groups).iy1);
               DAT.group(N.groups).iy2 = str2num(DAT.group(N.groups).iy2);


               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end  
            
%% Read CURVE (overwrites previous)
            if strfind(strtok(upper(rec)),'CURVE')==1
               if OPT.debug
                  disp('CURVE')
               end 
               if isfield(DAT,'curve')
                  N.ncurves = length(DAT.curve)+1;
               else                  
                  N.ncurves = 1;
               end               
               [keyword            ,rec] = strtok(rec);
               
              [DAT.curve(N.ncurves).sname    ,rec] = strtok(rec);
               quotes = strfind(DAT.curve(N.ncurves).sname,'''');
               DAT.curve(N.ncurves).sname = DAT.curve(N.ncurves).sname(quotes(1)+1:quotes(end)-1); % remove quote, as looks for match in quote-less names
              [DAT.curve(N.ncurves).xp1       ,rec] = strtok(rec);
              [DAT.curve(N.ncurves).yp1       ,rec] = strtok(rec);
               DAT.curve(N.ncurves).int      = [];
               DAT.curve(N.ncurves).xp2      = [];
               DAT.curve(N.ncurves).yp2      = [];
              while ~isempty(rec)
              [DAT.curve(N.ncurves).int{end+1},rec] = strtok(rec);
              [DAT.curve(N.ncurves).xp2{end+1},rec] = strtok(rec);
              [DAT.curve(N.ncurves).yp2{end+1},rec] = strtok(rec);
              end

               DAT.curve(N.ncurves).xp1 =        str2num(DAT.curve(N.ncurves).xp1);
               DAT.curve(N.ncurves).yp1 =        str2num(DAT.curve(N.ncurves).yp1);
               DAT.curve(N.ncurves).int =       cellfun(@str2num,DAT.curve(N.ncurves).int);
               DAT.curve(N.ncurves).xp2 =       cellfun(@str2num,DAT.curve(N.ncurves).xp2);
               DAT.curve(N.ncurves).yp2 =       cellfun(@str2num,DAT.curve(N.ncurves).yp2);

               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;

            end            

%% Read RAY (overwrites previous)
            if strfind(strtok(upper(rec)),'RAY')==1
               DAT.ray         = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end            

%% Read ISOLINE (overwrites previous)
            if strfind(strtok(upper(rec)),'ISOLINE')==1
               DAT.isoline     = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end
            
%% Read POINTS (overwrites previous)
            if strfind(strtok(upper(rec)),'POINTS')==1
               if OPT.debug
                  disp('POINTS')
               end
               if isfield(DAT,'points')
                  N.points = length(DAT.points)+1;
               else                  
                  N.points = 1;
               end

               [keyword            ,rec]     = strtok(rec);
               [keyword            ,rec]     = strtok(rec);
               quotes                        = findstr(keyword, '''');
               DAT.points(N.points).sname    = keyword(quotes(1)+1:quotes(2)-1);
               [keyword            ,rec]     = strtok(rec);
               if strcmpi(keyword,'FILE')
                  [keyword            ,rec]  = strtok(rec);
                  quotes                     = findstr(keyword, '''');
                  DAT.points(N.points).fname = keyword(quotes(1)+1:quotes(end)-1);
                  
                  %% Load file as indicated in SWAN file:
                  %% * OK when it has a full path associated with it,
                  %% * WRONG when it has not a full path associated with it
                  %%   and swan_io_input is called in a different folder
                  %%   For that case we FIX THAT by also trying to load the file with the
                  %%   path of the input file appaned to it. However, this goes
                  %% * WRONG AGAIN when there is a file with the same name in the directory from 
                  %%   which swan_io_input is called. Because then that one prevails over
                  %%   the one in the swna input file directory. But that is a common
                  %%   problem with relative references.
                  
                     loaded = 0;
                  if ~isempty(dir                 ([DAT.points(N.points).fname]))
                     tmp   = load                 ([DAT.points(N.points).fname]);
                     if OPT.disp;disp(['loaded external file: ',DAT.points(N.points).fname]);end
                     loaded = 1;
                  end
                  if ~isempty(dir                 ([filepathstr(DAT.fullfilename),filesep,DAT.points(N.points).fname]))
                     tmp   = load                 ([filepathstr(DAT.fullfilename),filesep,DAT.points(N.points).fname]);
                     if OPT.disp;disp(['loaded external file: ',filepathstr(DAT.fullfilename),filesep,DAT.points(N.points).fname]);end
                     loaded = 1;
                     DAT.points(N.points).fname =  [filepathstr(DAT.fullfilename),filesep,DAT.points(N.points).fname];
                  end
                     
                  if (loaded)
                     DAT.points(N.points).xp = tmp(:,1);
                     DAT.points(N.points).yp = tmp(:,2);

                     if strcmpi(DAT.cgrid.type,'curvilinear')
                     DAT.points(N.points).xp(DAT.points(N.points).xp==DAT.cgrid.xexc) = nan;
                     DAT.points(N.points).yp(DAT.points(N.points).yp==DAT.cgrid.yexc) = nan;
                     end                     
                     
                  else
                     disp(['not found external file: ',DAT.points(N.points).fname])
                     %try
                     %tmp = load([DAT.file.path,filesep,DAT.points(N.points).fname]);
                     %catch
                     %tmp = load([DAT.file.path,filesep,filename(DAT.points(N.points).fname)]);
                     %end
                  end
                  
               else
                  [keyword            ,rec] = strtok(rec);
                  DAT.points(N.points).xp   = str2num(keyword);
                  [keyword            ,rec] = strtok(rec);
                  DAT.points(N.points).yp   = str2num(keyword);
               end
               
               foundkeyword    = true;
               rec             = fgetlines_no_comment_line(fid);
            end
            
%% Read NGRID (overwrites previous)
            if strfind(strtok(upper(rec)),'NGRID')==1
               if OPT.debug
                  disp('NGRID')
               end
               DAT.ngrid       = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end
            
%% Read QUANTity
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,5,' '));
            if strfind(keyword1(1:5),'QUANT')==1
               if OPT.debug
                  disp('NGRID')
               end
               DAT.quantity    = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end
            
%% Read OUTPut OPTIons
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,4,' '));
            if strfind(keyword1(1:4),'OUTP')==1
            %keyword = pad(strtok(rec),6,' ');
 	    %    if strcmp(strtok(keyword(1:4)),'OUTP')
               if OPT.debug
                  disp('OUTP')
               end
               DAT.output      = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end 
            
%% Read BLOCK (overwrites previous)
            if strfind(strtok(upper(rec)),'BLOCK')==1
               if OPT.debug
                  disp('BLOCK')
               end
               if isfield(DAT,'block')
                  N.blocks  = length(DAT.block)+1;
               else                  
                  N.blocks  = 1;
               end

               DAT.block{N.blocks} = rec;
               rec                = fgetlines_no_comment_line(fid);
               foundkeyword       = true;
            end

%% TABLE  
            if strfind(strtok(upper(rec)),'TABLE')==1
               if OPT.debug
                  disp('TABLE')
               end
               
               if isfield(DAT,'table')
                  N.tables = length(DAT.table)+1;
               else                  
                  N.tables = 1;
               end
               
               [keyword                      ,rec] = strtok(rec);
               [keyword                      ,rec] = strtok(rec);
                quotes                             = strfind(keyword,'''');
                DAT.table(N.tables).sname          = keyword(quotes(1)+1:quotes(end)-1);
                
               [DAT.table(N.tables).header   ,rec] = strtok(rec);
               [keyword                      ,rec] = strtok(rec);
                quotes                             = strfind(keyword,'''');
                
                if isempty(quotes) 
                if strcmpi(DAT.table(N.tables).header(1:4),'head')
                DAT.table(N.tables).fname          = ''; % added to PRINT file
                else
                end
                else
                DAT.table(N.tables).fname          = keyword(quotes(1)+1:quotes(end)-1);
                end
                
                %% add absolute directory of table file too
                tmp = dir(DAT.table(N.tables).fname);
                if length(tmp)==0
                DAT.table(N.tables).fullfilename = [filepathstr(DAT.fullfilename) filesep DAT.table(N.tables).fname];
                else
                DAT.table(N.tables).fullfilename = DAT.table(N.tables).fname;
                end

               %% remove double quotes (removes one letter with singel quotes)
               %quotes = find(DAT.table(N.tables).fname, '''')
               %DAT.table(N.tables).fname = DAT.table(N.tables).fname(quotes(1)+1:quotes(end)-1);
               
%-----------------------
% fix reading lines with intermediate $ like
%-----------------------
%TABLE 'COMPGRID' HEADER   'Kaihutu2007_refraction0refdef.hdr'  & $ fixed decimal point
%                                  XP YP DEP HSIGN RTP TM01 TM02 DISSIP DISBOT DISSURF DISWCAP &
%                                  FSPR DIR WLEN $ WLENMR KI MUDL               
%-----------------------

               output = strfind(rec,'OUT');
               if isempty(output)
               DAT.table(N.tables).parameters = strtrim(rec);
               else
               DAT.table(N.tables).parameters = strtrim(rec(1:output-1));
               DAT.table(N.tables).output     = rec(output:end);
               end
               
               %  Expand table parameter info
               %  ------------------------------------------

               DAT.table(N.tables).parameterlist   = DAT.table(N.tables).parameters;
               DAT.table(N.tables).parameter.names = strtokens2cell(DAT.table(N.tables).parameters);
               
               %%  Use keyword (OVKEYW), not short name (OVSNAM) to match quantity properties in SWAN_QUANTITY
               DAT.table(N.tables).parameter.names = swan_shortname2keyword(DAT.table(N.tables).parameter.names);
               
               %  Get vector yes(2)/no(1)
               %  -----------------------
               nfields = length(DAT.table(N.tables).parameter.names);
               for ifield=1:nfields
                  
                  fldname = char(deblank(DAT.table(N.tables).parameter.names{ifield}));
                  
                  DAT.table(N.tables).parameter.nfields = ones(1,nfields);
                  
                  if length(fldname) > 5
                     fldname = fldname(1:5);
                  end
                  
                  fldname = deblank(fldname);

                  if strcmpi(fldname,'VELOC') | ...
                     strcmpi(fldname,'TRANS') | ...
                     strcmpi(fldname,'WIND' ) | ...
                     strcmpi(fldname,'FORCE')

                      DAT.table(N.tables).parameter.nfields(ifield) = 2;

                  end
                  
               end % for ifield=1:length(shape.nfields)               
               
               %  Add grid info
               %  ------------------------------------------
               
               found = 0;
               
               if strcmpi(strtrim(DAT.table(N.tables).sname),'COMPGRID')
               
                     DAT.table(N.tables).type = DAT.cgrid.type;
                  if     strcmpi(DAT.cgrid.type(1:3),'reg')
                     DAT.table(N.tables).xpc  = DAT.cgrid.xpc  ;
                     DAT.table(N.tables).ypc  = DAT.cgrid.ypc  ;
                     DAT.table(N.tables).alcp = DAT.cgrid.alcp ;
                     DAT.table(N.tables).xlenc= DAT.cgrid.xlenc;
                     DAT.table(N.tables).ylenc= DAT.cgrid.ylenc;
                  elseif strcmpi(DAT.cgrid.type(1:3),'cur')
                     DAT.table(N.tables).xexc = DAT.cgrid.xexc ;
                     DAT.table(N.tables).yexc = DAT.cgrid.yexc ;
                  end
                     DAT.table(N.tables).mxc  = DAT.cgrid.mxc  ;
                     DAT.table(N.tables).myc  = DAT.cgrid.myc  ;
                  
                     found = 1;
               end
               
               if isfield(DAT,'curve') & ~found
               
                  for icurve=1:N.ncurves
                  if strcmpi(strtrim(DAT.table(N.tables).sname),...
                             strtrim(DAT.curve(icurve).sname ))
                  
                     DAT.table(N.tables).type = 'curve';
                    %DAT.table(N.tables).name = DAT.curve(N.ncurves).sname;
                     DAT.table(N.tables).xp1  = DAT.curve(N.ncurves).xp1 ;
                     DAT.table(N.tables).yp1  = DAT.curve(N.ncurves).yp1 ;
                     DAT.table(N.tables).int  = DAT.curve(N.ncurves).int ;               
                     DAT.table(N.tables).xp2  = DAT.curve(N.ncurves).xp2 ;
                     DAT.table(N.tables).yp2  = DAT.curve(N.ncurves).yp2 ;

                  %% number of meshes

                     DAT.table(N.tables).mxc  = sum(DAT.curve(N.ncurves).int);
                     DAT.table(N.tables).myc  = 0;
                  
                     found = 1;
                  end
                  end
               end   
               
               if isfield(DAT,'points') & ~found
               
                  for ipoints=1:N.points
                  if strcmpi(strtrim(DAT.table (N.tables).sname),...
                             strtrim(DAT.points(ipoints).sname))
                  
                     DAT.table(N.tables).type = 'points';
                    %DAT.table(N.tables).name = DAT.points.sname;
                     DAT.table(N.tables).points       = DAT.points(ipoints);
                     DAT.table(N.tables).points.index = ipoints;

                  %% number of meshes (only when external file is present)

                     if isfield(DAT.table(N.tables).points,'xp')
                     DAT.table(N.tables).mxc          = length(DAT.table(N.tables).points.xp)-1;
                     DAT.table(N.tables).myc          = 0;
                     end
                  
                     found = 1;
                  end               
                  end               
               end
               
               if isfield(DAT,'group') & ~found
               
                  for igroup=1:N.groups
                  if strcmpi(strtrim(DAT.table(N.tables).sname),...
                             strtrim(DAT.group(igroup ).sname ))
                  
                     DAT.table(N.tables).type = 'group';
                    %DAT.table(N.tables).name = DAT.group(igroup).sname;
                     DAT.table(N.tables).group       = DAT.group(igroup );
                     DAT.table(N.tables).group.index = igroup;
                     DAT.table(N.tables).ix1  = DAT.group(igroup).ix1;
                     DAT.table(N.tables).ix2  = DAT.group(igroup).ix2;
                     DAT.table(N.tables).iy1  = DAT.group(igroup).iy1;
                     DAT.table(N.tables).iy2  = DAT.group(igroup).iy2;
                  
                     found = 1;
                  end                  
                  end
                  
               end
               
               if ~found
                   disp(['Warning: No data found for TABLE using frame or group: ',DAT.table(N.tables).sname])
               end
               
               rec             = fgetlines_no_comment_line(fid);
               
               % still to search for OUTPUT
               
               foundkeyword = true;
            end               

%% Read SPECout
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,4,' '));
               
            if strfind(keyword1(1:4),'SPEC')==1
               if OPT.debug
                  disp('SPEC')
               end
               if isfield(DAT,'spec')
                  N.specs  = length(DAT.spec)+1;
               else                  
                  N.specs  = 1;
               end
               
              [keyword                                ,rec] = strtok(rec);
              [DAT.spec(N.specs).sname                 ,rec] = strtok(rec);
               quotes = strfind(DAT.spec(N.specs).sname, '''');
               DAT.spec(N.specs).sname = DAT.spec(N.specs).sname(quotes(1)+1:quotes(end)-1);
               
              [keyword                                ,rec] = strtok(rec);
               if     strcmpi(keyword,'spec1d')
               DAT.spec(N.specs).dimension_of_spectrum       = 1;
               elseif strcmpi(keyword,'spec2d')
               DAT.spec(N.specs).dimension_of_spectrum       = 2;
               end
              
              [keyword                                ,rec] = strtok(rec);
               if     strcmpi(keyword(1:3),'abs')
               DAT.spec(N.specs).frequency_type              = 'relative';
              [keyword                 ,rec] = strtok(rec);
               elseif strcmpi(keyword(1:3),'rel')
               DAT.spec(N.specs).frequency_type              = 'absolute';
              [keyword                 ,rec] = strtok(rec);
               else
               DAT.spec(N.specs).frequency_type              = 'absolute'; % default
               end

               quotes = strfind(keyword, '''');
               DAT.spec(N.specs).fname = keyword(quotes(1)+1:quotes(end)-1);

               %% add absolute directory of table file too
               tmp = dir(DAT.spec(N.specs).fname);
               if length(tmp)==0
               DAT.spec(N.specs).fullfilename = [filepathstr(DAT.fullfilename) filesep DAT.spec(N.specs).fname];
               else
               DAT.spec(N.specs).fullfilename = DAT.spec(N.specs).fname;
               end

               if ~isempty(deblank(rec))
               DAT.spec(N.specs).REST                        = rec;
               end

               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
               
            end
            
%% Read NESTout
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,4,' '));
               
            if strfind(keyword1(1:4),'NEST')==1
               DAT.nest = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end

%% Read TEST
            if strfind(strtok(upper(rec)),'TEST')==1
              %DAT.test        = rec;
               raw             = rec;

              [keyword,rec] = strtok(raw); % TEST
              [keyword,rec] = strtok(rec); % POINTS ?
              
               if ~strcmpi(keyword,'points')
               
               DAT.test.itest  = str2num(keyword);
               [keyword,rec]   = strtok(rec);
               DAT.test.itrace = str2num(keyword);
               [keyword,rec]   = strtok(rec); % POINTS ?
               
               end
                            
               if strcmpi(keyword,'points')

                  [keyword,rec]   = strtok(rec); % IJ, XY ?
               
                  %  Read the list with test points
                  %  ------------------------------
                  
                  if strcmpi(keyword,'ij')
                     partype = 'ij';
                  elseif strcmpi(keyword,'xy')
                     partype = 'xy';
                  end
                  
              [   keyword,rec]   = strtok(rec);
                  
                  ntestpoints = 0;
                  
                  while ~strcmpi(keyword,'PAR') & ...
                        ~strcmpi(keyword,'S1D') & ...
                        ~strcmpi(keyword,'S2D')
                     
                    coordinates           = str2num(keyword);
                    [keyword,rec]         = strtok(rec);
                    coordinates(2)        = str2num(keyword);
                    
                    ntestpoints = ntestpoints + 1;
                    
                    DAT.test.(partype)(:,ntestpoints)  = coordinates;
                  
                     [keyword,rec]        = strtok(rec); % IJ, XY ?               
                  
                  end
               
               end % points

               %  Read the test file names
               %  ------------------------------    
               
               if strcmpi(keyword,'PAR')
                 [keyword,rec]       = strtok(rec);
                  quotes             = findstr(keyword, '''');
                  DAT.test.par.fname = keyword(quotes(1)+1:quotes(2)-1);
                 [keyword,rec]       = strtok(rec);
               end
               
               if strcmpi(keyword,'S1D')
                 [keyword,rec]       = strtok(rec);
                  quotes             = findstr(keyword, '''');
                  DAT.test.s1d.fname = keyword(quotes(1)+1:quotes(2)-1);
                 [keyword,rec]       = strtok(rec);
               end
               
               if strcmpi(keyword,'S2D')
                 [keyword,rec]       = strtok(rec);
                  quotes             = findstr(keyword, '''');
                  DAT.test.s2d.fname = keyword(quotes(1)+1:quotes(2)-1);
                 [keyword,rec]       = strtok(rec);
               end               
               
               rec          = fgetlines_no_comment_line(fid);
               foundkeyword = true;

            end % test            
	  
%% Read COMPUTE

               timeformat = 'yyyymmdd.HHMMSS';

              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,4,' '));
            if strfind(keyword1(1:4),'COMP')==1
               if DAT.mode.stationary
                [keyword,rec] = strtok(rec);
                 if ~isempty(rec);
                    error('STATionary simiulations shouldn''t have any arguments after COMPUTE');
                 end
                 DAT.compute.time    = [];
                 DAT.compute.datenum = [];
               else
                [keyword,rec] = strtok(rec);
                [keyword,rec] = strtok(rec);
                 if     strcmp(keyword(1:4),'STAT')
                 [keyword,rec] = strtok(rec);
                  DAT.compute.time    = keyword;
                  DAT.compute.datenum = datenum(keyword,timeformat);
                 elseif strcmp(keyword(1:5),'NONST')
                 [tbegc,rec] = strtok(rec);tbegc = datenum(tbegc,timeformat);
                 [deltc,rec] = strtok(rec);deltc = str2num(deltc);
                 [units,rec] = strtok(rec);deltc = deltc*convert_units(units,'day');
                 [tendc,rec] = strtok(rec);tendc = datenum(tendc,timeformat);
                 
                  DAT.compute.tbegc = tbegc;
                  DAT.compute.deltc = deltc;
                  DAT.compute.units = units;
                  DAT.compute.tendc = tendc;
                  DAT.compute.datenum = DAT.compute.tbegc:DAT.compute.deltc:DAT.compute.tendc;
                 end
               end
               
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword = true;
            end  
            
%% Read HOTFile
              [keyword1,rec1]   = strtok(rec);
               if isempty(keyword1);
               keyword1         = ' ';
               end
               keyword1         = upper(pad(keyword1,4,' '));
            if strfind(keyword1(1:4),'HOTF')==1
               DAT.hotfile     = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end 
            
%% Read STOP
            if strfind(upper(rec),'STOP')==1
               DAT.stop        = rec;
               rec             = fgetlines_no_comment_line(fid);
               foundkeyword    = true;
            end        
            
            if ~foundkeyword
               disp(rec)
               error('keyword on previous line not found, because not implemented.')
            end

   end % function DAT = addkeyword(fid,DAT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read a data line and concatenate if if continous on the next line
% and also skip any comment line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   function multilinerec   = fgetlines_no_comment_line(fid);
% TO DO: make sure comment is treated as all data on a SWAN line (_& continuation) in between $ or after last (odd) $
   
      rec                  = fgetl_no_comment_line(fid,'$',0,1); % do not allow empty lines, do remove spaces at start (no tabs yet)
      if isnumeric(rec) % eof -1
          multilinerec = '';
          return
      end

      %% remove inline + end-of-line comments
      ind = strfind(rec,'$');
      if ~isempty(ind) & ~isempty(rec)
         recraw = rec;
         rec    = [];
         if odd(length(ind))
            ind = [0 ind];
         else
            ind = [0 ind (length(recraw)+1)];
         end
         for ii=1:2:length(ind)
            rec = [rec recraw(ind(ii)+1:ind(ii+1)-1)];
         end
      end
      
      continuationmarks    = sort([strfind(deblank(rec),'_') ,...
                                   strfind(deblank(rec),'&')]);
                                 
      continuationmarks    = remove_characters_between_quotes_in_string_from_list(rec,continuationmarks);

      multilinerec         = [];
      
      while ~isempty(continuationmarks) % note that comment can follow each line after the continuationmarks
         % strcat removes blanks
         multilinerec      = [multilinerec,rec(1:continuationmarks-1)];

         rec               = fgetl_no_comment_line(fid,'$',0,1); % do not allow empty lines, do remove spaces at start (no tabs yet)
         %% remove inline + end-of-line comments
         ind = strfind(rec,'$');
         if ~isempty(ind) & ~isempty(rec)
            recraw = rec;
            rec    = [];
            if odd(length(ind))
               ind = [0 ind];
            else
               ind = [0 ind (length(recraw)+1)];
            end
            for ii=1:2:length(ind)
                rec = [rec recraw(ind(ii)+1:ind(ii+1)-1)];
            end
         end       
         
         continuationmarks = sort([strfind(deblank(rec),'_') ,...
                                   strfind(deblank(rec),'&')]);
      
         continuationmarks = remove_characters_between_quotes_in_string_from_list(rec,continuationmarks);

      end
      % strcat removes blanks
      multilinerec = [multilinerec,rec];
   end % function fgetlines_no_comment_line

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   function characters = remove_characters_between_quotes_in_string_from_list(rec,characters);

      characters2keep = ones(size(characters));
      stringmarks     = sort([strfind(deblank(rec),'''') ,...
                              strfind(deblank(rec),'"')]);
                              
      if ~isempty(stringmarks)'
         for i=1:2:length(stringmarks)
         %[i stringmarks(i  ) stringmarks(i+1)]
            for j=1:length(characters)
                   if characters(j) > stringmarks(i  ) & ...
                      characters(j) < stringmarks(i+1)
                      % this continuationmark is part of  file name or something like
                  characters2keep(j) = 0;
                   end
            end
         end
         characters = characters(logical(characters2keep));
      end
      
   end % function remove_characters_between_quotes_in_string_from_list
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   end % function, so all variables above are global within the scope of this file (part bewteen 'function' and this 'end')

%% EOF
