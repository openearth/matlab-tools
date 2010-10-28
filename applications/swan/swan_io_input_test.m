%SWAN_IO_INPUT_TEST   read as test 3 test cases from SWAN.tudelft.nl
%
%  refraction test (a11refr)
%  slanted current test (a33curs)
%  diffraction test (dif90)
%
% The SWAN test files reside in in https://repos.deltares.nl/repos/OpenEarthTools/test/matlab/
%
%See also: swan

 clear all
 I    = swan_io_input('a11refr.swn');
 B    = swan_io_bot     ('read',I.inpgrid{1});
 S    = swan_io_spectrum(which(I.spec.fname));
 T{2} = swan_io_table   (I.table(2)); % no
 T{3} = swan_io_table   (I.table(3));

 clear all
 I    = swan_io_input('a33curs.swn');
 B    = swan_io_bot     ('read',I.inpgrid{1});
%B    = swan_io_bot     ('read',I.inpgrid{2}); % binary
 T{2} = swan_io_table   (I.table(2)); % no
 T{3} = swan_io_table   (I.table(3));

 clear all
 I    = swan_io_input('dif90.swn');
 B    = swan_io_bot     ('read',I.inpgrid{1});
 T{1} = swan_io_table   (I.table(1));
 T{2} = swan_io_table   (I.table(2));
 T{3} = swan_io_table   (I.table(3));
