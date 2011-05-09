function varargout=bend(inputlist),
% BEND  Interactive curvilinear bend generation tool
%       Interactive mode, return X and Y coordinates
%       [X,Y]=BEND
%
%       Can also be used as kernel:
%       BEND(INPUT)

varargout=cell(1,nargout);
if nargin,
    inputelm=1;
end;
FirstSection=1;

fig=figure('renderer','zbuffer');
ax=axes('view',[0 90],'visible','off','dataaspectratio',[1 1 1],'parent',fig);
%O=line(0,0,'marker','o','parent',ax);
drawnow;
labels={'initial x coordinate of center line (m)','100'; ...
    'initial y coordinate of center line (m)','100'; ...
    'initial rotation angle (0=>right, 90=>up)','0'; ...
    'initial number of grid points in width direction','10'; ...
    'grid size in width direction (m)','1'};
if nargin,
    inp=inputlist{inputelm};
    inputelm=inputelm+1;
else,
    inp=inputdlg(labels(:,1),'Please specify',1,labels(:,2));
end;
if isempty(inp),
    close(fig);
    return;
end;
xc=eval(inp{1},100);
yc=eval(inp{2},100);
Rotation=eval(inp{3},0);
Rotation=Rotation-360*round(Rotation/360);
N=eval(inp{4},10);
if (N<2) | (N~=round(N)),
    Str='Error: N should be an integer larger than 1.';
    uiwait(msgbox(Str,'modal'));
    close(fig);
    return;
end;
dx=eval(inp{5},1);
if dx<=0,
    Str='Error: dx should be positive.';
    uiwait(msgbox(Str,'modal'));
    close(fig);
    return;
end;
W=((((N-1):-1:0)-(N-1)/2)*dx);
Nr=1;
Nl=N;

