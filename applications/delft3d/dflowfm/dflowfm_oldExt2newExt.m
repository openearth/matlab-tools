function dflowfm_oldExt2newExt(oldExtFile,varargin)
%% dflowfm_oldExt2newExt(oldExtFile,varargin)
%
% Based on a old-formatted .ext file, the boundary conditions of the
% Delft3D-FM model are converted to the new boundary condition format
% old: .tim , .cmp
% new: .bc
%
% Example:  dflowfm_oldExt2newExt('D:\model\externalforcing.ext')
%
% May2018	Julien Groenenboom      Only works for 'waterlevelbnd' and '.cmp'

OPT.outputDir=[fileparts(oldExtFile) filesep 'dflowfm_oldExt2newExt_OUTPUT'];

%% OPT
if nargin>1
    OPT = setproperty(OPT,varargin);
end

if ~exist(OPT.outputDir); mkdir(OPT.outputDir); end
%% convert old ext file to new ext file
oldExt=dflowfm_io_extfile('read',oldExtFile);

for iE=1:length(oldExt)
    if ~ismember(oldExt(iE).quantity,{'waterlevelbnd'})
    disp(['Quantity ''' oldExt(iE).quantity ''' is not yet implemented in this conversion'])
    end
    switch oldExt(iE).quantity
        case 'waterlevelbnd'
            % pli file
            pliFile=EHY_getFullWinPath(oldExt(iE).filename);
            copyfile(pliFile,OPT.outputDir);
            
            WlBcFile=[OPT.outputDir filesep 'WaterLevel.bc'];
            fidWlBc=fopen(WlBcFile,'a'); % create new or open existing
            
            [pathstr,name,ext]=fileparts(pliFile);
            pli=dflowfm_io_xydata('read',pliFile);
            if exist([pathstr filesep name '_0001.cmp']) % astro components
                for iP=1:size(pli.DATA,1)
                    % read cmp file
                    cmpFile=[pathstr filesep name '_' sprintf('%04d',iP) '.cmp'];
                    fidCmp=fopen(cmpFile,'r');
                    cmp=textscan(fidCmp,'%s%s%s');
                    cmp=[cmp{:}];
                    cmp(find(~cellfun(@isempty,strfind(cmp(:,1),'*'))),:)=[]; % delete header/commented lines
                    
                    % write cmp data to bc file
                    fprintf(fidWlBc,'[forcing]\n');
                    fprintf(fidWlBc,'Name                            = %s_%04d\n',name,iP);
                    fprintf(fidWlBc,'Function                        = astronomic\n');
                    fprintf(fidWlBc,'Quantity                        = astronomic component\n');
                    fprintf(fidWlBc,'Unit                            = -\n');
                    fprintf(fidWlBc,'Quantity                        = waterlevelbnd amplitude\n');
                    fprintf(fidWlBc,'Unit                            = m\n');
                    fprintf(fidWlBc,'Quantity                        = waterlevelbnd phase\n');
                    fprintf(fidWlBc,'Unit                            = deg\n');
                    for iC = 1:size(cmp,1)
                        fprintf(fidWlBc,'%-9s',cmp{iC,1});
                        fprintf(fidWlBc,'%20s  %20s\n',cmp{iC,2},cmp{iC,3});
                    end
                    fprintf(fidWlBc,'\n');
                    fclose(fidCmp);
                end
            elseif exist([pathstr filesep name '_0001.tim']) % time series
                % to be implemented
            end
            fclose(fidWlBc);
    end
end
