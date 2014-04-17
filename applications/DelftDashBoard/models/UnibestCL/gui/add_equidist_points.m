function outLDB=add_equidist_points(dx,ldb)
%=Overview=================================================================
%
% add_equidist_points - cuts up ldb's in dx sections (only finer, not coarser)
%
% Syntax:
%
% ldb_out=add_equidist_points            <-- 2 dialog prompts triggered (ldb & dx)
% ldb_out=add_equidist_points(dx)        <-- 1 dialog prompt triggered (ldb)
% ldb_out=add_equidist_points(dx,ldb_in) <-- scripting (no dialogs)
%
%=Scematic overview of functionality=======================================
%
% X = original ldb points
% # = new points in between ldb points (X's) using dx
%
%(1)(start)            (2)                                    (3)
% :                     :                                      :
% X_____________________X______________________________________X
%                                                               \        
%                                                                \       
%                                                                 \      
%                                                                  \     
%                                                                   \    
%                                                                    \   
%                                                                     \  
%                                                                      \ 
%         RETURNS:                                                      \
%                                                                        X
%                                                                        :
%(1)(start)            (2)                                    (3)       (4)
% :          1a         :          2a         2b         2c    :        end                                        
% X__________#__________X__________#__________#__________#_____X
%                                   <-- dx -->              ^   \
%                                                           :    \
%                                                           :     \ dx
%                                                           :      \
%                                                           :       \
%                                                           :        #
%                                                           :         \
% !Note that 'remainder' parts may be smaller than dx! <....:.........>\
%                                                                       \
%                                                                        X
%                                                                        :
%                                                                       (4)
%                                                                       end
%
%==========================================================================
% see also: landboundary ldbTool tekal disassembleLdb rebuildLdb

%
% Small additions 2014 (UI, endpoints check, help): Freek Scheel
% freek.scheel@deltares.nl
%
outLDB=[];

if nargin<2 
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    ldb=landboundary('read');
    if isempty(ldb)
        disp('No ldb chosen, aborting...');
        return
    end
end

if nargin==0
    dx_t = inputdlg('Specify a value for dx','dx?',1,{'1'});
    if isempty(dx_t)
        disp('No dx chosen, aborting...');
        return
    end
    dx = str2num(char(dx_t));
    if isempty(dx)
        error('Please specify a numeric number for dx');
    end
end

if isempty(ldb)
    return
end

if ~isstruct(ldb)
    [ldbCell, ldbBegin, ldbEnd, ldbIn]=disassembleLdb(ldb);
else
    ldbCell=ldb.ldbCell;
    ldbBegin=ldb.ldbBegin;
    ldbEnd=ldb.ldbEnd;
end


for cc=1:length(ldbCell)
    in=ldbCell{cc};
    out=[];
    for ii=1:size(in,1)-1
        %Determine distance between two points 
        dist=sqrt((in(ii+1,1)-in(ii,1)).^2 + (in(ii+1,2)-in(ii,2)).^2);
        
        ox=interp1([0 dist],in(ii:ii+1,1),0:dx:dist)';
        oy=interp1([0 dist],in(ii:ii+1,2),0:dx:dist)';

        out=[out ; [ox oy]];
    end
    outCell{cc}=out;
    if (outCell{cc}(end,1) ~= ldbEnd(cc,1)) | (outCell{cc}(end,2) ~= ldbEnd(cc,2))
        outCell{cc}(end+1,1:2) = ldbEnd(cc,:);
    end
end

if ~isstruct(ldb)
    outLDB=rebuildLdb(outCell);
else
    outLDB.ldbCell=outCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end