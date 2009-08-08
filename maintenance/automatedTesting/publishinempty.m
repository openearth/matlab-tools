function outputAbsoluteFilename = publishincaller(file,options)
%PUBLISH   Create a document from an M-file.
%   PUBLISH(FILE) evaluates the M-file one cell at a time in the
%   base workspace.  It saves the code, comments, and results to an HTML-file
%   with the same name.  The HTML-file is stored, along with other supporting
%   output files, in an "html" subdirectory within the script's directory.
%
%   PUBLISH(FILE,FORMAT) saves the results to the specified format.  FORMAT
%   can be one of the following:
%
%      'html'  - HTML.
%      'doc'   - Microsoft Word (requires Microsoft Word).
%      'ppt'   - Microsoft PowerPoint (requires Microsoft PowerPoint).
%      'xml'   - An XML file that can be transformed with XSLT or other tools.
%      'latex' - LaTeX.  Also sets the default imageFormat to 'epsc2' unless figureSnapMethod is 'getframe'.
%
%   PUBLISH(FILE,OPTIONS) provides a structure, OPTIONS, that may contain any
%   of the following fields.  If the field is not specified, the first choice
%   in the list is used.
%
%       format: 'html' | 'doc' | 'ppt' | 'xml' | 'latex'
%       stylesheet: '' | an XSL filename (ignored when format = 'doc' or 'ppt')
%       outputDir: '' (an html subfolder below the file) | full path
%       imageFormat: '' (default based on format)  | any supported by PRINT or IMWRITE, depending on figureSnapMethod
%       figureSnapMethod: 'print' | 'getframe'
%       useNewFigure: true | false
%       maxHeight: [] (unrestricted) | positive integer (pixels)
%       maxWidth: [] (unrestricted) | positive integer (pixels)
%       showCode: true | false
%       evalCode: true | false
%       catchError: true | false
%       createThumbnail: true | false
%       maxOutputLines: Inf | non-negative integer
%       codeToEvaluate: (the M-file you're publishing) | any valid code
%
%   When publishing to HTML, the default stylesheet stores the original code as
%   an HTML comment, even if "showcode = false".  Use GRABCODE to extract it.
%
%   Example:
%
%       opts.outputDir = tempdir;
%       file = publish('intro',opts);
%       web(file)
%
%   See also NOTEBOOK, GRABCODE.

% Matthew J. Simoneau, June 2002
% $Revision: 1.1.6.26.4.1 $  $Date: 2008/02/03 16:10:43 $
% Copyright 1984-2008 The MathWorks, Inc.

% This function requires Java.
if ~usejava('jvm')
    error('MATLAB:publish:NoJvm','PUBLISH requires Java.');
end

% Default to HTML publishing.
if (nargin < 2)
    options = 'html';
end

% If options is a simple string (format), convert to structure.
if ischar(options)
    t = options;
    options = struct;
    options.format = t;
end

% Process options.
checkOptionFields(options);
options = supplyDefaultOptions(options);
validateOptions(options)
format = options.format;

% Determine the image extension from the imageFormat, e.g. "jpeg" = "jpg".
[null,printTable(:,1),printTable(:,2)] = printtables;
lookup = strmatch(options.imageFormat,printTable(:,1),'exact');
if isempty(lookup)
    imageExtension = options.imageFormat;
else
    imageExtension = printTable{lookup,2};
end

% Locate source.
checkFilename(file,options)
fullPathToScript = locateFile(file);
if isempty(fullPathToScript)
    error('MATLAB:publish:SourceNotFound','Cannot find "%s".',file);
% Do a case insensitve match because the PC is case-insensitve.
elseif ~strcmpi(strrep(fullPathToScript,'/',filesep),which(file)) && ...
        (options.evalCode==true)
    pathMessage = 'PUBLISH needs to run the M-file because the evalCode option is set,\nbut the M-file is not on the MATLAB path.';
    error('MATLAB:publish:OffPath',pathMessage)
end
code = file2char(fullPathToScript);
[scriptDir,prefix] = fileparts(fullPathToScript);

% Determine publish location.
if isfield(options,'outputDir') && ~isempty(options.outputDir)
    outputDir = options.outputDir;
    % Check for relative path.
    javaFile = java.io.File(outputDir);
    if ~(javaFile.isAbsolute)
        outputDir = fullfile(pwd,outputDir);
    end
else
    outputDir = fullfile(scriptDir,'html');
end
switch format
    case 'latex'
        ext = 'tex';
    otherwise
        ext = format;
end
outputAbsoluteFilename = fullfile(outputDir,[prefix '.' ext]);

% Make sure we can write to this filename.  Create the directory, if needed.
message = prepareOutputLocation(outputAbsoluteFilename);
if ~isempty(message)
    error('MATLAB:publish:CannotWriteOutput',strrep(message,'\','\\'))
end

% Determine where to save image files.
switch format
    case {'doc','ppt'}
        imageDir = tempdir;
        needToCleanTempdir = true;
    otherwise
        imageDir = outputDir;
        needToCleanTempdir = false;
end

% Flush out any existing images.  This also verifies there are no read-only
% images in the way.  It also keeps us from drooling images if a
% republished version has fewer images than the existing one.
deleteExistingImages(imageDir,prefix,imageExtension,false)

% Convert the M-code to XML.
[dom,cellBoundaries] = m2mxdom(code);

% Add reference to original M-file.
newNode = dom.createElement('m-file');
newTextNode = dom.createTextNode(prefix);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);
newNode = dom.createElement('filename');
newTextNode = dom.createTextNode(fullPathToScript);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);
newNode = dom.createElement('outputdir');
newTextNode = dom.createTextNode(outputDir);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);

