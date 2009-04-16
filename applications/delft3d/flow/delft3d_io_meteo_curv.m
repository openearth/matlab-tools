function varargout = delft3d_io_meteo_curv(cmd,varargin)
%DELFT3D_IO_METEO_CURV    Read/write meteo files defined on curvi-linear grid (IN PROGRESS)
%
% D = DELFT3D_IO_METEO_CURV('read',fname) reads Delftd3D flow meteo file into struct D.
%
% D = DELFT3D_IO_METEO_CURV('read',fname,<keyword,value>)  
%
% Where the following keyword,value have been implemented
% * timestep : the time step to load from the file
%              - 0       is first timestep
%              - integer is specific timestep number
%              - Inf     is all timesteps
%              - []      is next timestep (not yet implemented)
%
% See also: DELFT3D_IO_BND, DELFT3D_IO_BCA, DELFT3D_IO_BCH,  
%           DELFT3D_IO_CRS, DELFT3D_IO_DEP, DELFT3D_IO_DRY,, DELFT3D_IO_EVA 
%           DELFT3D_IO_GRD, DELFT3D_IO_INI, DELFT3D_IO_OBS,  
%           DELFT3D_IO_SRC, DELFT3D_IO_THD, DELFT3D_IO_RESTART
%           DELFT3D_IO_WND, DELFT3D_IO_TEM, DELFT3D_IO_MDF, 
%           KNMIHYDRA, HMCZ_WIND_READ

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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_meteo_curv(''read''/''write'',filename)'])
end

warning('In progress ...')

%% Switch read/write
%% ------------------

switch lower(cmd)

case 'read'

  [DAT,iostat] = Local_read(varargin{1:end});

  if     nargout <2

     varargout  = {DAT};
     
     if iostat<1
        error('Error reading.')
     end
  
  elseif nargout  == 2
  
     varargout  = {DAT,iostat};
  
  elseif nargout >2
  
     error('too much output parameters: 1 or 2')
  
  end

case 'write'

  iostat = Local_write(varargin{1:end});
  
  if nargout ==1
  
     varargout = {iostat};
  
  elseif nargout >1
  
     error('too much output parameters: 0 or 1')
  
  end
  
end;


% ------------------------------------
% --READ------------------------------
% ------------------------------------

