function OK = mkhtml_test
%MKHTML_TEST    tets for mkhtml
%
%See also: mkhtml

OK = strcmpi(mkhtml('% |/<,()'),'%25%20%7C%2F%3C%2C%28%29');