function varargout = getAdditionalErosion(x, z, varargin)
%GETADDITIONALEROSION  iteratively fit additional erosion in cross-shore profile
%
%   Routine iteratively fits a predefined volume into a cross-shore
%   profile. This routine is applicable both for positive landward and
%   positive seaward orientated profiles. If the x-direction of the profile
%   not is specified, this property will be derived using
%   checkCrossShoreProfile.
%
%   Syntax:
%   varargout = getAdditionalErosion(varargin)
%
%   Input:
%   x         =
%   z         =
%   varargin  = 'PropertyName' PropertyValue pairs
%                 'TargetVolume' - volume to enclose (default = 0)
%                 'poslndwrd'    - x-direction: positive landward is -1 or 1
%                 'zmin'         - lower boundary of enclosed volume (default is minimum of profile)
%                 'slope'        - landward slope of enclosed profile (default = 1, meaning a 1:1 slope)
%                 'precision'    - precision criterium for iteration (default = 1e-2)
%                 'maxiter'      - maximum number of iterations (default = 50)
%               
%
%   Output:
%   varargout =
%
%   Example
%   getAdditionalErosion
%
%   See also checkCrossShoreProfile

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 24 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%%
OPT = struct(...
    'TargetVolume', 0,...
    'poslndwrd', [],...
    'zmin', min(z),...
    'slope', 1,...
    'precision', 1e-2,...
    'maxiter', 50);

OPT = setProperty(OPT, varargin{:});

%% derive x-direction (poslndwrd) if not specified
if isempty(OPT.poslndwrd)
    [x z OPT.poslndwrd] = checkCrossShoreProfile(x, z);
end

%%
[xcr zcr x1_new_out z1_new_out x2_new_out z2_new_out crossdir] = findCrossings(x, z, x, repmat(OPT.zmin,size(x)));

if OPT.poslndwrd == 1
    % x direction is positive landward
    
    % dune face is defined as the first downward crossing of the zmin level
    % with the profile
    idDuneFace = find(sign(crossdir) == -1, 1, 'first');
    OPT.x0min = xcr(idDuneFace);
    
    % all upward and downward crossings landward of the dune face are
    % potential dune valley indicators
    idValley = crossdir ~= 0;
    idValley(1:idDuneFace) = false;
    
    % take cumsum to filter for horizontal profile parts at the zmin level
    temp = cumsum(crossdir.*idValley);
    idValleyupwrd = [NaN; temp(1:end-1)] == 0 & idValley;
    idValleydwnwrd = temp == 0 & idValley;
    
    if sum(idValleydwnwrd) ~= sum(idValleyupwrd)
        % landward end of profile is below zmin level. Assign most landward
        % crossing as x0max
        OPT.x0max = xcr(find(idValleyupwrd, 1, 'last'));
        % skip this crossing as valley indicator
        idValley(find(idValleyupwrd, 1, 'last')) = false;
    else
        % landward end of profile is above zmin level. Take most landward
        % profile point as x0max
        OPT.x0max = max(x);
    end
else
    % x direction is positive seaward
    
    % dune face is defined as the last upward crossing of the zmin level
    % with the profile
    idDuneFace = find(sign(crossdir) == 1, 1, 'last');
    OPT.x0max = xcr(idDuneFace);
    
    % all upward and downward crossings landward of the dune face are
    % potential dune valley indicators
    idValley = crossdir ~= 0;
    idValley(idDuneFace:end) = false;
    
    % take cumsum to filter for horizontal profile parts at the zmin level
    temp = cumsum(flipud(crossdir.*idValley));
    idValleydwnwrd = flipud([NaN; temp(1:end-1)] == 0) & idValley;
    idValleyupwrd = flipud(temp == 0) & idValley;
    
    if sum(idValleydwnwrd) ~= sum(idValleyupwrd)
        % landward end of profile is below zmin level. Assign most landward
        % crossing as x0min
        OPT.x0min = xcr(find(idValleydwnwrd, 1, 'first'));
        % skip this crossing as valley indicator
        idValley(find(idValleydwnwrd, 1, 'first')) = false;
    else
        % landward end of profile is above zmin level. Take most landward
        % profile point as x0min
        OPT.x0min = min(x);
    end
end

if isempty(idDuneFace)
    % no dune face is detected
    varargout = {[]};
    return
end

if OPT.x0max == max(x)
    % end of profile is above zmin
    OPT.x0max = max(x) + OPT.poslndwrd * -diff([OPT.zmin z(x == max(x))])/OPT.slope;
end

if OPT.x0min == min(x)
    % begin of profile is above zmin
    OPT.x0min = min(x) + OPT.poslndwrd * -diff([OPT.zmin z(x == min(x))])/OPT.slope;
end

x0 = [OPT.x0max OPT.x0min]; % predefine both ultimate situations

OPT.x0except = [xcr(idValleyupwrd & idValley) xcr(idValleydwnwrd & idValley)];
m = size(OPT.x0except,1);
x0exceptID = zeros(m,1);

Iter = 0;               % Iteration number
iterid = 1;             % dummy value for iteration number which gives the best possible solution;
NoAddErosion = false;   % predefinition: initially, no additional erosion has been specified
[Volume xmax xmin] = deal(repmat(NaN, 1, OPT.maxiter)); % Preallocation of variable to store calculated volumes
NextIteration = true;
x2 = -OPT.poslndwrd * [diff([min(x) max(x)]) 0 -diff([OPT.zmin max(z)])/OPT.slope];
z2 = [OPT.zmin OPT.zmin max(z)];

