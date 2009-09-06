ftItem = t.profilerresult.FunctionTable(1);

fullName = ftItem.FileName;

fid = fopen(fullName,'r');
txt = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',30000);
fclose(fid);
f = txt{1};

runnableLineIndex = callstats('file_lines',ftItem.FileName);
runnableLines = zeros(size(f));
runnableLines(runnableLineIndex) = runnableLineIndex;


canRunList = find(linelist(startLine:endLine)==runnableLines(startLine:endLine)) + startLine - 1;
didRunList = ftItem.ExecutedLines(:,1);
notRunList = setdiff(canRunList,didRunList);
neverRunList = find(runnableLines(startLine:endLine)==0);