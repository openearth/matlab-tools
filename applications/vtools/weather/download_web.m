%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 11:40:08 +0100 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_floodplane.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_floodplane.m $
%

function err=download_web(url_down,fpath_out,varargin)

parin=inputParser;

addOptional(parin,'chrome','c:\Program Files (x86)\Google\Chrome\Application\new_chrome.exe');

parse(parin,varargin{:})

fpath_chrome=parin.Results.chrome;

% "c:\Program Files (x86)\Google\Chrome\Application\new_chrome.exe" --headless --dump-dom https://www.buienradar.nl/weer/delft/nl/2757345/14daagse > c:\Users\chavarri\Downloads\file.html
cmd_down=sprintf('"%s" --headless --dump-dom %s > %s',fpath_chrome,url_down,fpath_out);

fpath_bat='c:\Users\chavarri\Downloads\dw.bat';
fid=fopen(fpath_bat,'w');
fprintf(fid,'%s \n',cmd_down);
fclose(fid);
status=system(fpath_bat);
err=false;
if status~=0
    err=true;
end

%for some reason this does not work
% system(cmd_down);
% dos(cmd_down)

end