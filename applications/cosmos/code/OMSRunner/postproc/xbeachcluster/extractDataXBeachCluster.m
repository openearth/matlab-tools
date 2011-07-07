function extractDataXBeachCluster(hm,m)

Model=hm.Models(m);


for ip=1:Model.NrProfiles
    
    disp('Extracting data profile ')
    
    profile=Model.Profile(ip).Name;

    disp(['Extracting data ' Model.Name ' - profile ' profile]);

    dr=Model.Dir;
    inputdir=[dr 'lastrun' filesep 'input' filesep profile filesep];
    outputdir=[dr 'lastrun' filesep 'output' filesep profile filesep];
    archivedir=[Model.ArchiveDir hm.CycStr filesep 'netcdf' filesep profile filesep];
    
    % Check if simulation has run
    if exist([outputdir 'dims.dat'],'file')
        
        if ~exist(archivedir,'dir')
            mkdir(archivedir);
        end
        
        tref=Model.TFlowStart;
        

%         % Wave statistics from input sp2 files
%         [t,Dp,Tp,Hs] = calc_wavestats(inputdir);
%         
% %        dr=[Model.ArchiveDir hm.CycStr filesep 'timeseries' filesep];
%         dr=archivedir;

%         s3.Time=t;
%         s3.Name=profile;
%         
%         s3.Parameter='Significant wave height';
%         s3.Val=Hs;
%         fname=[dr 'hs.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');
% 
%         s3.Parameter='Peak wave period';
%         s3.Val=Tp;
%         fname=[dr 'tp.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');
% 
%         s3.Parameter='Peak wave direction';
%         s3.Val=Dp;
%         fname=[dr 'wavdir.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');
% 
%         % Tide time series
%         s=load([inputdir 'tide.txt']);
%         s3.Parameter='Water level';
%         s3.Time=tref+s(:,1)/86400;
%         s3.Val=s(:,2);
%         fname=[dr 'wl.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');

%         % Convert to netCDF
%         xbprofile2nc(inputdir,outputdir,archivedir,profile,tref);

        % Convert to netCDF
%        xbprofile2nc_all(inputdir,outputdir,archivedir,profile,tref);

%        unzip([inputdir 'sp2.zip'],inputdir);
        system([hm.MainDir 'exe' filesep 'unzip.exe -q ' inputdir 'sp2.zip -d ' inputdir]);
        xbprofile2nc_stat(inputdir,outputdir,archivedir,profile,tref);
        delete([inputdir '*.sp2']);

    end
    
end
