function [Volume, result, Boundaries] = getVolume(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary, x2, z2, NoErosion)
%GETVOLUME   generic routine to determine volumes on transects
%
%   Routine determines volumes on transects. In case of no second profile (x2, z2),
%   the volume above the lowerboundary, below the profile (x, z) and eventually the upperboundary,
%   and between the landwardboundary and seawardboundary will be computed.
%   In case of a second profile (x2, z2), the volume between the two
%   profiles will be computed, eventually confined by one or more
%   boundaries. Where profile 2 is below profile 1, the volume will be
%   considered as erosion (negative). Where profile 2 is above profile 1,
%   the volume will be considered as accretion (positive).
%   The horizontal boundaries (UpperBoundary and LowerBoundary) do not
%   have to be straight (the x-coordinates of these boundaries have to be ascending).
%
%   syntax:
%   [Volume, result, Boundaries] =
%   getVolume(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary, x2, z2)
%
%   input:
%       x                   = column array with x points (increasing index and positive x in seaward direction)
%       z                   = column array with z points
%       UpperBoundary       = upper horizontal plane of volume area (not specified please enter [] as argument)
%       LowerBoundary       = lower horizontal plane of volume area (not specified please enter [] as argument)
%       LandwardBoundary    = landward vertical plane of volume area (not specified please enter [] as argument)
%       SeawardBoundary     = seaward vertical plane of volume area (not specified please enter [] as argument)
%       x2                  = column array with x2 points (increasing index and positive x in seaward direction)
%       z2                  = column array with z2 points
%
%   example:
%
%
%   See also getInputSize
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 2.1, January 2008 (Version 2.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% -------------------------------------------------------------

tic;
%% check and inventorise input
if nargin<9 % geen getdefaults omdat er dan een melding wordt gemaakt.
    % TODO: switch in getdefaults om ook writemessage te onderdrukken?
    NoErosion = false;
end

variables  = getInputVariables(mfilename);
inputSize  = getInputSize(variables);
for i = [1 7]
    if sum(inputSize(i,:) == inputSize(i+1,:)) ~= 2 % number of rows and columns of x must be equal to z (also holds for x2 and z2)
        error('GETVOLUME:SizeInputs', ['Size of input argument ',variables{i},' must be equal to ',variables{i+1},'.']);
    end
    eval([variables{i} '=' variables{i} '(~isnan(' variables{i+1} '));' variables{i+1} '=' variables{i+1} '(~isnan(' variables{i+1} '));']) % use only non-NaN values
    if sign(diff(size(eval(variables{i}))))==1 % in case of rows
        eval([variables{i} '=' variables{i} ''';' variables{i+1} '=' variables{i+1} ''';']) % transpose x and z to column vectors
    end
    [inputSize(i,:), inputSize(i+1,:)] = deal(size(eval(variables{i}))); % update inputSize
    if i == 1 && sum(inputSize(i,:))<= 2 || i == 7 && sum(inputSize(i,:)) == 2 % no input arguments, empty x and z, or only one non-NaN data point
        error('GETVOLUME:NotEnoughPts',['There must be at least two non-NaN data points in ',variables{i},' and ',variables{i+1},'.'])
    end
end
[xold, zold] = deal(x, z);

result = createEmptyDUROSResult;

%% determine Upper and Lower boundaries and set LandwardBoundary and SeawardBoundary
x_min = min(x); x_max = max(x);
if inputSize(3,1)>1; x_min = max([x_min min(UpperBoundary(:,1))]); x_max = min([x_max max(UpperBoundary(:,1))]); end
if inputSize(4,1)>1; x_min = max([x_min min(LowerBoundary(:,1))]); x_max = min([x_max max(LowerBoundary(:,1))]); end
if inputSize(5,1)>1; LandwardBoundary = LandwardBoundary(1,1); end
if inputSize(6,1)>1; SeawardBoundary = SeawardBoundary(1,1); end
if inputSize(7,1)>1; x_min = max([x_min min(x2)]); x_max = min([x_max max(x2)]); end
LandwardBoundary = max([LandwardBoundary x_min]); inputSize(5,:) = size(LandwardBoundary);
SeawardBoundary = min([SeawardBoundary x_max]); inputSize(6,:) = size(SeawardBoundary);

if LandwardBoundary == SeawardBoundary
    result.xActive = LandwardBoundary;
    [result.z2Active, result.zActive] = deal(interp1(xold, zold, LandwardBoundary));
    [idLand, idSea] = deal(xold<min(result.xActive), xold>max(result.xActive));
    [result.xLand, result.zLand, result.xSea, result.zSea] = deal(xold(idLand), zold(idLand), xold(idSea), zold(idSea));
    [result.Volumes.Volume, Volume, result.Volumes.Accretion, result.Volumes.Erosion] = deal(0);
    result.info.time = toc;
    [Boundaries.Upper, Boundaries.Lower, Boundaries.Landward, Boundaries.Seaward] = deal(UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary);
    if ~NoErosion
        writemessage(-3, 'LandwardBoundary and SeawardBoundary are equal');
    end
    return
end;

%% set UpperBoundary and LowerBoundary
if inputSize(3,1)<2 && inputSize(3,2)<2
    z_max = min([max([max(z) max(z2)]) UpperBoundary]);
    UpperBoundary = [LandwardBoundary SeawardBoundary; z_max z_max]';
elseif inputSize(3,1)==1 && inputSize(3,2)==2
    z_max = min([max([max(z) max(z2)]) UpperBoundary(1,2)]);
    UpperBoundary = [LandwardBoundary SeawardBoundary; z_max z_max]';
end
inputSize(3,:) = size(UpperBoundary);

if inputSize(4,1)==0 && inputSize(4,2)==0
    z_min = max([min([min(z) min(z2)]) LowerBoundary]);
    LowerBoundary = [LandwardBoundary SeawardBoundary; z_min z_min]';
elseif inputSize(4,1)==1 && inputSize(4,2)==1
    z_min = LowerBoundary;
    LowerBoundary = [LandwardBoundary SeawardBoundary; z_min z_min]';
elseif inputSize(4,1)==1 && inputSize(4,2)==2
    z_min = min([min([min(z) min(z2)]) LowerBoundary(1,2)]);
    LowerBoundary = [LandwardBoundary SeawardBoundary; z_min z_min]';
end
inputSize(4,:) = size(LowerBoundary);

%% get intersections of profiles with x-boundaries and strip profiles
[x, z] = removeDoublePoints(x, z);
z_new = interp1(x, z, [LandwardBoundary SeawardBoundary]);
z = [z_new(1); z(x>LandwardBoundary & x<SeawardBoundary); z_new(2)];
x = [LandwardBoundary; x(x>LandwardBoundary & x<SeawardBoundary); SeawardBoundary];
if inputSize(3,1)>=2 % MvK 06-04-2008: '=' added because points should be added also when UpperBoundary is a horizontal line 
    z_new = interp1(UpperBoundary(:,1), UpperBoundary(:,2), [LandwardBoundary SeawardBoundary]);
    ids = UpperBoundary(:,1)>LandwardBoundary & UpperBoundary(:,1)<SeawardBoundary;
    UpperBoundary = [LandwardBoundary z_new(1); UpperBoundary(ids,:); SeawardBoundary z_new(2)];
end
if inputSize(4,1)>=2 % MvK 06-04-2008: '=' added because points should be added also when LowerBoundary is a horizontal line 
    z_new = interp1(LowerBoundary(:,1), LowerBoundary(:,2), [LandwardBoundary SeawardBoundary]);
    ids = LowerBoundary(:,1)>LandwardBoundary & LowerBoundary(:,1)<SeawardBoundary;
    LowerBoundary = [LandwardBoundary z_new(1); LowerBoundary(ids,:); SeawardBoundary z_new(2)];
end
if ~isempty(x2)
    [x2, z2] = removeDoublePoints(x2, z2);
    id(1) = find(x2<=LandwardBoundary, 1, 'last' );
    id(2) = find(x2>=SeawardBoundary, 1 );
    z2_new = interp1(x2(id(1):id(2)), z2(id(1):id(2)), [LandwardBoundary SeawardBoundary]);
    z2 = [z2_new(1); z2(x2>LandwardBoundary & x2<SeawardBoundary); z2_new(2)];
    x2 = [LandwardBoundary; x2(x2>LandwardBoundary & x2<SeawardBoundary); SeawardBoundary];
end;

%% find intersections, create common x-grid and derive the accompanying z-values
% first match xgrid of upper and lower boundaries
[xcr, zcr, UpperBoundary_new(:,1), UpperBoundary_new(:,2), LowerBoundary_new(:,1), LowerBoundary_new(:,2)] = findCrossings(UpperBoundary(:,1), UpperBoundary(:,2), LowerBoundary(:,1), LowerBoundary(:,2),'synchronizegrids');
[UpperBoundary, LowerBoundary] = deal(UpperBoundary_new, LowerBoundary_new); clear UpperBoundary_new LowerBoundary_new
% now match upper boundary with x and z (this will include crossing points)
[xcr, zcr, x, z, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x, z, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
[UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new
% now match lower boundary with x and z (this might include crossing points that are not yet in upper boundary)
[xcr, zcr, x, z, LowerBoundary_new(:,1), LowerBoundary_new(:,2)] = findCrossings(x, z, LowerBoundary(:,1), LowerBoundary(:,2),'synchronizegrids');
[LowerBoundary] = deal(LowerBoundary_new); clear LowerBoundary_new
% to make sure lower, upper and x and z contain all points match upper with x, z once more (this will NOT include new crossings so no further updating is needed)
[xcr, zcr, x, z, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x, z, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
[UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new

if ~isempty(x2) % now if also an x2 and z2 are available match those too
    % first match x and z with z2 and z2
    [xcr, zcr, x, z, x2, z2] = findCrossings(x, z, x2, z2,'synchronizegrids');
    % now match upper boundary with x2 and z2 (this will include crossing points)
    [xcr, zcr, x2, z2, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x2, z2, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
    [UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new
    % now match lower boundary with x2 and z2 (this might include crossing points that are not yet in upper boundary)
    [xcr, zcr, x2, z2, LowerBoundary_new(:,1), LowerBoundary_new(:,2)] = findCrossings(x2, z2, LowerBoundary(:,1), LowerBoundary(:,2),'synchronizegrids');
    [LowerBoundary] = deal(LowerBoundary_new); clear LowerBoundary_new

    % to make sure lower, upper and x2 and z2 contain all points match
    % upper with x2, z2 once more (this will NOT include new crossings so no further updating is needed)
    [xcr, zcr, x2, z2, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x2, z2, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
    [UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new
    % to make sure x and z and x2 and z2 contain all points match x, z with x2, z2 once more (this will NOT include new crossings so no further updating is needed)
    [xcr, zcr, x, z, x2, z2] = findCrossings(x, z, x2, z2,'synchronizegrids');
end



%% create columns containing all z-values available
% add z values related to: x, upper, lower
Z = [z UpperBoundary(:,2) LowerBoundary(:,2)];
% if exists add z values related to: x2
if ~isempty(x2)
    Z = [Z z2];
end

%% determine Zlimits (find out what lies over what)
if isempty(x2)
    Zlimits = Z(:,[3 1]); % lower limit = LowerBoundary; upper limit = z
    ids = Z(:,2)<=Z(:,1);
    Zlimits(ids,2) = Z(ids,2); % replace z by UpperBoundary in areas where the UpperBoundary is below the z
    ids = Zlimits(:,2)<=Zlimits(:,1);
    Zlimits(ids,2) = Zlimits(ids,1); % replace resulting upper limit by LowerBoundary in areas where the upper limit is below the LowerBoundary
else
    Zlimits = Z(:,[1 4]); % lower limit = z; upper limit = z2
    ids = Z(:,2)<=Z(:,1);
    Zlimits(ids,1) = Z(ids,2); % replace z by UpperBoundary in areas where the UpperBoundary is below the z
    ids = Z(:,2)<=Z(:,4);
    Zlimits(ids,2) = Z(ids,2); % replace z2 by UpperBoundary in areas where the UpperBoundary is below the z2
    ids = Z(:,3)>=Z(:,1);
    Zlimits(ids,1) = Z(ids,3); % replace z by LowerBoundary in areas where the LowerBoundary is above the z
    ids = Z(:,3)>=Z(:,4);
    Zlimits(ids,2) = Z(ids,3); % replace z2 by LowerBoundary in areas where the LowerBoundary is above the z2
end

%% get the volume
diffX = diff(x);
Xvolume = zeros(length(diffX),1);
volume = zeros(length(diffX),1);
for i = 1:length(diffX)
    volume(i,1) = (mean(Zlimits(i:i+1,2))-mean(Zlimits(i:i+1,1)))*diffX(i);
    Xvolume(i) = mean(x(i:i+1));
end

% [xold, zold] = deal(x, z);

[idLand, idSea] = deal(xold<min(x), xold>max(x));
[result.xLand, result.zLand, result.xActive, result.zActive, result.z2Active, result.xSea, result.zSea] = deal(xold(idLand), zold(idLand), x, Zlimits(:,1), Zlimits(:,2), xold(idSea), zold(idSea));
[Volume, result.Volumes.Volume] = deal(sum(volume));
[result.Volumes.volumes, result.Volumes.Accretion, result.Volumes.Erosion] = deal(volume, sum(volume(volume>0)), -sum(volume(volume<0)));
result.info.time = toc;
[Boundaries.Upper, Boundaries.Lower, Boundaries.Landward, Boundaries.Seaward] = deal(UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary);

% if dbstate
%     figure(11);clf;hold on
%     lh(1) = plot(UpperBoundary(:,1),UpperBoundary(:,2),'-or');
%     lh(2) = plot(LowerBoundary(:,1),LowerBoundary(:,2),'-dg');
%     lh(3) = plot([SeawardBoundary SeawardBoundary],get(gca,'YLim'),'m');
%     lh(4) = plot([LandwardBoundary LandwardBoundary],get(gca,'YLim'),'y');
%     try
%         lh(5) = plot(x,z,'-xk');
%         lh(6) = plot(x2,z2,':k');
%     end
%     hold on
%     color = {'b'};
%     for i = 1 : length(result)
%         if ~isempty(result(i).z2Active)
%             volumepatch = [result(i).xActive' fliplr(result(i).xActive'); result(i).z2Active' fliplr(result(i).zActive')]';
%             hp(i) = patch(volumepatch(:,1), volumepatch(:,2), ones(size(volumepatch(:,2)))*-(length(result)-i),color{i});
%         end
%     end
%     legendtxt = {'Upperboundary','Lowerboundary','Seawardboundary','Landwardboundary','Profile'};
%     l = legend(lh,legendtxt,'location','northwest');
%     set(l,'fontsize',8,'fontweight','bold');
%     legend  boxoff;
% 
%     set(gca,'XDir','reverse')
%     xlabel('Crossshore location (m wrt RSP)');
%     ylabel('Profile height (m wrt NAP)', 'Rotation', 270, 'VerticalAlignment', 'top');
%     box on
%     dbstopcurrent
% end

%%
function [x, z] = removeDoublePoints(x, z)
[x sortid]=sort(x);
z=z(sortid);

threshold = 1e-10;
if length(unique(x))~=length(x)
    xz = unique([x z], 'rows');
    if size(xz,1)==length(unique(x))
        [x z] = deal(xz(:,1), xz(:,2));
    else
        ids = find(diff(x)==0);
        for idd = 1:length(ids)
            id=ids(idd);
            if id<length(x) && abs(diff(z(id:id+1)))<threshold
                z(id+1) = NaN;
            end
        end
        [x, z] = deal(x(~isnan(z)), z(~isnan(z)));
    end
    disp('Warning: Duplicate point(s) skipped');
end
