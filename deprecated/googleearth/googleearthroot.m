function s=googleearthroot()
 error('%s has been deprecated',mfilename)
a=mfilename('fullpath');
Ix=findstr(a,filesep);
s=a(1:Ix(end));

