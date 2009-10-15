function [result, messages] = getDuneErosion(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t)

writemessage('init');

NoDUROSResult = false;
getdefaults(...
    'xInitial', [-250 -24.375 5.625 55.725 230.625 1950]', 1,...
    'zInitial', [15 15 3 0 -3 -14.4625]', 1,...
    'D50', 225e-6, 1,...
    'WL_t', 5, 1,...
    'Hsig_t', 9, 1,...
    'Tp_t', 12, 1);

[xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t] = DUROSCheckConditions(xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t);

AdditionalErosionMax = DuneErosionSettings('get', 'AdditionalErosionMax');
Bend = DuneErosionSettings('get', 'Bend');

SKIPBOUNDPROF = false;

if dbstate
    dbPlotDuneErosion('new');
end

%% STEP 1; get DUROS erosion
if DuneErosionSettings('get', 'DUROS')
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
