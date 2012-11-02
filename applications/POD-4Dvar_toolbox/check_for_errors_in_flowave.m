 %% THIS SCRIPT WILL MAKE A LIST OF FILES CALLED FLOWAVE.LOG AND LOOK IN
 % their content whether the string 'ERROR:' is present. If so, the script
 % will rerun the model.
 %
 % This script should be run from the cluster HBR or H4, so that the
 % submission of jobs is succesful. 
    
    current_folder = pwd;
    
    % Look for flowave.log files: let's make a list with the system's FIND
    % command.
                              disp(['find ',pwd,filesep,'test_5',filesep,'iteration001',filesep,' -name ''flowave.log''']);
    [~,the_line_of_files] = system(['find ',pwd,filesep,'test_5',filesep,'iteration001',filesep,' -name ''flowave.log''']);
    
    % 
    thefolders = regexp(the_line_of_files, ['flowave.log',char(10)],'split');
    
    for ifile = 1:length(thefolders)
        ['''',thefolders{ifile},'''']
        if exist(thefolders{ifile},'dir')
            
            disp(thefolders{ifile})
            thefile = textread([thefolders{ifile},'flowave.log'],'%s');
            
            if find(ismember(thefile,'ERROR:'))
                disp('Error found, deleting job')
                [~,res] = system(['find ',thefolders{ifile},' -name ''*IG*.e*''']);
                the_job_name = res(strfind(res,'IG'):strfind(res,'.e')-1);
                
                system(['qdel ',the_job_name]);
            end
        end
    end
    
    
%% Lets rerun Them
    
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
        disp(thefolders{ifolder})
        if exist(thefolders{ifolder},'dir')
            cd(thefolders{ifolder})
            for ifiles=1:length(files_to_delete)
                delete(files_to_delete{ifiles});
            end
        
            elnum = num2str(fix(rand*100000));

            disp(['executing: qsub -V -N ','IG',elnum ,' run_flow2d3d_wave.sh efrance.mdw'])
            [status,w] = system(['qsub -V -N ','IG',elnum ,' run_flow2d3d_wave.sh efrance.mdw']);
            cd(current_folder)
        end
    end