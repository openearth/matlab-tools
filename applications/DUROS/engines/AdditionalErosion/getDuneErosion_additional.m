function result = getDuneErosion_additional(xInitial, zInitial, xDUROS, zDUROS, x2, z2, WL_t, x0min, x0max, x0except, TargetVolume, maxRetreat, x0DUROS, AVolume)
%GETDUNEEROSION_ADDITIONAL  routine to fit additional dune erosion into profile
%
% This routine returns the x-location of the floating profile (x2, z2) to fit
% a TargetVolume between the initial profile and profile (x2, z2)
%
% Syntax:       result = getDuneErosion_additional(xInitial,
%       zInitial, x2, z2, WL_t, x0min, x0max, x0except, TargetVolume)
%
% Input:
%               xInitial  = column array containing x-locations of initial (for this particular step) profile [m]
%               zInitial  = column array containing z-locations of initial (for this particular step) profile [m]
%               x2        = column array with x2 points (increasing index and positive x in seaward direction)
%               z2        = column array with z2 points
%               WL_t      = Water level [m] w.r.t. NAP
%               x0min     = landward boundary of boundary profile
%               x0max     = seaward boundary of boundary profile
%               x00min    = ultimate landward boundary of boundary profile
%               x0except  = possible exception area because of dune valleys
%               TargetVolume = additional volume to be fitted in profile
%               maxRetreat= maximum horizontal difference between DUROS 1:1
%                               slope and additional profile 1:1 slope
%               x0DUROS   = x-location of origin of DUROS-profile
%               AVolume   = Erosion volume above SSL (DUROS-profile)
%
% Output:       Eventual output is stored in a structure result
%
%   See also getDuneErosion_DUROS
%
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.0, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% --------------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% Initiate variables
tic;
getdefaults('TargetVolume', 0, 1,...
    'x0except', [], 0,...
    'maxRetreat', [], 0);

m = size(x0except,1);
x0exceptID = zeros(m,1);

x0 = [x0max x0min]; % predefine both ultimate situations

Iter = 0;               % Iteration number
iterid = 1;             % dummy value for iteration number which gives the best possible solution;
maxiter = DuneErosionSettings('get', 'maxiter');           % specify maximum number of iterations
precision = 1e-2;       % specify maximum error
NoAddErosion = false;   % predefinition: initially, no additional erosion has been specified
[Volume LandwardBoundary SeawardBoundary] = deal(repmat(NaN,1,maxiter)); % Preallocation of variable to store calculated volumes

if TargetVolume == 0
    result = createEmptyDUROSResult(...
        'xLand', [xInitial(xInitial<min(xDUROS)); xDUROS(xDUROS<x0(iterid))],...
        'zLand', [zInitial(xInitial<min(xDUROS)); zDUROS(xDUROS<x0(iterid))],...
        'xActive', x0(iterid),...
        'zActive', zDUROS(xDUROS==x0(iterid)),...
        'z2Active', zDUROS(xDUROS==x0(iterid)),...
        'xSea', [xDUROS(xDUROS>x0(iterid)); xInitial(xInitial>max(xDUROS))],...
        'zSea', [zDUROS(xDUROS>x0(iterid)); zInitial(xInitial>max(xDUROS))],...
        'Volume', 0,...
        'volumes', 0,...
        'Accretion', 0,...
        'Erosion', 0,...
        'ID', 'Additional Erosion',...
        'x0', x0(iterid),...
        'iter', 0,...
        'precision', 0);
    return
else
    result = createEmptyDUROSResult;
    NextIteration = true;   % Condition of while loop
end

%% Start iteration loop
% First perform two iterations with the most landward and seaward profiles possible,
% then iterate further


