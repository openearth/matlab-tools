function codeOut = replaceTabsInCode(codeIn)
%REPLACETABSINCODE  Substitute spaces for tabs in code to appear as HTML
%   codeOut = replaceTabsInCode(codeIn)

% Copyright 2006 The MathWorks, Inc.

% Get the number of spaces per tab based on the MATLAB Editor's preferences
spacesPerTab = com.mathworks.mde.editor.EditorOptions.getSpacesPerTab();
% I have to make an assumption about the number of characters per tab. If
% they are using another editor, they might be expecting a value other than
% spacesPerTab, but I have no way of knowing.
tabChar = sprintf('\t');

codeOut = codeIn;

tabIndex = find(codeOut==tabChar);
while ~isempty(tabIndex)
    % Add enough spaces to take us to the next even multiple of spacesPerTab
    numSpaces = spacesPerTab - rem(tabIndex(1),spacesPerTab) + 1;
    codeOut = regexprep(codeOut,'\t',char(32*ones(1,numSpaces)),'once');
    tabIndex = find(codeOut==tabChar);
end

