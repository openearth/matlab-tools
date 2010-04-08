function OK = nerc_verify_test
%NERC_VERIFY_TEST   test for nerc_verify
%
%See also: nerc_verify

a1 = nerc_verify('http://vocab.ndg.nerc.ac.uk/term/P061/current/UPBB');
b1 = nerc_verify('http://vocab.ndg.nerc.ac.uk/term/P011/current/PRESPS01');

a2 = nerc_verify('P061::UPBB');
b2 = nerc_verify('P011::PRESPS01');

if isequal(a1,a2) & isequal(b1,b2)
 OK=1;
else
 OK=0;
end