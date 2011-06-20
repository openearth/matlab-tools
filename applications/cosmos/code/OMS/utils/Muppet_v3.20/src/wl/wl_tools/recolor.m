function recolor(colit,FClr,TClr)
% RECOLOR Replaces a color by another color.
%      Usage: RECOLOR(Handle,FromColor,ToColor)

% (c) 2000, H.R.A. Jagers
%           bert.jagers@wldelft.nl

if isempty(colit) | ~ishandle(colit)
   error('Incorrect input argument.')
end
ColChar={'k' 'w' 'r' 'g' 'b' 'c' 'm' 'y'};
ColVec={[0 0 0],[1 1 1],[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1],[1 1 0]};
if ischar(FClr)
   f=strmatch(lower(FClr),ColChar,'exact');
   if length(f)~=1
      error('Invalid character for FromColor')
   end
   FClr=ColVec{f};
end
if ischar(TClr)
   f=strmatch(lower(TClr),ColChar,'exact');
   if length(f)~=1
      error('Invalid character for ToColor')
   end
   TClr=ColVec{f};
end

colh=findall(colit); % find all children of selected objects
for i=1:length(colh)
   tp=get(colh(i),'type');
   switch tp
      case {'patch'}
         Clrs={'edgecolor', 'facecolor', 'markeredgecolor', 'markerfacecolor'};
         for c=1:length(Clrs)
            Clr=get(colh(i),Clrs{c});
            if isequal(Clr,FClr)
               set(colh(i),Clrs{c},TClr);
            end
         end
         % facevertexcdata
         
      case 'surface'
         Clrs={'edgecolor', 'facecolor', 'markeredgecolor', 'markerfacecolor'};
         for c=1:length(Clrs)
            Clr=get(colh(i),Clrs{c});
            if isequal(Clr,FClr)
               set(colh(i),Clrs{c},TClr);
            end
         end
         % cdata
         
      case 'image'
         % cdata
         
      case 'light'
         Clr=get(colh(i),'color');
         if isequal(Clr,FClr)
            set(colh(i),'color',TClr);
         end
      case 'axes'
         Clrs={'color', 'xcolor', 'ycolor', 'zcolor', 'ambientlightcolor'};
         for c=1:length(Clrs)
            Clr=get(colh(i),Clrs{c});
            if isequal(Clr,FClr)
               set(colh(i),Clrs{c},TClr);
            end
         end
      case 'line'
         Clrs={'color', 'markeredgecolor', 'markerfacecolor'};
         for c=1:length(Clrs)
            Clr=get(colh(i),Clrs{c});
            if isequal(Clr,FClr)
               set(colh(i),Clrs{c},TClr);
            end
         end
      case 'figure'
         Clr=get(colh(i),'color');
         if isequal(Clr,FClr)
            set(colh(i),'color',TClr);
         end
         %colormap, dithermap
      case 'text'
         Clr=get(colh(i),'color');
         if isequal(Clr,FClr)
            set(colh(i),'color',TClr);
         end
      case 'uicontrol'
         Clrs={'foregroundcolor', 'backgroundcolor'};
         for c=1:length(Clrs)
            Clr=get(colh(i),Clrs{c});
            if isequal(Clr,FClr)
               set(colh(i),Clrs{c},TClr);
            end
         end
   end
end