c=1;
LastAdd=0;
while c>0,
    labels=str2mat('curved', ...
        'straight', ...
        'change width', ...
        'shift centerline');
    %  LastAdd=0;
    if LastAdd,
        labels=str2mat(labels, ...
            'remove last reach added');
    end;
    if ~FirstSection,
        labels=str2mat(labels, ...
            'quit grid generation');
    end;
    if nargin,
        c=inputlist{inputelm};
        inputelm=inputelm+1;
    else,
        c=popup('next command','',labels,char(32*ones(size(labels,1),1)),'noclose');
    end;
    if c==1, % curved
        labels=str2mat('radius of curvature, total angle, and the number of steps', ...
            'radius of curvature, the number of steps, and grid cell size along centerline');
        if nargin,
            c=inputlist{inputelm};
            inputelm=inputelm+1;
        else,
            c=popup('curved reach','',labels,char(32*ones(size(labels,1),1)),'noclose');
        end;
        if c==1, % total angle, M
            labels={'radius of curvature along centerline (m) (+ left turn, - right turn)','10'; ...
                'total angle covered by reach (deg)','45'; ...
                'number of grid points','7'};
            inp={};
            if nargin,
                inp=inputlist{inputelm};
                inputelm=inputelm+1;
            else,
                while isempty(inp),
                    inp=inputdlg(labels(:,1),'Please specify',1,labels(:,2));
                end;
            end;
            R =eval(inp{1},10);
            A =eval(inp{2},45);
            M =eval(inp{3},7);
            if M~=0,
                dy=pi/180*(A*R)/M;
            else,
                dy=inf;
            end;
            Str=sprintf('Grid size along centerline is %8.4f m.',dy);
            if ~nargin,
                uiwait(msgbox(Str,'modal'));
            end;
        elseif c==2, % Radius, dy, M
            labels={'radius of curvature along center line (m) (+ left turn, - right turn)','10'; ...
                'number of grid points','7'; ...
                'grid cell size along centerline (m)','1'};
            inp={};
            if nargin,
                inp=inputlist{inputelm};
                inputelm=inputelm+1;
            else,
                while isempty(inp),
                    inp=inputdlg(labels(:,1),'Please specify',1,labels(:,2));
                end;
            end;
            R =eval(inp{1},10);
            M =eval(inp{2},7);
            dy=eval(inp{3},1);
            A =180/pi*(M*dy)/abs(R);
            Str=sprintf('Total angle covered by reach is %8.4f degrees.',A);
            if 0,%~nargin,
                uiwait(msgbox(Str,'modal'));
            end;
        else,
            c=0;
        end;
        if (c~=0) & (M>0),
            A=A*pi/180;
            if FirstSection,
                FirstSection=0;
                m=transpose(0:M)/M;
                x0=sin(m*A)*(abs(R)+sign(R)*W);
                y0=R-cos(m*A)*(R+W);
                x=xc+cos(Rotation*pi/180)*x0-sin(Rotation*pi/180)*y0;
                y=yc+sin(Rotation*pi/180)*x0+cos(Rotation*pi/180)*y0;
                z=ones(M+1,N);
                S=surface(x,y,z,'edgecolor',[1 1 1],'facecolor','none','clipping','off');
                x0CL=transpose(sin(m*A)*abs(R));
                y0CL=transpose(R-cos(m*A)*R);
                xCL=xc+cos(Rotation*pi/180)*x0CL-sin(Rotation*pi/180)*y0CL;
                yCL=yc+sin(Rotation*pi/180)*x0CL+cos(Rotation*pi/180)*y0CL;
                CL=line(xCL,yCL);
            else,
                m=transpose(1:M)/M;
                x0=sin(m*A)*(abs(R)+sign(R)*W);
                y0=R-cos(m*A)*(R+W);
                x=xc+cos(Rotation*pi/180)*x0-sin(Rotation*pi/180)*y0;
                y=yc+sin(Rotation*pi/180)*x0+cos(Rotation*pi/180)*y0;
                x=[get(S,'xdata'); x];
                y=[get(S,'ydata'); y];
                z=[get(S,'zdata'); ones(M,N)];
                set(S,'xdata',x,'ydata',y,'zdata',z,'cdata',z);
                x0CL=transpose(sin(m*A)*abs(R));
                y0CL=transpose(R-cos(m*A)*R);
                xCL=xc+cos(Rotation*pi/180)*x0CL-sin(Rotation*pi/180)*y0CL;
                yCL=yc+sin(Rotation*pi/180)*x0CL+cos(Rotation*pi/180)*y0CL;
                xCL=[get(CL,'xdata'), xCL];
                yCL=[get(CL,'ydata'), yCL];
                set(CL,'xdata',xCL,'ydata',yCL);
            end;
            xc=xc+cos(Rotation*pi/180)*abs(R)*sin(A)-sin(Rotation*pi/180)*(R-R*cos(A));
            yc=yc+sin(Rotation*pi/180)*abs(R)*sin(A)+cos(Rotation*pi/180)*(R-R*cos(A));
            Rotation=Rotation+180/pi*A*sign(R);
            LastAdd=1;
        else,
            LastAdd=0;
        end;
        c=1;
    elseif c==2, % straight
        labels={'number of grid points','10'; ...
            'grid cell size (m)','1'};
        inp={};
        if nargin,
            inp=inputlist{inputelm};
            inputelm=inputelm+1;
        else,
            while isempty(inp),
                inp=inputdlg(labels(:,1),'Please specify',1,labels(:,2));
            end;
        end;
        M =eval(inp{1},10);
        dy=eval(inp{2},1);

        if FirstSection,
            FirstSection=0;
            x0=transpose((0:M)*dy)*ones(1,N);
            y0=ones(M+1,1)*(-W);
            x=xc+cos(Rotation*pi/180)*x0-sin(Rotation*pi/180)*y0;
            y=yc+sin(Rotation*pi/180)*x0+cos(Rotation*pi/180)*y0;
            z=ones(M+1,N);
            S=surface(x,y,z,'edgecolor',[1 1 1],'facecolor','none','clipping','off');
            x0CL=(0:M)*dy;
            xCL=xc+cos(Rotation*pi/180)*x0CL;
            yCL=yc+sin(Rotation*pi/180)*x0CL;
            CL=line(xCL,yCL);
        else,
            x0=transpose((1:M)*dy)*ones(1,N);
            y0=ones(M,1)*(-W);
            x=xc+cos(Rotation*pi/180)*x0-sin(Rotation*pi/180)*y0;
            y=yc+sin(Rotation*pi/180)*x0+cos(Rotation*pi/180)*y0;
            x=[get(S,'xdata'); x];
            y=[get(S,'ydata'); y];
            z=[get(S,'zdata'); ones(M,N)];
            set(S,'xdata',x,'ydata',y,'zdata',z,'cdata',z);
            x0CL=(1:M)*dy;
            xCL=xc+cos(Rotation*pi/180)*x0CL;
            yCL=yc+sin(Rotation*pi/180)*x0CL;
            xCL=[get(CL,'xdata'), xCL];
            yCL=[get(CL,'ydata'), yCL];
            set(CL,'xdata',xCL,'ydata',yCL);
        end;
        xc=xc+cos(Rotation*pi/180)*M*dy;
        yc=yc+sin(Rotation*pi/180)*M*dy;
        LastAdd=2;
    elseif c==3, % change width
        labels={'number of grid cells to be added on right hand side','0'; ...
            'number of grid cells to be added on left hand side','0'};
        inp={};
        if nargin,
            inp=inputlist{inputelm};
            inputelm=inputelm+1;
        else,
            while isempty(inp),
                inp=inputdlg(labels(:,1),'Please specify change (+ add, - remove)',1,labels(:,2));
            end;
        end;
        rhs=eval(inp{1},0);
        lhs=eval(inp{2},0);
        if (-rhs)>=(Nl-Nr+1),
        elseif (-lhs)>=(Nl-Nr+1),
        elseif (-rhs-lhs)>=(Nl-Nr),
        else,
            x=get(S,'xdata');
            y=get(S,'ydata');
            z=get(S,'zdata');
            Wp=W; % Wp used to increase width at last cross section without any concurrent width increase
            if lhs>0,
                W=[W(1:Nl) W(Nl)-(1:lhs)*dx];
                Wp=[Wp(1:Nl) Wp(Nl)-(1:lhs)*dx];
                if (Nl+lhs)<N, % width increase less than previous width decrease
                    W=[W NaN*ones(1,N-Nl-lhs)];
                    Wp=[Wp NaN*ones(1,N-Nl-lhs)];
                    Nl=Nl+lhs;
                else, % width increase more than or equal to previous width decrease
                    Nl=Nl+lhs;
                    y=[y NaN*ones(size(x,1),Nl-N)];
                    z=[z ones(size(x,1),Nl-N)];
                    x=[x NaN*ones(size(x,1),Nl-N)];
                    N=Nl;
                end;
            elseif lhs==0,
            else, % lhs<0
                W((Nl+lhs+1):Nl)=NaN*ones(1,-lhs);
                Nl=Nl+lhs;
            end;
            if rhs>0,
                W=[W(Nr)+(rhs:-1:1)*dx W(Nr:N)];
                Wp=[Wp(Nr)+(rhs:-1:1)*dx Wp(Nr:N)];
                if Nr>(rhs+1), % width increase less than previous width decrease
                    W=[NaN*ones(1,Nr-1-rhs) W];
                    Wp=[NaN*ones(1,Nr-1-rhs) Wp];
                    Nr=Nr-rhs;
                else, % width increase more than or equal to previous width decrease
                    N=N+rhs-Nr+1;
                    Nl=Nl+rhs-Nr+1;
                    y=[NaN*ones(size(x,1),rhs-Nr+1) y];
                    z=[ones(size(x,1),rhs-Nr+1) z];
                    x=[NaN*ones(size(x,1),rhs-Nr+1) x];
                    Nr=1;
                end;
            elseif rhs==0,
            else, % rhs<0
                W(Nr:(Nr-rhs-1))=NaN*ones(1,-rhs);
                Nr=Nr-rhs;
            end;
            x(size(x,1),:)=xc+sin(Rotation*pi/180)*Wp;
            y(size(x,1),:)=yc-cos(Rotation*pi/180)*Wp;
            set(S,'xdata',x,'ydata',y,'zdata',z,'cdata',z);
        end;
        LastAdd=3;
    elseif c==4, % shift centerline
        labels={'shift of centerline (m) (+ right, - left)','0'};
        inp={};
        if nargin,
            inp=inputlist{inputelm};
            inputelm=inputelm+1;
        else,
            while isempty(inp),
                inp=inputdlg(labels(:,1),'Please specify shift',1,labels(:,2));
            end;
        end;
        shft=eval(inp{1},0);
        xc=xc+shft*dx*sin(Rotation*pi/180);
        yc=yc-shft*dx*cos(Rotation*pi/180);
        W=W-shft*dx;
        xCL=[get(CL,'xdata'), NaN, xc];
        yCL=[get(CL,'ydata'), NaN, yc];
        set(CL,'xdata',xCL,'ydata',yCL);
        LastAdd=4;
    elseif LastAdd & c==5, % remove last added
        switch LastAdd,
            case {1,2},
                x=get(S,'xdata');
                y=get(S,'ydata');
                z=get(S,'zdata');
                old=(1:(size(x,1)-M));
                set(S,'xdata',x(old,:),'ydata',y(old,:),'zdata',z(old,:),'cdata',z(old,:));
                xCL=get(CL,'xdata');
                yCL=get(CL,'ydata');
                old=(1:(length(xCL)-M));
                set(CL,'xdata',xCL(old),'ydata',yCL(old));
                if LastAdd==1,
                    xc=xc-cos(Rotation*pi/180)*abs(R)*sin(A)-sin(Rotation*pi/180)*(R-R*cos(A));
                    yc=yc-sin(Rotation*pi/180)*abs(R)*sin(A)+cos(Rotation*pi/180)*(R-R*cos(A));
                    Rotation=Rotation-180/pi*A*sign(R);
                elseif LastAdd==2,
                    xc=xc-cos(Rotation*pi/180)*M*dy;
                    yc=yc-sin(Rotation*pi/180)*M*dy;
                end;
                %    case 3,
            case 4,
                xc=xc-shft*dx*sin(Rotation*pi/180);
                yc=yc+shft*dx*cos(Rotation*pi/180);
                W=W+shft*dx;
                xCL=get(CL,'xdata');
                yCL=get(CL,'ydata');
                old=(1:(length(xCL)-2));
                set(CL,'xdata',xCL(old),'ydata',yCL(old));
            otherwise,
                Str=sprintf('Undo not implemented for last executed option.');
                uiwait(msgbox(Str,'modal'));
        end;
        LastAdd=0;
    else,
        c=0;
    end;