% Creat images of TeX equations for non-TeX output.
if ~isequal(format,'latex')
    dom = createEquationImages(dom,imageDir,prefix);
end

% Evaluate each cell, snap the output, and store the results.
if options.evalCode
    dom = evalmxdom(prefix,dom,cellBoundaries,prefix,imageDir,options);
end

% Post-process the DOM.
dom = removeDisplayCode(dom,options.showCode);
dom = truncateOutput(dom,options.maxOutputLines);

% Write to the output format.
switch format
    case 'xml'
        if isempty(options.stylesheet)
            xmlwrite(outputAbsoluteFilename,dom)
        else
            xslt(dom,options.stylesheet,outputAbsoluteFilename);
        end

    case {'html','latex'}
        xslt(dom,options.stylesheet,outputAbsoluteFilename);

    case 'doc'
        mxdom2word(dom,outputAbsoluteFilename);

    case 'ppt'
        mxdom2ppt(dom,outputAbsoluteFilename);

end

% Cleanup.
if needToCleanTempdir
    try
        deleteExistingImages(imageDir,prefix,imageExtension,true)
    catch
        % Don't error if cleanup fails for some strange reason.
    end
end

%===============================================================================
function checkFilename(file,options)
% Check for valid M-file name.
[unused,base,ext] = fileparts(file);
if (options.evalCode==true) && ...
    (~isvarname(base) || ~(isempty(ext) || strcmp(ext,'.m')))
        error( ...
            'MATLAB:publish:BadName', ...
            'PUBLISH needs to run the M-file because the "evalCode" option is set to "true",\nbut "%s" is not a valid M-file name.' , ...
            [base ext])
end
end

%===============================================================================
function checkOptionFields(options)
validOptions = {'format','stylesheet','outputDir','imageFormat', ...
    'figureSnapMethod','useNewFigure','maxHeight','maxWidth','showCode', ...
    'evalCode','stopOnError','catchError','createThumbnail','maxOutputLines', ...
    'codeToEvaluate'};
bogusFields = setdiff(fieldnames(options),validOptions);
if ~isempty(bogusFields)
    error('MATLAB:publish:InvalidOption','Invalid option "%s".  Note that options are case sensitive.',bogusFields{1});
end
end

