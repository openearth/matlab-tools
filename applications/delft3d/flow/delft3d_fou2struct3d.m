function MATLAB_STRUCT = delft3d_fou2struct3d(TEKAL_DATA_STRUCT)
%DELFT3D_FOU2STRUCT3D   transforms fourier data to struct
%
% MATLAB_STRUCT = delft3d_fou2struct3d.m(TEKAL_DATA_STRUCT)
% MATLAB_STRUCT = delft3d_fou2struct3d.m(TEKAL_DATA_STRUCT)
%
% Transforms the data in a tekal fourier file to a matlab struct.
% Handy for LAAAARGE fourier files.
%
% Note that the function does not allow one parameter (frequencies,layer) to be 
% determined twice (by performing the same analysis in two different time
% intervals of equal lenght). The last parameter encountered in the foruier file
% is then saved to the struct.
%
% Is is not possible to merge the fourier analysis of the velicities
% with the ellipcitical properties into one field for the 
% velocities. The cause for this is that the calculation of the elliptical
% properties is optional.
% 
% TEKAL_DATA_STRUCT and MATLAB_STRUCT are defined as global variables,
% so use these names also in the calling procedure and define them there 
% global as well to save memory.
%
% See also: DELFT3D_IO_FOU, FFT_ANAL, T_TIDE

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

% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

global TEKAL_DATA_STRUCT MATLAB_STRUCT

if ischar(TEKAL_DATA_STRUCT)
   disp('Reading ASCII fourier file, please wait ...')
   TEKAL_DATA_STRUCT = tekal('open',TEKAL_DATA_STRUCT);
end

add_times2variable_name = 0; % default variable name is variable__layer__ncycles
                             % when performing a similar fourier analysis in different
                             % time intervals, the variable names are not unique

disp('Transforming TEKAL struct into matlab struct, please wait ...')
[MATLAB_STRUCT,OK] = tekal2hdf(TEKAL_DATA_STRUCT,add_times2variable_name);

if (~add_times2variable_name) & (~OK)
[MATLAB_STRUCT,OK] = tekal2hdf(TEKAL_DATA_STRUCT,add_ellips2fou,add_times2variable_name);
end

%% #######################################
%% #######################################
%% #######################################

function [MATLAB_STRUCT,OK] = tekal2hdf(TEKAL_DATA_STRUCT,add_times2variable_name)

%% Initialise
%% --------------------------

nfield            = length(TEKAL_DATA_STRUCT.Field);
first             = 1;
OK                = 1;
debugopt          = 0;

MATLAB_STRUCT.nodatavalue = nan;

