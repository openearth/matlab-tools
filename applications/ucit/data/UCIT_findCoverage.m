function batchvar = UCIT_findCoverage(OPT)

% UCIT_FINDCOVERAGE  This script computes grid data coverage
%
%
%   Syntax:     batchvar    =   findCoverage(datatype, ref_cov, timewindow)
%
%   Input:      datatype    =   type of data
%               ref_cov     =   minimal coverage treshold for a year to be used in the budget computation
%               timewindow  =   number of months to look back for additional data
%
%   Output:     batchvar    =   a list of years to be used for the budget
%                               conmputation
%               coverage    =   the coverage per year is stored in the
%                               coverage directory
%
%   See also UCIT_getSandbalance, UCIT_findCoverage, UCIT_batchViewResults
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

warningstate = warning;
warning off

if ~isfield(OPT, 'datatype')
    OPT.datatype = UCIT_getInfoFromPopup('GridsDatatype');
end

%% if polygon exists within OPT save it as ldb
if isfield(OPT,'polygon');
    mkdir(['polygons']);
    polygon = OPT.polygon;
    fid = fopen(['polygons\Polygon.ldb'],'w');
    fprintf(fid,'%s\n',['polygon']);
    fprintf(fid,'%3.0f %3.0f \n',[size(polygon,1) size(polygon,2)]);
    fprintf(fid,'%8.2f %8.2f \n',[polygon]');
    fclose(fid);
end

%% load all polygons from the polygon directory (mat and ldb)
fns = dir(['polygons' filesep '*.*']);
fns(find(strcmp({fns.name},'.')|strcmp({fns.name},'..')))= [];

%% compute coverage based on batch structure (batchvar)
if ~isempty(fns)
    for r = 1:length(fns)
        batchvar1(r,:) = {1,OPT.thinning, fns(r,1).name(1:end-4)     , 'b', 1, [] };
    end
    
    for i = 1:size(batchvar1,1)
        if batchvar1{i,1}==1
            
            % load polygon i
            if strcmp(fns(i,1).name(end-2:end),'ldb')
                polygon = landboundary('read',['polygons',filesep fns(i,1).name]);
            elseif strcmp(fns(i,1).name(end-2:end),'mat')
                load(['polygons',filesep fns(i,1).name]);
            else
                error('Please specify polygons as ldbfile or matfile')
            end
            
            if ~exist([ 'coverage' filesep 'timewindow = ' num2str(OPT.timewindow) filesep fns(i,1).name(1:end-4) '_coverage.dat'])
                
                for j = 1:length(OPT.inputyears)
                    
                    if exist(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep fns(i,1).name '_' num2str(OPT.inputyears(j)) '_1231.mat'])
                        load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep fns(i,1).name '_' num2str(OPT.inputyears(j)) '_1231.mat']);
                    else
                        
                        % get data of selected year
                        [X, Y, Z, Ztime] = grid_orth_getDataInPolygon(...
                            'dataset'       , OPT.catalog, ...
                            'urls'          , OPT.urls, ...
                            'x_ranges'      , OPT.x_ranges, ...
                            'y_ranges'      , OPT.y_ranges, ...
                            'tag'           , OPT.datatype, ...
                            'starttime'     , datenum(OPT.inputyears(j),12,31), ...
                            'searchinterval', -365/12*OPT.timewindow, ...
                            'datathinning'  , OPT.thinning,...
                            'cellsize'      , OPT.cellsize,...
                            'plotresult'    ,0, ...
                            'polygon'       ,polygon);
                        in = inpolygon(X, Y, polygon(:,1), polygon(:,2));
                        d.name       = fns(i,1).name(1:end-4);
                        d.year       = OPT.inputyears(j);
                        d.soundingID = '1231';
                        d.X          = X;
                        d.Y          = Y;
                        d.Z          = Z;
                        d.Ztemps     = Ztime;
                        d.inpolygon   = in;
                        
                        save(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep d.name '_' num2str(d.year) '_1231.mat'],'d');
                    end
                    
                    %% compute coverage
                    total = sum(sum(d.inpolygon));
                    cov(j).year  = sum(sum((~isnan(d.Z))))/total; % coverage per jaar voor polygoon j
                    results(j,:)=([OPT.inputyears(j) cov(j).year]);
                end
                
                %% save to text file
                fid = fopen([ 'coverage' filesep 'timewindow = ' num2str(OPT.timewindow) filesep num2str(d.name) '_coverage.dat'],'w');
                fprintf(fid,'%s\n',['Year      Coverage']);
                fprintf(fid,'%5.0f %9.2f\n',[results]');
                fclose(fid);
                
            else
                [results(:,1),results(:,2)] = textread(['coverage' filesep 'timewindow = ' num2str(OPT.timewindow) filesep num2str(fns(i,1).name(1:end-4)) '_coverage.dat'],'%f%f','headerlines',1);
            end
            
            %% normalise coverage to 100%
            maxCov                      = max(results(:,2));
            covfactor                   = 100/maxCov(1);
            results(:,2)                = results(:,2).*covfactor;
            
            %% generate best years
            r1 = find(results(:,2) >= OPT.min_coverage);
            years1 = results(r1,1); yt=[years1']; yearstemp=unique(yt);
            
            if ~isempty(yearstemp)
                clear r2; clear r3
                for q=1:size(yearstemp,2)
                    r2(q)=find(yearstemp(q)==results(:,1));
                    r3(q)=results(r2(q),2);
                end
                
                w2=find(max(r3)==results(:,2),1,'first');
                bestyear1=results(w2,1);
                
                % convert date to 1231 format
                bestyear(i,:)=([bestyear1].*10000+1231); yearstemp=[yearstemp.*10000+1231];
                yearsofgoodcov(i,1)={unique(yearstemp)}; % dit moet cell array zijn, anders omdat bij elke i een andere grootte: Subscripted assignment dimension mismatch
                
                % create batchvar
                lines1(i,:)={[num2str(fns(i,1).name(1:end-4)),' - minimal data coverage ', num2str(OPT.min_coverage),'%: ',num2str(yearsofgoodcov{i,1}(1,:)),'; Best coverage year = ',num2str(bestyear(i,1))]};
                batchvar(i,:)={1, OPT.thinning, fns(i,1).name(1:end-4) , 'g', 1, [yearsofgoodcov{i,1}(1,:)], [find(yearsofgoodcov{i,1}(1,:)==bestyear(i,1))]};
                
            else
                disp([fns(i,1).name(1:end-4), ' - No years founding matching coverage criteria']);
                batchvar = [];
            end
            clear results;
        end
    end
end

warning(warningstate)

%% EOF