while NextIteration
    Iter = Iter + 1;
    x0InValley = false;
    for i = 1:m
        % check for each pair of x0 exceptions
        if x0(Iter)>x0except(i,1) && x0(Iter)<x0except(i,2)
            % current x0 is in between pair of x0 exceptions
            x0InValley = true;
            % set x0 to one of the boundaries of the exception area
            % starting from the seaward boundary
            x0(Iter) = x0except(i,x0exceptID(i)+1);
            % by highering the x0exceptID by 1, next time, the landward
            % boundary will be chosen
            x0exceptID(i) = x0exceptID(i)+1;

        end
    end
    % find crossings for this particular iteration
    xcross = findCrossings(xInitial, zInitial, x0(Iter)+x2, z2, 'keeporiginalgrid');
    if min(z2)~=max(z2)
        % normal situation for additional volume
        LandwardBoundary(Iter) = min(xcross);
    else
        % only applicable for volumetric boundary profile
        LandwardBoundary(Iter) = min(x0(Iter)+x2);
    end
    SeawardBoundary(Iter) = max(xcross);
    [Volume(Iter) iterresult(Iter)] = getVolume(xInitial, zInitial, [], WL_t, LandwardBoundary(Iter), SeawardBoundary(Iter), x0(Iter)+x2, z2);  %#ok<AGROW>
    Volume(Iter) = Volume(Iter) - AVolume;
    % create conditions for if statement to adjust profile shift x0
    FirstTwoItersCompleted = Iter==numel(x0); % after the second iteration, x0 is extended for each next iteration
    PrecisionNotReached = abs(diff([TargetVolume Volume(Iter)])) >= abs(precision);
    SolutionPossibleWithinBoundaries = diff(sign(Volume(1:2)-TargetVolume))~=0;
    MaxNrItersReached = Iter==maxiter;
    if FirstTwoItersCompleted && ~x0InValley
        % difference between last two iterations is smaller than precision
        VollDiffSmall = abs(diff(Volume(Iter-1:Iter)))<precision;
    else
        VollDiffSmall = false;
    end

    if x0InValley && Volume(Iter) < TargetVolume
        % x0 was located in valley, landward valley side results appears to
        % be too far landward. Theoretically, choosing the x0 at the
        % seaward side of the valley should result in the same volume (in
        % practice, this can differ, even so that the latter results in
        % more volume...) By setting the x0 for this situation to the
        % seaward side of the valley prevents this problem
        x0(Iter) = x0except(x0except(:,1)==x0(Iter),2);
    end

    if FirstTwoItersCompleted && PrecisionNotReached && SolutionPossibleWithinBoundaries && ~MaxNrItersReached && ~VollDiffSmall
        % new profile shift has to be calculated.

        % find identifier of Volume closest but larger than TargetVolume
        idpos = find(Volume==min(Volume(Volume>TargetVolume)));
        if length(idpos)>1
            % to prevent a vector of idpos
            [dummy IX] = sort(x0(idpos));
            idpos = idpos(IX(1)); % take the first one
        end

        % find identifier of Volume closest but smaller than TargetVolume
        idneg = find(Volume==max(Volume(Volume<TargetVolume))); % find identifier of Volume closest but smaller than TargetVolume
        if length(idneg)>1
            % to prevent a vector of idneg
            [dummy IX] = sort(x0(idneg));
            idneg = idneg(IX(end)); % take the first one
        end

        % interpolation using two Volumes, closest larger and closest
        % smaller value than TargetVolume
        x0(Iter+1) = interp1(Volume([idpos idneg]), x0([idpos idneg]), TargetVolume); % interpolation using two Volumes, closest larger and closest smaller value than TargetVolume
    elseif FirstTwoItersCompleted
        % either no solution is possible between the boundaries, the
        % maximum number of solutions is reached or the precision has been
        % reached (--> a satisfying solution)

        % find the iteration number of the latest iteration which resulted
        % in the best possible solution
        iterid = find(abs(Volume-TargetVolume)==min(abs(Volume-TargetVolume)),1,'last'); % find the iteration number of the latest iteration which resulted in the best possible solution

        % change while loop condition
        NextIteration = false;
    end
    if dbstate
        dbPlotDuneErosion
    end
end