%===============================================================================
function options = supplyDefaultOptions(options)
% Supply default options for any that are missing.
if ~isfield(options,'format')
    options.format = 'html';
end
format = options.format;
if ~isfield(options,'stylesheet') || isempty(options.stylesheet)
    switch format
        case 'html'
            codepadDir = fileparts(which(mfilename));
            styleSheet = fullfile(codepadDir,'private','mxdom2simplehtml.xsl');
            options.stylesheet = styleSheet;
        case 'latex'
            codepadDir = fileparts(which(mfilename));
            styleSheet = fullfile(codepadDir,'private','mxdom2latex.xsl');
            options.stylesheet = styleSheet;
        otherwise
            options.stylesheet = '';
    end
end
if ~isfield(options,'figureSnapMethod')
    options.figureSnapMethod = 'print';
end
if ~isfield(options,'imageFormat') || isempty(options.imageFormat)
    if strcmp(format,'latex') && strcmp(options.figureSnapMethod,'print')
        options.imageFormat = 'epsc2';
    else
        options.imageFormat = 'png';
    end
elseif strcmp(options.imageFormat,'jpg')
    options.imageFormat = 'jpeg';
elseif strcmp(options.imageFormat,'tif')
    options.imageFormat = 'tiff';
elseif strcmp(options.imageFormat,'gif')
    error('MATLAB:publish:NoGIFs','"gif" is not a supported imageFormat.');
end
if ~isfield(options,'useNewFigure')
    options.useNewFigure = true;
end
if ~isfield(options,'maxHeight')
    options.maxHeight = [];
end
if ~isfield(options,'maxWidth')
    options.maxWidth = [];
end
if ~isfield(options,'showCode')
    options.showCode = true;
end
if ~isfield(options,'evalCode')
    options.evalCode = true;
end
if ~isfield(options,'stopOnError')
    options.stopOnError = true;
end
if ~isfield(options,'catchError')
    options.catchError = true;
end
if ~isfield(options,'createThumbnail')
    options.createThumbnail = true;
end
if ~isfield(options,'maxOutputLines')
    options.maxOutputLines = Inf;
end
if ~isfield(options,'codeToEvaluate')
    options.codeToEvaluate = '';
end
end

%===============================================================================
function validateOptions(options)

% Check format.
supportedFormats = {'html','doc','ppt','xml','rpt','latex'};
if isempty(strmatch(options.format,supportedFormats,'exact'))
    error('MATLAB:publish:UnknownFormat','Unsupported format "%s".',options.format);
end

% Check stylesheet.
if ~isempty(options.stylesheet) && ~exist(options.stylesheet,'file')
    error( ...
        'MATLAB:publish:StylesheetNotFound', ...
        'The specified stylesheet, "%s", does not exist.', ...
        options.stylesheet)
end

% Check logical scalars.
logicalScalarOptions = {'useNewFigure','showCode','evalCode','catchError','createThumbnail'};
isLogicalScalarOrEmpty = @(x) ...
    isempty(options.(x)) || ...
    (islogical(options.(x)) && (numel(options.(x))==1));
badOptions = logicalScalarOptions(~cellfun(isLogicalScalarOrEmpty,logicalScalarOptions));
if ~isempty(badOptions)
    error( ...
        'MATLAB:publish:InvalidOptionValue', ...
        'The value of "%s" must be a logical scalar, e.g. true and not the string ''true''.', ...
        badOptions{1})
end

% Check consistency.
vectorFormats = getVectorFormats;
if ~isempty(strmatch(options.imageFormat,vectorFormats,'exact'))
    if strcmp(options.figureSnapMethod,'getframe')
        error( ...
            'MATLAB:publish:StylesheetNotFound', ...
            'The imageFormat "%s" is incompatible with the figureSnapMethod "getframe".', ...
            options.imageFormat)
    end
    if ~isempty(options.maxHeight)
        warning('MATLAB:publish:IncompatibleOptions', ...
            'Setting a maximum image height is incompatible with %s-files and will be ignored.', ...
            upper(options.imageFormat))
    end
    if ~isempty(options.maxWidth)
        warning('MATLAB:publish:IncompatibleOptions', ...
            'Setting a maximum image width is incompatible with %s-files and will be ignored.', ...
            upper(options.imageFormat))
    end
