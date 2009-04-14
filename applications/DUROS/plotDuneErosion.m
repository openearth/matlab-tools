function plotDuneErosion(result, nr)
%PLOTDUNEEROSION    routine to plot dune erosion results
%
% This routine plots the results of a dune erosion calculation in a figure
%
% Syntax:       plotDuneErosion(result, nr)
%
% Input:
%               result    = structure with dune erosion results
%               nr        = figure number or handle
%
% Output:       Eventual output is plotted in figure(nr)
%
%   See also getDuneErosion_DUROS_test, getDuneErosion_TAW1984_test,
%   getDuneErosion_VTV2006_test
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, January 2008 (Version 1.0, January 2007)
% By:           <C.(Kees) den Heijer (email: Kees.denHeijer@deltares.nl)>
% --------------------------------------------------------------------------

% $Id$ 
% $Date$
% $Author$
% $Revision$

%%
getdefaults('nr', gcf, 0);

if ishandle(nr)
    fig = nr;
else
    fig = figure(nr);
end

children = get(fig, 'children');
IsAxes = strcmp(get(children, 'type'), 'axes') & ~strcmp(get(children, 'tag'), 'legend');
if sum(IsAxes) == 1
    parent = children(IsAxes);
else
    parent = axes(...
        'Parent', fig);
end

set(parent,...
    'Xdir', 'reverse',...
    'Box', 'on',...
    'color', 'none',...
    'NextPlot', 'add')

xlabel('cross shore distance to RSP [m]')
ylabel('height to NAP [m]',...
    'Rotation', 270,...
    'VerticalAlignment', 'top')

LastFilledField = [];
for i = fliplr(1 : length(result))
    FieldIsempty = isempty(result(i).xActive);
    if ~FieldIsempty
        LastFilledField = i;
        break
    end
end

