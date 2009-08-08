function htmlOutput = visdiffCreateHTML(path1,shortname1,fname1,date1,text1, ...
        path2,shortname2,fname2,date2,text2,showchars)
%VISDIFFCREATEHTML Helper function for visdiff and mdbvisdiffbuffer that
%   creates the actual HTML output.
%
%   This file is for internal use only and is subject to change without
%   notice.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

% The diffcode algorithm makes an m-by-n matrix, where m is length(text1)
% and n is length(text2). If it gets too big, there are memory problems.
% Set this size limit to suit your hardware.
m = length(text1);
n = length(text2);
sizeLimit = 2.5e7;
sizeLimitExceeded = false;
if m*n < sizeLimit
    [a1,a2] = diffcode(text1,text2);
else
    a1 = zeros(1,max(m,n));
    a2 = zeros(1,max(m,n));
    a1(1:m) = 1:m;
    a2(1:n) = 1:n;
    sizeLimitExceeded = true;
end


% Construct a final version of the file for display
% Skipped lines are indicated by "-----"

blankLine = char(32*ones(1,showchars));
f1n = [{blankLine}; text1];
f2n = [{blankLine}; text2];
a1Final = cell(size(a1));
a1Final = f1n(a1+1);
a2Final = cell(size(a2));
a2Final = f2n(a2+1);

% Generate the HTML
s = {};
s{1} = makeheadhtml;
% Title is used in the Find Dialog.
if ~isequal(shortname1, shortname2)
    s{end+1} = sprintf('<title>File Comparison - %s vs. %s</title>', shortname1, shortname2);
else
    s{end+1} = sprintf('<title>File Comparison - %s</title>', shortname1);
end
s{end+1} = '</head>';
s{end+1} = '<body>';

if sizeLimitExceeded
    s{end+1} = sprintf('<span style="color:#FF0000;">Maximum file length exceeded. Defaulting to line-by-line comparison.</span>');
end

s{end+1} = '<table cellpadding="0" cellspacing="0" border="0">';
s{end+1} = '<tr>';
s{end+1} = sprintf('<td></td><td><a href="matlab: edit(urldecode(''%s''))"><strong>%s</strong></a></td>', ...
    urlencode(fname1),shortname1);
s{end+1} = sprintf('<td><a href="matlab: edit(urldecode(''%s''))"><strong>%s</strong></a></td><td></td>', ...
    urlencode(fname2),shortname2);
s{end+1} = '</tr>';
s{end+1} = '<tr>';
s{end+1} = sprintf('<td></td><td>%s</td>',path1);
s{end+1} = sprintf('<td>%s</td><td></td>',path2);
s{end+1} = '</tr>';
s{end+1} = '<tr>';
s{end+1} = sprintf('<td></td><td>%s</td>',date1);
s{end+1} = sprintf('<td>%s</td><td></td>',date2);
s{end+1} = '</tr>';
s{end+1} = '<tr>';
s{end+1} = '<td><pre>    </pre></td>';
s{end+1} = sprintf('<td><pre>%s   </pre></td>',blankLine);
s{end+1} = sprintf('<td><pre>%s</pre></td>',blankLine);
s{end+1} = '</tr></table>';

match = zeros(size(a1));

s{end+1} = '<pre>';

for n = 1:length(a1Final)
    
    line1 = blankLine;
    line1Content = replaceTabsInCode(a1Final{n});
    line1Len = min(length(line1Content),length(blankLine));
    line1(1:line1Len) = line1Content(1:line1Len);
    line1 = code2html(line1);
    
    line2 = blankLine;
    line2Content = replaceTabsInCode(a2Final{n});
    line2Len = min(length(line2Content),length(blankLine));
    line2(1:line2Len) = line2Content(1:line2Len);
    line2 = code2html(line2);

    % Increment counters here
    if isequal(line1Content,line2Content)
        match(n) = 1;
        s{end+1} = sprintf('<span class="soft">%3d %s . %s %3d</span><br/>',a1(n),line1,line2,a2(n));
    elseif a1(n)==0
        s{end+1} = sprintf('  <span class="soft">-</span> <span class="diffold">%s</span><span class="diffnew"> <span style="color:#080">&gt;</span> %s</span> <a href="matlab: opentoline(''%s'',%d)">%3d</a><br/>', ...
            line1,line2,fname2,a2(n),a2(n));
    elseif a2(n)==0
        s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)">%3d</a> <span class="diffnew">%s <span style="color:#080">&lt;</span> </span><span class="diffold">%s</span>   <span class="soft">-</span><br/>', ...
            fname1,a1(n),a1(n),line1,line2);
    else
        s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)">%3d</a> <span class="diffnomatch">%s <span style="color:#F00">x</span> %s</span> <a href="matlab: opentoline(''%s'',%d)">%3d</a><br/>', ...
            fname1,a1(n),a1(n),line1,line2,fname2,a2(n),a2(n));
    end

end
s{end+1} = '</pre>';

numMatch = sum(match);

s{end+1} = sprintf('<p>Number of matched lines: %d<br/>', numMatch);

s{end+1} = '</body>';

s{end+1} = '</html>';

htmlOutput = [s{:}];