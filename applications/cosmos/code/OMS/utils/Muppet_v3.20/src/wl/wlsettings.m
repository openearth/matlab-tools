function output = wlsettings(mlbroot)
%WLSETTINGS Provides access to a set of additional tools
%  
%  wl_fileio  : Extended file input/output.
%  wl_tools   : Various MATLAB tools.
%  wl_ideas   : Interactive data editing and animation system. (BETA RELEASE)
%
%  Functions for internal WL | Delft Hydraulics use only.
%  Contact Bert Jagers for more information.

wlsettingsversion = 1.1;
if nargout>0
   output = wlsettingsversion;
   return
end

if sscanf(version,'%f',1)>=6.5
   s=warning;
   warning off
else
   [s,f]=warning;
   warning off
end

path_at_start = path;
try
   prefix='wl_';
   if nargin==0
      mlbroot=[matlabroot '/toolbox'];
      if isunix
         mlbroot='/u/jagers/_matlab';
      end
   end
   
   if isequal(mlbroot(end),'\/') % does removing a slash character help?
      mlbroot=mlbroot(1:end-1);
   end
   
   lastwarn('');
   addpath([mlbroot filesep prefix 'tools']);

   path_now = path;
   if isequal(path_now,path_at_start) & ~isempty(lastwarn) % directory not found
      mlbroot=pwd;
      if length(mlbroot)>6 & strcmp(lower(mlbroot(end-5:end)),[filesep 'local']) % does the current directory end on '\local'?
         mlbroot=mlbroot(1:end-6); % try path relative to where this wlsettings file is located
         lastwarn('');
         addpath([mlbroot filesep prefix 'tools']);
      end
   end

   path_now = path;
   if isequal(path_now,path_at_start) & ~isempty(lastwarn) %didn't help, try directly setting the path to where the files currently are.
      if isunix
         mlbroot='/u/jagers/_matlab'; % only useful if a path was specified (otherwise this is equal to the first attempt)
         lastwarn('');
         addpath([mlbroot filesep prefix 'tools']);
      else
         mlbroot='y:\app\matlab\toolbox';
         lastwarn('');
         addpath([mlbroot filesep prefix 'tools']);
      end
   end
   
   path_now = path;
   if isequal(path_now,path_at_start) & ~isempty(lastwarn) % still not able to find it ...
      fprintf('*** ERROR: cannot locate tool directories ***\n');
   else
      lastwarn('');
      fprintf('Using %s%s%s* for tools.\n',mlbroot,filesep,prefix);
      
      D=dir([mlbroot filesep prefix '*']);
      
      tobeadded='';
      if ~isempty(D)
         for i=1:length(D)
            if D(i).isdir
               if isempty(tobeadded)
                  tobeadded=[mlbroot filesep D(i).name];
               else
                  tobeadded=[tobeadded pathsep mlbroot filesep D(i).name];
               end
            end
         end
      end
      addpath(tobeadded);
      
      if isempty(lastwarn)
         fprintf('*** extra tools enabled ***\n');
      else
         fprintf('*** ERROR: cannot locate all tool directories ***\n');
      end
   end
   
catch
   fprintf('*** unexpected error while executing %s ***\n',mfilename);
   fprintf('*** extra tools not enabled ***\n');
end

try
   wlsettingsupdate(wlsettingsversion)
catch
end

set(0,'defaultfigurepapertype','a4')

if sscanf(version,'%f',1)>=6.5
   warning(s);
else
   warning(s);
   warning(f);
end
