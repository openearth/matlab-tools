function s=interpolate3D(x,y,dplayer,d,it,varargin)

tp='data';

if ~isempty(varargin)
    if strcmpi(varargin{1},'u') || strcmpi(varargin{1},'v')
        tp=varargin{1};
    end
end    

nlevels=length(d.levels);
levels=d.levels';

kmax=length(dplayer);
xd=d.lon;
yd=d.lat;
[xd,yd]=meshgrid(xd,yd);

x(isnan(x))=1e9;
y(isnan(y))=1e9;

for k=1:nlevels
    vald=squeeze(d.(tp)(:,:,k,it));
%     disp(['Level ' num2str(k)]);
    switch lower(tp(1))
        case{'u','v'}
            % Do NOT apply diffusion for velocities
            vald=internaldiffusion(vald,'nst',10);
        otherwise
%             disp('Internal diffusion ...');
%             tic
            vald=internaldiffusion(vald,'nst',10);
%             toc
    end
%     disp('Horizontal interpolation ...');
%     tic
    vals(:,:,k)=interp2(xd,yd,vald,x,y);
%     toc
    vals(isnan(vals))=-9999;
end

% disp('Vertical interpolation ...');
% tic
for i=1:size(vals,1)
    for j=1:size(vals,2)
        val=squeeze(vals(i,j,:));
        ii=find(val>-9000);
        if ~isempty(ii)
            i1=min(ii);
            i2=max(ii);
            depths=levels(i1:i2);
            temps=val(i1:i2);

            if size(depths,2)>1
                depths=depths';
            end
            
            switch lower(tp(1))
                case{'u','v'}
                    % Set velocities to 0 below where they are not available
                    ddep=depths(end)-depths(end-1);
                    ddep=1;
                    depths=[-100000;depths;depths(end)+ddep;100000];
                    temps =[temps(1);temps;0;0];
                otherwise
                    depths=[-100000;depths;100000];
                    temps =[temps(1);temps;temps(end)];
            end
            s(i,j,:)=interp1(depths,temps,squeeze(dplayer(i,j,:)));
        else
            s(i,j,1:kmax)=0;
        end
    end
end
% toc
