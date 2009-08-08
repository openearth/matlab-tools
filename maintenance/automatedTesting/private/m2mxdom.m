function [dom,cellBoundaries] = m2mxdom(originalCode)
%M2MXDOM  Converts codepad-style m-code into a Document Object Model.
%   M2MXDOM(TXT) parses the char array TXT and returns the contents as 
%   a cell script DOM.

% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.1.6.19 $  $Date: 2007/11/13 00:06:54 $

% Normalize line endings to Unix-style.
code = regexprep(originalCode,'\r\n?','\n');
newLine = sprintf('\n');

% Trim trailing whitespace.
code = regexprep(code,'[ \t]*(\n|$)','\n');

% Exactly one newline at the end of the file.
code = regexprep(code,'\n*$','');
code(end+1) = newLine;

% Find the cells.
cellLocations = com.mathworks.widgets.text.mcode.cell.CellUtils.getCellLocations(code);
if isempty(cellLocations) || (cellLocations(1) ~= 1)
    % Add the implicit outer cell.
    cellLocations = [1; sum(code==newLine); cellLocations];
end
cellStarts = cellLocations(1:2:end);
cellEnds = cellLocations(2:2:end);
cellBreaks = unique([cellStarts' cellEnds'+1]);
cellBoundaries = [cellStarts cellEnds];

% Now create the new DOM
dom = com.mathworks.xml.XMLUtils.createDocument('mscript');
rootNode = dom.getDocumentElement;
rootNode.setAttribute('xmlns:mwsh', ...
    'http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd')

% Add version.
newNode = dom.createElement('version');
matlabVersion = ver('MATLAB');
newTextNode = dom.createTextNode(matlabVersion.Version);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);

% Add date.
newNode = dom.createElement('date');
newTextNode = dom.createTextNode(datestr(now,29));
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);

ignoreMarker = 'XXX_IGNORE_THIS_LINE_XXX';
% Exclude some lines from the published output.
    function excludeLine(pattern,iKeep,nodeName)
        paddedPattern = ['(?<=\n|^)' pattern '(?:\n)'];
        paddedReplace = ['% ' ignoreMarker '\n'];
        match = regexp(code,paddedPattern,'tokens','once');
        if ~isempty(match)
            code = regexprep(code,paddedPattern,paddedReplace);
            if (nargin > 1)
                node = dom.createElement(nodeName);
                rootNode.appendChild(node);
                node.appendChild(dom.createTextNode(match{iKeep}));
            end
        end
    end
excludeLine( ...
    '(%[ \t]*)(Copyright.*?The MathWorks, Inc.)', ...
    2, ...
    'copyright')
excludeLine( ...
    '(%[ \t]*)(\$(?:Revision|Date):.*?\$[ \t]*)+', ...
    2, ...
    'revision')
excludeLine('([ \t]*)displayEndOfDemoMessage\(mfilename\)')

