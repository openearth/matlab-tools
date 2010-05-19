function handles=ddb_dnami_redrw_Farea(handles)

xf =[0 0 0 0 0 0]; yf =[0 0 0 0 0 0];
ufl=[0 0 0 0 0];   str=[ 0 0 0 0 0];  dp =[0 0 0 0 0];   sl =[0 0 0 0 0]; fd = [0 0 0 0 0];

nseg=handles.Toolbox(tb).Input.NrSegments;

ishft=0;
nsg  = nseg;
nsegold=nseg;

for i=1:nseg
  val = handles.Toolbox(tb).Input.FaultLength(i);
  if val==0 % delete faultline
     ishft=ishft+1;
     nsg  = nsg -1;
  else
     xf(i-ishft)=handles.Toolbox(tb).Input.FaultX(i);
     yf(i-ishft)=handles.Toolbox(tb).Input.FaultY(i);
     ufl(i-ishft)=val;
     str(i-ishft)=handles.Toolbox(tb).Input.Strike(i);
     dp (i-ishft)=handles.Toolbox(tb).Input.Dip(i);
     sl (i-ishft)=handles.Toolbox(tb).Input.SlipRake(i);
     fd (i-ishft)=handles.Toolbox(tb).Input.FocalDepth(i);
  end
end

totufl=sum(ufl);
%
% error in case fault length exceeds 10% of computed fault length through Mw
%
%if (abs(totufl-handles.Toolbox(tb).Input.TotalFaultLength) > handles.Toolbox(tb).Input.ToleranceLength*handles.Toolbox(tb).Input.TotalFaultLength)
%   errordlg(['Specified fault length: ' int2str(totufl) ' Length computed: ' int2str(handles.Toolbox(tb).Input.TotalFaultLength)]);
%   return
%end

%
% redefine polygon coordinates and fault area using new distance and bearing (strike dir)
%
for i=1:nsg
   [xf(i+1),yf(i+1)]=ddb_ddb_det_nxtvrtx(xf(i), yf(i), str(i), ufl(i));
end

%
% Now everything's OK: copy new values to old values
%
nseg = nsg;
handles.Toolbox(tb).Input.TotalUserFaultLength = totufl;
for i=1:nseg
   handles.Toolbox(tb).Input.FaultX(i)=xf(i);
   handles.Toolbox(tb).Input.FaultY(i)=yf(i);
   handles.Toolbox(tb).Input.FaultLength(i)=ufl(i);
   handles.Toolbox(tb).Input.Strike(i)=str(i);
   handles.Toolbox(tb).Input.Dip(i)=dp(i);
   handles.Toolbox(tb).Input.SlipRake(i)=sl(i);
   handles.Toolbox(tb).Input.FocalDepth(i)=fd(i);
end

% Clean up all fault segments that have been deleted
for i=nseg+1:nsegold
   handles.Toolbox(tb).Input.FaultX(i)=0;
   handles.Toolbox(tb).Input.FaultY(i)=0;
   handles.Toolbox(tb).Input.FaultLength(i)=0;
   handles.Toolbox(tb).Input.Strike(i)=0;
   handles.Toolbox(tb).Input.Dip(i)=0;
   handles.Toolbox(tb).Input.SlipRake(i)=0;
   handles.Toolbox(tb).Input.FocalDepth(i)=0;
end

handles.Toolbox(tb).Input.FaultX(nseg+1)=xf(nseg+1);
handles.Toolbox(tb).Input.FaultY(nseg+1)=yf(nseg+1);
handles.Toolbox(tb).Input.NrSegments = nseg;

handles = ddb_computeMw(handles);
if handles.Toolbox(tb).Input.Magnitude <= 6 & handles.Toolbox(tb).Input.Magnitude > 0
   warndlg('Probably negligible Tsunami wave')
end

%
% Moet VertexX/Y hier niet ook worden geupdate?
%
%handles.Toolbox(tb).Input.VertexX=xf;
%handles.Toolbox(tb).Input.VertexY=yf;

handles=ddb_dnami_comp_Farea(handles);
h=findall(gcf,'Tag','FaultArea');
if length(h)>0
    delete(h);
end
if (nseg > 0 & handles.Toolbox(tb).Input.Magnitude > 0)
   for i=1:nseg
      xx = [];
      yy = [];
      for k=1:5
         xx(k) = handles.Toolbox(tb).Input.VertexX(i,k);
         yy(k) = handles.Toolbox(tb).Input.VertexY(i,k);
      end
      fltpatch(i) = patch(xx,yy,'y');
      set(fltpatch(i),'FaceAlpha',0.8);
      set(fltpatch(i),'EdgeColor','none');
      set(fltpatch(i),'Tag','FaultArea');
      set(fltpatch(i),'HitTest','off');
   end
end

%-------------------------------------------------------
function val=getifld(txt)
vstr = get(findobj('Tag',txt),'string');
if isempty(vstr)
   val=0;
else
   val=str2num(vstr);
end