end

% Check deprication.
if ~isempty(options.stopOnError) && (options.stopOnError == false)
        warning('MATLAB:publish:DeprecatedOptions', ...
            'stopOnError is no longer supported.  Use TRY/CATCH in your code for a similar effect.')    
end
end

%===============================================================================
function deleteExistingImages(imageDir,prefix,imageExtension,equations)

% Start with a list of candidates for deletions.
d = dir(fullfile(imageDir,[prefix '_*.*']));

% Define the regexp to use to to lessen the chance of false hits.
tail = ['\d{2,}\.' imageExtension];
if equations
    tail = ['(' tail '|eq\d+\.png)'];
end
imagePattern = ['^' prefix '_' tail '$'];

% We need to detect if a DELETE failed by checking WARNING.  Save the
% original state and clear the warning.
[lastmsg,lastid] = lastwarn('');

% Delete the images.
for i = 1:length(d)
    if (regexp(d(i).name,imagePattern) == 1)
        toDelete = fullfile(imageDir,d(i).name);
        delete(toDelete)
        if ~isempty(lastwarn)
            error('MATLAB:publish:CannotWriteOutput', ...
                'Cannot delete "%s".',toDelete)
        end
    end
end

% Delete the thumbnail.
thumbnail = fullfile(imageDir,[prefix '.png']);
if ~isempty(dir(thumbnail))
    delete(thumbnail)
    if ~isempty(lastwarn)
        error('MATLAB:publish:CannotWriteOutput', ...
            'Cannot delete "%s".',thumbnail)
    end
end

% Restore the warning.
lastwarn(lastmsg,lastid);
end

%===============================================================================
function dom = removeDisplayCode(dom,showCode)
if ~showCode
    while true
        codeNodeList = dom.getElementsByTagName('mcode');
        if (codeNodeList.getLength == 0)
            break;
        end
        codeNode = codeNodeList.item(0);
        codeNode.getParentNode.removeChild(codeNode);
    end
    while true
        codeNodeList = dom.getElementsByTagName('mcode-xmlized');
        if (codeNodeList.getLength == 0)
            break;
        end
        codeNode = codeNodeList.item(0);
        codeNode.getParentNode.removeChild(codeNode);
    end
end
end

%===============================================================================
function dom = truncateOutput(dom,maxOutputLines)
if ~isinf(maxOutputLines)
    outputNodeList = dom.getElementsByTagName('mcodeoutput');
    % Start at the end in case we remove nodes.
    for iOutputNodeList = outputNodeList.getLength:-1:1
        outputNode = outputNodeList.item(iOutputNodeList-1);
        if (maxOutputLines == 0)
            outputNode.getParentNode.removeChild(outputNode);
        else
            text = char(outputNode.getFirstChild.getData);
            newlines = regexp(text,'\n');
            if maxOutputLines <= length(newlines)
                chopped = text(newlines(maxOutputLines):end);
                text = text(1:newlines(maxOutputLines));
                if ~isempty(regexp(chopped,'\S','once'))
                    text = [text '...'];
                end
            end
            outputNode.getFirstChild.setData(text);
        end
    end
end
end

%===============================================================================
% All these subfunctions are for equation handling.
%===============================================================================
function dom = createEquationImages(dom,imageDir,prefix)
% Render equations as images to be included in the document.

% Setup.
baseImageName = fullfile(imageDir,prefix);
[tempfigure,temptext] = getRenderingFigure;

