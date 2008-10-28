function varargout = delft3d_io_bca(cmd,varargin)
%DELFT3D_IO_BCA   read/write astronomical boundary table (*.bca) <<beta version!>>
%
%       delft3d_io_bca('write',bcafile,BCA,BND)
% Ok  = delft3d_io_bca('write',bcafile,BCA,BND)
%
% BCA = delft3d_io_bca('read' ,bcafile,BND,ncomponents)
%
% where the BND struct comes from BND = delft3d_bnd_io(...)
% and the BCA struct looks like this, with subfields 
% amp [m] and phi [deg]:
%
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).amp      (1:ncomponents)
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).phi      (1:ncomponents)
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).names    (1:ncomponents)
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).Label
%
% where the indices in DATA are in the order of the *.bnd file.
%
% For reading ncomponents has to be passed, which is the exact number 
% of components in the bcafile. It is the same for all boundaries.
%
% NOTE:
% Currently it is not possible to have a different number of components 
% per boundary. The reason for this is that boundary names and 
% component names cannot be distuinguished from another.
%
% a1) we need to include a table with possible names for that in delft3d_io_bca
% a2) we need the guarantee that labels cannot have the same name as 
%     components (checked by GUI).
% b1) Or we can try to see whether we have a component by looking if
%     there are any numeric data past character 8 on a line in the *.bca file.
% c1) we can try to convince DHS to adapt the *.bca file by incorporating one
%     line with the number of components after the line with the Label....
%
% G.J. de Boer, March 8th 2006
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 
%           bct2bca

% 2008 Jul 11: removed error in writing labels (%c instead of %12s to prevent leading blanks) [Anton de Fockert]
% 2008 Jul 21: more decimals in output for Nuemann boundary [Anton de Fockert]

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_bca(''read''/''write'',filename)'])
end

switch lower(cmd),

case 'read',
  STRUCT=Local_read(varargin{:});
  if nargout==1
     varargout = {STRUCT};
  elseif nargout >1
    error('too much output paramters: 0 or 1')
  end
  if STRUCT.iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;