%% iteration loop
% First perform two iterations with the most landward and seaward profiles possible,
% then iterate further


while NextIteration
    Iter = Iter + 1;
    x0InValley = false;
    for i = 1:m
        % check for each pair of x0 exceptions
        if x0(Iter) > OPT.x0except(i,1) && x0(Iter) < OPT.x0except(i,2)
            % current x0 is in between pair of x0 exceptions
            x0InValley = true;
            % set x0 to one of the boundaries of the exception area
            % starting from the seaward boundary
            x0(Iter) = OPT.x0except(i,x0exceptID(i)+1);
            % by highering the x0exceptID by 1, next time, the landward
            % boundary will be chosen
            x0exceptID(i) = x0exceptID(i)+1;
            break
        end
    end
    % find crossings for this particular iteration
    xcross = findCrossings(x, z, x0(Iter)+x2, z2, 'keeporiginalgrid');
    [xmin(Iter) xmax(Iter)] = deal(min(xcross), max(xcross));
    [Volume(Iter) iterresult(Iter)] = getVolume(x, z,...
        'LowerBoundary', OPT.zmin,...
        'LandwardBoundary', xmin(Iter),...
        'SeawardBoundary', xmax(Iter),...
        'x2', x0(Iter)+x2,...
        'z2', z2);
    
    % create conditions for if statement to adjust profile shift x0
    FirstTwoItersCompleted = Iter==numel(x0); % after the second iteration, x0 is extended for each next iteration
    PrecisionNotReached = abs(diff([OPT.TargetVolume Volume(Iter)])) >= abs(OPT.precision);
    SolutionPossibleWithinBoundaries = diff(sign(Volume(1:2)-OPT.TargetVolume))~=0;
    MaxNrItersReached = Iter == OPT.maxiter;
    if FirstTwoItersCompleted && ~x0InValley
        % difference between last two iterations is smaller than precision
        VollDiffSmall = abs(diff(Volume(Iter-1:Iter)))<OPT.precision;
    else
        VollDiffSmall = false;
    end

    if x0InValley
        if Volume(Iter) < OPT.TargetVolume
            % x0 was located in valley, landward valley side results appears to
            % be too far landward. Theoretically, choosing the x0 at the
            % seaward side of the valley should result in the same volume (in
            % practice, this can differ, even so that the latter results in
            % more volume...) By setting the x0 for this situation to the
            % seaward side of the valley prevents this problem
            x0(Iter) = OPT.x0except(fliplr(OPT.x0except==x0(Iter)));
        elseif Volume(Iter) > OPT.TargetVolume
            x0(Iter) = OPT.x0except(fliplr(OPT.x0except==x0(Iter)));
        end
    end

    if FirstTwoItersCompleted && PrecisionNotReached && SolutionPossibleWithinBoundaries && ~MaxNrItersReached && ~VollDiffSmall
        % new profile shift has to be calculated.

        % find identifier of Volume closest but larger than TargetVolume
        idpos = find(Volume==min(Volume(Volume>=OPT.TargetVolume)));
        if length(idpos)>1
            % to prevent a vector of idpos
            [dummy IX] = sort(x0(idpos)*OPT.poslndwrd); % take poslndwrd into account to always find the most landward idpos
            idpos = idpos(IX(end)); % take the last one
        end

        % find identifier of Volume closest but smaller than TargetVolume
        idneg = find(Volume==max(Volume(Volume<OPT.TargetVolume))); % find identifier of Volume closest but smaller than TargetVolume
        if length(idneg)>1
            % to prevent a vector of idneg
            [dummy IX] = sort(x0(idneg)*OPT.poslndwrd); % take poslndwrd into account to always find the most seaward idneg
            idneg = idneg(IX(1)); % take the first one
        end

        % interpolation using two Volumes, closest larger and closest
        % smaller value than TargetVolume
        x0(Iter+1) = interp1(Volume([idpos idneg]), x0([idpos idneg]), OPT.TargetVolume); % interpolation using two Volumes, closest larger and closest smaller value than TargetVolume
    elseif FirstTwoItersCompleted
        % either no solution is possible between the boundaries, the
        % maximum number of solutions is reached or the precision has been
        % reached (--> a satisfying solution)

        % find the iteration number of the latest iteration which resulted
        % in the best possible solution
        iterid = find(abs(Volume-OPT.TargetVolume)==min(abs(Volume-OPT.TargetVolume)),1,'last'); % find the iteration number of the latest iteration which resulted in the best possible solution

        % change while loop condition
        NextIteration = false;
    end
end

result = iterresult(iterid);
precision = abs(diff([Volume(iterid) OPT.TargetVolume])); % precision is the difference between Volume and TargetVolume; positive means TargetVolume>Volume; negative means TargetVolume<Volume
result.info.x0 = x0(iterid);
result.info.precision = precision;
result.info.iter = Iter;
result.info.time = toc;
result.info.resultinboundaries = SolutionPossibleWithinBoundaries;
result.info.ID = 'Additional Erosion';

varargout = {result};