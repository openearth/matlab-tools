function [VSNEW,ErrMsg]=vs_pack(varargin)
%VS_PACK removes inaccessible/unused space from a NEFIS file
%        by creating a copy of the original file and transfering
%        all data.
%
%        NewNFStruct=VS_PACK(NFStruct,'NewFileName',...options...)
%        NewNFStruct=VS_PACK(NFStruct,{'NewDatFile','NewDefFile'},...
%
%        Possible options are:
%           * 'GroupName',GroupIndex,{ElementList}
%             keep the data of the specified group. But only the
%             specified indices and elements are transferred to the
%             new file. The GroupIndex and Element list are optional.
%             Default all indices and elements are transferred.
%             The GroupIndex should be specified in the same way
%             as it is used in the vs_let/vs_get commands: for each
%             group dimension indices specified, combined within
%             braces. For instance {1:3:20} for a group with one
%             dimension or {[1 2 6] 2:4} for a group with two
%             dimensions.
%           * 'GroupName',[]
%             remove the group from the file
%           * '*',[]
%             remove all groups from the file
%        Options are processed in the specified order. That is,
%             ...,'*',[],'GroupX')
%        will create a new file containing only the data from GroupX.

% (c) Copyright 1997-2000, H.R.A.Jagers, Delft Hydraulics, The Netherlands

vs_debug=1;
ErrMsg='';
INP=varargin;
quiet=1;
if (length(INP)>0) & isequal(INP{end},'quiet')
   quiet=0;
   INP(end)=[];
end
VS=[];
for i=1:length(INP)
   if isstruct(INP{i})
      VS=INP{i};
      INP(i)=[];
      break
   end
end
if ~isstruct(VS)
   VS=vs_use('lastread');
end

if ~isstruct(VS)
   ErrMsg='No NEFIS file specified.';
   return
elseif length(INP)<1
   ErrMsg='Missing output filename(s).';