hsc = [];
[x, z] = deal([result(1).xLand; result(1).xActive; result(1).xSea], [result(1).zLand; result(1).zActive; result(1).zSea]);

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
tmp = guihandles(nr);
restoreAxisLimits = uipushtool('CData',repmat(0,[315,315,3]),...
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
for i = 1 : LastFilledField
    if ~isempty(result(i).z2Active)
        if isfield(result(i).info, 'ID')
            txt{i} = result(i).info.ID; % not applicable in case of debugging when result(i).info.ID doesn't exist
        end
        volumepatch = [result(i).xActive' fliplr(result(i).xActive'); result(i).z2Active' fliplr(result(i).zActive')]';
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
%             hsc(end+1) = scatter(result(i).xActive(1),result(i).z2Active(1),...
%                 'Marker','o',...
%                 'HandleVisibility','off',...
%                 'MarkerFaceColor','k',...
%                 'MarkerEdgeColor','k',...
%                 'SizeData',4,...
%                 'Parent',parent); %#ok<AGROW>
%             id = find(result(i).z2Active==min(result(i).z2Active), 1 );
%             hsc(end+1) = scatter(result(i).xActive(id),result(i).z2Active(id),...
%                 'Marker','o',...
%                 'HandleVisibility','off',...
%                 'MarkerFaceColor','k',...
%                 'MarkerEdgeColor','k',...
%                 'SizeData',4,...
%                 'Parent',parent); %#ok<AGROW>
        else
            heroprofile = plot(result(i).xActive, result(i).z2Active,...
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
    if ~isempty(result(i).info.messages) && any([result(1).info.messages{:,1}]==-99)
        text(0.5, 0.45,'Iteration boundaries are non-consistent!','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==-8)
        text(0.5, 0.45,{'The initial profile is not steep enough','to yield a solution under these conditions'},'Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==-7)
        text(0.5, 0.45,'No solution found within boundaries!','Units','normalized','Rotation',35,'FontSize',20,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(i).info.messages{:,1}]==-6)
        text(0.5, 0.1,'Solution is influenced by a channel slope!','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(result(i).info.messages) && any([result(1).info.messages{:,1}]==-5)
        text(0.5, 0.45,'Corrected for landward transport above the water line.','Units','normalized','Rotation',35,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
end

xlimits = [min(result(i).xActive) max(result(1).xActive)];
%     xlimits = [min(x) max(result(1).xActive)];
if numel(result(1).xActive)<2 
    if diff(xlimits)==0 %No erosion (active profile has no length) and no additional erosion
        xlimits = [min(result(1).xLand) max(result(1).xSea)];
        if length(xlimits)==1
            xlimits = ones(1,2)*xlimits;
        end
        zlimits = [min(result(1).zSea) max(result(1).zLand)];
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

[Er, AVolume, Xplocation, Xp, Xr, TVolume] = deal(nan);

for i = 1 : LastFilledField
    %     NaN : Geen oplossing mogelijk tussen de iteratie grenzen
    %     0 :   'Iteration boundaries are non-consistent'(**)
    %     2 :   Channel slope zit in de weg
    %     100 : landwaards transport correctie boven water ==> onzin oplossing
    if isempty(result(1).info.messages) ||...
            ~(...
            ~isempty(find(isnan(vertcat(result(1).info.messages{:,1}))))||...
            any(strcmp(result(1).info.messages(:,2),'Iteration boundaries are non-consistent'))|...
            ~isempty(find(vertcat(result(1).info.messages{:,1})==2))||...
            ~isempty(find(vertcat(result(1).info.messages{:,1})==100))...
            ) %#ok<EFIND>
        if ismember({result(i).info.ID},'DUROS-plus')
            if ~isempty(result(i).Volumes.Erosion)
                Er = -result(i).Volumes.Erosion;
            else
                Er = nan;
            end
        elseif ismember({result(i).info.ID},'DUROS-plus Erosion above SSL')
            AVolume = result(i).Volumes.Volume;
        elseif ismember({result(i).info.ID},'Additional Erosion')
            if isfield(result(1).info.input, 'WL_t')
                Xplocation = max([1 find(result(i).z2Active == result(1).info.input.WL_t, 1)]);
                Xp = result(i).xActive(Xplocation);
                Zp = result(i).z2Active(Xplocation);
                [Xr Zr] = erosionPoint(x, z, result(1).info.input.WL_t, result(i).info.x0);
                hsc(end+1) = plot([Xp Xr], [Zp Zr], 'ok',...
                    'HandleVisibility', 'off',...
                    'MarkerFaceColor', 'k',...
                    'MarkerSize', 4,...
                    'Parent', parent); %#ok<AGROW>
                TVolume = result(i).Volumes.Volume;
            else
                [Xplocation, Xp, Xr, TVolume] = deal(nan);
            end
        end
    else
        [Er, AVolume, Xplocation, Xp, Xr, TVolume] = deal(nan);
    end
end

if all(~isnan(hp))
    try
        if length(hp)==1
            AVolumeid = ~isempty(strfind(get(hp, 'DisplayName'), 'Erosion above SSL'));
            TVolumeid = ~isempty(strfind(get(hp, 'DisplayName'), 'Additional Erosion'));
        else
            AVolumeid = ~cellfun(@isempty, strfind(get(hp, 'DisplayName'), 'Erosion above SSL'));
            TVolumeid = ~cellfun(@isempty, strfind(get(hp, 'DisplayName'), 'Additional Erosion'));
        end
        set(hp(AVolumeid), 'DisplayName', [get(hp(AVolumeid), 'DisplayName') ' (' num2str(AVolume,'%8.2f'),' m^3/m^1)'])
        set(hp(TVolumeid), 'DisplayName', [get(hp(TVolumeid), 'DisplayName') ' (' num2str(TVolume,'%8.2f'),' m^3/m^1)'])
    catch %#ok<CTCH>
        if length(hp)==1
            AVolumeid = ~isempty(strfind(get(hp, 'Tag'), 'Erosion above SSL'));
            TVolumeid = ~isempty(strfind(get(hp, 'Tag'), 'Additional Erosion'));
        else
            AVolumeid = ~cellfun(@isempty, strfind(get(hp, 'Tag'), 'Erosion above SSL'));
            TVolumeid = ~cellfun(@isempty, strfind(get(hp, 'Tag'), 'Additional Erosion'));
        end
        set(hp(AVolumeid), 'Tag', [get(hp(AVolumeid), 'Tag') ' (' num2str(AVolume,'%8.2f'),' m^3/m^1)'])
        set(hp(TVolumeid), 'Tag', [get(hp(TVolumeid), 'Tag') ' (' num2str(TVolume,'%8.2f'),' m^3/m^1)'])
    end
end

results2plot = {
    'P: ',num2str(Xp,'%8.2f'),' m wrt RSP'; ...
    'R: ',num2str(Xr,'%8.2f'),' m wrt RSP'; ...
    'Er: ',num2str(Er,'%8.2f'),' m^3/m^1'};
% remove lines with nans
results2plot(isnan([Xp Xr Er]),:) = [];

try
    hwl = plot([min(x) max(x)], repmat(result(1).info.input.WL_t,1,2),'--b');
    try
        set(hwl,'Tag',['WL: ', num2str(result(1).info.input.WL_t, '%8.2f'), ' m wrt NAP'],...
            'DisplayName',['WL: ', num2str(result(1).info.input.WL_t, '%8.2f'), ' m wrt NAP'],...
            'HandleVisibility','on');
%         legend(parent,'show');
    catch %#ok<CTCH>
        set(hwl,'Tag',['WL: ', num2str(result(1).info.input.WL_t, '%8.2f'), ' m wrt NAP'],...
            'HandleVisibility','on');
%         legend(parent,'show');
    end
    input2plot = {...
...    'WL: ', num2str(result(1).info.input.WL_t, '%8.2f'), ' m wrt NAP'; ...
    'Hs: ', num2str(result(1).info.input.Hsig_t, '%8.2f'), ' m'; ...
    'Tp: ', num2str(result(1).info.input.Tp_t, '%8.2f'), ' s'; ...
    'D50: ', num2str(result(1).info.input.D50*1e6, '%8.2f'), ' \mum'};
catch
    input2plot = {};
end
displayResultsOnFigure(parent,[input2plot; results2plot])

function resetaxis(varargin)

set(varargin{3}, 'XLim', varargin{4}, 'YLim', varargin{5})
% set(varargin{1},'State','off');
% set(lh,'fontsize',6,'orientation','horizontal','location','SouthOutside');

% axisprop = axis;
% height_width_ratio = (axisprop(4) - axisprop(3))/(axisprop(2) - axisprop(1));
% paperposition = get(gcf,'paperposition');
% paperposition(3) = paperposition(4);%/height_width_ratio;

% set(gcf, 'paperposition',paperposition)