% Initialize variables for loop.
chunkList = [];
returns = find(code==newLine);
for iCodeBreaks = 1:numel(cellBreaks)-1
    cellStartLine = cellBreaks(iCodeBreaks);
    cellEndLine = cellBreaks(iCodeBreaks+1)-1;
    if cellStartLine == 1
        chunkStartIndex = 1;
    else
        chunkStartIndex = returns(cellStartLine-1)+1;
    end
    chunkEndIndex = returns(cellEndLine);
    chunk = code(chunkStartIndex:chunkEndIndex);
    descriptiveTextPattern = '(?:\n|^)([ \t]*%)%%?( .*?)?\n((\1)( [^\n]*)?\n)*';
    [dtStarts,dtEnds] = regexp(chunk,descriptiveTextPattern,'start','end');    
    if isempty(dtStarts)
        nextChunk = newChunk();
        nextChunk.code = chunk;
        chunkList = [chunkList nextChunk];
    else
        if (dtStarts(1) > 1)
            nextChunk = newChunk();
            nextChunk.code = chunk(1:dtStarts(1)-1);
            chunkList = [chunkList nextChunk];
        end
        for iDtStarts = 1:numel(dtStarts)
            nextChunk = newChunk();
            dtStart = dtStarts(iDtStarts);
            dtEnd = dtEnds(iDtStarts);
            descriptiveText = chunk(dtStart:dtEnd);
            if ~isempty(descriptiveText) && (descriptiveText(1) == newLine);
                descriptiveText(1) = [];
            end
            descriptiveText = regexprep(descriptiveText,'^[ \t]*%%%?[ \t]*','');

            % Isolate title.
            firstNewline = find(descriptiveText==newLine,1,'first');
            nextChunk.title = descriptiveText(1:firstNewline-1);
            
            % Isolate descriptive text.
            textLines = descriptiveText(firstNewline+1:end);
            textLines = regexprep(textLines,'(\n|^)[ \t]*%(?=\n)','$1\n');
            textLines = regexprep(textLines,'(\n|^)[ \t]*% ([^\n]+)','$1$2');
            lines = regexp(textLines,'([^\n]*)\n','tokens');
            nextChunk.text = [lines{:}]';
            
            % Isolate code.
            someCodeStart = dtEnd+1;
            if (iDtStarts == numel(dtStarts))
                someCodeEnd = numel(chunk);
            else
                someCodeEnd = dtStarts(iDtStarts+1)-1;
            end
            nextChunk.code = chunk(someCodeStart:someCodeEnd);
            
            % Populate output targets.
            chunkList = [chunkList nextChunk];
        end
    end
    chunkList(end).outputTargets = find(cellEndLine == cellEnds);
end

