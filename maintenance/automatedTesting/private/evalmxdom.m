function dom = evalmxdom(file,dom,cellBoundaries,imagePrefix,outputDir,options)
%EVALMXDOM   Evaluate cellscript Document Object Model, generating inline images.
%   dom = evaldom(dom,imagePrefix,outputDir,options)
%   imagePrefix is the prefix that will be used for the image files.

% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.1.6.15.4.1 $  $Date: 2008/02/03 16:10:44 $

% Provide a clean, white figure.
if options.useNewFigure
    myFigure = figure('color','white');
else
    myFigure = [];
end

% Run the code.
[data,text,laste] = instrumentAndRun(file,cellBoundaries,outputDir,imagePrefix,options);

% Cleanup the provided figure, if it is still around.
close(myFigure(ishandle(myFigure)))

% Handle errors.
if ~isempty(laste)
    if options.catchError
        disp(formatError(laste,true))
        beep
    else
        error(laste)
    end
end

populateDom(dom,data,text,laste)
createThumbnail(options,data)

end

function [data,text,laste] = instrumentAndRun(file,cellBoundaries,outputDir,imagePrefix,options)

% Save the original status of this file for later restoration.
originalDbstatus = dbstatus(file);

% Add conditional breakpoints.
endCondition = setConditionalBreakpoints(file,cellBoundaries);

% Initialize publishSnapshot.
data = [];
data.baseImageName = fullfile(outputDir,imagePrefix);
data.options = options;
data.marker = 'WDEavRCxr';
snapnow('set',data)

% Run the command.
if isempty(options.codeToEvaluate)
    cmd = imagePrefix;
else
    cmd = options.codeToEvaluate;
