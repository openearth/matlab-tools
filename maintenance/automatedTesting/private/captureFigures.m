function oldFigures = captureFigures
%CAPTUREFIGURES	Return figure information for later call to compareFigures
%   OLDFIGURES contains the information that can later be passed to 
%   the compareFigures function

% Copyright 1984-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2007/03/03 04:44:34 $

% The publishing tools and Notebook uses this 

% Call drawnow here to flush any changes/events that may have been
% triggered if the last loop of takepicture triggered a print.
% This drawnow could be taken out if the print of a uiflowcontainer does 
% not trigger a resize (G354913)
drawnow;

% For some reason, GETing an axes creates three text objects.  Do this in
% advance to be sure it doesn't register as a change.
handleList = findall(0,'type','axes');
for i = 1:length(handleList)
    null = get(handleList(i));
end
handleList = findall(0,'type','text');
for i = 1:length(handleList)
    null = get(handleList(i));
end

% GETting 'XLim', 'YLim', and 'ZLim' on a group object changes limits from
% things like [0 NaN] to [-1 1].
handleList = findall(0,'type','group');
for i = 1:length(handleList)
    null = get(handleList(i));
end

% GETting the property of a group object (above), can cause the renderer to want
% to change to something different (e.g. zbuffer to painters), but not until the
% next time a draw actually happens.  DRAWNOW forces this to flip before
% capturing the old state.
drawnow;

% Capture the old state
figureList = findall(0,'type','figure','visible','on');
oldFigures = [];
oldFigures.number = [];
for figureListNumber = 1:length(figureList)
    oldObjectList = findall(figureList(figureListNumber),'visible','on');
    oldProperties = {};
    for i = 1:length(oldObjectList)
        props = get(oldObjectList(i));
        switch props.Type
            case 'figure'
                props.CurrentPoint = 'IGNORE';
                % The windowing system can move a figure after it is created, so
                % ignore the position of the figure on the screen.
                props.Position(1) = 0;
                props.Position(2) = 0;
                % The figure dimensions are also not reliable.  See
                % g197164 for more information.
                props.Position(3) = 0;
                props.Position(4) = 0;
                % Something unknown callback is changing CurrentAxes.
                % Let's ignore it. See g273048.
                props.CurrentAxes = 0;
            case 'text'
                % Extent is unreliable, yet unneeded.  See g143468.
                props.Extent = 'IGNORE';
        end
        oldProperties{i} = props;
    end
    oldFigures(figureListNumber).number = figureList(figureListNumber);
    oldFigures(figureListNumber).objectList = oldObjectList;
    oldFigures(figureListNumber).properties = oldProperties;
end
