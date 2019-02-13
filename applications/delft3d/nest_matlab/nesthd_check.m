function nesthd_check

%NESTHD_CHECK test nesthd
%
%See also: nest_matlab
%% Settings
testdir         = 'c:\checkouts_svn\open_earth_repository\matlab\applications\delft3d\nest_matlab\check\';

tests           = {[testdir filesep 'delft3d\milford']                       ; ...
                   [testdir filesep 'delft3d\shenzen']                       ; ...
                   [testdir filesep 'delft3d\zeedelta']                      ; };

check_exe       = false;
check_comprompt = true;

%% set paths
if ~isdeployed && any(which('setproperty'))
   addpath(genpath('..\..\..\..\matlab'));
end

%% Create ini files
for i_test = 1: length(tests)
    copyfile([tests{i_test} filesep 'nesthd1.template'],[tests{i_test} filesep 'nesthd1.ini']);
    copyfile([tests{i_test} filesep 'nesthd2.template'],[tests{i_test} filesep 'nesthd2.ini']);
    substitute ('**rundir**',tests{i_test},[tests{i_test} filesep 'nesthd1.ini']);
    substitute ('**rundir**',tests{i_test},[tests{i_test} filesep 'nesthd2.ini']);
end


%% Windows batch file (first create)
if check_exe
    fid = fopen ('run.bat','w+');
    for i_test = 1: length(tests)
        str_hd1 = ['nesthd ' tests{i_test} filesep 'nesthd1.ini'];
        str_hd2 = ['nesthd ' tests{i_test} filesep 'nesthd2.ini'];
        fprintf(fid,'%s \n',str_hd1);
        fprintf(fid,'%s \n',str_hd2);
    end
    fclose(fid);

    % than run and compare with previous results
    system('run.bat');

    for itest = 1: length(tests)
        nesthd_compare([tests{itest} filesep 'nesthd2.ini']);
    end
end

%% Check if running from matlab command prompt works
if check_comprompt
    for i_test = 1: length (tests)
        nesthd        ([tests{i_test} filesep 'nesthd1.ini']);
        nesthd_compare([tests{i_test} filesep 'nesthd1.ini']);
        if i_test ~= 3
            nesthd        ([tests{i_test} filesep 'nesthd2.ini'],'check',true);
            nesthd_compare([tests{i_test} filesep 'nesthd2.ini']);
        end
    end
end
