spw.radius=500000;
spw.nr_directional_bins=36;
spw.nr_radial_bins=500;
spw.reference_time=datenum(2014,11,1);
spw.cs.name='WGS 84';
spw.cs.type='geographic';
spw.cut_off_speed=0;

tc=wes('wp2214.16.tcw','jmv30',spw,'test002.spw');

% % Now plot the data
%
% r100=0:5:300;
%
% for it=1:nt
%
%     angles0=[135 45 315 225]; % Angles where the wind is blowing to in the four quadrants
%
%     % Compute relative wind speeds for different radii
%     if tc.track(it).y>0
%         angles=angles0+tc.phi_spiral;        % Include spiralling effect
%     else
%         angles=angles0-tc.phi_spiral;        % Include spiralling effect
%     end
%     angles=angles*pi/180;                 % Convert to radians
%
%     if tc.track(it).method==2
%         for iquad=1:4
%
%             rr=squeeze(tc.track(it).quadrant(iquad).radius);
%
%             if ~isempty(find(~isnan(rr), 1))
%
%                 if iquad==1
%                     figure(it)
%                 end
%
%                 subplot(2,2,iquad);
%
%                 a=tc.track(it).quadrant(iquad).a;
%                 b=tc.track(it).quadrant(iquad).b;
%                 pdrop=tc.track(it).pdrop;
%
%                 vc = sqrt(a*b*pdrop*exp(-a./r100.^b)./(rhoa*r100.^b));
%
%                 urel=vc*cos(angles(iquad));
%                 vrel=vc*sin(angles(iquad));
%                 uabs=urel+tc.track(it).u_prop;
%                 vabs=vrel+tc.track(it).v_prop;
%                 vc=sqrt(uabs.^2+vabs.^2);
%
%                 plot(r100,vc,'b');hold on;
%
%                 plot(rr,tc.radius_velocity,'ro');
%                 rm = a^(1/b);
%
%
%                 plot(rm,tc.track(it).quadrant(iquad).vmax_abs,'ro');
%
%             end
%         end
%     end
% end
