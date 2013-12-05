%% development of volumes over time
function show_MassCont(s)
figure;
subplot(3,1,1)
plot(s.output_time,sum(s.data.supply')+sum(s.data.transport'),'Displayname','Total sediment in domain')
xlabel('Time [s]')
ylabel('mass [kg/m]')
legend('show','location','nw')

subplot(3,1,2)
plot(s.output_time,s.data.total_transport(:,end),'Displayname','Cumulative transport at downwind boundary')
% plot(sum(s.bedcomposition.source(2:end))/(s.wind.dt*s.dx)*s.output_time)
xlabel('Time [s])')
ylabel('mass [kg/m]')
legend('show','location','nw')

% let's calciulate the total mass
tot_sup = sum(s.bedcomposition.source(2:end))/(s.wind.dt*s.dx)*s.output_time'; % total cumulative supply
tot_out = s.data.total_transport(:,end); % total cumulative transport at downwind boundary
tot_bed = sum(s.data.supply'); % sediment at the bed at any moment
tot_transport = sum(s.data.transport'); % sediment in transport at any moment

tot_mass = tot_sup-tot_out-tot_bed'-tot_transport';
subplot(3,1,3)

plot(s.output_time,tot_mass,'Displayname','Sum of total mass (this should be zero)')
xlabel('Time [s]')
ylabel('mass [kg/m]')
hline(0)
legend('show','location','nw')


% plot(sum(s.bedcomposition.source(2:end))/(s.wind.dt*s.dx)*s.output_time'-s.data.total_transport(:,end))


% how much total source material du we have at any time ?
% hold all
% index = logical(zeros(size(source)));
% 
% 
% for i=1:length(s.data.transport)
%     
%     if 1
%         % assume constant supply
%         volume_in(i) = sum(source(1,2:end))*i;
%     else
%         % This method is more generic but for some reason very slow
%         index = logical(zeros(size(source)));
%         index(1:i,2:end)=1;
%         volume_in(i) = sum(sum(source(index)));
%     end
%     
%     if i==1
%         volume_out(i)=0;
%     else
% %         volume_out(i) = s.data.transport(i-1,end)*s.data.wind(i-1)*s.wind.dt+volume_out(i-1);
%                 volume_out(i) = s.data.transport(i-1,end)*s.data.wind(i-1)*s.wind.dt+volume_out(i-1);
% 
%     end
% end
% plot(volume_in-volume_out)
% 
% subplot(3,1,2)
% plot((volume_in-volume_out)-(sum(s.data.supply')+sum(s.data.transport')))
% 
% subplot(3,1,3)
% plot(s.data.capacity(:,end))