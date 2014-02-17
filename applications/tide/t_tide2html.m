function varargout = t_tide2html(D,varargin)
%t_tide2html store t_tide constituents as html table
%
% str = t_tide2html(D) where D = nc_t_tide() or t_tide_read()
%
% Example: savestr('tst.html',t_tide2html(D));
%
%See also: t_tide_read, t_tide, t_tide2xml

str = '';
str = [str sprintf('<table style="width:300px">')];
str = [str sprintf('<tr><td>%s </td><td> %s </td><td> %s</td></tr>','name','frequency [1/day]','amplitude')];
for i=1:length(D.data.fmaj)
str = [str sprintf('<tr><td>%s </td><td> %g </td><td> %g</td></tr>',D.component_name(i,:),D.frequency(i),D.data.fmaj(i))];
end

str = [str sprintf('</table>')];

if nargin==2
   savestr(varargin{1},str)
else
    varargout = {str};
end

