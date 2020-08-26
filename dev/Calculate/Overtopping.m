%Class with functions to calculate wave overtopping according to EurOtop
%manual 1. 
%
% @author JUM
% @author THL
% @version
%

classdef Overtopping < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependent properties
    properties (Dependent = true, SetAccess = private)
        
    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end
    
    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end
    
    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'private')
        
    end
    
    %Static methods
    methods (Static)
        
        
        function [overtoppingRate, cellResults ,comments] = calcOvertopping(depthToe, waterLevel, waveHeight, waveHeightDeep, wavePeriod,waveAngle, charcStruct, typeCalc, typeStruct,nameFile,nameSheet)
            % Calculates the overtopping discharge at a seawall based on
            % the formulas of EurOtop Manual 2007 and van der Meer & Bruce 2014
            %
            % [overtoppingRate, cellResults ,comments] = Overtopping.calcOvertopping(depthToe, waterLevel, waveHeight, 
            % waveHeightDeep, wavePeriod,waveAngle, charcStruct, typeCalc, typeStruct,nameFile,nameSheet)
            %
            %INPUT
            % - depthToe: depth at the toe of the structure [mTAW]
            % - waterLevel: time series of the waterLevel [mTAW]
            % - waveHeight: time series of the wave height Hm0 [m]
            % - wavePeriod: time series of the wave period (Tm-1,0) [s]
            % - waveAngle: angle between
            % - charcStruct: cell array with
            % - R1: slope angle of structure [°]
            % - R2: level quay wall [mTAW]
            % - R3: array wi th values of the different factors (see EurotopManual for the calculation of these factors
            % - coastal dikes: C1: gammaF
            %               C2: gammaB
            %               C3: gammaV
            % - armoured rubble slopes: C1: gammaF
            %                        C2: gammaB
            %                        C3: gammaV
            %                        C4: crets width
            % - vertical wall: C1: level berm [mTAW]
            %               C2: parameter foreshore slope m (1:m) or battered
            %               wall (m:1)
            % - typeCalc: string with values 'probabilistic' or 'deterministic'
            % - typeStruct: string with values 'dike' or 'armoured' or 'plain vertical' or
            % - 'battered vertical' or 'composite vertical' to determine which kind of calculation should be used
            % - nameFile: name of the excel file to write the data to
            % - nameSheet: name of sheet
            %
            %OUTPUT
            % - overtoppingRate: time series of the overtopping rate
            % - dikes: array with C1 freeboard [m], C2 chi, C3 overtopping rates [m³/s/m]
            % - armoured rubble slopes: array with C1 freeboard [m], C2 chi, C3 overtopping rates [m³/s/m] without reduction and C4 overtopping with reduction due to the crest width
            % - vertical walls: array with C1 freeboard [m], C2 wave breaking parameter, C3 overtopping rates [m³/s/m]
            %
            
            comments = {};
            g = 9.81;
            freeboard = charcStruct{2,1} - waterLevel;
            alpha = charcStruct{1,1}*pi/180;
            time = (0:1:length(waveHeight)-1)';
            qOvertop = zeros(size(waveHeight,1),1);
            qOvertopRed = zeros(size(waveHeight,1),1);
            
            s0 = 2*pi*waveHeight./(g*wavePeriod.^2);
            chi = tan(alpha)./sqrt(s0);
            
            %--------------------------------------------------------------------------
            %COASTAL DIKES AND EMBANKMENT SEAWALLS
            if strcmpi(typeStruct,'dike')
                %use of coefficients depends on probabilistic or deterministic design
                %and on the relative freeboard R/H
                %eurotop in case: R/H>0.5
                %van der Meer & Bruce: R/H=<0.5
                coefA = zeros(size(waveHeight,1),1);
                coefB = zeros(size(waveHeight,1),1);
                coefC = zeros(size(waveHeight,1),1);
                coefD = zeros(size(waveHeight,1),1);
                
                if strcmpi(typeCalc, 'probabilistic')
                    %coefficient for R/H >= 0.5
                    coefA(freeboard./waveHeight >= 0.5) = 4.75;
                    coefB(freeboard./waveHeight >= 0.5) = 2.6;
                    coefC(freeboard./waveHeight >= 0.5) = 0.067;
                    coefD(freeboard./waveHeight >= 0.5) = 0.2;
                    
                    %coefficient for R/H < 0.5
                    coefA(freeboard./waveHeight < 0.5) = 2.7;
                    coefB(freeboard./waveHeight < 0.5) = 1.5;
                    coefC(freeboard./waveHeight < 0.5) = 0.023;
                    coefD(freeboard./waveHeight < 0.5) = 0.09;
                end
                
                if strcmpi(typeCalc,'deterministic')
                    %coefficient for R/H >= 0.5
                    coefA(freeboard./waveHeight >= 0.5) = 4.3;
                    coefB(freeboard./waveHeight >= 0.5) = 2.3;
                    coefC(freeboard./waveHeight >= 0.5) = 0.067;
                    coefD(freeboard./waveHeight >= 0.5) = 0.2;
                    
                    %coefficient for R/H < 0.5
                    coefA(freeboard./waveHeight < 0.5) = 2.5;
                    coefB(freeboard./waveHeight < 0.5) = 1.35;
                    coefC(freeboard./waveHeight < 0.5) = 0.026;
                    coefD(freeboard./waveHeight < 0.5) = 0.103;
                end
                
                %evaluation of the different cases
                logFreeboardPosNonBreaking = freeboard > 0 & chi<=5;
                logFreeboardPosBreaking = freeboard > 0 & chi>=7;
                logFreeboardPosBetween = freeboard > 0 & 5<chi & chi<7;
                logFreeboardZeroNonSurging = freeboard ==0 & chi<2;
                logFreeboardZeroSurging = freeboard ==0 & chi>=2;
                logFreeboardNegNonSurging = freeboard < 0 & chi<2;
                logFreeboardNegSurging = freeboard < 0 & chi>=2;
                
                %factor gammaB
                gammaB = charcStruct{3,1}(1,2);
                %factor gammaF
                gammaF = charcStruct{3,1}(1,1);
                gammaF = min(max(repmat(gammaF,[size(waveHeight,1),1]),gammaF+(chi*gammaB-1.8)*(1-gammaF)/8.2),repmat(1,[size(waveHeight,1),1]));
                %factor gammaBeta
                gammaBeta = ones(length(waveHeight),1);
                gammaBeta(0 <= abs(waveAngle) & 80 >= abs(waveAngle)) = 1-0.0033*abs(waveAngle(0 <= abs(waveAngle) & 80 >= abs(waveAngle)));
                gammaBeta(80 < abs(waveAngle) & abs(waveAngle) <= 110) = 0.736;
                waveHeight(80 < abs(waveAngle) & abs(waveAngle) <= 110) = waveHeight(80 < abs(waveAngle) & abs(waveAngle) <= 110).*(110-abs(waveAngle(80 < abs(waveAngle) & abs(waveAngle) <= 110)))/30;
                wavePeriod(80 < abs(waveAngle) & abs(waveAngle) <= 110) = wavePeriod(80 < abs(waveAngle) & abs(waveAngle) <= 110).*sqrt((110-abs(waveAngle(80 < abs(waveAngle) & abs(waveAngle) <= 110)))/30);
                %factor gammaV
                gammaV = charcStruct{3,1}(1,3);
                
                
                %overtopping formula non-breaking waves and positive freeboard
                qOvertopNonBreaking = sqrt(g*waveHeight.^3).*coefC.*gammaB.*chi.*exp(-coefA.*freeboard./(chi.*waveHeight.*gammaB.*gammaF.*gammaBeta*gammaV))/sqrt(tan(alpha));
                qMax = sqrt(g*waveHeight.^3).*coefD.*exp(-coefB.*freeboard./(waveHeight.*gammaF.*gammaBeta));
                qOvertopNonBreaking = min(qOvertopNonBreaking,qMax);
                
                %overtopping formula breaking waves and positive freeboard
                qOvertopBreaking = 0.21*exp(-freeboard./(gammaF.*gammaBeta.*waveHeight.*(0.33+0.022.*chi))).*sqrt(g*waveHeight.^3);
                
                %interpolation between formula of breaking and non-breaking waves in
                %case 5<chi<7
                qOvertopBreaking7 = 0.21*exp(-freeboard./(gammaF.*gammaBeta.*waveHeight.*(0.33+0.022*7))).*sqrt(g*waveHeight.^3);
                qOvertopNonBreaking5 = min(sqrt(g*waveHeight.^3).*coefD.*exp(-coefB.*freeboard./(waveHeight.*gammaF.*gammaBeta)),sqrt(g*waveHeight.^3).*coefC*gammaB*5.*exp(-coefA.*freeboard./(5*waveHeight*gammaB.*gammaF.*gammaBeta*gammaV))/sqrt(tan(alpha)));
                qOvertopBetween = ((qOvertopBreaking7 - qOvertopNonBreaking5)./(7-5)).*(chi-5)+qOvertopNonBreaking5;
                
                %         %formula zero freeboard
                %         if strcmpi(typeCalc, 'probabilistic')
                %             qOvertopFreeboardZeroNonSurging = 0.0537*chi.*sqrt(g*waveHeight.^3);
                %             qOvertopFreeboardZeroSurging = (0.136 - 0.226./chi.^3).*sqrt(g*waveHeight.^3);
                %         end
                %         if strcmpi(typeCalc,'deterministic')
                %             qOvertopFreeboardZeroNonSurging = (0.0537*chi+0.14).*sqrt(g*waveHeight.^3);
                %             qOvertopFreeboardZeroSurging = ((0.136 - 0.226/chi.^3)+0.14).*sqrt(g*waveHeight.^3);
                %         end
                
                %formula negative freeboard
                %qOverflowNonSurging = 0.6*sqrt(g*abs(freeboard.^3))+0.0537*chi.*sqrt(g*waveHeight.^3);
                %qOverflowSurging = 0.6*sqrt(g*abs(freeboard.^3))+(0.136 - 0.226./chi.^3).*sqrt(g*waveHeight.^3);
                
                %evaluating which formula should be used
                qOvertopZero = zeros(1,size(waveHeight,1));
                qOvertop(logFreeboardPosNonBreaking) = qOvertopNonBreaking(logFreeboardPosNonBreaking);
                qOvertop(logFreeboardPosBreaking) = qOvertopBreaking(logFreeboardPosBreaking);
                qOvertop(logFreeboardPosBetween) = qOvertopBetween(logFreeboardPosBetween);
                %         qOvertop(logFreeboardZeroNonSurging) = qOvertopFreeboardZeroNonSurging(logFreeboardZeroNonSurging);
                %         qOvertop(logFreeboardZeroSurging) = qOvertopFreeboardZeroSurging(logFreeboardZeroSurging);
                qOvertop(logFreeboardNegNonSurging) = qOvertopZero(logFreeboardNegNonSurging);
                qOvertop(logFreeboardNegSurging) = qOvertopZero(logFreeboardNegSurging);
                qOvertop(waveAngle > 110) = qOvertopZero(waveAngle > 110);
                
                qOvertop = round(qOvertop,4);
                overtoppingRate = [freeboard chi qOvertop];
                
                
                cellResults = [time, waterLevel, waveHeight, wavePeriod, freeboard, chi, qOvertop];
                
                % xlswrite(nameFile,strHeadings,nameSheet,'A1');
                % xlswrite(nameFile,cellResults,nameSheet,'A2');
                % if ~isempty(comments)
                %     xlswrite(nameFile,comments,nameSheet,'H2');
                % end
                
            end
            %--------------------------------------------------------------------------
            %ARMOURED RUBBLE SLOPES AND MOUNDS
            if strcmpi(typeStruct,'armoured')
                %use of coefficients depends on probabilistic or deterministic design
                %and on the relative freeboard R/H
                %eurotop in case: R/H>0.5
                %van der Meer & Bruce: R/H=<0.5
                
                coefA = zeros(size(waveHeight,1),1);
                coefB = zeros(size(waveHeight,1),1);
                coefC = zeros(size(waveHeight,1),1);
                coefD = zeros(size(waveHeight,1),1);
                
                if strcmpi(typeCalc, 'probabilistic')
                    coefA(freeboard./waveHeight >= 0.5) = 4.75;
                    coefB(freeboard./waveHeight >= 0.5) = 2.6;
                    coefC(freeboard./waveHeight >= 0.5) = 0.067;
                    coefD(freeboard./waveHeight >= 0.5) = 0.2;
                    
                    coefA(freeboard./waveHeight < 0.5) = 2.7;
                    coefB(freeboard./waveHeight < 0.5) = 1.5;
                    coefC(freeboard./waveHeight < 0.5) = 0.023;
                    coefD(freeboard./waveHeight < 0.5) = 0.09;
                end
                
                if strcmpi(typeCalc,'deterministic')
                    coefA(freeboard./waveHeight >= 0.5) = 4.3;
                    coefB(freeboard./waveHeight >= 0.5) = 2.3;
                    coefC(freeboard./waveHeight >= 0.5) = 0.067;
                    coefD(freeboard./waveHeight >= 0.5) = 0.2;
                    
                    coefA(freeboard./waveHeight < 0.5) = 2.5;
                    coefB(freeboard./waveHeight < 0.5) = 1.35;
                    coefC(freeboard./waveHeight < 0.5) = 0.026;
                    coefD(freeboard./waveHeight < 0.5)= 0.103;
                end
                
                %evaluation of the different cases
                logFreeboardPosNonBreaking = freeboard > 0 & chi<=5;
                logFreeboardPosBreaking = freeboard > 0 & chi>=7;
                logFreeboardPosBetween = freeboard > 0 & 5<chi & chi<7;
                logFreeboardZeroNonSurging = freeboard ==0 & chi<2;
                logFreeboardZeroSurging = freeboard ==0 & chi>=2;
                logFreeboardNegNonSurging = freeboard < 0 & chi<2;
                logFreeboardNegSurging = freeboard < 0 & chi>=2;
                
                %factor gammaB
                gammaB = charcStruct{3,1}(1,2);
                %factor gammaF
                gammaF = charcStruct{3,1}(1,1);
                gammaF = min(max(repmat(gammaF,[size(waveHeight,1),1]),gammaF+(chi*gammaB-1.8)*(1-gammaF)/8.2),repmat(1,[size(waveHeight,1),1]));
                %factor gammaBeta
                gammaBeta = ones(length(waveHeight),1);
                gammaBeta(0 <= abs(waveAngle) & 80 >= abs(waveAngle)) = 1-0.0033*abs(waveAngle(0 <= abs(waveAngle) & 80 >= abs(waveAngle)));
                gammaBeta(80 < abs(waveAngle) & abs(waveAngle) <= 110) = 0.736;
                waveHeight(80 < abs(waveAngle) & abs(waveAngle) <= 110) = waveHeight(80 < abs(waveAngle) & abs(waveAngle) <= 110).*(110-abs(waveAngle(80 < abs(waveAngle) & abs(waveAngle) <= 110)))/30;
                wavePeriod(80 < abs(waveAngle) & abs(waveAngle) <= 110) = wavePeriod(80 < abs(waveAngle) & abs(waveAngle) <= 110).*sqrt((110-abs(waveAngle(80 < abs(waveAngle) & abs(waveAngle) <= 110)))/30);
                %factor gammaV
                gammaV = charcStruct{3,1}(1,3);
                %crest width
                crestWidth = charcStruct{3,1}(1,4);
                
                %overtopping formula non-breaking waves and positive freeboard
                qOvertopNonBreaking = sqrt(g*waveHeight.^3).*coefC*gammaB.*chi.*exp(-coefA.*freeboard./(chi.*waveHeight*gammaB.*gammaF.*gammaBeta*gammaV))/sqrt(tan(alpha));
                qMax = sqrt(g*waveHeight.^3).*coefD.*exp(-coefB.*freeboard./(waveHeight.*gammaF.*gammaBeta));
                qOvertopNonBreaking = min(qOvertopNonBreaking,qMax);
                
                %overtopping formula breaking waves and positive freeboard
                qOvertopBreaking = 0.21*exp(-freeboard./(gammaF.*gammaBeta.*waveHeight.*(0.33+0.022.*chi))).*sqrt(g*waveHeight.^3);
                
                %interpolation between formula of breaking and non-breaking waves in
                %case 5<chi<7
                qOvertopBreaking7 = 0.21*exp(-freeboard./(gammaF.*gammaBeta.*waveHeight.*(0.33+0.022*7))).*sqrt(g*waveHeight.^3);
                qOvertopNonBreaking5 = min(sqrt(g*waveHeight.^3).*coefD.*exp(-coefB.*freeboard./(waveHeight.*gammaF.*gammaBeta)),sqrt(g*waveHeight.^3).*coefC*gammaB*5.*exp(-coefA.*freeboard./(5*waveHeight*gammaB.*gammaF.*gammaBeta*gammaV))/sqrt(tan(alpha)));
                qOvertopBetween = ((qOvertopBreaking7 - qOvertopNonBreaking5)./(7-5)).*(chi-5)+qOvertopNonBreaking5;
                
                %         %formula zero freeboard
                %         if strcmpi(typeCalc, 'probabilistic')
                %             qOvertopFreeboardZeroNonSurging = 0.0537*chi.*sqrt(g*waveHeight.^3);
                %             qOvertopFreeboardZeroSurging = (0.136 - 0.226./chi.^3).*sqrt(g*waveHeight.^3);
                %         end
                %         if strcmpi(typeCalc,'deterministic')
                %             qOvertopFreeboardZeroNonSurging = (0.0537*chi+0.14).*sqrt(g*waveHeight.^3);
                %             qOvertopFreeboardZeroSurging = ((0.136 - 0.226/chi.^3)+0.14).*sqrt(g*waveHeight.^3);
                %         end
                
                %formula negative freeboard
                %qOverflowNonSurging = 0.6*sqrt(g*abs(freeboard.^3))+0.0537*chi.*sqrt(g*waveHeight.^3);
                %qOverflowSurging = 0.6*sqrt(g*abs(freeboard.^3))+(0.136 - 0.226./chi.^3).*sqrt(g*waveHeight.^3);
                
                %evaluating which formula should be used
                qOvertopZero = zeros(1,size(waveHeight,1));
                qOvertop(logFreeboardPosNonBreaking) = qOvertopNonBreaking(logFreeboardPosNonBreaking);
                qOvertop(logFreeboardPosBreaking) = qOvertopBreaking(logFreeboardPosBreaking);
                qOvertop(logFreeboardPosBetween) = qOvertopBetween(logFreeboardPosBetween);
                %         qOvertop(logFreeboardZeroNonSurging) = qOvertopFreeboardZeroNonSurging(logFreeboardZeroNonSurging);
                %         qOvertop(logFreeboardZeroSurging) = qOvertopFreeboardZeroSurging(logFreeboardZeroSurging);
                qOvertop(logFreeboardNegNonSurging) = qOvertopZero(logFreeboardNegNonSurging);
                qOvertop(logFreeboardNegSurging) = qOvertopZero(logFreeboardNegSurging);
                qOvertop(waveAngle > 110) = qOvertopZero(waveAngle > 110);
                
                %reduction due to crest width
                redCrestWidth = min(3.06*exp(-1.5*crestWidth./waveHeight),1);
                crestWidth = repmat(crestWidth,[size(waveHeight,1),1]);
                testCrestWidth = crestWidth > 0.75.*waveHeight;
                redCrestWidth = testCrestWidth .* testCrestWidth;
                redCrestWidth(redCrestWidth == 0) = 1;
                qOvertopRed(logFreeboardPosNonBreaking) = qOvertopNonBreaking(logFreeboardPosNonBreaking).*redCrestWidth(logFreeboardPosNonBreaking);
                qOvertopRed(logFreeboardPosBreaking) = qOvertopBreaking(logFreeboardPosBreaking).*redCrestWidth(logFreeboardPosBreaking);
                qOvertopRed(logFreeboardPosBetween) = qOvertopBetween(logFreeboardPosBetween).*redCrestWidth(logFreeboardPosBetween);
                %         qOvertopRed(logFreeboardZeroNonSurging) = qOvertopFreeboardZeroNonSurging(logFreeboardZeroNonSurging).*redCrestWidth(logFreeboardZeroNonSurging);
                %         qOvertopRed(logFreeboardZeroSurging) = qOvertopFreeboardZeroSurging(logFreeboardZeroSurging).*redCrestWidth(logFreeboardZeroSurging);
                qOvertopRed(logFreeboardNegNonSurging) = qOvertopZero(logFreeboardNegNonSurging);
                qOvertopRed(logFreeboardNegSurging) = qOvertopZero(logFreeboardNegSurging);
                qOvertopRed(waveAngle > 110) = qOvertopZero(waveAngle > 110);
                
                qOvertop = round(qOvertop,4);
                overtoppingRate = [freeboard chi qOvertop qOvertopRed];
                
                % strHeadings = {'time [min]','waterlevel [mTAW]','Hm0 [m]','Tm-1,0 [s]','Rc [m]', 'chi [-]','q [m³/s/m]','comments'};
                cellResults = [time, waterLevel, waveHeight, wavePeriod, freeboard, chi, qOvertop];
                
                % xlswrite(nameFile,strHeadings,nameSheet,'A1');
                % xlswrite(nameFile,cellResults,nameSheet,'A2');
                % if ~isempty(comments)
                %     xlswrite(nameFile,comments,nameSheet,'H2');
                % end
            end
            
            %--------------------------------------------------------------------------
            %VERTICAL AND STEEP SEAWALLS
            if strcmpi(typeStruct,'plain vertical') || strcmpi(typeStruct,'battered vertical') || strcmpi(typeStruct,'composite vertical')
                [overtoppingRate, cellResults ,comments] = Overtopping.calcOvertoppingVertWall(depthToe, waterLevel, waveHeight, waveHeightDeep, wavePeriod,waveAngle, charcStruct, typeCalc, typeStruct,nameFile,nameSheet);
            end
            
        end
        
        function [overtoppingRate, cellResults ,comments] = calcOvertoppingVertWall(depthToe, waterLevel, waveHeight, waveHeightDeep, wavePeriod,waveAngle, charcStruct, typeCalc, typeStruct,nameFile,nameSheet)
            % Calculate the overtopping discharge at a vertical seawall
            % based on the formulas of EurOtop Manual 2007
            %
            % [overtoppingRate, cellResults ,comments] = Overtopping.calcOvertoppingVertWall(depthToe, waterLevel, waveHeight, waveHeightDeep, wavePeriod,waveAngle, charcStruct, typeCalc, typeStruct,nameFile,nameSheet)
            %
            %INPUT:
            % - depthToe: depth at the toe of the structure [mTAW]
            % - waterLevel: time series of the waterLevel [mTAW]
            % - waveHeight: time series of the wave height Hm0 [m]
            % - wavePeriod: time series of the wave period (Tm-1,0) [s]
            % - waveAngle: angle between
            % - charcStruct: cell array with
            % - R1: slope angle of structure [°]
            % - R2: level quay wall [mTAW]
            % - R3: array with values of the different factors (see EurotopManual for the calculation of these factors
            % - vertical wall: C1: level berm [mTAW]
            %               C2: parameter foreshore slope m (1:m) or battered
            %               wall (m:1)
            % - typeCalc: string with values 'probabilistic' or 'deterministic'
            % - typeStruct: string with values 'dike' or 'armoured' or 'plain vertical' or
            %'battered vertical' or 'composite vertical' to determine which kind of
            %calculation should be used
            % - nameFile: name of the excel file to write the data to
            % - nameSheet: name of sheet
            %
            %OUTPUT
            % - overtoppingRate: time series of the overtopping rate
            % - dikes: array with C1 freeboard [m], C2 chi, C3 overtopping rates [m³/s/m]
            % - armoured rubble slopes: array with C1 freeboard [m], C2 chi, C3 overtopping rates [m³/s/m] without reduction and C4 overtopping with reduction due to the crest width
            % - vertical walls: array with C1 freeboard [m], C2 wave breaking parameter, C3 overtopping rates [m³/s/m]
            %
            
            comments = {};
            g = 9.81;
            freeboard = charcStruct{2,1} - waterLevel;
            alpha = charcStruct{1,1}*pi/180;
            time = (0:1:length(waveHeight)-1)';
            qOvertop = zeros(size(waveHeight,1),1);
            
            s0 = 2*pi*waveHeight./(g*wavePeriod.^2);
            chi = tan(alpha)./sqrt(s0);
            
            %--------------------------------------------------------------------------
            
            %--------------------------------------------------------------------------
            %VERTICAL AND STEEP SEAWALLS
            %check if toe is submerged
            depthToe = repmat(depthToe,[size(waterLevel,1),1]);
            toeSubmerged = depthToe < waterLevel;
            waterdepthToe = abs(depthToe - waterLevel);
            
            %----------------------------------------------------------------------
            %case of plain vertical walls
            if strcmpi(typeStruct,'plain vertical')
                %wave breaking parameter
                waveBreakingPar = 1.35*waterdepthToe.^2*2*pi./(waveHeight*g.*wavePeriod.^2);
                
                %foreshore slope
                foreshoreSlope = charcStruct{3,1}(1,2);
                if isempty(foreshoreSlope)
                    foreshoreSlope = 100;
                end
                
                %criteria
                nonImpulsive = waveBreakingPar > 0.3 & freeboard > 0;
                impulsive = waveBreakingPar < 0.2 & freeboard > 0;
                impulsiveBetween = 0.2 <= waveBreakingPar & waveBreakingPar <= 0.3 & freeboard > 0;
                zeroFreeboardNonImpulsive = waveBreakingPar > 0.3 & freeboard == 0;
                zeroFreeboardImpulsive = waveBreakingPar < 0.2 & freeboard == 0;
                overtopNonImpulsiveValidation = freeboard./waveHeight < 0.1 | freeboard./waveHeight > 3.5;
                overtopImpulsiveValidation = waveBreakingPar.*freeboard./waveHeight <= 0.02 | waveBreakingPar.*freeboard./waveHeight >= 1;
                overtopImpulsiveBroken = waveBreakingPar.*freeboard./waveHeight < 0.02;
                overtopEmergedValidation1 = foreshoreSlope*s0.^0.33.*freeboard./waveHeightDeep < 2 | foreshoreSlope*s0.^0.33.*freeboard./waveHeightDeep >5;
                overtopEmergedValidation2 = freeboard./waveHeightDeep < 0.55 | freeboard./waveHeightDeep > 1.6;
                compare = foreshoreSlope~=10;
                overtopEmergedValidation3 = repmat(compare,[size(freeboard,1),1]);
                overtopEmergedValidation = overtopEmergedValidation1 & overtopEmergedValidation2 & overtopEmergedValidation3;
                negFreeboard = freeboard < 0;
                
                %use of coefficients depends on probabilistic or deterministic design
                if strcmpi(typeCalc, 'probabilistic')
                    coefA = 2.6;
                    coefB = 0.062;
                    coefC = 1.5;
                    coefD = 2.16;
                    coefE = 2.7;
                end
                if strcmpi(typeCalc,'deterministic')
                    coefA = 1.8;
                    coefB = 0.062+0.0062;
                    coefC = 2.8;
                    coefD = 1.95;
                    coefE = 3.8;
                end
                
                %overtopping non-impulsive
                gammaBeta = ones(size(waveHeight,1),1);
                gammaBeta(waveAngle == 0) = 1;
                gammaBeta(abs(waveAngle) > 0 & abs(waveAngle) <= 45) = 1-0.0062*abs(waveAngle(abs(waveAngle) > 0 & abs(waveAngle) <= 45));
                gammaBeta(abs(waveAngle) > 45 & abs(waveAngle) <= 110) = 0.72;
                
                qOvertopNonImpulsive = 0.04*exp(-coefA*freeboard./(waveHeight.*gammaBeta)).*sqrt(g*waveHeight.^3);
                qOvertopNonImpulsiveZeroFreeboard = coefB*sqrt(g*waveHeight.^3);
                %in case waveAngle >110, q = 0
                qOvertopNonImpulsiveZeros = zeros(size(waveHeight,1),1);
                qOvertopNonImpulsive(waveAngle > 110)= qOvertopNonImpulsiveZeros(waveAngle > 110);
                qOvertopNonImpulsiveZeroFreeboard(waveAngle > 110) = qOvertopNonImpulsiveZeros(waveAngle > 110);
                
                
                %overtopping impulsive
                condwaveAngleZero = abs(waveAngle) == 0;
                condwaveAngleZeroFift = abs(waveAngle) > 0 & abs(waveAngle) < 15;
                condwaveAngleFift = abs(waveAngle) == 15;
                condwaveAngleThirt = abs(waveAngle) == 30;
                condwaveAngleFiftThirt = abs(waveAngle) > 15 & abs(waveAngle) < 30;
                condwaveAngleSixt = abs(waveAngle) >= 60 & abs(waveAngle) <=110;
                condwaveAngleThirtSixt = abs(waveAngle) > 30 & abs(waveAngle) < 60;
                condwaveAngle110 = abs(waveAngle) > 110;
                
                if strcmpi(typeCalc, 'probabilistic')
                    qOvertopImpulsive = zeros(size(waveHeight,1),1);
                    qOvertopImpulsiveBroken = zeros(size(waveHeight,1),1);
                    qOvertopImpulsiveZeroFreeboard = zeros(size(waveHeight,1),1);
                    
                    % waveAngle == 0
                    qOvertopImpulsive0 = coefC*10^(-4)*(waveBreakingPar.*freeboard./waveHeight).^(-3.1).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsive(condwaveAngleZero) = qOvertopImpulsive0(condwaveAngleZero);
                    qOvertopImpulsiveBroken0 = coefE*10^(-4).*(waveBreakingPar.*freeboard./waveHeight).^(-2.7).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsiveBroken(condwaveAngleZero) = qOvertopImpulsiveBroken0(condwaveAngleZero);
                    qOvertopImpulsiveZeroFreeboard0 = coefB*sqrt(g*waveHeight.^3);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleZero) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleZero);
                    
                    %waveAngle == 15
                    qOvertopImpulsive15A = 5.8*10^(-5)*(waveBreakingPar.*freeboard./waveHeight).^(-3.7).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsive15B = coefC*10^(-4)*(waveBreakingPar.*freeboard./waveHeight).^(-3.1).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsiveBroken(condwaveAngleFift) = qOvertopImpulsiveBroken0(condwaveAngleFift);
                    testA = waveBreakingPar.*freeboard./waveHeight >= 0.2;
                    testB = waveBreakingPar.*freeboard./waveHeight < 0.2;
                    qOvertopImpulsive(testA & condwaveAngleFift) = qOvertopImpulsive15A(testA & condwaveAngleFift);
                    qOvertopImpulsive(testB & condwaveAngleFift) = qOvertopImpulsive15B(testB & condwaveAngleFift);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleFift) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleFift);
                    
                    %waveAngle == 30
                    qOvertopImpulsive30 = 8*10^(-6)*(waveBreakingPar.*freeboard./waveHeight).^(-4.2).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsiveBroken30 = 8*10^(-6)*(waveBreakingPar.*freeboard./waveHeight).^(-4.2).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsive(condwaveAngleThirt) = qOvertopImpulsive30(condwaveAngleThirt);
                    qOvertopImpulsiveBroken(condwaveAngleThirt) = qOvertopImpulsiveBroken30(condwaveAngleThirt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleThirt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleThirt);
                    
                    %waveAngle >= 60 && waveAngle <=110
                    qOvertopImpulsive60 = 0.04*exp(-coefA*freeboard./(waveHeight.*0.72)).*sqrt(g*waveHeight.^3);
                    qOvertopImpulsive(condwaveAngleSixt) = qOvertopImpulsive60(condwaveAngleSixt);
                    qOvertopImpulsiveBroken(condwaveAngleSixt) = qOvertopImpulsive60(condwaveAngleSixt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleSixt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleSixt);
                    
                    %waveAngle > 0 && waveAngle < 15
                    qImpulsiveA(condwaveAngleZeroFift) = (qOvertopImpulsive15A(condwaveAngleZeroFift)- qOvertopImpulsive0(condwaveAngleZeroFift))/15.*(abs(waveAngle(condwaveAngleZeroFift))-15)+ qOvertopImpulsive15A(condwaveAngleZeroFift);
                    qImpulsiveB(condwaveAngleZeroFift) = qOvertopImpulsive15B(condwaveAngleZeroFift);
                    qOvertopImpulsiveBroken(condwaveAngleZeroFift) = qOvertopImpulsiveBroken0(condwaveAngleZeroFift);
                    qOvertopImpulsive(testA & condwaveAngleZeroFift) = qImpulsiveA(testA & condwaveAngleZeroFift);
                    qOvertopImpulsive(testB & condwaveAngleZeroFift) = qImpulsiveB(testB & condwaveAngleZeroFift);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleZeroFift) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleZeroFift);
                    
                    %waveAngle > 15 && abs(waveAngle) < 30
                    qOvertopImpulsive15 = zeros(size(waveHeight,1),1);
                    qOvertopImpulsive15(testA & condwaveAngleFiftThirt) = qOvertopImpulsive15A(testA & condwaveAngleFiftThirt);
                    qOvertopImpulsive15(testB & condwaveAngleFiftThirt) = qOvertopImpulsive15B(testB & condwaveAngleFiftThirt);
                    qOvertopImpulsive(condwaveAngleFiftThirt) = ((qOvertopImpulsive15(condwaveAngleFiftThirt)-qOvertopImpulsive30(condwaveAngleFiftThirt))/(-15)).*(abs(waveAngle(condwaveAngleFiftThirt))-15)+ qOvertopImpulsive15(condwaveAngleFiftThirt);
                    qOvertopImpulsiveBroken(condwaveAngleFiftThirt) = ((qOvertopImpulsiveBroken0(condwaveAngleFiftThirt)-qOvertopImpulsiveBroken30(condwaveAngleFiftThirt))/-15).*(abs(waveAngle(condwaveAngleFiftThirt))-15)+ qOvertopImpulsiveBroken0(condwaveAngleFiftThirt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleFiftThirt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleFiftThirt);
                    
                    %abs(waveAngle) > 30 && abs(waveAngle) < 60
                    qOvertopImpulsive(condwaveAngleThirtSixt) = ((qOvertopImpulsive30(condwaveAngleThirtSixt)-qOvertopImpulsive60(condwaveAngleThirtSixt))/-30).*(abs(waveAngle(condwaveAngleThirtSixt))-30)+ qOvertopImpulsive30(condwaveAngleThirtSixt);
                    qOvertopImpulsiveBroken(condwaveAngleThirtSixt) = ((qOvertopImpulsiveBroken30(condwaveAngleThirtSixt)-qOvertopImpulsive60(condwaveAngleThirtSixt))/-30).*(abs(waveAngle(condwaveAngleThirtSixt))-30)+ qOvertopImpulsiveBroken30(condwaveAngleThirtSixt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleThirtSixt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleThirtSixt);
                    
                    %waveAngle > 110
                    qOvertopImpulsiveZeros = zeros(size(waveHeight,1),1);
                    qOvertopImpulsiveBrokenZeros = zeros(size(waveHeight,1),1);
                    qOvertopImpulsiveZeroFreeboardZeros = zeros(size(waveHeight,1),1);
                    qOvertopImpulsive(condwaveAngle110) = qOvertopImpulsiveZeros(condwaveAngle110);
                    qOvertopImpulsiveBroken(condwaveAngle110) = qOvertopImpulsiveBrokenZeros(condwaveAngle110);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngle110) = qOvertopImpulsiveZeroFreeboardZeros(condwaveAngle110);
                    
                end
                if strcmpi(typeCalc,'deterministic')
                    qOvertopImpulsive = zeros(size(waveHeight,1),1);
                    qOvertopImpulsiveBroken = zeros(size(waveHeight,1),1);
                    qOvertopImpulsiveZeroFreeboard = zeros(size(waveHeight,1),1);
                    
                    %waveAngle >= 0 && abs(waveAngle) <= 15
                    qOvertopImpulsive0 = coefC*10^(-4)*(waveBreakingPar.*freeboard./waveHeight).^(-3.1).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsive(condwaveAngleZero | condwaveAngleZeroFift) = qOvertopImpulsive0(condwaveAngleZero | condwaveAngleZeroFift);
                    qOvertopImpulsiveBroken0 = coefE*10^(-4).*(waveBreakingPar.*freeboard./waveHeight).^(-2.7).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsiveBroken(condwaveAngleZero | condwaveAngleZeroFift) = qOvertopImpulsiveBroken0(condwaveAngleZero | condwaveAngleZeroFift);
                    qOvertopImpulsiveZeroFreeboard0 = coefB*sqrt(g*waveHeight.^3);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleZero | condwaveAngleZeroFift) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleZero | condwaveAngleZeroFift);
                    
                    %abs(waveAngle) == 30
                    qOvertopImpulsive30A = 5.8*10^(-5)*(waveBreakingPar.*freeboard./waveHeight).^(-3.7).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsive30B = coefC*10^(-4)*(waveBreakingPar.*freeboard./waveHeight).^(-3.1).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    qOvertopImpulsiveBroken30 = coefE*10^(-4).*(waveBreakingPar.*freeboard./waveHeight).^(-2.7).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                    testA = waveBreakingPar.*freeboard./waveHeight >= 0.2;
                    testB = waveBreakingPar.*freeboard./waveHeight < 0.2;
                    qOvertopImpulsive(testA & condwaveAngleThirt) = qOvertopImpulsive30A(testA & condwaveAngleThirt);
                    qOvertopImpulsive(testB & condwaveAngleThirt) = qOvertopImpulsive30B(testB & condwaveAngleThirt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleThirt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleThirt);
                    qOvertopImpulsiveBroken(condwaveAngleThirt) = qOvertopImpulsiveBroken30(condwaveAngleThirt);
                    
                    %abs(waveAngle) > 15 && abs(waveAngle) < 30
                    qOvertopImpulsive30 = zeros(size(waveHeight,1),1);
                    qOvertopImpulsive30(testA & condwaveAngleFiftThirt) = qOvertopImpulsive30A(testA & condwaveAngleFiftThirt);
                    qOvertopImpulsive30(testB & condwaveAngleFiftThirt) = qOvertopImpulsive30B(testB & condwaveAngleFiftThirt);
                    qOvertopImpulsive15 = zeros(size(waveHeight,1),1);
                    qOvertopImpulsive15(condwaveAngleFiftThirt) = qOvertopImpulsive0(condwaveAngleFiftThirt);
                    qOvertopImpulsiveBroken(condwaveAngleFiftThirt) = qOvertopImpulsiveBroken30(condwaveAngleFiftThirt);
                    qOvertopImpulsive(condwaveAngleFiftThirt) = (qOvertopImpulsive15(condwaveAngleFiftThirt)- qOvertopImpulsive30(condwaveAngleFiftThirt))/-15.*(abs(waveAngle(condwaveAngleFiftThirt))-15)+ qOvertopImpulsive15(condwaveAngleFiftThirt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleFiftThirt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleFiftThirt);
                    
                    
                    %abs(waveAngle) > 30 && abs(waveAngle) < 60
                    qOvertopImpulsive30(testA & condwaveAngleThirtSixt) = qOvertopImpulsive30A(testA & condwaveAngleThirtSixt);
                    qOvertopImpulsive30(testB & condwaveAngleThirtSixt) = qOvertopImpulsive30B(testB & condwaveAngleThirtSixt);
                    qOvertopImpulsive60 = 0.04*exp(-coefA*freeboard./(waveHeight.*gammaBeta)).*sqrt(g*waveHeight.^3);
                    qOvertopImpulsiveBroken60 = 0.04*exp(-coefA*freeboard./(waveHeight.*gammaBeta)).*sqrt(g*waveHeight.^3);
                    qOvertopImpulsive(condwaveAngleThirtSixt) = (qOvertopImpulsive30(condwaveAngleThirtSixt)- qOvertopImpulsive60(condwaveAngleThirtSixt))/-30.*(abs(waveAngle(condwaveAngleThirtSixt))-30)+ qOvertopImpulsive30(condwaveAngleThirtSixt);
                    qOvertopImpulsiveBroken(condwaveAngleThirtSixt) = ((qOvertopImpulsiveBroken30(condwaveAngleThirtSixt)- qOvertopImpulsiveBroken60(condwaveAngleThirtSixt))/-30).*(abs(waveAngle(condwaveAngleThirtSixt))-30)+ qOvertopImpulsiveBroken30(condwaveAngleThirtSixt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleThirtSixt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleThirtSixt);
                    
                    
                    %abs(waveAngle) >= 60 && abs(waveAngle) <=110
                    qOvertopImpulsive(condwaveAngleSixt) = qOvertopImpulsive60(condwaveAngleSixt);
                    qOvertopImpulsiveBroken(condwaveAngleSixt) = qOvertopImpulsiveBroken60(condwaveAngleSixt);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngleSixt) = qOvertopImpulsiveZeroFreeboard0(condwaveAngleSixt);
                    
                    %abs(waveAngle) > 110
                    qOvertopZeros = zeros(size(waveHeight,1),1);
                    qOvertopImpulsive(condwaveAngle110) = qOvertopZeros(condwaveAngle110);
                    qOvertopImpulsiveBroken(condwaveAngle110) = qOvertopZeros(condwaveAngle110);
                    qOvertopImpulsiveZeroFreeboard(condwaveAngle110) = qOvertopZeros(condwaveAngle110);
                end
                
                %emerged wall
                qOvertopZeros = zeros(size(waveHeight,1),1);
                qOvertopEmerged(~condwaveAngle110) = 0.043.*sqrt(g*waveHeightDeep(~condwaveAngle110)).*exp(-coefD*foreshoreSlope*s0((~condwaveAngle110)).^0.33.*freeboard((~condwaveAngle110))./waveHeightDeep((~condwaveAngle110)))./sqrt(foreshoreSlope.*s0((~condwaveAngle110)));
                qOvertopEmerged(condwaveAngle110) = qOvertopZeros(condwaveAngle110);
                
                
                %overtopping rate
                qOvertop(nonImpulsive & toeSubmerged) = qOvertopNonImpulsive(nonImpulsive&toeSubmerged);
                qOvertop(impulsive & toeSubmerged) = qOvertopImpulsive(impulsive&toeSubmerged);
                qOvertopBetween = max(qOvertopNonImpulsive,qOvertopImpulsive);
                qOvertop(impulsiveBetween & toeSubmerged) = qOvertopBetween(impulsiveBetween&toeSubmerged);
                qOvertop(zeroFreeboardNonImpulsive & toeSubmerged) = qOvertopNonImpulsiveZeroFreeboard(zeroFreeboardNonImpulsive & toeSubmerged);
                qOvertop(overtopImpulsiveBroken & toeSubmerged & impulsive) = qOvertopImpulsiveBroken(overtopImpulsiveBroken & toeSubmerged & impulsive);
                qOvertop(zeroFreeboardImpulsive & toeSubmerged) = qOvertopImpulsiveZeroFreeboard(zeroFreeboardImpulsive & toeSubmerged);
                qOvertop(~toeSubmerged) = qOvertopEmerged(~toeSubmerged);
                qOvertop(negFreeboard) = qOvertopZeros(negFreeboard);
                
                
                comments = {};
                comments(zeroFreeboardImpulsive & toeSubmerged) = {'No data available for impulsive overtopping at zero freeboard (EurotopManual). Same approach as for non-impulsive waves applied'};
                comments(overtopNonImpulsiveValidation & toeSubmerged & nonImpulsive) = {'Formula is not valid in this case, see EurotopManual formula 7.3'};
                comments(overtopImpulsiveValidation & toeSubmerged & impulsive) = {'Formula is not valid in this case, see EurotopManual formula 7.6'};
                comments(overtopImpulsiveBroken & impulsive) = {'-'};
                comments(overtopEmergedValidation & ~toeSubmerged) = {'Formula is not valid in this case, see EurotopManual formula 7.10'};
                comments(freeboard < 0) = {'No formula available for negative freeboards at a vertical wall (EurotopManual)'};
                
                comments = comments';
                qOvertop = round(qOvertop,4);
                if isempty(qOvertop); qOvertop = NaN(1,size(time,1)); end
                overtoppingRate = [freeboard waveBreakingPar qOvertop];
                
            end
            %----------------------------------------------------------------------
            %case of battered vertical walls
            if strcmpi(typeStruct,'battered vertical')
                waveBreakingPar = 1.35*waterdepthToe.^2*2*pi./(waveHeight*g.*wavePeriod.^2);
                nonImpulsive = waveBreakingPar > 0.3 & freeboard > 0;
                impulsive = waveBreakingPar < 0.2 & freeboard > 0;
                zeroFreeboard = freeboard == 0;
                negFreeboard = freeboard < 0;
                slopeWall = charcStruct{3,1}(1,2);
                slopeValidation1 = slopeWall == 10;
                slopeValidation1 = repmat(slopeValidation1,[size(freeboard,1),1]);
                slopeValidation2 = slopeWall == 5;
                slopeValidation2 = repmat(slopeValidation2,[size(freeboard,1),1]);
                overtopImpulsiveValidation = waveBreakingPar.*freeboard./waveHeight <= 0.03 | waveBreakingPar.*freeboard./waveHeight >= 1;
                
                condwaveAngle110 = abs(waveAngle) <= 110;
                
                if strcmpi(typeCalc, 'probabilistic')
                    coefB = 0.062;
                    coefC = 1.5;
                end
                if strcmpi(typeCalc,'deterministic')
                    coefC = 2.8;
                    coefB = 0.062+0.0062;
                end
                
                %overtopping rate
                qOvertopImpulsive = coefC*10^(-4)*(waveBreakingPar.*freeboard./waveHeight).^(-3.1).*waveBreakingPar.^2.*sqrt(g*waterLevel.^3);
                qOvertopImpulsiveBattered1 = qOvertopImpulsive*1.3;
                qOvertopImpulsiveBattered2 = qOvertopImpulsive*1.9;
                qOvertopImpulsiveZeroFreeboard = coefB*sqrt(g*waveHeight.^3);
                
                qOvertop(slopeValidation1&impulsive&nonImpulsive) = qOvertopImpulsiveBattered1(slopeValidation1&impulsive&nonImpulsive);
                qOvertop(slopeValidation2&impulsive&nonImpulsive) = qOvertopImpulsiveBattered2(slopeValidation2&impulsive&nonImpulsive);
                qOvertop(zeroFreeboard) = qOvertopImpulsiveZeroFreeboard(zeroFreeboard);
                qOvertopZeros = zeros(1,size(waveHeight,1));
                qOvertop(negFreeboard) = qOvertopZeros(negFreeboard);
                qOvertop(~condwaveAngle110) = qOvertopZeros(~condwaveAngle110);
                
                qOvertop = round(qOvertop,4);
                overtoppingRate = [freeboard waveBreakingPar qOvertop];
                
                comments(overtopImpulsiveValidation&impulsive) = {'Formula is not valid in this case, see EurotopManual formula 7.6'};
                comments(nonImpulsive) = {'No dataset is available to indicate an appropriate adjustment under non-impulsive conditions. The same formula as for impulsive waves is applied.'};
                comments(~slopeValidation1 | ~slopeValidation2) = {'Formula 7.12 (EurotopManual) only valid for 10:1 or 5:1 battered wall'};
                comments(zeroFreeboard) = {'No specific formula is available for zero freeboard (battered walls), the same approach as for plain vertical walls is followed'};
                
                comments = comments';
            end
            %----------------------------------------------------------------------
            %case of composite vertical walls
            if strcmpi(typeStruct,'composite vertical')
                %wave breaking parameter
                depthBerm = repmat(charcStruct{3,1}(1,1),[size(waterLevel,1),1]);
                waterdepthBerm = abs(depthBerm - waterLevel);
                waveBreakingParImpulsive = 1.35*waterdepthBerm.*2*pi*waterdepthToe./(waveHeight*g.*wavePeriod.^2);
                waveBreakingParNonImpulsive = 1.35*waterdepthToe.^2*2*pi./(waveHeight*g.*wavePeriod.^2);
                nonImpulsive = waveBreakingParNonImpulsive > 0.3 & freeboard >0;
                impulsive = waveBreakingParNonImpulsive < 0.3 & freeboard >0;
                zeroFreeboard = freeboard == 0;
                negFreeboard = freeboard < 0;
                overtopNonImpulsiveValidation = freeboard./waveHeight < 0.1 | freeboard./waveHeight > 3.5;
                overtopImpulsiveValidation = waveBreakingParImpulsive.*freeboard./waveHeight < 0.05 | waveBreakingParImpulsive.*freeboard./waveHeight > 1;
                
                if strcmpi(typeCalc, 'probabilistic')
                    coefA = 2.6;
                    coefB = 4.1;
                    coefC = 2.9;
                    coefD = 0.062;
                end
                if strcmpi(typeCalc,'deterministic')
                    coefA = 1.8;
                    coefB = 7.8;
                    coefC = 2.6;
                    coefD = 0.062+0.0062;
                end
                
                %overtopping non-impulsive
                qOvertopNonImpulsive = 0.04*exp(-coefA*freeboard./waveHeight).*sqrt(g*waveHeight.^3);
                
                %overtopping impulsive
                qOvertopImpulsive = coefB*10^(-4)*(waveBreakingParImpulsive.*freeboard./waveHeight)^(-coefC).*(waveBreakingParImpulsive.^2.*sqrt(g*waterLevel.^3));
                
                %zero freeboard
                qOvertopZeroFreeboard = coefD*sqrt(g*waveHeight.^3);
                
                %overtopping rate
                qOvertop(nonImpulsive) = qOvertopNonImpulsive(nonImpulsive);
                qOvertop(impulsive) = qOvertopImpulsive(impulsive);
                qOvertop(zeroFreeboard) = qOvertopZeroFreeboard(zeroFreeboard);
                waveBreakingPar(nonImpulsive) = waveBreakingParNonImpulsive(nonImpulsive);
                waveBreakingPar(impulsive) = waveBreakingParImpulsive(impulsive);
                waveBreakingPar = waveBreakingPar';
                
                qOvertopZeros = zeros(1,size(waveHeight,1));
                qOvertop(negFreeboard) = qOvertopZeros(negFreeboard);
                qOvertop(abs(waveAngle) > 110) = qOvertopZeros(abs(waveAngle) > 110);
                
                qOvertop = round(qOvertop,4);
                overtoppingRate = [freeboard waveBreakingPar qOvertop'];
                
                comments(freeboard < 0) = {'No formula available for a freeboard smaller than 0'};
                comments(zeroFreeboard) = {'For zero freeboard the same formula as for plain vertical walls is assumed as in the EurotopManual no specific formula is available'};
                comments(overtopNonImpulsiveValidation & nonImpulsive) = {'Formula is not valid in this case, see EurotopManual formula 7.3'};
                comments(impulsive & overtopImpulsiveValidation) = {'Formula is not valid in this case, see EurotopManual formula 7.13'};
                
                comments = comments';
            end
            
            % strHeadings = {'time [min]','waterlevel [mTAW]','Hm0 [m]','Tm-1,0 [s]','Rc [m]', 'h* [-]','q [m³/s/m]','comments'};
            if isempty(qOvertop);
                qOvertop = NaN(1,size(time,1));
            end
            cellResults = [time, waterLevel, waveHeight, wavePeriod, freeboard, waveBreakingPar, qOvertop];
        end
    end
end