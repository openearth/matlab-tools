function [result, messages] = getDuneErosion(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t)
% Work in progress. This routine cannot be used at this moment.

%GETDUNEEROSION Calculates dune erosion according to the DUROS+ method
%
%   This is the main routine for calculations of dune erosion with the
%   DUROS+ method. Based on hydraulic input parameters a parabolic erosion
%   profile is determined. This profile is extended with a part above the
%   water line (1:1) and beneath the toe (1:12,5). The erosion profile is
%   fitted in the initial profile in such a way that the amount of
%   accretion equals the amount of erosion. Influences of coastal bends and
%   or channels near the dune are incorporated as well as dune breaches.
%   After calculation of the erosion profile the function determines: the 
%   amount of erosion above the maximum storm search level; any additional
%   erosion (due to uncertainties in the calculation method) and; fits a
%   boundary profile in the remaining erosion profile.
%
%   Syntax:
%   [result, messages] = getDuneErosion(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t)
%
%   Input:
%   xInitial /zInitial -    doubles (n*1) with x-points and the 
%                           corresponding height of the dune initial profile.
%   D50                -    Grain size.
%   WL_t               -    Maximum storm search level
%   Hsig_t             -    Significant wave height during the storm
%   Tp_t               -    Peak wave period during the storm
%
%   Output:
%   result             -    a struc that contains the results for each
%                           calculation step. The result struct has fields:
%                               info:    information about the calculation
%                                           step
%                               Volumes: Cumulative volumes, erosion volume
%                                           and accretion volume
%                               xActive: x-coordinates of the area that was
%                                           changes during the calculation 
%                                           step
%                               zActive: z-coordinates of the points that
%                                           was changes prior to the change
%                               z2Active:z-coordinates of the changed
%                                           points
%                               xLand:   x-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zLand:   z-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               xSea:    x-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zSea:    z-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               
%   Example
%
%   See also DuneErosionSettings optimiseDUROS getDuneErosion_DUROS getDuneErosion_additional

%   --------------------------------------------------------------------
%   Copyright (C) $date(yyyy) $Company
%       $author
%
%       $email	
%
%       $address
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

% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: dune dunes erosion DUROS DUROS+ VTV beach

%% Initiate variables
writemessage('init');

NoDUROSResult = false;
getdefaults(...
    'xInitial', [-250 -24.375 5.625 55.725 230.625 1950]', 1,...
    'zInitial', [15 15 3 0 -3 -14.4625]', 1,...
    'D50', 225e-6, 1,...
    'WL_t', 5, 1,...
    'Hsig_t', 9, 1,...
    'Tp_t', 12, 1);
AdditionalErosionMax = DuneErosionSettings('get', 'AdditionalErosionMax');
Bend = DuneErosionSettings('get', 'Bend');
SKIPBOUNDPROF = false;

%% Check input
[xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t] = DUROSCheckConditions(xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t);

%% debug plot initial profile
if dbstate
    dbPlotDuneErosion('new');
end

if DuneErosionSettings('get', 'DUROS')
    %% STEP 1; get DUROS erosion
    writemessage(100,'Start first step: Get and fit DUROS profile');
    [result, Volume, x00min, x0max, x0except, x0min] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t,false);
    
    % update initial profile with minor modification by findCrossings
    [xInitial zInitial] = deal(...
        [result(1).xLand; result(1).xActive; result(1).xSea],...
        [result(1).zLand; result(1).zActive; result(1).zSea]);
    
    if isempty(Volume)
        NoDUROSResult = true;
    end
    %% STEP 2; get profile shift due to coastal Bend
    if result(1).info.resultinboundaries && ~NoDUROSResult
        TargetVolume = eval(DuneErosionSettings('AdditionalVolume'));  % Attention, TargetVolume represents an additional amount of erosion, which is a negative number (!)
        AdditionalErosionforCoastalBend = Bend > 6;
        if AdditionalErosionforCoastalBend
            FallvelocityArgs = [DuneErosionSettings('get', 'FallVelocity') {D50}];
            w = feval(FallvelocityArgs{:});
            G = getG(TargetVolume + Volume, Hsig_t, w, Bend);
            g = G/diff(result(1).zActive([end 1])); % G = g * z ==> g = G/z; see Basisrapport Zandige Kust pp 469
            x0bend = result(1).info.x0 + g;
            writemessage(51, ['Additional retreat of ' num2str(-g, '%.2f') ' m as a contribution for a coastal bend']);
            x0bendwithinboundaries = x0bend > x0min && x0bend < x0max;
            if ~x0bendwithinboundaries
                x0bend = x0min;
                writemessage(53, ['Additional retreat as a contribution for a coastal bend limited to ' num2str(-(x0bend-result(1).info.x0), '%.2f') ' m']);
            end
            xInitialpreBend = [result(1).xLand; result(1).xActive; result(1).xSea];
            zInitialpreBend = [result(1).zLand; result(1).zActive; result(1).zSea];
            result(end+1) = getDUROSprofile(xInitialpreBend, zInitialpreBend, x0bend, Hsig_t, Tp_t, WL_t, w);
            if x0bendwithinboundaries
                result(end).info.ID = ['Shifted for coastal bend (Bend = ' num2str(Bend) '^{\circ}; G = ' num2str(G, '%.2f')  ' m^3/m^1)'];
            else
                %TODO: recalculate G (because it is limited by x0min)
                result(end).info.ID = ['Shifted for coastal bend (Bend = ' num2str(Bend) '^{\circ})'];
            end
            
            % the shifted DUROS profile has been constructed with respect
            % to the initial profile. To create the correct patch, the
            % active profile has to adapted, to the original DUROS result.
            
            % part of the seaward tail has to become part of the active
            % profile
            idSea = result(end).xSea <= result(1).xActive(end);
            result(end).xActive = [result(end).xActive; result(end).xSea(idSea)];
            result(end).xSea = result(end).xSea(~idSea);
            result(end).z2Active = [result(end).z2Active; result(end).zSea(idSea)];
            result(end).zSea = result(end).zSea(~idSea);
            % zActive can now be interpolated based on the original DUROS
            % result
            result(end).zActive = interp1([result(1).xLand; result(1).xActive; result(1).xSea],...
                [result(1).zLand; result(1).z2Active; result(1).zSea],...
                result(end).xActive);
            
            idAddProf = 3;
        else
            idAddProf = 1;
        end
    end
