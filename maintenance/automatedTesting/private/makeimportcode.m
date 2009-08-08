function varargout = makeimportcode(varargin)
% This undocumented function may change in a future release.

%MAKEIMPORTCODE Generates readable m-code function based on input argument
%
%  MAKEIMPORTCODE(PARAMS) Generates m-code for importing data from a file 
%               (or the clipboard) using the specified parameters, and
%               displays the code in the desktop editor.
%
%  STR = MAKEIMPORTCODE(PARAMS, 'Output', '-editor')  Display code in the
%               desktop editor
%
%  STR = MAKEIMPORTCODE(PARAMS, 'Output', '-string') Output code as a 
%                string variable
%
%  MAKEIMPORTCODE(PARAMS,'Output', FILENAME) Output code as a file
%
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/27 18:07:24 $

% Fields for PARAMS
% --------
% REQUIRED:
% hasInputArg - logical
% hasOutputArg - logical
% needsStructurePatch - logical
% loadFunc - double.  One of...
%     0 = IMPORTDATA
%     1 = LOAD -MAT
%     2 = LOAD -ASCII
% outputBreakup - double.  One of...
%     0 = "normal"
%     1 = "by Column"
%     2 = "by Row"
% unpackXLSdata - logical
% unpackXLStextdata - logical
% unpackXLScolheaders - logical
% unpackXLSrowheaders - logical

%
% OPTIONAL:
% delimiter - char (ignored if loadFunc ~= 0)
% headerLines - double (ignored if loadFunc ~= 0)
 
% Check arguments.
checkArguments(varargin)
% Strip away unnecessary arguments, and add some new, calculated 
% parameters for later use.
params = adjustParams(varargin{1});
% Generate the basic function code.
hFunc = localGenCode(params);
% Add it to a codeprogram.
hProgram = codegen.codeprogram;
hProgram.addSubFunction(hFunc);
% Configure the output options, and use them to generate the code.
options = configureOptions(varargin);
strCells = hProgram.toMCode(options);
% Output the generated code in the requested style, possibly returning it.
out = handleGeneratedCode(options, generateCodeString(strCells));
if ~isempty(out)
    varargout{1} = out;
end

%-------------------------------
function checkArguments(args)
if isempty(args)
    error('MATLAB:codetools:makeimportcode:InsufficientArguments', ...
        'MAKEIMPORTCODE requires at least one input argument.');
end
if rem(length(args), 2) ~= 1
    error('MATLAB:codetools:makeimportcode:ArgumentsMustBeOdd', ...
        'MAKEIMPORTCODE requires an odd number of input arguments.');
end
if ~isstruct(args{1})
    error('MATLAB:codetools:makeimportcode:FirstArgMustBeStruct', ...
        'The first input argument to MAKEIMPORTCODE must be a structure.');
end
for i = 2:length(args)
    if ~ischar(args{i})
        error('MATLAB:codetools:makeimportcode:ArgsMustBeChars', ...
        'The second and subsequent input arguments to MAKEIMPORTCODE must be character arrays.');
    end
end

%-------------------------------
function params = adjustParams(params)
params.LOADMAT = params.loadFunc == 1;
params.LOADASCII = params.loadFunc == 2;
params.IMPORTDATA = ~params.LOADMAT && ~params.LOADASCII;
if (~params.IMPORTDATA)
    if isfield(params, 'delimiter')
        params = rmfield(params, 'delimiter');
    end
    if isfield(params, 'headerLines')
        params = rmfield(params, 'headerLines');
    end
end

%-------------------------------
function options = configureOptions(args)
options.Output = '-editor';
options.OutputTopNode = false;
options.ReverseTraverse = false;
options.ShowStatusBar = false;
options.MFileName = '';
if length(args) > 2
    for i = 2:(length(args)-1)
        if strcmpi(args{i}, 'Output')
            options.Output = args{i+1};
        end
    end
    if ( ~strcmp(options.Output,'-editor') && ...
            ~strcmp(options.Output,'-string') && ...
            ~strcmp(options.Output,'-cmdwindow') )
        [unused, file] = fileparts(options.Output); %#ok
        options.MFileName = file;
    end