% Loop over each cell in the node
codeCount = 0;
for n = 1:length(chunkList)
    cellNode = dom.createElement('cell');
    rootNode.appendChild(cellNode);

    % Save this cell number.
    countNode = dom.createElement('count');
    cellNode.appendChild(countNode);
    countTextNode = dom.createTextNode(sprintf('%.0f',n));
    countNode.appendChild(countTextNode);

    % Add an title element to the cell
    if ~isempty(chunkList(n).title)
        titleNode = dom.createElement('steptitle');
        cellNode.appendChild(titleNode);
        formatText(dom,titleNode,chunkList(n).title);
    end    
    
    % Add a text element to the cell
    textLines = chunkList(n).text;
    linesToIgnore = strmatch(ignoreMarker,textLines,'exact');
    if ~isempty(linesToIgnore)
        textLines(linesToIgnore) = {''};
    end
    % Remove leading and trailing empty lines
    nonBlank = setdiff(1:length(textLines),strmatch('',textLines,'exact'));
    textLines = textLines(min(nonBlank):max(nonBlank));
    if ~isempty(textLines)
        textNode = buildTextNode(dom,textLines);
        cellNode.appendChild(textNode); 
    end
    
    % Add an mcode element to the cell
    newCode = chunkList(n).code;
    newCode = strrep(newCode,['% ' ignoreMarker],'');
    newCode = removeBlankLinesAtTopAndBottom(newCode);
    if ~isempty(newCode)
        % Save the straight m-code (for easy eval'ing and plain display)
        codeNode = dom.createElement('mcode');
        cellNode.appendChild(codeNode);
        codeTextNode = dom.createTextNode(newCode);
        codeNode.appendChild(codeTextNode);
        
        % Save the colorized m-code (for fancy-pants display)
        codeNode = dom.createElement('mcode-xmlized');
        cellNode.appendChild(codeNode);
        node=com.mathworks.widgets.CodeAsXML.xmlize(dom,char(newCode));
        codeNode.appendChild(node);

        % Save position of this code.
        codeNode = dom.createElement('mcode-count');
        cellNode.appendChild(codeNode);
        codeCount = codeCount + 1;
        codeTextNode = dom.createTextNode(num2str(codeCount));
        codeNode.appendChild(codeTextNode);
    end
    
    for cellOutputTarget = chunkList(n).outputTargets'
        cellOutputTargetNode = dom.createElement('cellOutputTarget');
        newTextNode = dom.createTextNode(num2str(cellOutputTarget));
        cellOutputTargetNode.appendChild(newTextNode);
        cellNode.appendChild(cellOutputTargetNode);
    end

end

% Tag the first cell if it is an "Overview".
cellList = dom.getFirstChild.getElementsByTagName('cell');
if (cellList.getLength > 1) && ...
        (cellList.item(0).getElementsByTagName('mcode').getLength == 0)
    cellList.item(0).setAttribute('style','overview')
    % A title in the "Overview" cell is the document title.
    firstStepTitle = cellList.item(0).getElementsByTagName('steptitle');
    if (firstStepTitle.getLength == 1)
        firstStepTitle.item(0).setAttribute('style','document')
    end
end

% Potentially tag the first steptitle as the document title.
if (dom.getElementsByTagName('steptitle').getLength == 1)
    firstStepTitle = cellList.item(0).getElementsByTagName('steptitle');
    if (firstStepTitle.getLength == 1)
        firstStepTitle.item(0).setAttribute('style','document')
    end
end

% Save the virgin code in a node.
originalCodeNode = dom.createElement('originalCode');
rootNode.appendChild(originalCodeNode);
originalCodeNode.appendChild(dom.createTextNode(originalCode));

end

%===============================================================================
function chunk = newChunk()
chunk = [];
chunk.title = '';
chunk.text = {};
chunk.code = '';
chunk.outputTargets = [];
end

%===============================================================================
function txt = removeBlankLinesAtTopAndBottom(txt)
nonReturns = find(txt~=10 & txt~=13);
txt = txt(min(nonReturns):max(nonReturns));
end

%===============================================================================
function textNode = buildTextNode(dom,textLines)
% buildTextNode Creates dom nodes for a block of "text" comments.

% Create the <text> node.
textNode = dom.createElement('text');

% Create an empty line at the end to mark the end of the last section.
textLines{end+1} = '';

currentParagraph = [];
paragraphText = '';
for lineNumber = 1:length(textLines)
    textLine = textLines{lineNumber};
    if isempty(textLine) && isempty(currentParagraph)
        % Another blank line between sections.  Do nothing.
    elseif isempty(textLine)
        % End of a section.  Put this text into the currentParagraph node.
        oldMarkupPattern = '^(http|ftp|file):.*\.(jpg|jpeg|gif|png)$';
        newMarkupPattern = '^<<.*>>$';
        isInParagraph = isequal(char(currentParagraph.getNodeName),'p');
        if isInParagraph && ~isempty(regexp(paragraphText,oldMarkupPattern,'once'))
            % An image to include by URL.
            imgNode = dom.createElement('img');
            imgNode.setAttribute('src',paragraphText);
            currentParagraph.appendChild(imgNode);
        elseif isInParagraph && ~isempty(regexp(paragraphText,newMarkupPattern,'once'))
            % An image to include by URL.
            imgNode = dom.createElement('img');
            imgNode.setAttribute('src',paragraphText(3:end-2));
            currentParagraph.appendChild(imgNode);
        elseif isInParagraph && length(paragraphText) > 3 && ...
                isequal(paragraphText([1 2 end-1 end]),'$$$$')
            % A LaTeX equation to convert.
            % Mark with <equation> for processing by EVALMXDOM.
            equationNode = dom.createElement('equation');
            equationNode.setAttribute('text',paragraphText);
            equationNode.appendChild(dom.createTextNode(paragraphText));
            currentParagraph.appendChild(equationNode);
        elseif isInParagraph && ...
                ~isempty(regexp(paragraphText,'^<html>.*</html>$','once'))
            % Raw HTML.
            htmlNode = dom.createElement('html');
            htmlNode.setAttribute('text',paragraphText);
            htmlNode.appendChild(dom.createTextNode(paragraphText));
            currentParagraph.appendChild(htmlNode);
        elseif isInParagraph && ...
                ~isempty(regexp(paragraphText,'^<latex>.*</latex>$','once'))
            % Raw LaTeX.
            htmlNode = dom.createElement('latex');
            htmlNode.setAttribute('text',paragraphText(8:end-8));
            htmlNode.appendChild(dom.createTextNode(paragraphText));
            currentParagraph.appendChild(htmlNode);
        else
            if currentParagraph.getNodeName.equals('pre')
                currentParagraph.appendChild(dom.createTextNode(paragraphText));
            else
                paragraphText = findUrls(paragraphText);
                formatText(dom,currentParagraph,paragraphText);
            end
        end
        currentParagraph = [];
        paragraphText = '';
        listNode = [];
    else
        if isempty(currentParagraph)
            if ~isempty(regexp(textLine,'^[#*] ','once'))
                % Beginning of a list.
                switch textLine(1)
                    case '*'
                        element = 'ul';
                    case '#'
                        element = 'ol';
                end
                listNode = dom.createElement(element);
                textNode.appendChild(listNode);
                % Create a new bullet.
                currentParagraph = dom.createElement('li');
                listNode.appendChild(currentParagraph);
                textLine(1:2) = [];
            elseif strncmp(textLine,' ',1)
                % Beginning of preformatted text.
                currentParagraph = dom.createElement('pre');
                textNode.appendChild(currentParagraph);
                textLine(1) = [];
            else
                % Beginning of a new "regular" paragraph.
                currentParagraph = dom.createElement('p');
                textNode.appendChild(currentParagraph);
            end
        end
        
        if (isequal(char(currentParagraph.getNodeName),'li') && ...
                ~isempty(regexp(textLine,'^[#*] ','once')))
            % Another bullet in a bulleted list.
            % Snap the last bullet.
            paragraphText = findUrls(paragraphText);
            formatText(dom,currentParagraph,paragraphText);
            paragraphText = '';
            % Create a new bullet.
            currentParagraph = dom.createElement('li');
            listNode.appendChild(currentParagraph);
            textLine(1:2) = [];
        end
        
        % Tack this line of text on.
        if isempty(paragraphText)
            paragraphText = textLine;
        elseif isequal(char(currentParagraph.getNodeName),'pre')
            if strncmp(textLine,' ',1)
                textLine(1) = [];
            end
            paragraphText = [paragraphText 10 textLine];
        else
            paragraphText = [paragraphText ' ' textLine];
        end
    end
end

end

%===============================================================================
function s = findUrls(s)

% Add markup for bare URLs.

% As defined in http://www.ietf.org/rfc/rfc2396.txt
excludedUrlChars = ' <>|<{}|\^[]`';
escapedExcludedUrlChars = reshape( ...
    ['\' .* ones(size(excludedUrlChars)); excludedUrlChars], ...
    1, ...
    length(excludedUrlChars)*2);
pattern = ['(?:^|\s|\()((http|file|ftp|mailto):[^' escapedExcludedUrlChars ']+)'];
[null,null,tokens] = regexp(s,pattern);

for i = length(tokens):-1:1
    start = tokens{i}(1);
    finish = tokens{i}(2);
    switch s(finish)
        % Exclude common punctuation from the end of a URL.
        case {'.',',','?',':',';','!','"','''',')'}
            finish = finish-1;
    end
    if ~((start > 1) && s(start-1) == '<')
        s = [s(1:start-1) '<' s(start:finish) '>' s(finish+1:end)];
    end
end

% Add markup for bare e-mail addresses.

[null,null,tokens] = regexp(s, ...
    '(?:^|\s|\()([a-zA-Z0-9_\-\.]+\@[a-zA-Z0-9_\-\.]+\.[a-zA-Z]+)');
for i = length(tokens):-1:1
    start = tokens{i}(1);
    finish = tokens{i}(2);
    if (s(start) ~= '<') && ...
            ~((start > 8) && isequal(s(start-8:start-1),'<mailto:'))
        s = [s(1:start-1) '<mailto:' s(start:finish) ' ' ...
                s(start:finish) '>' s(finish+1:end)];
    end
end

end

%===============================================================================
function formatText(dom,parentNode,textBlock)
% FORMATTEXT Recursively format the text and add the nodes to the dom.

if isempty(textBlock)
    % Nothing to do.  Bail out.
    return
end

[tagStart,tagEnd,tagType] = findMarkup(textBlock);

if isempty(tagStart)
    % No special formatting.  Just put the text in a node.
    for ss = {'R','TM';174,8482}
        pat = '(?<=\w)\((??@ss{1})\)(?=\W|$)';
        textBlock = regexprep(textBlock,pat,char(ss{2}));
    end
    textNode = dom.createTextNode(textBlock);
    parentNode.appendChild(textNode);
elseif (tagStart == 1)
    tagNode = dom.createElement(tagType);
    parentNode.appendChild(tagNode);
    % Handle the text inside the tag.
    if isequal(tagType,'a')
        link = textBlock(tagStart+1:tagEnd);
        spacePosition = find(link == ' ',1,'first');
        if isempty(spacePosition)
            % Use the link as the link text.
            tagNode.setAttribute('href',link)
            formatText(dom,tagNode,link);
        else
            % Use alternate text for the link text.
            tagNode.setAttribute('href',link(1:spacePosition-1))
            formatText(dom,tagNode,textBlock(tagStart+spacePosition+1:tagEnd));
        end
    else
        formatText(dom,tagNode,textBlock(tagStart+1:tagEnd));
    end
    % Handle the text after the tag.
    formatText(dom,parentNode,textBlock(tagEnd+2:end));
else
    % Some special formatting, but not at the beginning of the text.
    % Handle the text before the formatting.
    formatText(dom,parentNode,textBlock(1:tagStart-1));
    % Handle the rest of the line starting with the formatting.
    formatText(dom,parentNode,textBlock(tagStart:end));
end
end

%===============================================================================
function [start,finish,tagType] = findMarkup(s)

tagList = 'btai';
beginningCharList = '*|<_';
endingCharList = '*|>_';

start = Inf;
finish = Inf;
for iTag = 1:length(tagList);
    % Figure out which could be beginnings.
    locations = find(s==beginningCharList(iTag));
    keep = true(size(locations));
    for i = 1:length(locations)
        b = locations(i);
        % A beginning must either the first character or preceded by whitespace
        % or an alphahumeric.
        if (b > 1) && (~isWhitespace(s(b-1)) && ...
                ~isMarkupStart(s(b-1)) && ~isPunctuationStart(s(b-1)))
            keep(i) = false;
        end
        % A beginning must not be the last character and must be followed by
        % non-whitespace.
        if (b == length(s)) || isWhitespace(s(b+1))
            keep(i) = false;
        end
    end
    beginnings = locations(keep);
    
    % Figure out which could be endings.
    locations = find(s==endingCharList(iTag));
    keep = true(size(locations));
    for i = 1:length(locations)
        e = locations(i);
        % An ending character must not be the first character and must not be
        % preceded by whitespace.
        if (e == 1) || isWhitespace(s(e-1))
            keep(i) = false;
        end
        % An ending character must either be the last character or it must not
        % be followed by an alphanumeric.
        if (e < (length(s))) && isAlphanumeric(s(e+1))
            keep(i) = false;
        end
    end
    endings = locations(keep);
    
    % Make sure the the match.
    match = false;
    if ~isempty(beginnings)
        beginning = beginnings(1);
        endings = endings(endings > (beginning+1));
        if ~isempty(endings)
            ending = endings(1);
            match = true;
        end
    end
    if match && (beginning < start)
        start = beginning;
        finish = ending-1;
        tagType = tagList(iTag);
    end
end

if isinf(start)
    start = []; 
    finish = [];
    tagType = '';
end

if (tagType == 't')
    tagType = 'tt';
end

end

%===============================================================================
function t = isAlphanumeric(s)
t = ('a' <= s & s <= 'z') | ('A' <= s & s <= 'Z') | ('0' <= s & s <= '9');
end

%===============================================================================
function t = isWhitespace(s)
t = (s == ' ');
end

%===============================================================================
function t = isMarkupStart(s)
t = (s == '*') | (s == '|') | (s == '<') | (s == '_');
end

%===============================================================================
function t = isPunctuationStart(s)
t = (s == '(');
end