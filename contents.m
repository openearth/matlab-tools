% Vodas Log Toolbox for reading and processing vodas log data!
%
%   WorkingWithVolt        - is an example of how volt works.
% 
% volt is an object based program. This means two things.
%
% 1) volt is a data structure with the following fields
% 
%                file: the name of the vodas log file
%                path: the directory of the vodas log file
%              header: the header lines from the vodas log file
%     numberOfSignals: the total number of signals from the logging
%          signalTags: the signal name tags from the header
%                data: a matrix with the signals
%                  t1: start time for the time selection
%                  t2: end time for the time selection
%           selection: a time selection
%
%
% 2) volt has the following methods
%
%   voltReadLog            - read a VODAS log file.
%   voltLoadMatFile        - load the volt mat file.
%   voltListTags           - show the list of signal tags.
%   voltSetTimeSelection   - set a time selection.
%   voltGetTagNumber       - get the number of a signal.
%   voltPlot               - plot one or more signals.
%   voltGetSignal         -  get a signal.
%
% volt is a global variable. This is not strictly necessary. But the use
% of a global will allow volt to handle larger files. volt stores
% all the data in a field (volt.data). Since volt is global it is not
% required to make a copy in the computer memory, when passing the data as
% an input argument into a function.
%
%
%
%
%
%
% Known bugs:
%    >> vodasReadLog reads the header. With the Vox Máxima the header line
%       can become long for a large selection signals the buffer size
%       for textscan can be too small. The buffer size is currently set
%       to 8190. This can generate an unexpected error at the end of
%       vodasReadLog when calling vertcat. This is cause by the wrong
%       numberOfSignals derived from the header.
%    >> Log files from the Nordness can contain the following value:
%       "Infinity". Matlab does not recognise this, since it uses: "Inf".
%       A "work around" solution is to open the file in Word and use
%       find "Infinity" / replace "Inf     ".
%
%
%
% Solved bugs:
%    >> The date format differs between vodas log files. voltReadLog can
%       now read both the format dd-mm-yyyy, and also dd/mm/yyyy.