end

%-------------------------------
function str = generateCodeString(strCells)
str = [];
for n = 1:length(strCells)
    str = [str, strCells{n}, sprintf('\n')];
end

%-------------------------------
function hFunc = localGenCode(params)

hFunc = codegen.coderoutine;

hFunc.Name = 'importfile';
if params.hasInputArg
    hFunc.Comment = 'Imports data from the specified file';
else
    hFunc.Comment = 'Imports data from the system clipboard';
end

hInputArg = generateInputArg(params.hasInputArg);
if (params.hasInputArg)
    hFunc.addArgin(hInputArg);
end
    
hOutputArg = generateOutputArgForImport;
importTheData(hFunc, params, hInputArg, hOutputArg);

if params.needsStructurePatch
    hOutputArg = createSimpleOutputWorkaround(hFunc, hInputArg, hOutputArg);
end

if params.unpackXLSdata || params.unpackXLStextdata || ...
        params.unpackXLScolheaders || params.unpackXLSrowheaders
    hFunc.addText('');
    hFunc.addText('% For some XLS and other spreadsheet files, returned data are packed'); 
    hFunc.addText('% within an extra layer of structures.  Unpack them.');
end

if params.unpackXLSdata
    createXLSunpack(hFunc, hOutputArg, 'data');
end

if params.unpackXLStextdata
    createXLSunpack(hFunc, hOutputArg, 'textdata');
end

if params.unpackXLScolheaders
    createXLSunpack(hFunc, hOutputArg, 'colheaders');
end

if params.unpackXLSrowheaders
    createXLSunpack(hFunc, hOutputArg, 'rowheaders');
end

if params.outputBreakup ~= 0
    hOutputArg = changeOutputBreakup(hFunc, hOutputArg, params);
end

generateOutputHandling(hFunc, params.hasOutputArg, hOutputArg);

%-------------------------------
function hInputArg = generateInputArg(hasInputArg)
hInputArg = codegen.codeargument;
hInputArg.IsParameter = hasInputArg;
if hasInputArg
    hInputArg.Name = 'fileToRead';
    hInputArg.Comment = 'File to read';
else
    hInputArg.Name = '''-pastespecial''';
    hInputArg.Comment = 'Read data from the system clipboard';
    hInputArg.Value = '-pastespecial';
end

%-------------------------------
function hOut = generateOutputArgForImport
hOut = codegen.codeargument;
hOut.IsParameter = true;
hOut.IsOutputArgument = true;
hOut.Name = 'newData';

%-------------------------------
function createNewVariables(hFunc, hStructure)
hFunc.addText('');
hFunc.addText('% Create new variables in the base workspace from those fields.');
hFunc.addText('vars = fieldnames(', hStructure, ');');
hFunc.addText('for i = 1:length(vars)');
hFunc.addText('    assignin(''base'', vars{i}, ', hStructure, '.(vars{i}));');
hFunc.addText('end');

%-------------------------------
function returnValuesAsStructure(hFunc, hOut)
hFunc.addArgout(hOut);