%% maximise the additional retreat to maxRetreat
AdditionalRetreat = diff([x0(iterid) x0DUROS]);
AdditionalRetreatExceedsmaximum = AdditionalRetreat > maxRetreat;
if AdditionalRetreatExceedsmaximum
    writemessage(42, ['Additional retreat limit of ' num2str(maxRetreat) ' m reached. '...
        'An Additional volume of ' num2str(Volume(iterid), '%.2f') ' m^3/m^1 (TargetVolume=' num2str(TargetVolume, '%.2f') ' m^3/m^1) leads to an additional retreat of ' num2str(AdditionalRetreat, '%.2f') ' m.']);
    Iter = Iter + 1;
    % new x0 at the maximum retreat distance
    x0(Iter) = x0max - maxRetreat;
    xcross = findCrossings(xInitial, zInitial, x0(Iter)+x2, z2, 'keeporiginalgrid');
%     if ~isempty(xcross)
%         % In my opinion comparing x2+x0 / z2 with the initial profile will
%         % not be empty (ever!!) if there is a DUROS solution (profile sticks
%         % above the water line and therefore always crosses x2+x0(iter),z2). 
%         % All points seaward of the Duros solution should be removed to 
%         % judge whether we really have a solution that is inside a valley. 
%         
%         xcross(xcross>=x0(1))=[];
%         
%         % In that case:
%         %   - no crossings left means:
%         %       Our main solution is inside a valley. The (restricted)
%         %       additional erosion lies in that same valley and thus is
%         %       restricted to a volume of.... 0!! Xr equals Xp (but where
%         %       is the question..??).
%         %   - one or more crossings means:
%         %       Our Duros solution crosses a dune. Some of the
%         %       additional volume can be met. If the most landward crossing
%         %       is smaller than x0(Iter, The imposed 15 m maximum
%         %       distance) -> Xp(with additional erosion) lies inside a dune 
%         %       and therefore equals x0(Iter). Xr equals the minimum value
%         %       of xcross (as normal so far). In case min(xcross) is larger 
%         %       than x0(Iter), the imposed maximum retreat lies in a valley. 
%         %       We have to correct that, because Xp cannot be drifting in 
%         %       the air.In this case both Xp and Xr (with additional 
%         %       erosion volume) equal min(xcross).
%     end
    if isempty(xcross)
        % no crossings means that the additional erosion is restricted
        % within the dune valley
        writemessage(45, 'Erosional length restricted within dunevalley. No additional Erosion volume determined.');
        iterresult(Iter) = createEmptyDUROSResult;
        
        % Landward part of the profile is landward from x0
        iterresult(Iter).xLand = xInitial(xInitial<x0(Iter));
        iterresult(Iter).zLand = zInitial(xInitial<x0(Iter));
        
        % Active part of profile is defined as only the x0
        iterresult(Iter).xActive= x0(Iter);
        if any(xInitial==x0(Iter))
            % if x0 is a member of xInitial, pick the corresponding z, z2
            iterresult(Iter).zActive = zInitial(xInitial==x0(Iter));
            iterresult(Iter).z2Active = zInitial(xInitial==x0(Iter));
        else
            % else, interpolate the corresponding z, z2
            iterresult(Iter).zActive = interp1(xInitial,zInitial,x0(Iter));
            iterresult(Iter).z2Active = interp1(xInitial,zInitial,x0(Iter));
        end
        
        % Seaward part of the profile is seaward from x0
        iterresult(Iter).xSea = xInitial(xInitial>x0(Iter));
        iterresult(Iter).zSea = zInitial(xInitial>x0(Iter));
        
        iterresult(Iter).Volumes.Volume = 0; %#ok<NASGU>
        NoAddErosion = true;
    else
        % derive the additional volume based on the restriction
        SeawardBoundary(Iter) = max(xcross);
        LandwardBoundary(Iter) = min(xcross);
        [Volume(Iter) iterresult(Iter)] = getVolume(xInitial, zInitial, [], WL_t, LandwardBoundary(Iter), SeawardBoundary(Iter), x0(Iter)+x2, z2);
    end
    iterid = Iter;
    if dbstate
        dbPlotDuneErosion
    end
end