for ifield = 1:nfield

   % disp(num2str(ifield))

   ncolumn = size(TEKAL_DATA_STRUCT.Field(ifield).Data,3);
   
   %% Read comment lines
   %% --------------------------

   if first
   
      MATLAB_STRUCT.xcen = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,1));
      MATLAB_STRUCT.ycen = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,2));
      MATLAB_STRUCT.xcor = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,3));
      MATLAB_STRUCT.ycor = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,4));
      MATLAB_STRUCT.m    = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,5));
      MATLAB_STRUCT.n    = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,6));
      
      %if add_times2variable_name
      %MATLAB_STRUCT(ifield).how_does_this_struct_work = 'parametername__analysistype_tstart_tstop';
      %else
      %MATLAB_STRUCT(ifield).how_does_this_struct_work = 'parametername__analysistype';
      %end
      
      skipCommentlines = 1;

   else
   
      skipCommentlines = 0;
   
   end
   
   i = skipCommentlines + 1;
   parameter          = deblank2(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(32:end));
   i = i + 1;
   if strcmp(lower(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(3:7)),'layer')
   layer              =  str2num(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(32:end));
   i = i + 1;
   else
   layer              =  1;
   end
   t_start            =  str2num(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(32:end));
   i = i + 1;
   t_stop             =  str2num(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(32:end));
   i = i + 1;
   n_cycles           =  str2num(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(32:end));
   i = i + 1;
   frequency_deg_p_hr =  str2num(TEKAL_DATA_STRUCT.Field(ifield).Comments{i}(32:end));
   i = i + 1;  
   
   %% fou:  - Fourier amplitude for water levels
   %%       - Fou amp u1 for velocities
   %% amp:  - Fou amp u1
   %% min:  - Minimum value for water levels
   %%       - Min u1 for velocities
   %% max:  - Maximum value for water levels
   %%       - Max u1 for velocities
   %% avg:  - when fou and ncycles==0
   %% --------------------------
   analysis_type = lower(char(TEKAL_DATA_STRUCT.Field(ifield).ColLabels{7}(1:3)));
   
   if strcmp(analysis_type,'fou') & n_cycles ==0
      analysis_type = 'avg';
   end

   %% Determine variable field names
   %% based on meta information
   %% - remove traling blanks
   %% - allow only letters, and numbers
   %% - only small case
   %% --------------------------
   
   if add_times2variable_name
   parameter_name      = lower(mkvar([deblank2(parameter),'_',...
                                      analysis_type,'__',...
                                      num2str(t_start ,'%0.9d'),'__',...
                                      num2str(t_stop  ,'%0.9d')]));
   else
   parameter_name      = lower(mkvar([deblank2(parameter),'__',...
                                      analysis_type]));
   end
   
   %% Copy meta information to variable field
   %% --------------------------
  
   MATLAB_STRUCT.(parameter_name).parameter          = parameter;
   
   if ~isfield(MATLAB_STRUCT.(parameter_name),'layer'             ) & ...
      ~isfield(MATLAB_STRUCT.(parameter_name),'frequency_deg_p_hr')
      f_k_combi = 1;
   else
      f_k_combi = length(MATLAB_STRUCT.(parameter_name).layer) + 1; % curent number of f_k_combi's
   end
   
   if debugopt
   disp([num2str(ifield),' ',parameter,'  ',num2str([f_k_combi layer frequency_deg_p_hr])])
   end

   MATLAB_STRUCT.(parameter_name).layer              (f_k_combi) = layer;
   MATLAB_STRUCT.(parameter_name).frequency_deg_p_hr (f_k_combi) = frequency_deg_p_hr;
   MATLAB_STRUCT.(parameter_name).t_start            (f_k_combi) = t_start           ;
   MATLAB_STRUCT.(parameter_name).t_stop             (f_k_combi) = t_stop            ;
   MATLAB_STRUCT.(parameter_name).n_cycles           (f_k_combi) = n_cycles          ;
   
   %% Put all data blocks in variable field
   %% --------------------------
   
   for icolumn = 7:ncolumn
   
      %% Replace all non-letters and non-numbers with _
      %% --------------------------
      
      variable_name = mkvar(char(TEKAL_DATA_STRUCT.Field(ifield).ColLabels{icolumn}));
      
      %% Make a field for each variable
      %% --------------------------
      
      %% APPLY MASKS DEPENDING ON PARAMETER
      
      if strcmp(analysis_type,'fou')
         MATLAB_STRUCT.(parameter_name).(variable_name)(:,:,f_k_combi) = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,icolumn));
      else
         MATLAB_STRUCT.(parameter_name).(variable_name)(:,:,f_k_combi) = squeeze(TEKAL_DATA_STRUCT.Field(ifield).Data(:,:,icolumn));
      end

   end
   
   %% Replace all nodata with nan
   %% using the KCS field
   %% --------------------------
   
   dummyvalue_center = (MATLAB_STRUCT.(parameter_name).KCS==0);
   
   if first
      MATLAB_STRUCT.xcen (dummyvalue_center) = nan;
      MATLAB_STRUCT.ycen (dummyvalue_center) = nan;
      MATLAB_STRUCT.m    (dummyvalue_center) = nan;
      MATLAB_STRUCT.n    (dummyvalue_center) = nan;
   end
   
   for icolumn = 7:ncolumn
   
      variable_name = mkvar(char(TEKAL_DATA_STRUCT.Field(ifield).ColLabels{icolumn}));
      
      MATLAB_STRUCT.(parameter_name).(variable_name)(dummyvalue_center) = MATLAB_STRUCT.nodatavalue;

   end

   if first; first=0; end

   % - After processing try rmfield Data ?
   % - pack every field as a different variable ?
   % - remember all fields as single ?
   
   % tmpfile = gettmpfilename;
   % save(tmpfile,'MATLAB_STRUCT')
   % clear MATLAB_STRUCT
   %
   % TEKAL_DATA_STRUCT.Field(ifield).Data = rmfield(TEKAL_DATA_STRUCT.Field(ifield),'Data')
   %
   % MATLAB_STRUCT = load(tmpfile)
   
   disp(['Processed ',num2str(ifield),' of ',num2str(nfield)]);

end % for ifield = 1:nfield

clear TEKAL_DATA_STRUCT

end % function [MATLAB_STRUCT,OK] = tekal2hdf(TEKAL_DATA_STRUCT,add_times2variable_name)

%??? Error: File: fou2struct3d.m Line: 216 Column: 1
%The function "tekal2hdf" was closed 
% with an 'end', but at least one other function definition was not. 
% To avoid confusion when using nested functions, 
% it is illegal to use both conventions in the same file.

end % function, so all variables above are global within the scope of this file (part bewteen 'function' and this 'end')