function varargout=Local_read(fname,varargin),

   D.filename       = fname;
   iostat           = -1;

   %% Keywords
   %% -----------------
   
   H.timestep         = 0;
   H.numeric_keywords = {'NODATA_value',...
                               'n_cols',...
                               'n_rows',...
                           'x_llcorner',...
                           'y_llcorner',...
                                   'dx',...
                                   'dy',...
                           'n_quantity'};
   
   if nargin>2
      if isstruct(varargin{2})
         H = mergestructs(H,varargin{2});
      else
         iargin = 1;
         %% remaining number of arguments is always even now
         while iargin<=nargin-1,
             switch lower ( varargin{iargin})
             % all keywords lower case
             case 'timestep'         ;iargin=iargin+1;H.timestep         = varargin{iargin};
             case 'numeric_keywords' ;iargin=iargin+1;H.numeric_keywords = varargin{iargin};
             otherwise
               error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
             end
             iargin=iargin+1;
         end
      end  
   end
   
   %% Locate
   %% ------------------------
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      D.iostat = -1;
      disp (['??? Error using ==> delft3d_io_meteo_curv'])
      disp (['Error finding meteo file: ',fname])
      
   elseif length(tmp)>0
   
      D.filedate  = tmp.date;
      D.filebytes = tmp.bytes;
   
      %% Read
      %% ------------------------
         
      %try
      
         fid           = fopen(fname,'r');
        %rec           = fgetl_no_comment_line(fid,'#');
        %[keyword,rec] = strtok(rec);
        %[issign ,rec] = strtok(rec);
        %[value  ,rec] = strtok(rec);
         [keyword,value,rec] = fgetl_key_val(fid,'#');

         %% Read header
         %% ----------------------------

         while ~strcmpi(keyword,'TIME')
            
            D.data.keywords.(keyword)   = value;

           %rec           = fgetl_no_comment_line(fid,'#');
           %[keyword,rec] = strtok(rec);
           %[issign ,rec] = strtok(rec);
           %[value  ,rec] = strtok(rec);
            [keyword,value,rec] = fgetl_key_val(fid,'#');
         
         end
         
         %% Process header
         %% ----------------------------

         keywords = fieldnames(D.data.keywords);
         for inum=1:length(H.numeric_keywords)
         for ikey=1:length(keywords)
            if strcmpi(H.numeric_keywords(inum),keywords(ikey))
               D.data.keywords.(keywords{ikey}) = str2num(D.data.keywords.(keywords{ikey}));
            end
         end
         end
         
         %% Make or read grid (corners AND centers)
         %% ----------------------------

         if     isfield(D.data.keywords,'curvi_grid_file')
         
            %% Read external grid (corners AND centers)
            %% ----------------------------
            
            %[D.data.cor.x,D.data.cor.y,dummy]=wlgrid('read',D.data.keywords.curvi_grid_file)
            
            %D.data.cen.x = corner2center(D.data.cor.x);
            %D.data.cen.y = corner2center(D.data.cor.y);
            
             D.data.keywords.n_rows = 130; % size(D.data.cor,1 or 2) | size(D.data.cor,1 or 2)
             D.data.keywords.n_cols = 291; % size(D.data.cor,2 or 1) | size(D.data.cor,2 or 1)
            
            warning ('How to know difference degrees and meters, that is not written in grd file ... ?')

         elseif isfield(D.data.keywords,'n_cols')

            %% Make grid (corners AND centers)
            %% ----------------------------
            
            if ~isempty(H.timestep)
	    
               if strcmpi(D.data.keywords.grid_unit,'degrees')
               D.data.cen.lonSticks   = D.data.keywords.x_llcorner + [0.5:1:(D.data.keywords.n_cols-0.5)].*D.data.keywords.dx;
               D.data.cen.latSticks   = D.data.keywords.y_llcorner + [0.5:1:(D.data.keywords.n_rows-0.5)].*D.data.keywords.dy;
               
               D.data.cor.lonSticks   = D.data.keywords.x_llcorner + [0  :1:(D.data.keywords.n_cols    )].*D.data.keywords.dx;
               D.data.cor.latSticks   = D.data.keywords.y_llcorner + [0  :1:(D.data.keywords.n_rows    )].*D.data.keywords.dy;
	    
              [D.data.cen.lon,...
               D.data.cen.lat]        = meshgrid(D.data.cen.lonSticks,D.data.cen.latSticks);
	    
              [D.data.cor.lon,...
               D.data.cor.lat]        = meshgrid(D.data.cor.lonSticks,D.data.cor.latSticks);
	    
               else
               D.data.cen.xSticks     = D.data.keywords.x_llcorner + [0.5:1:(D.data.keywords.n_cols-0.5)].*D.data.keywords.dx;
               D.data.cen.ySticks     = D.data.keywords.y_llcorner + [0.5:1:(D.data.keywords.n_rows-0.5)].*D.data.keywords.dy;
               
               D.data.cor.xSticks     = D.data.keywords.x_llcorner + [0  :1:(D.data.keywords.n_cols    )].*D.data.keywords.dx;
               D.data.cor.ySticks     = D.data.keywords.y_llcorner + [0  :1:(D.data.keywords.n_rows    )].*D.data.keywords.dy;
	    
              [D.data.cen.x  ,...
               D.data.cen.y  ]        = meshgrid(D.data.cen.xSticks ,D.data.cen.ySticks   );
	    
              [D.data.cor.x  ,...
               D.data.cor.y  ]        = meshgrid(D.data.cor.xSticks ,D.data.cor.ySticks   );
	    
               end
               
            end
            
         end
            
         %% Read data
         %% * JUST THE FIRST ONE FOR NOW
         %% + all 
         %% + one specified time/inded
         %% + scroll file to find number of times first?
         %% + or simply read next field ?
         %% ----------------------------
         %% better method is to rewind one lione and than make a subfucction that reads one block incl. time
         %% ----------------------------
            
         if ~strcmpi(keyword,'time') & ~isempty(H.timestep)
            disp('No data in file')
         else
         
            timestep = 1;
         
            while 1
         
               if isempty(H.timestep) | timestep > 1
                 %rec           = fgetl_no_comment_line(fid,'#');
                 %[keyword,rec] = strtok(rec);
                 %[issign ,rec] = strtok(rec);
                 %[value  ,rec] = strtok(rec);
                  [keyword,value,rec] = fgetl_key_val(fid,'#');
                  if isempty(keyword)
                     break
                  end
               end
               
               % Load block
               rawblock = fscanf(fid,'%f',[D.data.keywords.n_cols D.data.keywords.n_rows]);

               % The upper left numer of the ASCII file belongs to index
               % (1,1), so swap in y-direction
               rawblock = fliplr(rawblock);

               % NaNs
               rawblock(rawblock==D.data.keywords.NODATA_value) = NaN;
               
               if isinf(H.timestep)
                  D.data.time{timestep}                                = [value,' ',rec]; % note that spaces in between are lost, so put one bakc for proper workings of strtok
                 [D.data.datenum(timestep) ,...
                  D.data.timezone{timestep}]                           = cfstring2datenum(D.data.time{timestep});
                  D.data.cen.(D.data.keywords.quantity1)(:,:,timestep) = rawblock;
               elseif H.timestep==0 | H.timestep==timestep
                  D.data.time                                          = [value,' ',rec];
                 [D.data.datenum ,...
                  D.data.timezone]                                     = cfstring2datenum(D.data.time);
                  D.data.cen.(D.data.keywords.quantity1)(:,:)          = rawblock;
                  break
               end
               timestep = timestep + 1;
            end
            
            D.data.time = char(D.data.time);
            D.data.datestr = datestr(D.data.datenum,0);

         end
         
         %% Finished succesfully
         %% --------------------------------------
   
         fclose(fid);

         D.iostat    = 1;
         D.read_by   = 'delft3d_io_meteo_curv.m';
         D.read_at   = datestr(now);
         
      %catch
      %
      %   D.iostat = -3;
      %   disp (['??? Error using ==> delft3d_io_meteo_curv'])
      %   disp (['Error reading meteo file: ',fname])
      %
      %end % catch
   
   end %elseif length(tmp)>0

