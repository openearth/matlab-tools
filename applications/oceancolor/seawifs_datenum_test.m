function seawifs_datenum_test
%SEAWIFS_DATENUM_TEST   unit test for seawifs_datenum
%
%See also: seawifs_datenum

str = '1998128121603';
num = ceil(now*24*60)./24/60; % on minutes


assert(num==seawifs_datenum(seawifs_datenum(num)),'num should be returned.');
assert(strcmpi(str,seawifs_datenum(seawifs_datenum(str))),'String should be returned');
%% EOF