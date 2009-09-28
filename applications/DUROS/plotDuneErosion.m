function plotDuneErosion(result, varargin)
%PLOTDUNEEROSION    routine to plot dune erosion results
%
% This routine plots the results of a dune erosion calculation in a figure.
% The result structure is also stored in the axes containing the plotted results.
%
% Syntax:       plotDuneErosion(result, nr, PropertyName, PropertyValue)
%
% Input:
%               result    = structure with dune erosion results
%               nr        = figure number or handle (optional), or axes
%                           handle.
%
%               Property-value pairs:
%               xoffset   = a double denoting the length that is added to
%                           all x-coordinates in the plot.
%               zoffset   = a double denoting the height that is added to
%                           all z-coordinates in the plot.
%               xdir      = {reverse} | normal. Positive direction of the
%                            x-axis. This must be reverse in case of a
%                            positive direction to the left, or normal
%                            plotting the matlab default axes direction.
%
% Output:       Eventual output is plotted in figure(nr)
%
%   See also getDuneErosion_DUROS
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.2, june 2009 (Version 1.0, January 2007)
% By:           <Pieter van Geer and C.(Kees) den Heijer (email: Kees.denHeijer@deltares.nl)>
% --------------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $Keywords: plot, dune erosion$

%%

OPT = struct(...
    'xdir','reverse',...
    'xoffset',0,...
    'zoffset',0,...
    'xlabel', 'cross shore distance to RSP [m]',...
    'ylabel', 'height to NAP [m]',...
    'hordatum', 'RSP',...
    'vertdatum', 'NAP',...
    'legenditems', {{'Hs' 'Tp' 'D50' 'Er'}});

if nargin>1
    if ishandle(varargin{1})
        nr = varargin{1};
        varargin(1) = [];
    end
    getdefaults('nr', gcf, 0);
    if ishandle(nr)
        fig = nr;
    else
        fig = figure(nr);
    end

    OPT = setProperty(OPT,varargin);
    
    OPT.xlabel = strrep(OPT.xlabel, 'RSP', OPT.hordatum);
    OPT.ylabel = strrep(OPT.ylabel, 'NAP', OPT.vertdatum);
    if all(~strcmp(OPT.xdir,{'normal','reverse'}))
        error('PlotDuneErosion:WrongProperty','Parameter xdir can only be "normal" or "reverse"');
    end
    if ~isnumeric(OPT.xoffset)
        error('PlotDuneErosion:WrongProperty','Parameter xoffset must be numeric');
    end
else
    fig = gcf;
end

if strcmp(get(fig,'Type'),'axes')
    parent = fig;
    % fig is not the handle to the figure, but we don't need it anyway...
elseif strcmp(get(fig,'Type'),'figure')
    % Why don't we just take gca???
    children = get(fig, 'children');
    IsAxes = strcmp(get(children, 'type'), 'axes') & ~strcmp(get(children, 'tag'), 'legend');
    if sum(IsAxes) == 1
        parent = children(IsAxes);
    else
        parent = axes(...
            'Parent', fig);
    end
else
    error('plotDuneErosion:WrongHandle','The handle specified is not of type axis or figure.');
end
set(parent,...
    'Xdir', OPT.xdir,...
    'Box', 'on',...
    'color', 'none',...
    'NextPlot', 'add')

xlabel(OPT.xlabel)
ylabel(OPT.ylabel),...
%     'Rotation', 270,...
%     'VerticalAlignment', 'top')

LastFilledField = [];
for i = fliplr(1 : length(result))
    FieldIsempty = isempty(result(i).xActive);
    if ~FieldIsempty
        LastFilledField = i;
        break
    end
end

hsc = [];
[x, z] = deal([result(1).xLand; result(1).xActive; result(1).xSea]+OPT.xoffset, [result(1).zLand; result(1).zActive; result(1).zSea]+OPT.zoffset);

if ~issorted(x)
    % relevant if poslndwrd == 1
    [x IX] = sort(x);
    z = z(IX);
end

hinitprofile = plot(x, z,...
    'Color','k',...
    'LineStyle','-',...
    'Parent',parent,...
    'LineWidth',1,...
    'DisplayName','Initial profile');

initxlimits = [min(x) max(x)];
initzlimits = get(parent, 'YLim');
tmp = guihandles(fig);

%if exist('stretchaxes.bmp','file')
    pushim = imread('stretchaxes.bmp');
