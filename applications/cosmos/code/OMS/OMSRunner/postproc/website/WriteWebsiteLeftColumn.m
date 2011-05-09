function WriteWebsiteLeftColumn(fid,buttons1,varargin)

if nargin==2
    buttons2=[];
else
    buttons2=varargin{1};
end

fprintf(fid,'%s\n','            <div id="leftcolumn">');
if ~isempty(buttons1)
    fprintf(fid,'%s\n','                <div id="leftcolumn1">');
    for i=1:length(buttons1)
        fprintf(fid,'%s\n',['                    <p class="leftbar_buttons1"><a href="' buttons1(i).link '">' buttons1(i).text '</a></p>']);
    end
    fprintf(fid,'%s\n','                </div>');
end
if ~isempty(buttons2)
    fprintf(fid,'%s\n','            <div id="leftcolumn1">');
    for i=1:length(buttons2)
        fprintf(fid,'%s\n',['                <p class="leftbar_buttons2"><a href="' buttons2(i).link '">' buttons2(i).text '</a></p>']);
    end
    fprintf(fid,'%s\n','            </div>');
end

fprintf(fid,'%s\n','            </div> <!-- end #sidebar -->');
fprintf(fid,'%s\n','');