% Loop over each equation.
equationList = dom.getElementsByTagName('equation');
for i = 1:getLength(equationList)
    equationNode = equationList.item(i-1);
    equationText = char(equationNode.getTextContent);
    fullFilename = [baseImageName '_' hashEquation(equationText) '.png'];
    % Check to see if this equation needs to be rendered.
    if ~isempty(dir(fullFilename))
        % We've already got it on disk.  Use it.
        swapTexForImg(dom,equationNode,imageDir,fullFilename)
    else
        % We need to render it.
        [x,texWarning] = renderTex(equationText,tempfigure,temptext);
        if isempty(texWarning)
            % Now shrink it down to get anti-aliasing.
            newSize = ceil(size(x)/2);
            x = make_thumbnail(x,newSize(1:2));
            % Rendering succeeded.  Write out the image and use it.
            imwrite(x,fullFilename)
            % Put a link to the image in the DOM.
            swapTexForImg(dom,equationNode,imageDir,fullFilename)
        else
            % Rendering failed.  Add error message.
            beep
            errorNode = dom.createElement('pre');
            errorNode.setAttribute('class','error')
            errorNode.appendChild(dom.createTextNode(texWarning));
            % Insert the error after the equation.  This would be easier if
            % there were an insertAfter node method.
            pNode = equationNode.getParentNode;
            if isempty(pNode.getNextSibling)
                pNode.getParentNode.appendChild(errorNode);
            else
                pNode.getParentNode.insertBefore(errorNode,pNode.getNextSibling);
            end
        end
    end
end

% Cleanup.
close(tempfigure)
end

%===============================================================================
function swapTexForImg(dom,equationNode,imageDir,fullFilename)
% Swap the TeX equation for the IMG.
equationNode.removeChild(equationNode.getFirstChild);
imgNode = dom.createElement('img');
imgNode.setAttribute('src',strrep(fullFilename,[imageDir filesep],''));
equationNode.appendChild(imgNode);
end

%===============================================================================
function [tempfigure,temptext] = getRenderingFigure

% Create a figure for rendering the equation, if needed.
tag = ['helper figure for ' mfilename];
tempfigure = findall(0,'type','figure','tag',tag);
if isempty(tempfigure)
    figurePos = get(0,'ScreenSize');
    if ispc
        % Set it off-screen since we have to make it visible before printing.
        % Move it over and down plus a little bit to keep the edge from showing.
        figurePos(1:2) = figurePos(3:4)+100;
    end
    % Create a new figure.
    tempfigure = figure( ...
        'handlevisibility','off', ...
        'integerhandle','off', ...
        'visible','off', ...
        'paperpositionmode', 'auto', ...
        'PaperOrientation', 'portrait', ...
        'color','w', ...
        'position',figurePos, ...
        'tag',tag);
    tempaxes = axes('position',[0 0 1 1], ...
        'parent',tempfigure, ...
        'xtick',[],'ytick',[], ...
        'xlim',[0 1],'ylim',[0 1], ...
        'visible','off');
    temptext = text('parent',tempaxes,'position',[.5 .5], ...
        'horizontalalignment','center','fontsize',22, ...
        'interpreter','latex');
else
    % Use existing figure.
    tempaxes = findobj(tempfigure,'type','axes');
    temptext = findobj(tempaxes,'type','text');
end
end

%===============================================================================
function [x,texWarning] = renderTex(equationText,tempfigure,temptext)

% Render and snap!
[lastMsg,lastId] = lastwarn('');
set(temptext,'string',equationText);
if ispc
    % The font metrics are not set properly unless the figure is visible.
    set(tempfigure,'Visible','on');
end
drawnow;
x = hardcopy(tempfigure,'-dzbuffer','-r0');
set(tempfigure,'Visible','off');
texWarning = lastwarn;
lastwarn(lastMsg,lastId)
set(temptext,'string','');

if isempty(texWarning)
    % Sometimes the first pixel isn't white.  Crop that out.
    x(1,:,:) = [];
    x(:,1,:) = [];
    % Crop out the rest of the whitespace border.
    [i,j] = find(sum(double(x),3)~=765);
    x = x(min(i):max(i),min(j):max(j),:);
    if isempty(x)
        % The image is empty.  Return something so IMWRITE doesn't complain.
        x = 255*ones(1,3,'uint8');
    end
end
end

end
%===============================================================================
%===============================================================================
