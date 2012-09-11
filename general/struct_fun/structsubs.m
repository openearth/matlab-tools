function D2 = structsubs(D,ind)
%STRUCTSUBS  make subset from all struct fields
%
% D2 = structsubs(D,ind) takes subset ind from
% all field of struct D (array and cell field)
% 
% Example 1: like an SQL WHERE query
% T.a = [1     2    3       4    5    6       7    8    9]
% T.b = {'a' ,'b' ,'c',    'a' ,'b' ,'c'    ,'a' ,'b' ,'c'}
% T.c = {'NY','NY','NY',   'SF','SF','SF',   'LA','LA','LA'}
% ind = strmatchb('NY',T.c) & T.a <3
% T2 = structsubs(T,ind) % where T2 = struct('a',{[1 2]},'b', {{'a','b'}},'c',{{'NY','NY'}})
%
%See also: struct_fun, strmatchb

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Sep 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

flds = fieldnames(D);
for ifld=1:length(flds)
    fld = flds{ifld};
    if iscell(D.(fld))
        D2.(fld) = {D.(fld){ind}};
    else isnumeric(D.(fld))
        D2.(fld) = D.(fld)(ind);
    end
end