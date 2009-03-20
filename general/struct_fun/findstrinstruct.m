function n=findstrinstruct(h,fld1,val1,varargin)
%FINDSTRINSTRUCT
%
% n=findstrinstruct(h,fld1,val1,varargin)
%
%See also:

n    = [];
flds = fieldnames(h);
c0   = struct2cell(h);

if nargin==3
    ii1 = strmatch(fld1,flds,'exact');
    c1  = c0(ii1,1,:);
    n   = strmatch(val1,c1,'exact');
else
    fld2 = varargin{1};
    val2 = varargin{2};
    ii1  = strmatch(fld1,flds,'exact');
    c1   = c0(ii1,1,:);
    ii2  = strmatch(fld2,flds,'exact');
    c2   = c0(ii2,1,:);
    hhh  = strmatch(val1,c1,'exact');
    iii  = strmatch(val2,c2,'exact');
    n    = intersect(hhh,iii);
end
