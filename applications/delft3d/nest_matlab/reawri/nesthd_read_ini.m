function [handles] = read_ini(handles,varargin)

   % read_ini : reads the session file for nesthd


   %
   % Get filename ini file
   %

   if isempty(varargin)
      if ~isempty(handles.filedir); cd(handles.filedir); end
      [fin,pin] = uigetfile('*.ini','Name of Session file');
      cd (handles.progdir);

      if pin~=0
         handles.filedir = pin;
      end
      
      if fin ~= 0
         filename = [pin fin];
      else
         filename = '';
      end
   else
      filename = varargin{1};
   end

   %
   % Read Info structure from the nesthd_inifile
   %

   if ~isempty(filename) 
 
      Info = nesthd_inifile('open',filename);
   
      %
      % Which subsystem was active when saving the file?
      %

      handles.active = nesthd_inifile('get',Info,'Subsystem','Active');

      switch handles.active
         case 'Nesthd1'
            handles.files_hd1{1}=nesthd_inifile('get',Info,handles.active,'Overall model grid  ');
            handles.files_hd1{2}=nesthd_inifile('get',Info,handles.active,'Detailled model grid');
            handles.files_hd1{3}=nesthd_inifile('get',Info,handles.active,'Boundary Definition ');
            handles.files_hd1{4}=nesthd_inifile('get',Info,handles.active,'Observation Points  ');
            handles.files_hd1{5}=nesthd_inifile('get',Info,handles.active,'Nest Administration ');
            handles.files_hd1{6}=nesthd_inifile('get',Info,handles.active,'Enclosure           ');
         case 'Nesthd2'
            handles.files_hd2{1}=nesthd_inifile('get',Info,handles.active,'Boundary definition             ');
            handles.files_hd2{2}=nesthd_inifile('get',Info,handles.active,'Nest administration             ');
            handles.files_hd2{3}=nesthd_inifile('get',Info,handles.active,'Overall result file             ');
            handles.files_hd2{4}=nesthd_inifile('get',Info,handles.active,'Hydrodynamic Boundary conditions');
            handles.files_hd2{5}=nesthd_inifile('get',Info,handles.active,'Transport Boundary Conditions   ');

            if ~isempty(handles.files_hd2{3}) && ~isempty(handles.files_hd2{1}) 
               handles.nfs_inf = nesthd_get_general(handles.files_hd2{3});
               [handles]       = nesthd_set_add_inf(handles);

               %
               % Get additional information
               %

               Chapter = 'Additional';
               if handles.wlev
                  handles.add_inf.a0=nesthd_inifile('get',Info,Chapter,'A0                             ');
               end
               if handles.vel
                  handles.add_inf.profile=nesthd_inifile('get',Info,Chapter,'Profile                   ');
               end
               if handles.conc
                  handles.add_inf.l_act=nesthd_inifile('get',Info,Chapter,'Active                       ');
                  for l = 1: handles.nfs_inf.lstci
                     handles.add_inf.genconc(l)=nesthd_inifile('get',Info,Chapter,['Genconc' num2str(l)]);
                     handles.add_inf.add(l)    =nesthd_inifile('get',Info,Chapter,['Add' num2str(l)]    );
                     handles.add_inf.max(l)    =nesthd_inifile('get',Info,Chapter,['Max' num2str(l)]    );
                     handles.add_inf.min(l)    =nesthd_inifile('get',Info,Chapter,['Min' num2str(l)]    );
                  end
               end
            end
      end
   end

   