%else
%    pushim = repmat(0,[315,315,3]);
%end
uipushtool('CData',pushim,...
    'ClickedCallback',{@resetaxis, parent, initxlimits, initzlimits},...
    'Parent',tmp.FigureToolBar,...
    'Separator','on',...
    'Tag','Set XS Limits',...
    'TooltipString','Reset axis');

color = {[255 222 111]/255, [150 116 0]/255, [0 0.8 0], [1 0.6 1], [0 0.8 0]};
if length(result) > length(color)
    color = [color(1:2) {.9*color{1}} color(3:end)];
end
hp = NaN(size(result));
txt = cell(size(result));
TpCorrected = false;
for i = 1 : LastFilledField
    if ~isempty(result(i).z2Active)
        if isfield(result(i).info, 'ID')
            txt{i} = result(i).info.ID; % not applicable in case of debugging when result(i).info.ID doesn't exist
        end
        volumepatch = [result(i).xActive'+OPT.xoffset fliplr(result(i).xActive')+OPT.xoffset; result(i).z2Active'+OPT.zoffset fliplr(result(i).zActive')+OPT.zoffset]';
        hp(i) = patch(volumepatch(:,1), volumepatch(:,2), ones(size(volumepatch(:,2)))*-(LastFilledField-i),color{i},...
            'EdgeColor',[1 1 1]*0.5,...
            'Parent',parent);
        if max(diff(volumepatch)) == 0
            if i == 1
                % displaying the empty patch of the DUROS profile in the legend
                % makes no sense
                set(hp(i), 'HandleVisibility','off')
            else
                % only the remark "no erosion" is required, the color of
                % the patch isn't
                set(hp(i), 'EdgeColor','none', 'FaceColor', 'none');
            end
        end
        if isempty(txt{i})
            txt{i} = 'UnKnown';
        end
        try
            % DisplayNames for patches are only possible for matlab
            % version 8 and higher
            set(hp(i), 'DisplayName',txt{i});
        catch %#ok<CTCH>
            % alternatively put the text in the Tag
            set(hp(i), 'Tag', txt{i});
        end
        %% Displayname
        if i > 1
            %{
            hsc(end+1) = scatter(result(i).xActive(1),result(i).z2Active(1),...
                'Marker','o',...
                'HandleVisibility','off',...
                'MarkerFaceColor','k',...
                'MarkerEdgeColor','k',...
                'SizeData',4,...
                'Parent',parent); %#ok<AGROW>
            id = find(result(i).z2Active==min(result(i).z2Active), 1 );
            hsc(end+1) = scatter(result(i).xActive(id),result(i).z2Active(id),...
                'Marker','o',...
                'HandleVisibility','off',...
                'MarkerFaceColor','k',...
                'MarkerEdgeColor','k',...
                'SizeData',4,...
                'Parent',parent); %#ok<AGROW>
            %}
        else
            heroprofile = plot(result(i).xActive+OPT.xoffset, result(i).z2Active+OPT.zoffset,...
                'Color','r',...
                'LineStyle','-',...
                'Parent',parent,...
                'LineWidth',2,...
                'DisplayName','Erosion profile');
            if isscalar(result(i).xActive)
                set(heroprofile,...
                    'HandleVisibility','off');
            end
        end
    end
    % TODO('Change the i's / 1's for DUROSresultid in some cases');
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==-2)
        oldtptext = result(i).info.messages{[result(i).info.messages{:,1}]==-2,2};
        spaces = strfind(oldtptext,' ');
        oldTp = str2double(oldtptext(spaces(end-1):spaces(end)));
        TpCorrected = true;
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==-99)
        text(0.5, 0.45,'Iteration boundaries are non-consistent!','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(1).info.messages) && any([result(1).info.messages{:,1}]==-8)
        text(0.5, 0.45,{'The initial profile is not steep enough','to yield a solution under these conditions'},'Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==-7)
        text(0.5, 0.45,'No solution found within boundaries!','Units','normalized','Rotation',35,'FontSize',20,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(1).info.messages) && any([result(1).info.messages{:,1}]==-6)
        text(0.5, 0.1,'Solution is influenced by a channel slope!','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(1).info.messages) && any([result(1).info.messages{:,1}]==-5)
        text(0.5, 0.45,'Corrected for landward transport above the water line.','Units','normalized','Rotation',35,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==45)
        text(0.5, 0.1,'Additional erosion restricted within dune valley.','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==42)
        text(0.5, 0.1,'Additional retreat limit reached.','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==47)
        id = [result(i).info.messages{:,1}]==47;
        text(0.5, 0.1,result(i).info.messages{id,2},'Units','normalized','Rotation',0,'FontSize',12,'color','r','HorizontalAlignment','center');
    end
end

xlimits = [min(result(i).xActive+OPT.xoffset) max(result(1).xActive+OPT.xoffset)];
%     xlimits = [min(x) max(result(1).xActive)];
if numel(result(1).xActive)<2
    if diff(xlimits)==0 %No erosion (active profile has no length) and no additional erosion
        xlimits = [min(result(1).xLand+OPT.xoffset) max(result(1).xSea+OPT.xoffset)];
        if length(xlimits)==1
            xlimits = ones(1,2)*xlimits;
        end
        zlimits = [min(result(1).zSea)+OPT.zoffset max(result(1).zLand)+OPT.zoffset];
        if length(zlimits)==1
            zlimits = ones(1,2)*zlimits;
        end
    else % No erosion, but additional erosion/ boundary profile was calculated
        xlimits = [min(xlimits)-150 max(xlimits)+150];
        zlimits = [min(z(x>xlimits(1) & x<xlimits(2))) max(z(x>xlimits(1) & x<xlimits(2)))];
        zlimits = [zlimits(1)-.05*diff(zlimits) zlimits(2)+.05*diff(zlimits)];
    end
    text(xlimits(2)-0.8*diff(xlimits),zlimits(2)-0.8*diff(zlimits),'No erosion');
else
    xlimits = [xlimits(1)-.05*diff(xlimits) xlimits(2)+.05*diff(xlimits)];
    zlimits = [min(z(x>xlimits(1) & x<xlimits(2))) max(z(x>xlimits(1) & x<xlimits(2)))];
    zlimits = [zlimits(1)-.05*diff(zlimits) zlimits(2)+.05*diff(zlimits)];
end
try %#ok<TRYNC>
    axis([xlimits zlimits]);
    uistack(hinitprofile,'top');
    uistack(heroprofile,'top');
    uistack(hsc,'top');
end

[WL_t,Er, AVolume, Xplocation, TVolume] = deal(nan);

for i = 1 : LastFilledField
    if ~isempty(result(i).info.input) && isfield(result(i).info.input,'WL_t')
        WL_t = result(i).info.input.WL_t+OPT.zoffset;
    end
    if ~isempty(cat(1,result(i).info.ID))
        if ismember({result(i).info.ID},'DUROS-plus') || ismember({result(i).info.ID},'DUROS')
            if ~isempty(result(i).Volumes.Erosion)
                Er = -result(i).Volumes.Erosion;
            else
                Er = nan;
            end
        elseif ismember({result(i).info.ID},'DUROS-plus Erosion above SSL') || ismember({result(i).info.ID},'DUROS Erosion above SSL')
            AVolume = result(i).VTVinfo.AVolume;
        elseif ismember({result(i).info.ID},'Additional Erosion')
            Xp = result(i).VTVinfo.Xp+OPT.xoffset;
            Zp = result(i).VTVinfo.Zp+OPT.zoffset;
            Xr = result(i).VTVinfo.Xr+OPT.xoffset;
            Zr = result(i).VTVinfo.Zr+OPT.zoffset;
            if isempty(Xp) || isempty(Xr)
                continue;
            end

            hsc(end+1) = plot(Xp,Zp,...
                'Marker','o',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor', 'b',...
                'MarkerSize', 5,...
                'HandleVisibility', 'on',...
                'LineStyle','none',...
                'DisplayName',['P: ',num2str(Xp,'%8.2f'),' m w.r.t. ' OPT.hordatum],...
                'Parent', parent); %#ok<AGROW>
            hsc(end+1) = plot(Xr,Zr,...
                'Marker','o',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor', 'r',...
                'MarkerSize', 5,...
                'HandleVisibility', 'on',...
                'LineStyle','none',...
                'DisplayName',['R: ',num2str(Xr,'%8.2f'),' m w.r.t. ' OPT.hordatum],...
                'Parent', parent); %#ok<AGROW>
            TVolume = result(i).VTVinfo.TVolume;
            if isempty(TVolume)
                TVolume = nan;
            end
        end
    end
end

hptemp = hp(~isnan(hp));
try
    if length(hp)==1
        AVolumeid = ~isempty(strfind(get(hptemp, 'DisplayName'), 'Erosion above SSL'));
        TVolumeid = ~isempty(strfind(get(hptemp, 'DisplayName'), 'Additional Erosion'));
    else
        AVolumeid = ~cellfun(@isempty, strfind(get(hptemp, 'DisplayName'), 'Erosion above SSL'));
        TVolumeid = ~cellfun(@isempty, strfind(get(hptemp, 'DisplayName'), 'Additional Erosion'));
    end
    set(hptemp(AVolumeid), 'DisplayName', [get(hptemp(AVolumeid), 'DisplayName') ' (' num2str(AVolume,'%8.2f'),' m^3/m^1)'])
    set(hptemp(TVolumeid), 'DisplayName', [get(hptemp(TVolumeid), 'DisplayName') ' (' num2str(TVolume,'%8.2f'),' m^3/m^1)'])
catch %#ok<CTCH>
    if length(hp)==1
        AVolumeid = ~isempty(strfind(get(hptemp, 'Tag'), 'Erosion above SSL'));
        TVolumeid = ~isempty(strfind(get(hptemp, 'Tag'), 'Additional Erosion'));
    else
        AVolumeid = ~cellfun(@isempty, strfind(get(hptemp, 'Tag'), 'Erosion above SSL'));
        TVolumeid = ~cellfun(@isempty, strfind(get(hptemp, 'Tag'), 'Additional Erosion'));
    end
    set(hptemp(AVolumeid), 'Tag', [get(hptemp(AVolumeid), 'Tag') ' (' num2str(AVolume,'%8.2f'),' m^3/m^1)'])
    set(hptemp(TVolumeid), 'Tag', [get(hptemp(TVolumeid), 'Tag') ' (' num2str(TVolume,'%8.2f'),' m^3/m^1)'])
end

results2plot = {};
if any(ismember(OPT.legenditems, 'Er'))
    results2plot = {
        'Er: ',num2str(Er,'%8.2f'),' m^3/m^1'};
end
% remove lines with nans
results2plot(isnan(Er),:) = [];

try
    hwl = plot([min(x) max(x)], repmat(WL_t,1,2),'--b');
    try
        set(hwl,'Tag',['WL: ', num2str(WL_t, '%8.2f'), ' m w.r.t. ' OPT.vertdatum],...
            'DisplayName',['WL: ', num2str(WL_t, '%8.2f'), ' m w.r.t. ' OPT.vertdatum],...
            'HandleVisibility','on');
    catch %#ok<CTCH>
        set(hwl,'Tag',['WL: ', num2str(WL_t, '%8.2f'), ' m w.r.t. ' OPT.vertdatum],...
            'HandleVisibility','on');
    end
    input2plot = {...
        'Hs: ', num2str(result(1).info.input.Hsig_t, '%8.2f'), ' m'; ...
        'Tp: ', num2str(result(1).info.input.Tp_t, '%8.2f'), ' s'; ...
        'D50: ', num2str(result(1).info.input.D50*1e6, '%8.2f'), ' \mum'};
catch %#ok<CTCH>
    input2plot = {};
end
displayResultsOnFigure(parent,[input2plot; results2plot])
if strcmp(OPT.xdir,'normal')
    leg = legend(parent);
    set(leg,'Location','NorthEast');
    legendxdir(leg,'xdir','reverse');
end
if TpCorrected
    leg = legend(parent);
    ch = findobj(leg,'Type','text');
    str = get(ch,'String');
    Tpid = strncmp(str,'Tp:',3);
    if sum(Tpid==1)==1
        set(ch(Tpid),...
            'String',cat(2,get(ch(Tpid),'String'),[' (target: ' num2str(oldTp, '%8.2f') ' s)']),...
            'Color','r');
    end
end
%% store results in userdata.
% In this way storing one figure stores the
% complete result. No need to seperately store the .mat file anymore
set(parent,'UserData',result);

function resetaxis(varargin)

set(varargin{3}, 'XLim', varargin{4}, 'YLim', varargin{5})
% set(varargin{1},'State','off');
% set(lh,'fontsize',6,'orientation','horizontal','location','SouthOutside');

% axisprop = axis;
% height_width_ratio = (axisprop(4) - axisprop(3))/(axisprop(2) - axisprop(1));
% paperposition = get(gcf,'paperposition');
% paperposition(3) = paperposition(4);%/height_width_ratio;

% set(gcf, 'paperposition',paperposition)