end;


% get the complete grid
x=get(S,'xdata');
y=get(S,'ydata');
area=finite(x);
[i,j,c]=boundary(area);
K=length(i);
X=zeros(K,1);
Y=zeros(K,1);
Z=[c c];
for k=1:K,,
    if isnan(i(k)),
        X(k)=NaN;
        Y(k)=NaN;
    else,
        X(k)=x(i(k),j(k));
        Y(k)=y(i(k),j(k));
    end;
end;
X=[X X];
Y=[Y Y];
bnd=surface(X,Y,10+Z,Z*10,'edgecolor','flat');
set(bnd,'clipping','off');
set(fig,'renderer','zbuffer');
colormap hsv;
M=size(x,1);

if nargout,
    outhandles=[S,CL,bnd]; % handles of grid, centerline, and boundaries
end;

if nargin,
    return;
end;

% shift all points if any one lies on x- or y-axis.
% convert coordinate NaN's to zeros.
err=any(any(x==0));
if err,
    delta=0;
    while err,
        if delta<0,
            delta=-delta;
        else,
            delta=-(delta+.001);
        end;
        err=any(any(x==delta));
    end;
    x=x-delta;
    Str=sprintf('Warning: x-coordinates shifted by %12.3f.',-delta);
    uiwait(msgbox(Str,'modal'));
