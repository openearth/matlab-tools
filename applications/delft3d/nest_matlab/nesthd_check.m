function nesthd_check

%NESTHD_CHECK test nesthd
%
%See also: nest_matlab

% Windows batch file

system('run.bat');

% Matlab command prompt

nesthd ('test\simona\dickv_hd1.ini');
nesthd ('test\simona\dickv_hd2.ini');

nesthd ('d:\projects\nesthd_matlab\test\shenzen\shenzen_hd1.ini');
nesthd ('d:\projects\nesthd_matlab\test\shenzen\shenzen_hd2.ini');

nesthd ('d:\projects\nesthd_matlab\test\tidal_flume_triwaq\triwaq_coarse\flume_hd1.ini');
nesthd ('d:\projects\nesthd_matlab\test\tidal_flume_triwaq\triwaq_coarse\flume_hd2.ini');

nesthd ('d:\projects\nesthd_matlab\test\milford\milford_hd1.ini');
nesthd ('d:\projects\nesthd_matlab\test\milford\milford_hd2.ini');

nesthd ('d:\projects\nesthd_matlab\test\zeedelta\zeedelta_hd1.ini');
nesthd ('d:\projects\nesthd_matlab\test\zeedelta\zeedelta_hd2.ini');