%-------------------------------
function importTheData(hFunc, params, hInputArg, hOutputArg)
delimiterArgument = '';
headerLinesArgument = '';
if isfield(params, 'delimiter') && (~isempty(params.delimiter))
    hFunc.addText('DELIMITER = ''', params.delimiter, ''';');
    delimiterArgument = ', DELIMITER';
    if isfield(params, 'headerLines') && (params.headerLines ~= -1)
        hFunc.addText('HEADERLINES = ', num2str(params.headerLines), ';');
        headerLinesArgument = ', HEADERLINES';
    end
    hFunc.addText('');
end

hFunc.addText('% Import the file');
if params.LOADMAT
    fun = 'load(''-mat'', ';
elseif params.LOADASCII
    fun = 'load(''-ascii'', ';
else
    fun = 'importdata(';
end

hFunc.addText(hOutputArg, ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, ');');

%-------------------------------
function hNewOutputArg = createSimpleOutputWorkaround(hFunc, hInputArg, hOutputArg)
hOutputArg.Name = 'rawData';

hNewOutputArg = codegen.codeargument;
hNewOutputArg.IsParameter = true;
hNewOutputArg.IsOutputArgument = true;
hNewOutputArg.Name = 'newData';

hFunc.addText('');
hFunc.addText('% For some simple files (such as a CSV or JPEG files), IMPORTDATA might'); 
hFunc.addText('% return a simple array.  If so, generate a structure so that the output'); 
hFunc.addText('% matches that from the Import Wizard.');
hFunc.addText('[unused,name] = fileparts(', hInputArg, '); %#ok');
hFunc.addText(hNewOutputArg, '.(genvarname(name)) = ', hOutputArg, ';');

%-------------------------------
function createXLSunpack(hFunc, hOutputArg, fieldname)             
hFunc.addText('fields = fieldnames(', hOutputArg, '.', fieldname, ');');
hFunc.addText(hOutputArg, '.', fieldname, ' = ', hOutputArg, '.', fieldname, '.(fields{1});');

%-------------------------------
function hOutputArg = changeOutputBreakup(hFunc, hOutputArg, params)
switch (params.outputBreakup) 
    case 1
        hNewOutputArg = codegen.codeargument;
        hNewOutputArg.IsParameter = true;
        hNewOutputArg.IsOutputArgument = true;
        hNewOutputArg.Name = 'dataByColumn';
        hFunc.addText('');
        hFunc.addText('% Break the data up into a new structure with one field per column.');
        hFunc.addText('colheaders = genvarname(', hOutputArg ,'.colheaders);');
        hFunc.addText('for i = 1:length(colheaders)');
        hFunc.addText('    ', hNewOutputArg, '.(colheaders{i}) = ', ...
            hOutputArg, '.data(:, i);');
        hFunc.addText('end');
        hOutputArg = hNewOutputArg;
    case 2
        hNewOutputArg = codegen.codeargument;
        hNewOutputArg.IsParameter = true;
        hNewOutputArg.IsOutputArgument = true;
        hNewOutputArg.Name = 'dataByRow';
        hFunc.addText('');
        hFunc.addText('% Break the data up into a new structure with one field per row.');
        hFunc.addText('rowheaders = genvarname(', hOutputArg ,'.rowheaders);');
        hFunc.addText('for i = 1:length(rowheaders)');
        hFunc.addText('    ', hNewOutputArg, '.(rowheaders{i}) = ', ...
            hOutputArg, '.data(i, :);');
        hFunc.addText('end');
        hOutputArg = hNewOutputArg;
    otherwise
        % Do nothing
end 

%-------------------------------
function generateOutputHandling(hFunc, hasOutputArg, hOutputArg)
if hasOutputArg
    returnValuesAsStructure(hFunc, hOutputArg);
else
    createNewVariables(hFunc, hOutputArg);
end

%-------------------------------
function res = handleGeneratedCode(options, str)
res = '';
if strcmp(options.Output,'-cmdwindow')
    disp(str);
elseif strcmp(options.Output,'-editor')
    % Throw to command window if java is not available
    err = javachk('mwt','The MATLAB Editor');
    if ~isempty(err)
        local_display_mcode(str,'cmdwindow');
    end
    com.mathworks.mlservices.MLEditorServices.newDocument(str,true)
elseif strcmp(options.Output,'-string')
    res = str;
else
    fid = fopen(options.Output,'w');
    if(fid<0)
        error('MATLAB:codetools:makeimportcode:CannotSave',['Could not create file: ',options.Output]);
    end
    fprintf(fid,'%s',str);
    fclose(fid);
end