end;
err=any(any(y==0));
if err,
    delta=0;
    while err,
        if delta<0,
            delta=-delta;
        else,
            delta=-(delta+.001);
        end;
        err=any(any(y==delta));
    end;
    y=y-delta;
    Str=sprintf('Warning: y-coordinates shifted by %12.3f.',-delta);
    uiwait(msgbox(Str,'modal'));
end;

for i=1:size(x,1),
    for j=1:size(x,2),
        if isnan(x(i,j)),
            x(i,j)=0;
        end;
        if isnan(y(i,j)),
            y(i,j)=0;
        end;
    end;
end;

[filename,pad]=uiputfile('*.grd','Specify name of grid file');
if ~isstr(filename),
    return
end
filename=[pad filename];
[p,n,e]=fileparts(filename);
if isempty(e)
    filename=[filename '.grd'];
end
wlgrid('write',filename,x,y)

if nargout>0
    varargout={x y};
end

if 0
    %
    % oude code voor grid2d
    %
    l=Z(2:size(Z,1),1)-Z(1:(size(Z,1)-1),1);
    m=find(l~=0);     % m  contains all vertices
    m1=[1;m+1];       % m1 contains the starting indices of the edges
    m2=[m;length(Z)]; % m2 contains the ending indices of the edges
    [filename,pad]=uiputfile('*.bnd','Specify boundary file');
    if isstr(filename),
        fid=fopen([pad,filename],'w');
        for i=1:length(m1),
            if i<length(m1),
                fprintf(fid,'%8i%8i%8i%8i\n',m2(i)-m1(i)+1,1,i,i+1);
            else,
                fprintf(fid,'%8i%8i%8i%8i\n',m2(i)-m1(i)+1,1,i,1);
            end;
            for j=m1(i):m2(i),
                fprintf(fid,'%12.3f %12.3f\n',X(j,1),Y(j,1));
            end;
        end;
        fclose(fid);
    end;
    [filename,pad]=uiputfile('*.inp','Specify input file');
    if isstr(filename),
        fid=fopen([pad,filename],'w');
        fprintf(fid,'* Input file created by Matlab at %s\n',datestr(now));
        fprintf(fid,'%8i%8i\n',length(m1),1);
        fprintf(fid,'%8i%8i%8i\n',length(m1),0,0);
        for i=1:length(m1),
            fprintf(fid,'%8i%8i%8i%8i%8i\n',i,c(m1(i)),m2(i)-m1(i)+1,2,0);
        end;
        fclose(fid);
    end;
end