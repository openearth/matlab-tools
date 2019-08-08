function open_print_doc()
 error('%s has been deprecated',mfilename)
%This file is used by 'html/print_doc_index.html' to open up a pdf file.
p=mfilename('fullpath');
[ppath,name,ext,vrsn]=fileparts(p);
docURL = [ppath,filesep,'doc',filesep,'Google Earth Toolbox tutorial.pdf'];
web(docURL,'-browser')