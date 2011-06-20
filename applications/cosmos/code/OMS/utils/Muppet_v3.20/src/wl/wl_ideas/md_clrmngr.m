function Range=md_clrmngr(arg1,arg2),
% MD_CLRMNGR  Color management module
%     Range=MD_CLRMNGR('Tag')           % get range reserved for 'Tag'
%     Range=MD_CLRMNGR('Tag',CMap)      % change CMap for 'Tag' and return range
%     MD_CLRMNGR('Tag',[])              % remove CMap
%     N=MD_CLRMNGR(H)                   % optimize color palette of figure H (figure containing H)
%                                       % and returns the length of the palette

% The figure contains a IDEAS_ClrMap field in the UserData property
% which is structured as
%   { 'TAG1' [Min_Range1 Max_Range1];
%     'TAG2' [Min_Range2 Max_Range2];
%                                 ... }
% with the ranges Min_Range[i+1]=Max_Range[i]+1
% cleared entries have an empty tag ''

SHH=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
switch nargin,
case 1,
  if ischar(arg1), % Range=MD_CLRMNGR('Tag')
    H=findobj('tag',arg1);
    if isempty(H),
      Range=[];
    else,
      Fig=H(1); % assume that all items are part of the same figure
      while ishandle(Fig) & isfigchild(Fig),
        Fig=get(Fig,'parent');
      end;
      if ishandle(Fig) & strcmp(get(Fig,'type'),'figure'),
        if isudf(Fig,'IDEAS_ClrMap'),
          Table=getudf(Fig,'IDEAS_ClrMap');
        else,
          Table={};
        end;
        I=strmatch(arg1,Table(:,1),'exact');
        if isempty(I),
          Range=[];
        else,
          Range=Table{I,2};
        end;
      end;
    end;
  else, % N=MD_CLRMNGR(H)
    Range=[];
    Fig=arg1;
    while ishandle(Fig) & isfigchild(Fig),
      Fig=get(Fig,'parent');
    end;
    if ishandle(Fig) & strcmp(get(Fig,'type'),'figure'),
      if isudf(Fig,'IDEAS_ClrMap'),
        Table=getudf(Fig,'IDEAS_ClrMap');
      else,
        Table={};
      end;
      CMap=get(Fig,'colormap');
      shift=0;
      for i=1:size(Table,1),
        Tag=Table{i,1};
        R=Table{i,2};
        if isempty(Tag),
          shift=shift+R(2)-R(1)+1;
        else,
          H=findobj('tag',Tag);
          if isempty(H),
            Table{i,1}='';
            shift=shift+R(2)-R(1)+1;
          else,
            for j=1:length(H), % all parts of the object with tag Tag
              switch get(H(j),'type'),
              case 'patch',
                if strcmp(get(H(j),'cdatamapping'),'direct'),
                  set(H(j),'facevertexcdata',get(H(j),'facevertexcdata')-shift);
                end;
              case {'surface','image'},
                if strcmp(get(H(j),'cdatamapping'),'direct'),
                  set(H(j),'cdata',get(H(j),'cdata')-shift);
                end;
              end;
            end;
            Table{i,2}=R-shift;
            CMap((R(1):R(2))-shift,:)=CMap(R(1):R(2),:);
          end;
        end;
      end;
      if ~isempty(Table),
        I=strmatch('',Table(:,1),'exact');
        Table(I,:)=[];
        CMap((end-shift+1):end,:)=[];
      end;
      setudf(Fig,'IDEAS_ClrMap',Table);
      set(Fig,'colormap',CMap);
      Range=size(CMap,1);
    end;
  end;
case 2, % Range=MD_CLRMNGR('Tag',CMap)
        %       MD_CLRMNGR('Tag',[])
  H=findobj('tag',arg1);
  if isempty(H),
   Range=[];
  else,
    Fig=H(1); % assume that all items are part of the same figure
    while ishandle(Fig) & isfigchild(Fig),
      Fig=get(Fig,'parent');
    end;
    if ishandle(Fig) & strcmp(get(Fig,'type'),'figure'),
      if isudf(Fig,'IDEAS_ClrMap'),
        Table=getudf(Fig,'IDEAS_ClrMap');
      else,
        Table={};
      end;
      CMap=get(Fig,'colormap');
      if isempty(Table),
        I=[];
      else,
        I=strmatch(arg1,Table(:,1),'exact');
      end;
      if isempty(I), % new
        if ~isempty(arg2),
          if isempty(Table),
            Range=[1 size(arg2,1)];
            Table(1,1:2)={arg1 Range};
            CMap=arg2;
          else,
            R=Table{end,2};
            Range=[R(2)+1 R(2)+size(arg2,1)];
            Table(end+1,1:2)={arg1 Range};
            CMap=[CMap; arg2];
          end;
        %else, % delete something that does not yet exist -> do nothing
        end;
      else, % old
        R=Table{I,2};
        if isempty(arg2), % remove
          Range=[];
          Table{I,1}='';
        elseif size(arg2,1)>(R(2)-R(1)+1), % now more colors
          Table{I,1}='';
          R=Table{end,2};
          Range=[R(2)+1 R(2)+size(arg2,1)];
          Table(end+1,1:2)={arg1 Range};
          CMap=[CMap; arg2];
        elseif size(arg2,1)<(R(2)-R(1)+1), % now less colors
          Range=[R(1) R(1)+size(arg2,1)-1];
          Table=[Table(1:I,:); {'' []}; Table((I+1):end,:)];
          Table{I,2}=Range;
          Table{I+1,2}=[Range(2)+1 R(2)];
          CMap(Range(1):Range(2),:)=arg2;
        else, % equal number of colors
          Range=R;
          CMap(R(1):R(2),:)=arg2;
          Range=Table{I,2};
        end;
      end;
      setudf(Fig,'IDEAS_ClrMap',Table);
      set(Fig,'colormap',CMap);
    else,
      error('Handle not figure child.');
    end;
  end;
end;
set(0,'showhiddenhandles',SHH);


function L=isfigchild(Fig),
L=isempty(strmatch(get(Fig,'type'),{'figure','root'},'exact'));