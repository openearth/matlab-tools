function n=findinstruct(h,fld1,val1,varargin)
%FINDINSTRUCT
%
% n=findinstruct(h,fld1,val1,varargin)
%
%See also:

n    = [];
flds = fieldnames(h);
c0   = struct2cell(h);

if nargin==3
    ii1 = strmatch(fld1,flds,'exact');
    c1  = squeeze(c0(ii1,1,:));
    m1  = squeeze(cell2mat(c1));
    n   = find(m1==val1);
else
    fld2 = varargin{1};
    val2 = varargin{2};
    ii1  = strmatch(fld1,flds,'exact');
    c1   = squeeze(c0(ii1,1,:));
    m1   = squeeze(cell2mat(c1));
    ii2  = strmatch(fld2,flds,'exact');
    c2   = squeeze(c0(ii2,1,:));
    m2   = squeeze(cell2mat(c2));
    n    = find(m1==val1 & m2==val2);
end