end
ret = char(10);
[unused,tempVar] = fileparts(tempname);
setappdata(0,tempVar,cmd)
evalstr = [ ...
    'feature(''hotlinks'',0);' ret ...
    'evalinemptyworkspace(getappdata(0,''' tempVar '''));' ret ...
    endCondition ';'];
warnState = warning('off','backtrace');
% We use the two-argument form of EVALC here instead of wrapping EVALC in
% a TRY/CATCH so that "text" will still be populated with partial results,
% even when there's an error.
laste = [];
text = evalc(evalstr,'laste = lasterror;'); %#ok<EVLC>
warning(warnState);
rmappdata(0,tempVar)

% Remove all the extra conditional breakpoints we added.
safeDbclear(file)
dbstop(originalDbstatus)

if ~isempty(laste)
    % Trim the publishing infrastructure off of the error stack.
    laste.stack(end-(numel(dbstack)-1):end) = [];
end

% Get the latest info out of publishSnapshot.
data = snapnow('get',data);

end

function endCondition = setConditionalBreakpoints(file,cellBoundaries)

% Initialize structure for DBSTOP.
dbStruct.name = file;
dbStruct.file = which(file);
dbStruct.line = [];
dbStruct.expression = {};
dbStruct.anonymous = [];
dbStruct.cond = '';
dbStruct.identifier = {};

% Initialize variables for conditions.
condition = 'snapnow(%.0f,''%sCell'')';
endCondition = '';

% Add conditions to structure and endCondition.
safeDbclear
for iCell = 1:size(cellBoundaries,1)
    beginCell = findLandingLine(file,cellBoundaries(iCell,1));
    endCell = findLandingLine(file,cellBoundaries(iCell,2)+1);
    if isnan(beginCell)
        % No executible code left.
    elseif beginCell == endCell
        % No executible code in this cell.
    else
        bc = sprintf(condition,iCell,'begin');
        dbStruct = addCondition(dbStruct,beginCell,bc);
        ec = sprintf(condition,iCell,'end');
        if isnan(endCell)
            % The end file was reached before finding an executible line.
            endCondition = joinWithOr(endCondition,ec,'before');
        else
            dbStruct = addCondition(dbStruct,endCell,ec);
        end
    end
end

% Set the conditional breakpoints.
% DBSTOP crashes if dbStruct is "empty".
if ~isempty(dbStruct.line)
    dbstop(dbStruct)
end
    
end

function populateDom(dom,data,text,laste)

% Create nodeList.
nodeList = [];

% Populate images into nodeList.
for i = 1:numel(data.pictureList)
    imgNode = dom.createElement('img');
    [unused,name,ext] = fileparts(data.pictureList{i});
    imgNode.setAttribute('src',[name ext]);
    nodeList(end+1).node = imgNode;
    nodeList(end).cell = data.placeList(2*i-1);
    nodeList(end).count = data.placeList(2*i);
end

% Apply any "backspace" characters.
while true
    codeOutputSize = numel(text);
    text = regexprep(text,('([^\b])\b'),'');
    if codeOutputSize == numel(text)
        break
    end
end

% Populate M-code output into nodeList.
[cellTextNumbers,cellTextTexts,cellTextCounts] = textparse(text,data.marker);
for i = 1:numel(cellTextNumbers)
    cell = cellTextNumbers(i);
    text = cellTextTexts{i};
    count = cellTextCounts(i);
    if ~isempty(text)
        mcodeOutputNode = dom.createElement('mcodeoutput');
        mcodeOutputTextNode = dom.createTextNode(text);
        mcodeOutputNode.appendChild(mcodeOutputTextNode);
        nodeList(end+1).node = mcodeOutputNode;
        nodeList(end).cell = cell;
        nodeList(end).count = count;
    end
end

% Populate error into nodeList.
if ~isempty(laste)
    mcodeOutputNode = dom.createElement('mcodeoutput');
    mcodeOutputTextNode = dom.createTextNode(formatError(laste,false));
    mcodeOutputNode.appendChild(mcodeOutputTextNode);
    nodeList(end+1).node = mcodeOutputNode;
    % TODO Flag as error node so it will be red.
    nodeList(end).cell = data.lastGo;
    nodeList(end).count = data.counter();
end

% Put nodeList into cells.
if ~isempty(nodeList)
    [unused,ind] = sort([nodeList.count]);
    nodeList = nodeList(ind);
    cellOutputTargetList = dom.getElementsByTagName('cellOutputTarget');
    for i = 1:numel(nodeList)
        for iCellOutputTargetList = 1:cellOutputTargetList.getLength
            cellOutputTarget = cellOutputTargetList.item(iCellOutputTargetList-1);
            if str2double(char(cellOutputTarget.getTextContent)) == nodeList(i).cell
                cellOutputTarget.getParentNode.appendChild(nodeList(i).node);
                break
            end
        end
    end
end

end

function createThumbnail(options,data)

% Create thumbnail.
if options.createThumbnail && ~isempty(data.pictureList)
    switch options.imageFormat
        case {'png','jpeg','tiff','gif','bmp','hdf','pcx','xwd','ico','cur','ras','pbm','pgm','ppm'}
            % Read in the last image.
            [X,map] = imread(data.pictureList{end});

            % Convert to UINT8 RGB if we have to.
            if ~isempty(map)
                X = uint8(ind2rgb(X,map)*255);
            end

            % Limit the size of the thumbnail, but preserve the aspect ratio.
            imHeight = 64;
            imWidth = 85;
            [height,width,unused] = size(X); %#ok<NASGU> SIZE changes outputs.
            if (height > imHeight)
                width = floor(width*(imHeight/height));
                height = imHeight;
            end
            if (width > imWidth)
                height = floor(height*(imWidth/width));
                width = imWidth;
            end

            % Resize and write out.
            X = make_thumbnail(X,[height width]);
            imgFilename = [data.baseImageName '.png'];
            imwrite(X,imgFilename)
    end
end

end

function dbStruct = addCondition(dbStruct,landingLine,newCondition)
    % Put the breakpoint on the right line.
    % Find out if there was already a breakpoint there.
    iBreakpoint = find(dbStruct.line == landingLine,1);
    % Append this new condition onto an existing one.
    if isempty(iBreakpoint)
        dbStruct.line(end+1,1) = landingLine;
        dbStruct.anonymous(end+1,1) = 0;
        dbStruct.expression{end+1,1} = newCondition;
    else
        originalCondition = dbStruct.expression{iBreakpoint};
        dbStruct.expression{iBreakpoint} = joinWithOr(originalCondition,newCondition,'after');
    end
end

function newCondition = joinWithOr(base,addition,order)
if strcmp(order,'before')
    [base,addition] = deal(addition,base);
end
if isempty(base)
    newCondition = addition;
elseif isempty(addition)
    newCondition = base;
else
    newCondition = [base ' || ' addition];
end
end

function landingLine = findLandingLine(file,targetLine)
% Probe to see where the breakpoint wants to land.
% Precondition: this file has no existing breakpoints.
try
    dbstop(file,num2str(targetLine))
catch
    % This errors if there aren't any executible lines left.
end
tempDbstatus = dbstatus(file);
safeDbclear(file)
if isempty(tempDbstatus) || isempty(tempDbstatus.line)
    landingLine = NaN;
else
    landingLine = tempDbstatus.line;
end

end

function safeDbclear(file)
try
    dbclear('in',file)
catch
    % This errors when the file contains a parse error.
end
end

function [cellTextNumbers,cellTextTexts,cellTextCounts] = textparse(text,marker,cellTextNumbers,cellTextTexts,cellTextCounts,enclosingCell,enclosingCount)
if nargin < 3
    cellTextNumbers = [];
    cellTextTexts = {};
    cellTextCounts = [];
end
while ~isempty(text)
    [tMatches,mStartStart,mStartEnd] = ...
        regexp(text,[marker 'A(\d{5})(\d{5})'],'tokens','start','end','once');
    if isempty(tMatches)
        text = regexprep(text,[marker '[AZ](\d{5})(\d{5})'],'');
        if exist('enclosingCell','var')
            cellTextNumbers(end+1) = enclosingCell;
            cellTextTexts{end+1} = text;
            cellTextCounts(end+1) = enclosingCount;
        else
            disp(text)
        end
        break
    end
    iCell = str2double(tMatches(1));
    iCount = str2double(tMatches(2));
    [match,mEndStart,mEndEnd] = regexp(text, ...
        sprintf('%sZ%05.0f(\\d{5})',marker,iCell), ...
        'match','start','end','once');
    if isempty(match)
        mEndStart = numel(text+1);
        mEndEnd = numel(text+1);
    end
    [cellTextNumbers,cellTextTexts,cellTextCounts] = textparse(text(mStartEnd+1:mEndStart-1),marker,cellTextNumbers,cellTextTexts,cellTextCounts,iCell,iCount);
    text(mStartStart:mEndEnd) = [];
end
end

function m = formatError(laste,hotlinks)
    try
        rethrow(laste)
    catch e
        m = getReport(e);
    end
    if ~hotlinks
        m = regexprep(m,'<a .*?>(.*?)</a>','$1');
    end
end