if nargout==1
   varargout = {D};   
else
   varargout = {D,D.iostat};   
end

end % function varargout=Local_read(fname,varargin),

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------

function iostat=Local_write(fname,DAT,varargin),

   iostat       = 0;


   %% Keywords
   %% -----------------

      H.userfieldnames = false;

      if nargin>2
         if isstruct(varargin{2})
            H = mergestructs(H,varargin{2});
         else
            iargin = 2;
            %% remaining number of arguments is always even now
            while iargin<=nargin-1,
                switch lower ( varargin{iargin})
                % all keywords lower case
                case 'userfieldnames';iargin=iargin+1;H.parameternames = varargin{iargin};
                otherwise
                  error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
                end
                iargin=iargin+1;
            end
         end  
      end

   %% Locate
   %% ------------------------
   
   tmp       = dir(fname);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else

      while ~islogical(writefile)
         disp(['Meteo file already exists: ''',fname,'''']);
         writefile    = input('o<verwrite> / c<ancel>: ','s');
         if strcmpi(writefile(1),'o')
            writefile = true;
         elseif strcmpi(writefile(1),'c')
            writefile = false;
            iostat    = 0;
         end
      end

   end % length(tmp)==0
   
   if writefile

     %% Open
     %% ------------------------

         %try
         
            iostat = 1;

      %end % fid
      
   end % writefile
   
end % function iostat=Local_write(fname,DAT,varargin),

end % function varargout=delft3d_io_meteo_curv(cmd,varargin),
   
%% EOF   