end

%% STEP 3; get additional erosion
if DuneErosionSettings('get', 'AdditionalErosion') && ~NoDUROSResult
    if result(1).info.resultinboundaries
        writemessage(300,'Start third step: get Additional erosion');
        if AdditionalErosionMax
            maxRetreat = DuneErosionSettings('maxRetreat'); % No more than 15 m additional retreat
        else
            maxRetreat = []; % No limitation
        end
        zDUROS = [result(idAddProf).zLand; result(idAddProf).z2Active; result(idAddProf).zSea];
        idnr = length(result)+1;
        if max(zDUROS) < WL_t
            % no additional erosion because DUROS solution does not have
            % any point above the water level.
            result(idnr) = noAdditionaleErosionResult(xInitial,zInitial,result,maxRetreat,TargetVolume);
            SKIPBOUNDPROF = true;
            %% subroutine
%             writemessage(4,'No profile information above sea level after DUROS calculation');
%             result(idnr) = createEmptyDUROSResult;
%             KnownRestrictedSolutionPossible = (result(1).info.x0 - min(xInitial)) > maxRetreat;
%             if KnownRestrictedSolutionPossible
%                 writemessage(45, 'Erosional length restricted within dunevalley. No additional Erosion volume determined.');
%                 result(idnr).xLand = xInitial(xInitial<result(1).info.x0);
%                 result(idnr).zLand = zInitial(xInitial<result(1).info.x0);
%                 result(idnr).xActive= result(1).info.x0;
%                 if any(xInitial==result(1).info.x0)
%                     result(idnr).zActive = zInitial(xInitial==result(1).info.x0);
%                     result(idnr).z2Active = zInitial(xInitial==result(1).info.x0);
%                 else
%                     result(idnr).zActive = interp1(xInitial,zInitial,result(1).info.x0);
%                     result(idnr).z2Active = interp1(xInitial,zInitial,result(1).info.x0);
%                 end
%                 result(idnr).xSea = xInitial(xInitial>result(1).info.x0);
%                 result(idnr).zSea = zInitial(xInitial>result(1).info.x0);
%                 result(idnr).Volumes.Volume = 0; %#ok<NASGU>
%                 result(idnr).info.x0 = result(1).info.x0;
%                 result(idnr).info.precision = TargetVolume;
%                 result(idnr).info.resultinboundaries = true;
%                 result(idnr).info.ID = 'Additional Erosion';
%             end
        else
            result(idnr) = getDuneErosion_additional(xInitial,zInitial,...
                result(idAddProf),...
                WL_t,...
                TargetVolume,...
                result(2).Volumes.Volume,...
                maxRetreat,...
                x0except);
        end
    else
        result(end+1) = createEmptyDUROSResult;
        writemessage(41,'No additional erosion possible');
        SKIPBOUNDPROF = true;
    end
end

%% STEP 4; fit Boundary profile
if DuneErosionSettings('get', 'BoundaryProfile') && ~NoDUROSResult
    if ~SKIPBOUNDPROF && result(end).info.resultinboundaries
        writemessage(400,'Start fourth step: fit boundary profile');
        x2 = [result(end).xLand; result(end).xActive; result(end).xSea];
        z2 = [result(end).zLand; result(end).z2Active; result(end).zSea];
        result(end+1) = fitBoundaryProfile(xInitial, zInitial, x2, z2, WL_t, Tp_t, Hsig_t, x00min, result(end).info.x0, x0except);
    else
        result(end+1) = createEmptyDUROSResult;
        result(end).info.ID = 'BoundaryProfile';
        writemessage(-1,'Boundary profile cannot be fit into the profile');
    end
end

%% STEP 5; process messages
messages=writemessage('get');
for i=1:length(result)
    ids=find([messages{:,1}]==i*100,1,'last');
    ids_next=find([messages{:,1}]==100*(i+1),1,'first');
    if isempty(ids_next)
        ids_next=size(messages,1)+1;
    end
    result(i).info.messages=messages(ids+1:ids_next-1,:);
end
if DuneErosionSettings('get','Verbose')
    msgcodes = DuneErosionSettings('get','verbosemessages');
    cds = cell2mat(messages(:,1));
    if any(ismember(msgcodes,cds))
        for imess = 1:size(messages,1)
            if any(msgcodes==cds(imess))
                disp(messages{imess,2});
            end
        end
    end
end

%% add input to result structure
result(1).info.input = struct(...
    'D50', D50,...
    'WL_t', WL_t,...
    'Hsig_t', Hsig_t,...
    'Tp_t', Tp_t);