case 'write',
  iostat=Local_write(varargin{:});
  if nargout==1
     varargout = {iostat};
  elseif nargout >1
    error('too much output paramters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function BCA=Local_read(bcafile,BND,ncomponents)

fid     = fopen(bcafile,'r');

if fid > 0 

   BCA.filename = bcafile;
   BCA.phi_unit = 'deg';
   
   while 1   
   
      labelAB = fgetl(fid);
      
      if ~ischar(labelAB), break, end
      
      %% Scroll linearly trough the *.bca file and find associated boundary 
      %% name(s) in the *.bnd file.
      %%
      %% Other way round would also be possible
      %% I.e. scroll trough *.bnd file and find associated table in *.bca file by 
      %% reading the *.bca file again for every boundary segment.
      %% This obviously requires much more file io, which is generally slow..
      %%
      %% The idea generally used in numerical models that two neighbouring boundary 
      %% segments can share one tidal specification point (one Label) is bullshit 
      %% in Delft3D since in Delft3D two neighbouring boundaries have water level
      %% points 1dx apart.
      %% -------------------------------
   
      isize = 0;
      
      %% For every boundary segment in the bca file, check 3 things
      %% --------------------------------------------

      for ibnd = 1:BND.NTables
         
         %% 1) whether is defined as astronimical, and if yes
         %% --------------------------------------------

         if ~lower(BND.DATA(ibnd).datatype)=='a'
   
            %% This warning should not appears for every block in the bca file
            %% as we scroll through the bca file ....
            %% Check for existance field name "displayed_warning"

            if ~(BND.DATA(ibnd).displayed_warning)
               disp(['Boundary ''',BND.DATA(ibnd).name,''' in *.bnd not defined as astronomical, ignored.'])
               BND.DATA(ibnd).displayed_warning = true;
            end
            isize = 0;
            break;
            
         %% 2) whether is has labels, and if yes
         %% --------------------------------------------

            if ~isfield(BND.DATA(ibnd),'labelA') | ...
               ~isfield(BND.DATA(ibnd),'labelB')
   
               error(['Boundary ''',BND.DATA(ibnd).name,''' in *.bnd defined as astronomical, but has no point labels.'])
   
            end
   
         end
   
         %% Labels determine whether we are on side 1 or 2
         %% --------------------------------------------
         
         if     strcmp(deblank2(labelAB),deblank2(BND.DATA(ibnd).labelA))
            isize = 1;
            break
         elseif strcmp(deblank2(labelAB),deblank2(BND.DATA(ibnd).labelB))
            isize = 2;
            break
   
         end
      
      end % for ibnd = 1:BND.NTables
      
      %% 3) whether the label has an associated table in the bca file.
      %% --------------------------------------------

      if isize==0

         disp (['Boundary ''',BND.DATA(ibnd).name,''' with label ',deblank(labelAB),', has no table in *.bca file.'])
         error(['Note that every Table (Label) in the bca file can be used by 1 bounary, boundaries segment cannot share labels as their end points are 1 gridcell apart...'])
         
      else
      
      %% Everything is OK, now read the data
      %% -------------------------------

         BCA.DATA(ibnd,isize).names   = [];
         BCA.DATA(ibnd,isize).Label   = deblank(labelAB);
         
         for icomp                    = 1:ncomponents
            record                    = fgetl(fid);
            componentname             = sscanf(record,'%s',1);
            ASCII_lenght_of_component = length(componentname);
            amp_phi                   = sscanf(record(ASCII_lenght_of_component+1:end),'%f',2);
            
            BCA.DATA(ibnd,isize).amp(icomp) = amp_phi(1);
            BCA.DATA(ibnd,isize).phi(icomp) = amp_phi(2);

            %% make it a 2D char array
            %% cell array would also be possible
            %% FOrtunetely, the *.bca write routine can handle both
            
            BCA.DATA(ibnd,isize).names      = strvcat(BCA.DATA(ibnd,isize).names,...
                                                      deblank(componentname));

         end
         
      end
   
   end % while 1   
   
   fclose(fid);
   
   BCA.iostat = 1;

else   

   error(['Opening file ',bcafile])

end % if fid > 0 

% ------------------------------------
% ------------------------------------
% ------------------------------------

function varargout = Local_write(bcafile,BCA,BND),

iostat = 0;

fid = fopen(bcafile,'w');

if fid > 0 

   for ibnd = 1:BND.NTables
   
      for iside = 1:2
      
             if iside==1
            fprintf(fid,'%c'  ,deblank2(BND.DATA(ibnd).labelA)); % format '%12s' results in leading spaces
         elseif iside==2
            fprintf(fid,'%c'  ,deblank2(BND.DATA(ibnd).labelB)); % format '%12s' results in leading spaces
         end
         
         fprintf(fid,'\n');
   
         for icomp=1:length(BCA.DATA(ibnd,iside).amp)
         
            % if strmatch('RHO' ,component); component = 'RO1'     ; end
            % if strmatch('SIG' ,component); component = 'SIGMA1'  ; end
            % if strmatch('THE1',component); component = 'THETA1'  ; end
            % if strmatch('PHI1',component); component = 'FI1'     ; end
            % if strmatch('UPS1',component); component = 'UPSILON1'; end
            % if strmatch('EPS2',component); component = 'EPSILON2'; end            
            % if strmatch('LDA2',component); component = 'LABDA2'  ; end
            % if strmatch('2MK5',component); component = '3MO5'    ; end            
            % if strmatch('3MK7',component); component = '2MSO7'   ; end          
       
            if iscell(BCA.DATA(ibnd,iside).names)
            component = char(BCA.DATA(ibnd,iside).names{icomp});
            elseif ischar(BCA.DATA(ibnd,iside).names)
            component = char(BCA.DATA(ibnd,iside).names(icomp,:));
            end
            
            amp       =      BCA.DATA(ibnd,iside).amp  (icomp);
            phase     =      BCA.DATA(ibnd,iside).phi  (icomp);
   	 
           %fprintf(fid,'%8s %f7    %f7',pad(component,8,' '),amp,phase);
            fprintf(fid,'%8s %15.7e %f7',pad(component,8,' '),amp,phase); % more decimals to get sufficient decimals for Neumann boundary
            fprintf(fid,'\n');
            
         end % for icmp=1:length(BCA.components)
   
      end %  for iside = 1:2
      
   end % for ibnd = 1:BND.NTables
   
   fid = fclose(fid);
   
end % if fid > 0 
   
if ~(fid==-1)
  iostat = 1;
end

if nargout == 1
   
   varargout = {iostat};
   
end

%% EOF