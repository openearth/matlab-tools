function seawifs_datenum_test
%SEAWIFS_DATENUM_TEST   unit test for seawifsdatenum
%
%See also: seawifsdatenum_test.m

str = '1998128121603';
num = ceil(now*24*60)./24/60; % on minutes

assert(num==seawifsdatenum(seawifsdatenum(num)) & ...
        strcmpi(str,seawifsdatenum(seawifsdatenum(str))));
%% EOF