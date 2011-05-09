function [VSNEW,ErrMsg]=vs_copy(varargin)
%VS_COPY copies data from one NEFIS file to another
%        NewNFS2=VS_COPY(NFS1,NFS2,...options...)
%        NFS1 and NFS2 Nefis file structures as obtained initially from
%        VS_USE or VS_INI. NewNFS2 equals NFS2, but is updated with
%        information on the newly written data fields.
%
%        Possible options are:
%           * 'GroupName',GroupIndex,{ElementList}
%             copy the data of the specified group. But only the
%             specified indices and elements are transferred to the
%             second file. The GroupIndex and Element list are
%             optional. Default all indices and elements are trans-
%             ferred. The GroupIndex should be specified in the same
%             way as it is used in the vs_let/vs_get commands: for
%             each group dimension indices specified, combined within
%             braces. For instance {1:3:20} for a group with one
%             dimension or {[1 2 6] 2:4} for a group with two
%             dimensions.
%           * 'GroupName',[]
%             excludes the group from the copy operation
%           * '*',[]
%             excludes all groups from the copy operation
%        Options are processed in the specified order. That is,
%             ...,'*',[],'GroupX')
%        will copy only the data from GroupX.

% (c) Copyright 1997-2000, H.R.A.Jagers, Delft Hydraulics, The Netherlands

vs_debug=1;
ErrMsg='';
INP=varargin;
quiet=0;
append=0;
if (length(INP)>0) & isequal(INP{end},'quiet')
   quiet=1;
   INP(end)=[];
end
VS=[];
VSn=[];
j=1;
i=1;
while i<=length(INP)
   if isstruct(INP{i})
      if j==1
         VS=INP{i};
         INP(i)=[];
         j=2;
      else
         VSn=INP{i};
         INP(i)=[];
         break
      end
   else
      i=i+1;
   end
end
if quiet
   vs_debug=0;
end

if ~isstruct(VS)
   ErrMsg='No NEFIS file specified to copy from.';
   if nargout<2
      error(ErrMsg)
   end
   return
elseif ~isstruct(VSn)
   ErrMsg='No NEFIS file specified to copy to.';
   if nargout<2
      error(ErrMsg)
   end
   return
else
   allgrp={VS.GrpDat.Name};
   gName=allgrp;
   for i=1:length(VS.GrpDat)
      for k=1:length(VS.GrpDat(i).SizeDim)
         gIndex{i}{k}=1:VS.GrpDat(i).SizeDim(k);
      end
      gElms{i}=vs_disp(VS,gName{i});
   end
   Opt=1;
   lINP=length(INP);
   while Opt<=lINP
      grp=INP{Opt};
      if ~ischar(grp) | size(grp,1)~=1 | ndims(grp)>2
         ErrMsg='Invalid group name.';
         break
      end
      if strcmp(grp,'-append')
         append=1;
         Opt=Opt+1;
      elseif strcmp(grp,'*')
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
   % I use here a "while" loop instead of an "if" statement to make
   % exception handling easier.
   % Exception are handled by "break" statements, otherwise one would have
   % to resort to multiple local exception handlers; now, there is only one
   % global exception handler after the "loop". The loop exists always after
   % one iteration due to a "break" statement at the end.
   while isempty(ErrMsg)
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
      gName_target={VSn.GrpDat.Name};
      for i=1:length(ig)
         i0=strmatch(VS.GrpDat(ig(i)).Name,gName,'exact');
         i1=strmatch(VS.GrpDat(ig(i)).Name,gName_target,'exact');
         if vs_debug
            fprintf(vs_debug,'Transfering data of group: %s.\n',gName{i0});
         end
         Idx={};
         Idx(1:length(gIndex{i0}))={0};
         VD=VS.GrpDat(ig(i)).VarDim;
         nflds_in_VSn=0;
         if VD
            VDIdx=gIndex{i0}{VD};
            gIndex{i0}{VD}=1;
            if append
               nflds_in_VSn=VSn.GrpDat(i1).SizeDim(VD);
            end
         elseif append
            ErrMsg=sprintf('Group %s cannot be extended.',gName{i0});
            break
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
                  Idx{VD}=VDIdx(k);
                  [Data,Chk]=vs_let(VS,gName{i0},Idx,eName,'quiet','nowarn');
                  Data=Data(gIndex{i0}{:},eIndex{:},:);
                  Idx{VD}=nflds_in_VSn+k;
                  [VSn,ErrMsg]=vs_put(VSn,gName{i0},Idx,eName,Data);
                  if ~isempty(ErrMsg)
                     break
                  end
               end
            else
               [Data,Chk]=vs_let(VS,gName{i0},eName,'quiet','nowarn');
               Data=Data(gIndex{i}{:},eIndex{:},:);
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