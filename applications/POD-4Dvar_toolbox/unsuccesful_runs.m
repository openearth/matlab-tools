%% This script looks for "flowave_finished.log" files. From the list it
% will take all files with less than 3kb in size and assume that they are
% errors. After identifying errors it will re-run the jobs. 
%
% This script should be run from the cluster HBR or H4, so that the
% submission of jobs is possible. 

    current_folder = pwd;    
    directory_of_interest = [pwd,filesep,'test_7',filesep,'iteration001',filesep];
    
    disp(['find ',directory_of_interest,' -name ''flowave_finished.log'' -size -3k'])
    [~,the_line_of_files] = system(['find ',directory_of_interest,' -name ''flowave_finished.log'' -size -3k'])
    
    thefolders = regexp(the_line_of_files,['flowave_finished.log',char(10)],'split');
        
    files_to_delete = {'com-efrance.dat';...
                        'trim-efrance.def';...
                        'com-efrance.def';...
                        'flowave*';...
                        'tri-diag.efrance';...
                        'TMP_efrance.bcc';...
                        'IG*.*';...
                        'TMP_efrance.bch';...
                        'TMP_efrance.grd';...
                        'trim-efrance.dat'};
                    
    for ifolder = 1:length(thefolders)
        
        disp(['''',thefolders{ifolder},''''])
        if exist(thefolders{ifolder},'dir')
            disp('The folder exists')
            
            cd(thefolders{ifolder})

            % Delete the files specified in files_to_delete
            for ifiles=1:length(files_to_delete), delete(files_to_delete{ifiles}); end
            
            % Generate a random number for the job name
            elnum = num2str(fix(rand*100000));
            
            disp(['executing: qsub -V -N ','IG',elnum ,' run_flow2d3d_wave.sh efrance.mdw'])
            system(['qsub -V -N ','IG',elnum ,' run_flow2d3d_wave.sh efrance.mdw']);
            
            cd(current_folder)
        end
    end
    
    disp('End of process...')