else
   NewFile=INP{1};
   allgrp={VS.GrpDat.Name};
   gName=allgrp;
   for i=1:length(VS.GrpDat)
      for k=1:length(VS.GrpDat(i).SizeDim)
         gIndex{i}{k}=1:VS.GrpDat(i).SizeDim(k);
      end
      gElms{i}=vs_disp(VS,gName{i});
   end
   Opt=2;
   lINP=length(INP);
   while Opt<=lINP
      grp=INP{Opt};
      if ~ischar(grp) | size(grp,1)~=1 | ndims(grp)>2
         ErrMsg='Invalid group name.';
         break
      end
      if strcmp(grp,'*')
         if Opt<lINP
            grpopt=INP{Opt+1};
         end
         if isempty(grpopt) & isnumeric(grpopt) % []
            gName={};
            gIndex={};
            gElms={};
            Opt=Opt+2;
         else
            ErrMsg='The all groups indicator ''*'' can only be combined with the removal indicator [].';
            break
         end
      else
         ig=strmatch(grp,allgrp,'exact');
         igi=strmatch(grp,gName,'exact');
         if isempty(ig)
            ErrMsg=sprintf('Group ''%s'' not found.',grp);
            break
         end
         if Opt<lINP
            grpopt=INP{Opt+1};
         else
            grpopt='';
         end
         if isempty(grpopt) & isnumeric(grpopt) % []
            gName(igi)=[];
            gIndex(igi)=[];
            gElms(igi)=[];
            Opt=Opt+2;
         elseif iscell(grpopt) % indices and/or elements
            if Opt+1<lINP
               grpopt2=INP{Opt+2};
            else
               grpopt2='';
            end
            if iscell(grpopt2) % indices and elements
               if iscellstr(grpopt)
                  dummy=grpopt2;
                  grpopt2=grpopt;
                  grpopt=dummy;
               end
               if ~isequal(size(grpopt),[1 length(VS.GrpDat(ig).SizeDim)])
                  ErrMsg=sprintf('Invalid indices for group ''%s''.',grp);
                  break
               else
                  for k=1:length(VS.GrpDat(ig).SizeDim)
                     if isequal(grpopt{k},0)
                        grpopt{k}=1:VS.GrpDat(ig).SizeDim(k);
                     elseif isempty(grpopt{k})
                        ErrMsg=sprintf('Index %i for group ''%s'' should not be empty.',k,grp);
                        break
                     else
                        grpopt{k}=unique(grpopt{k}(:));
                        if ~all(round(grpopt{k})==grpopt{k}) | grpopt{k}(end)>VS.GrpDat(ig).SizeDim(k) | grpopt{k}<1
                           ErrMsg=sprintf('Invalid index %i for group ''%s''.',k,grp);
                           break
                        end
                     end
                  end
               end
               Elms=vs_disp(VS,grp);
               eDiff=setdiff(grpopt2,Elms);
               if ~isempty(eDiff)
                  ErrMsg=sprintf('Group ''%s'' does not contain element ''%s''.',grp,eDiff{1});
                  break
               end
               if isempty(igi)
                  igi=length(gName)+1;
                  gName{igi}=grp;
               end
               gIndex{igi}=grpopt;
               gElms{igi}=unique(grpopt2);
               Opt=Opt+3;
            elseif iscellstr(grpopt) % elements
               Elms=vs_disp(VS,grp);
               eDiff=setdiff(grpopt,Elms);
               if ~isempty(eDiff)
                  ErrMsg=sprintf('Group ''%s'' does not contain element ''%s''.',grp,eDiff{1});
                  break
               end
               if isempty(igi)
                  igi=length(gName)+1;
                  gName{igi}=grp;
               end
               for k=1:length(VS.GrpDat(ig).SizeDim)
                  gIndex{igi}{k}=1:VS.GrpDat(ig).SizeDim(k);
               end
               gElms{igi}=unique(grpopt);
               Opt=Opt+2;
            else % indices
               if ~isequal(size(grpopt),[1 length(VS.GrpDat(ig).SizeDim)])
                  ErrMsg=sprintf('Invalid indices for group ''%s''.',grp);
                  break
               else
                  for k=1:length(VS.GrpDat(ig).SizeDim)
                     if isequal(grpopt{k},0)
                        grpopt{k}=1:VS.GrpDat(ig).SizeDim(k);
                     elseif isempty(grpopt{k})
                        ErrMsg=sprintf('Index %i for group ''%s'' should not be empty.',k,grp);
                        break
                     else
                        grpopt{k}=unique(grpopt{k}(:));
                        if ~all(round(grpopt{k})==grpopt{k}) | grpopt{k}(end)>VS.GrpDat(ig).SizeDim(k) | grpopt{k}<1
                           ErrMsg=sprintf('Invalid index %i for group ''%s''.',k,grp);
                           break
                        end
                     end
                  end
               end
               if isempty(igi)
                  igi=length(gName)+1;
                  gName{igi}=grp;
               end
               gIndex{igi}=grpopt;
               gElms{igi}=vs_disp(VS,gName{igi});
               Opt=Opt+2;
            end
         else % no opt -> include complete group
            if isempty(igi)
               igi=length(gName)+1;
               gName{igi}=grp;
            end
            for k=1:length(VS.GrpDat(ig).SizeDim)
               gIndex{igi}{k}=1:VS.GrpDat(ig).SizeDim(k);
            end
            gElms{igi}=vs_disp(VS,gName{igi});
            Opt=Opt+1;
         end
      end
   end
   while isempty(ErrMsg),
      % create new file
      if ischar(NewFile)
         if vs_debug
            fprintf(vs_debug,'Creating the new file:\n  %s\n',NewFile);
         end
         VSn=vs_ini(NewFile);
      else
         if vs_debug
            fprintf(vs_debug,'Creating the new files:\n  %s\n  %s\n',NewFile{:});
         end
         VSn=vs_ini(NewFile{:});
      end
      % define all elements
      allelm=unique([gElms{:}]);
      [dummy,dummy2,ie]=intersect(allelm,{VS.ElmDef.Name});
      for i=ie
         if vs_debug
            fprintf(vs_debug,'Creating element: %s\n',VS.ElmDef(i).Name);
         end
         [VSn,ErrMsg]=vs_def(VSn,'elm',VS.ElmDef(i).Name,VS.ElmDef(i).Type,VS.ElmDef(i).SizeVal, ...
            VS.ElmDef(i).Size,VS.ElmDef(i).Quantity,VS.ElmDef(i).Units,VS.ElmDef(i).Description);
         if ~isempty(ErrMsg)
            break
         end
      end
      if ~isempty(ErrMsg)
         break
      end
      % define all groups
      [dummy,dummy2,ig]=intersect(gName,allgrp);
      for i=1:length(ig)
         i0=strmatch(VS.GrpDat(ig(i)).Name,gName,'exact');
         if vs_debug
            fprintf(vs_debug,'Creating group: %s\n',gName{i0});
         end
         % cell names and group names not copied,
         % because doing so could result in a confliction with
         % different element selections in the various groups
         % (different data groups, same cells, but different elements
         % to keep) or with different dimensional restrictions.
         id=VS.GrpDat(ig(i)).DefIndex;
         ic=VS.GrpDef(id).CelIndex;
         Sz=zeros(1,length(gIndex{i0}));
         for k=1:length(gIndex{i0})
            if k~=VS.GrpDat(ig(i)).VarDim
               Sz(k)=length(gIndex{i0}{k});
            end
         end
         % attribute data is not yet copied
         [VSn,ErrMsg]=vs_def(VSn,'data',gName{i0},gElms{i0},Sz,VS.GrpDef(id).OrderDim);
         if ~isempty(ErrMsg)
            break
         end
      end
      if ~isempty(ErrMsg)
         break
      end
      % now transfer the data
      for i=1:length(ig)
         i0=strmatch(VS.GrpDat(ig(i)).Name,gName,'exact');
         if vs_debug
            fprintf(vs_debug,'Transfering data of group: %s.\n',gName{i0});
         end
         Idx={};
         Idx(1:length(gIndex{i0}))={0};
         VD=VS.GrpDat(ig(i)).VarDim;
         if VD
            VDIdx=gIndex{i0}{VD};
            gIndex{i0}{VD}=1;
         end
         for e=1:length(gElms{i0})
            eName=gElms{i0}{e};
            if vs_debug
               stp=0;
               fprintf(vs_debug,'                  element: %s',eName);
            end
            eIndex={};
            Info=vs_disp(VS,gName{i0},eName);
            for k=1:length(Info.SizeDim)
               eIndex{k}=1:Info.SizeDim(k);
            end
            if VD
               for k=1:length(VDIdx)
                  if vs_debug
                     if stp==0 | stp==50
                        fprintf(vs_debug,'\n            %4i of %4i : .',k,length(VDIdx));
                        stp=1;
                     else
                        fprintf(vs_debug,'.');
                        stp=stp+1;
                     end
                  end
                  Idx{VS.GrpDat(ig(i)).VarDim}=VDIdx(k);
                  [Data,Chk]=vs_let(VS,gName{i0},Idx,eName,'quiet','nowarn');
                  Data=Data(gIndex{i0}{:},eIndex{:},:);
                  Idx{VS.GrpDat(ig(i)).VarDim}=k;
                  [VSn,ErrMsg]=vs_put(VSn,gName{i0},Idx,eName,Data);
                  if ~isempty(ErrMsg)
                     break
                  end
               end
            else
               [Data,Chk]=vs_let(VS,gName{i0},eName,'quiet','nowarn');
               Data=Data(gIndex{i0}{:},eIndex{:},:);
               [VSn,ErrMsg]=vs_put(VSn,gName{i0},eName,Data);
            end
            if vs_debug
               fprintf(vs_debug,'\n');
            end
            if ~isempty(ErrMsg)
               break
            end
         end
         if ~isempty(ErrMsg)
            break
         end
      end
      break
   end
end

if ~isempty(ErrMsg) & nargout<2
   error(ErrMsg)
end
% if the default lastread structure was used update the lastread structure
if nargout>0
   VSNEW=VSn;
end
vs_use(VSn)