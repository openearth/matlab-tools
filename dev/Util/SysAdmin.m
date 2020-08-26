%Class with routines for systemadmionistration
%
% @author ABR
% @version
%

classdef SysAdmin < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
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
    
    %Stactic methods
    methods (Static)
        function plotUsageK(aProject,theDir)
            %
            if nargin ==0
                aProject = 'all';
            end
            
            
            if nargin <2
                theDir = '\\imdc-file.IMDC.LOCAL\K-AN\PROJECTS\00\00085\07-UITV\projectsize';
            end
            
            % open all files
            allFiles = dir([theDir,'\*.csv']);
            nrFiles  = length(allFiles);
            % preallocate
            t         = zeros(nrFiles,1);
            projectNrArray = 11000:19999;
            nrProjects = length(projectNrArray);
            allProjectSize = zeros(nrProjects,nrFiles);
            
            
            
            
            for i=1:nrFiles
                % read csvs
                theFile    = fullfile(theDir,allFiles(i).name);
                theDateStr = regexp(allFiles(i).name,'\d*','match');
                theDate    = datenum(theDateStr{1},'yyyymmdd');
                t(i) = theDate;
                % read the file
                fid = fopen(theFile);
                cellData = textscan(fid,'%s','headerlines',1,'delimiter','');
                fclose(fid);
                cellData = cellData{1};
                % process the data

                % this should work with folders with a comma in the
                % directory name
                %new dataformat since 30-8-2015
                nrCell = length(cellData);
                if theDate>=datenum([2015 08 27 0 0 0])
                    %process all lines
                    for iCell=1:nrCell
                        % split data
                        theStr = cellData{iCell};
                        if length(theStr)>=7
                            sep = strfind(theStr,',');
                            sep = sep(end);
                            % get size and projectnr
                            mapSize = str2double(theStr(sep+1:end));
                            projNum = str2double(theStr(1:5));
                            % add data
                            if ~isnan(projNum)
                                ind = projNum-projectNrArray(1)+1;
                                allProjectSize(ind,i) = allProjectSize(ind,i) + mapSize;
                            end
                        end
                    end
                else
                    % old formatr with interschanged columns
                    for iCell=1:nrCell
                        % split data
                        theStr = cellData{iCell};
                        sep = strfind(theStr,',');
                        sep = sep(1);
                        % get size and projectnr
                        mapSize = str2double(theStr(1:sep-1));
                        projNum = str2double(theStr(sep+1:sep+5));
                        % add data
                        if ~isnan(projNum)       
                            ind = projNum-projectNrArray(1)+1;
                            allProjectSize(ind,i) = allProjectSize(ind,i) + mapSize;                            
                        end
                    end
                    
                end
                
            end
            % convert from mB to GB
            allProjectSize = allProjectSize/1024;
            
            %delete empty data
            mask = all(allProjectSize<=1,2);
            projectNrArray(mask)   = [];
            allProjectSize(mask,:) = [];
            totalSize = sum(allProjectSize,1)/1024;
            % sort projects by size
            [~,ind] = sort(allProjectSize(:,end),1,'descend');
            % plot
            figure;
            % total size
            plot(t,totalSize,'-ok','linewidth',2);
            hold on
            grid on;
            sctIn.start = min(t);
            sctIn.end  = max(t);
            sctIn.interval = 3;
            timeStamp = Time.timeStampMonth(sctIn);
            xlim(timeStamp([1 end]))
            set(gca,'xtick',timeStamp)
            set(gca,'xticklabel',datestr(timeStamp','mmm-yy'))
            xlabel('time')
            ylabel('size [TB]')            
            
            figure
            % plot largest projects
            plot(t,allProjectSize(ind(1:5),:),'-')
            
            grid on;
            legend(num2str(projectNrArray(ind(1:5))'));
            datetick('x')
            xlim(timeStamp([1 end]))
            set(gca,'xtick',timeStamp)
            set(gca,'xticklabel',datestr(timeStamp','mmm-yy'))
            xlabel('time')
            ylabel('size [GB]')
            
            %plot specific projects
            if iscell(aProject)
                figure;
                hold on
                for i=1:length(aProject)
                    ind = projectNrArray==str2double(aProject{i});
                    plot(t,allProjectSize(ind,:));
                    cLeg{i} = num2str(projectNrArray(ind));
                end
                grid on;
                legend(cLeg);
                datetick('x')
                xlabel('time')
                ylabel('size [GB]')
                xlim(timeStamp([1 end]))
                set(gca,'xtick',timeStamp)
                set(gca,'xticklabel',datestr(timeStamp','mmm-yy'))
            end
        end
    end
end