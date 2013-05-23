function nesthd_check

%NESTHD_CHECK test nesthd
%
%See also: nest_matlab

testdir = 'd:\open_earth_test\matlab\applications\delft3d\nest_matlab';

tests      = {[testdir filesep 'simona\tidal_flume_triwaq\triwaq_coarse\flume'] ;
              [testdir filesep 'delft3d\milford\milford']                       ; ...
              [testdir filesep 'delft3d\shenzen\shenzen']                     } ; ...
%              [testdir filesep 'delft3d\zeedelta\zeedelta']                   }; 

% Windows batch file (firt create)

fid = fopen ('run.bat','w+');
for itest = 1: length(tests)
    fprintf(fid,'nesthd_w64  %s_hd1.ini \n',tests{itest});
    fprintf(fid,'nesthd_w64  %s_hd2.ini \n',tests{itest});
end
fclose(fid);

% than run and compare with previous results

system('run.bat');

for itest = 1: length(tests)
    nesthd_compare([tests{itest} '_hd2.ini']);
end

% Check if running from matlab command prompt works

for itest = 1: length (tests)
    nesthd        ([tests{itest} '_hd1.ini']);
    nesthd        ([tests{itest} '_hd2.ini']);
    nesthd_compare([tests{itest} '_hd2.ini']);
end
