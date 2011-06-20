function PostFTP(hm,m)

Model=hm.Models(m);

locdir=[hm.WebDir Model.WebSite filesep 'scenarios' filesep hm.Scenario filesep ...
        Model.Continent filesep Model.Name filesep 'figures'];

try

    cont=hm.Models(m).Continent;
    disp('Connecting to FTP site ...');
    f=ftp('members.upc.nl','m.ormondt','8AMGU55S');

    disp(['cd ' Model.WebSite filesep 'scenarios' hm.Scenario filesep cont]);
    
    cd(f,[Model.WebSite filesep 'scenarios' filesep hm.Scenario filesep cont]);

    try % to delete existing directory
        disp('Entering current directory ...');
        cd(f,hm.Models(m).Name);
        cd(f,'figures');
        disp('Deleting files in current directory ...');
        try
            delete(f,'*');
        end
        disp('Going up one directory ...');
        cd(f,'..');
        disp('Deleting current directory ...');
        [success,message,messageid]=rmdir(f,'figures','s');
    end
    
    try % to upload figures
        disp('Uploading data ...');
        mput(f,locdir);
        disp('Data uploaded ...');
    end

    cd(f,'..');
    cd(f,'..');

    try % to delete models.xml
        disp('Deleting models.xml ...');
        delete(f,'models.xml');
    end

    try % to upload models.xml
        disp('Uploading models.xml ...');
        mput(f,[hm.WebDir Model.WebSite filesep 'scenarios' filesep hm.Scenario ...
                filesep 'models.xml']);
        disp('models.xml uploaded ...');
    end
    
    close(f);

catch
    disp('Something went wrong with uploading to FTP site!');
end


% % Post data to FTP for Dano
% 
% if strcmpi(hm.Models(m).Name,'kuststrook')
% 
%     locdir=[hm.ArchiveDir filesep Model.Continent filesep Model.Name
%     filesep 'archive' filesep 'appended' filesep 'timeseries'];
% 
%     try
% 
%         disp('Connecting to FTP site ...');
%         f=ftp('ftp.wldelft.nl','ormondt','ibQLw54');
%  
%         try % to delete existing directory
%             disp('Entering current directory ...');
%             cd(f,'timeseries');
%             disp('Deleting files in current directory ...');
%             try
%                 delete(f,'*');
%             end
%             disp('Going up one directory ...');
%             cd(f,'..');
%             disp('Deleting current directory ...');
%             rmdir(f,'timeseries');
%         end
% 
%         try % to upload figures
%             disp('Uploading data kuststrook...');
%             mput(f,locdir);
%             disp('Data uploaded ...');
%         end
% 
%         close(f);
% 
%     catch
%         disp('Something went wrong with uploading to FTP site!');
%     end
% 
% 
% end
% 
% if strcmpi(hm.Models(m).Name,'delflandxbeach')
% 
%     locdir=[hm.ArchiveDir filesep Model.Continent filesep Model.Name
%     filesep 'lastrun' filesep 'input'];
% 
%     try
% 
%         disp('Connecting to FTP site ...');
%         f=ftp('ftp.wldelft.nl','ormondt','ibQLw54');
%  
%         try % to delete existing directory
%             disp('Entering current directory ...');
%             cd(f,'delflandxbeach');
%             cd(f,'input');
%             disp('Deleting files in current directory ...');
%             try
%                 delete(f,'*');
%             end
%             disp('Going up one directory ...');
%             cd(f,'..');
%             disp('Deleting current directory ...');
%             rmdir(f,'input');
%         catch
%             disp('Something went wrong with uploading to FTP site!')
%         end
% 
%         try % to upload figures
%             disp('Uploading data delfland xbeach...');
%             mput(f,locdir);
%             disp('Data uploaded ...');
%         end
% 
%         close(f);
% 
%     catch
%         disp('Something went wrong with uploading to FTP site!');
%     end
% 
% 
% end
