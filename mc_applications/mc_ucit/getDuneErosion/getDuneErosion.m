function [result, messages] = getDuneErosion(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t)
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
    [result, Volume, x00min, x0max, x0except] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t,false);
    if isempty(Volume)
        NoDUROSResult = true;
    end
    %% STEP 2; get profile shift due to coastal Bend
    if result(1).info.resultinboundaries && ~NoDUROSResult
        TargetVolume = eval(DuneErosionSettings('AdditionalVolume'));  % Attention, TargetVolume represents an additional amount of erosion, which is a negative number (!)
        AdditionalErosionforCoastalBend = Bend > 6;
        if AdditionalErosionforCoastalBend
            G = getG(TargetVolume + Volume, Hsig_t, w, Bend);
            result(end+1) = getDUROSprofile(xInitial, zInitial, result(1).info.x0 - G, Hsig_t, Tp_t, WL_t, w);
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
        z = [result(idAddProf).zLand; result(idAddProf).z2Active; result(idAddProf).zSea];
        if max(z) < WL_t
            SKIPBOUNDPROF = true;
            writemessage(4,'No profile information above sea level after DUROS calculation');
            idnr = length(result)+1;
            result(idnr) = createEmptyDUROSResult;
            KnownRestrictedSolutionPossible = (result(1).info.x0 - min(xInitial)) > maxRetreat;
            if KnownRestrictedSolutionPossible
                writemessage(45, 'Erosional length restricted within dunevalley. No additional Erosion volume determined.');
                result(idnr).xLand = xInitial(xInitial<result(1).info.x0);
                result(idnr).zLand = zInitial(xInitial<result(1).info.x0);
                result(idnr).xActive= result(1).info.x0;
                if any(xInitial==result(1).info.x0)
                    result(idnr).zActive = zInitial(xInitial==result(1).info.x0);
                    result(idnr).z2Active = zInitial(xInitial==result(1).info.x0);
                else
                    result(idnr).zActive = interp1(xInitial,zInitial,result(1).info.x0);
                    result(idnr).z2Active = interp1(xInitial,zInitial,result(1).info.x0);
                end
                result(idnr).xSea = xInitial(xInitial>result(1).info.x0);
                result(idnr).zSea = zInitial(xInitial>result(1).info.x0);
                result(idnr).Volumes.Volume = 0; %#ok<NASGU>
                result(idnr).info.x0 = result(1).info.x0;
                result(idnr).info.precision = TargetVolume;
                result(idnr).info.resultinboundaries = true;
                result(idnr).info.ID = 'Additional Erosion';
            end
        else
            x = result(idAddProf).xActive;
            z = result(idAddProf).z2Active;
            if TargetVolume <= 0
                [x0minAddEr, x0maxAddEr] = deal(x00min, result(idAddProf).info.x0);
            else % positive TargetVolume will reduce the retreat distance (!)
                writemessage(40, 'Warning: Additional erosion volume is positive, this reduces the retreat distance');
                x0minAddEr = result(idAddProf).info.x0;
                x0maxAddEr = max(findCrossings(xInitial, zInitial, xInitial([1 end]), ones(2,1)*WL_t, 'keeporiginalgrid'));  % intersections of initial profile with WL_t
            end
            x2 = [WL_t-max(zInitial) 0 x0max-x00min]';
            z2 = [max(zInitial) WL_t WL_t]';
            x0DUROS = result(1).info.x0;
            AVolume = result(2).Volumes.Volume;
            result(end+1) = getDuneErosion_additional(xInitial, zInitial, x, z, x2, z2, WL_t, x0minAddEr, x0maxAddEr, x0except, TargetVolume, maxRetreat, x0DUROS, AVolume);
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
        result(end+1) = fitBoundaryProfile(xInitial, zInitial, x2, z2, WL_t, Tp_t, Hsig_t, x00min, result(3).info.x0, x0except);
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