%% create the contours of the additional volume
if all(zDUROS<WL_t)
    % DUROS profile is below water level
    if Volume(iterid)>0
        xtemp = [min(findCrossings(xInitial,zInitial,[min(xDUROS); max(xInitial)],repmat(WL_t,2,1),'keeporiginalgrid')) LandwardBoundary(iterid)];
    else
        xtemp = [LandwardBoundary(iterid) max(findCrossings(xInitial,zInitial,[min(xInitial); min(xDUROS)],repmat(WL_t,2,1),'keeporiginalgrid'))];
    end
else
    if Volume(iterid)>0
        xtemp = [min(xDUROS) LandwardBoundary(iterid)];
    else
        xtemp = [LandwardBoundary(iterid) min(xDUROS)];
    end
end
ztemp = interp1(xInitial,zInitial,xtemp);
if Volume(iterid)>0
    if all(zDUROS<WL_t)
        % DUROS profile is below water level
        x1 = [xtemp(1); x0(iterid)];
        z1 = repmat(WL_t,2,1);
    else
        x1 = [xDUROS(zDUROS>=WL_t); x0(iterid)];
        z1 = [zDUROS(zDUROS>=WL_t); WL_t];
    end
    id = xInitial>min(xDUROS) & xInitial<LandwardBoundary(iterid);
    x2 = [xtemp(1); xInitial(id); xtemp(2); x0(iterid)];
    z2 = [ztemp(1); zInitial(id); ztemp(2); WL_t];
else
    NoAddErosion = Volume(iterid) == 0;
    if NoAddErosion
        [x1, z1, x2, z2] = deal([]);
    else
        id = xInitial<min(xDUROS) & xInitial>LandwardBoundary(iterid);
        if all(zDUROS<WL_t)
            % DUROS profile is below water level
            x1 = [xtemp(1); xInitial(id); xtemp(2); min(xDUROS)];
            z1 = [ztemp(1); zInitial(id); ztemp(2); interp1(xInitial,zInitial,min(xDUROS))];
        else
            x1 = [xtemp(1); xInitial(id); xtemp(2); max(xDUROS(zDUROS>=WL_t))];
            z1 = [ztemp(1); zInitial(id); ztemp(2); WL_t];
        end
        x2 = [xtemp(1); x0(iterid); x0DUROS];
        z2 = [ztemp(1); WL_t; WL_t];
    end
end
[x2 uniid] = unique(x2);
z2 = z2(uniid);
[x1 uniid] = unique(x1);
z1 = z1(uniid);
if isempty(x1)
    xa = xDUROS;
    [z2a za] = deal(WL_t);
else
    xa = unique([x1;x2]);
    za = interp1(x1,z1,xa);
    z2a = interp1(x2,z2,xa);
    [dumx dumz xa za xa z2a] = findCrossings(xa(~isnan(za)&~isnan(z2a)), za(~isnan(za)&~isnan(z2a)), xa(~isnan(za)&~isnan(z2a)), z2a(~isnan(za)&~isnan(z2a)), 'synchronizegrids');
end

if TargetVolume <= 0
    % set z2a to za where za is below z2a (i.e. in dune valleys), for plotting
    % purposes
    z2a(z2a>za) = za(z2a>za);
end

if NoAddErosion
    result = iterresult(iterid);
else
    [dum result] = getVolume(xa, za, [], WL_t, min(xa), max(xa), xa, z2a);
    result.xActive = xa;
    result.zActive = za;
    result.z2Active = z2a;
end
idLand = xInitial < min(result.xActive);
idSeaDUROS = xDUROS > max(result.xActive);
idSeaInitial = xInitial > max(xDUROS);
[result.xLand result.zLand result.xSea result.zSea] = deal(xInitial(idLand), zInitial(idLand), [xDUROS(idSeaDUROS); xInitial(idSeaInitial)], [zDUROS(idSeaDUROS); zInitial(idSeaInitial)]);
precision = diff([Volume(iterid) TargetVolume]); % precision is the difference between Volume and TargetVolume; positive means TargetVolume>Volume; negative means TargetVolume<Volume
result.info.x0 = x0(iterid);
result.info.precision = precision;
result.info.iter = Iter;
result.info.time = toc;
result.info.resultinboundaries = SolutionPossibleWithinBoundaries;
result.info.ID = 'Additional Erosion';
