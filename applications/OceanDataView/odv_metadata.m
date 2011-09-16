function L = odv_metadata(directory)
%ODV_METADATA   read meta-data table and connect associated mess of files
%
% L = odv_metadata(directory)
%
%  only works for data sent by later versions of seadatanet
%
% Example:
%
% L = odv_metadata('userab12c34-data_centre000-311210_result')
%
%See also: OceanDataView, 

% What a delight would it be if SDN would just adopt some kind of standard syntax as netcdf or ISO191xx xml, 
% so we could simply use nc_cf_opendap2catalog or xmlread to get meta-data, pfff.

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

OPT.mask = '*.txt';

tmp = dir([directory,'*.csv']);

%% old SDN server version at datacentre
%  (why is there no datacentre software version number in name of zip?, pfffffff)

if isempty(tmp)==1

   fprintf(2,['warning: ' , mfilename,': no contents file found\n'])
   fprintf(2,['warning: ' , mfilename,': TO DO: call odv2meta.m\n'])

   tmp  = dir([directory,OPT.mask]);

   L.name          = {tmp.name};
   L.name          = {tmp.name};
   L.date          = {tmp.date};
   L.bytes         = {tmp.bytes};
   L.isdir         = {tmp.isdir};
   L.datenum       = {tmp.datenum};
   L.CDI_record_id = cell(1,length(L.name));
  [L.CDI_record_id{:}] = deal({nan});
   
else

%% newer SDN server version at datacentre
%  (why is there no datacentre software version number in name of zip?, pfffffff)

   L = csv2struct([directory,filesep,tmp.name],'delimiter',',','quotes',1);
   
   tmp  = dir([directory,'*.txt']);
   name = cellstr(char({tmp.name}));
   
   %% pre allocate to have correct overall size, also if you removed some files
            L.Versions = cell(size(L.LOCAL_CDI_ID));
    L.Download_datenum = cell(size(L.LOCAL_CDI_ID));
                L.name = cell(size(L.LOCAL_CDI_ID));
                L.date = cell(size(L.LOCAL_CDI_ID));
               L.bytes = cell(size(L.LOCAL_CDI_ID));
               L.isdir = cell(size(L.LOCAL_CDI_ID));
             L.datenum = cell(size(L.LOCAL_CDI_ID));
              L.fnames = cell(size(L.LOCAL_CDI_ID));
   
   for i=1:length(L.LOCAL_CDI_ID)
      n   = length(L.LOCAL_CDI_ID{i});
      ind = strmatch(L.LOCAL_CDI_ID{i},name); % search this way around, not the other way around
      
      % For some reason a LOCAL_CDI_ID can occur multiple times with
      % different timestaps/version numbers, which
      % happens because the moronic SDN RSM "shopping basket" system allows 
      % adding only limited selections at once to the "shopping basket", 
      % and as ultimate stupid feature has a maximum shopping basket content per order, pfffffffffff
      %
      % so therefore here's some code to try to clean up this mess by selecting
      % the most recent file associated with one LOCAL_CDI_ID.
      
      if ~isempty(ind) % if you removed some odv files

         L.fnames{i}   = name{ind};
         
         L.Versions{i} = {};
         for j=1:length(ind)
            if strcmpi(name{ind(j)}(n+1),'_'); % do not allows  blabla4x_ when you search only blabla4_
               L.Versions{i}{end+1} = name{ind(j)}(n+2:end-4); % skip traling _ as it separates LOCAL_CDI_ID from version and skip leading .txt 
            end
         end
         L.Download_datenum{i} = datenum(L.Versions{i},'yyyymmdd_HHMMSS');
         
         [dummy,jj]=max(L.Download_datenum{i});
         
         L.name{i}     = [name{ind(jj)}];
         
         tmp2 = dir([directory,filesep,L.name{i}]);
         
         L.date{i}     = tmp2.date;
         L.bytes{i}    = tmp2.bytes;
         L.isdir{i}    = tmp2.isdir;
         L.datenum{i}  = tmp2.datenum;
      end
   
   end
end

L.fullfile  = cellfun(@(x) helperfun(x,directory),L.name,'UniformOutput',0);

function y=helperfun(x,pre)

if isempty(x)
    y='';
else
   y=[pre,x];
end

% due to some very strange decision the LOCAL_CDI_ID is not resolvable, only the
% CDI_record_id is, which is not supplied in the old versions of RSM
% deliveries.
% L.xml = ['http://www.nodc.nl/v_cdi_v2/print_xml.aspx?n_code=',L.CDI_record_id];

%%

