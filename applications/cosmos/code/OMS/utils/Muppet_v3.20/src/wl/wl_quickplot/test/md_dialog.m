function FinalAnswer=md_dialog(cmd,varargin)
%MD_DIALOG Simple dialog tool.
%
%   Answer=MD_DIALOG(Title, {Text List}, ...
%     {UI Type List}, {UI Options List}, ...
%     {Default Answer List})
%   Opens dialog and waits for answer. Except for the
%   first argument all arguments must be cell arrays
%   of equal length.
%
%   UI Type List and options:
%   edit        edit field, option: number of edit lines
%               (at most 5)
%   popupmenu   popup menu, option: cell array of choices
%   radiolist   list of mutual exclusive radio button choices
%               option: cell array of radio button strings
%   checkbox    checkbox item, no options
%   editint     edit field for integer, option: [min max]
%   editreal    edit field for floating point value, option:
%               [min max]
%   defedit     single line edit field with standard answers,
%               option: list of standard answers.
%
%   Example
%      md_dialog('Title', ...
%         {'Edit text:','Choose from list:', ...
%          'Select one:','Checkbox for true/false', ...
%          'Positive integer','Fraction', ...
%          'Edit or select:'}, ...
%         {'edit','popupmenu','radiolist','checkbox', ...
%          'editint','editreal','defedit'}, ...
%         {2,{'a','b','c'},{'al','bl','cl'},[],[0 inf], ...
%          [0 1],{'a','b','c'}}, ...
%         {'Double line edit','a','al',0,0,0.25,'g'})

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
