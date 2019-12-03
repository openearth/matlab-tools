%script om golfvorm te bepalen, april 2012.
clear all
close all
%addpath('d:\Matlab\wafo\wstats\')
    
    %variabelen:
Qbase_level=1000; %m3/s, onder dit level worden de afvoeren naar beneden doorgetrokken

load Class
%load Q_h
%Q_h=Q_h_Maas;
toon_figuur=1; %1/0 yes/no show figures

% for k=1:8
%    aantal_golven(k,1)=length(Class{k}.wave );
% end

for j=1:1:1%7 %length(Class);
    Waves.org=Class{j}.wave;

    %%
    %methode Henk: middelen over afvoeren per duur
    % schalen naar 1 gemiddelde afvoer van klasse
    % middelen en 5%, 50% en 95% bepalen
    % per klasse:

    %omzetten naar uren

    dt=0.1;
    tdag=(-l:1:l)';
    tuur=(-l:dt:l)';
    for i=1:length(Waves.org)
        Waves.uur(i,:)= (INTERP1(tdag,Waves.org(i,:),tuur,'linear'))';
    end

    % gemiddelde bepalen
    maximum=10*round((max(Waves.org(:,l+1)))/10);
    minimum=10*round((min(Waves.org(:,l+1)))/10);
    average=100*round((maximum+minimum)/200);

    %schalen over Q per tijdstap
    for i=1:length(Waves.org)
        Waves.geschaald(i,:)=Waves.org(i,:)./(Waves.org(i,l+1)/average) ;
    end

    Waves.sort=sort(Waves.geschaald);    
    
    percentielen = prctile(Waves.geschaald,[5 25 50 75 95]);
    gemiddelde=mean(Waves.geschaald);
    
    percentielen2(1,:)=0.05.*sum(Waves.geschaald)./length(Waves.geschaald);
    percentielen2(2,:)=0.25.*sum(Waves.geschaald)./length(Waves.geschaald);
    percentielen2(3,:)=0.5.*sum(Waves.geschaald)./length(Waves.geschaald);
    percentielen2(4,:)=0.75.*sum(Waves.geschaald)./length(Waves.geschaald);
    percentielen2(5,:)=0.95.*sum(Waves.geschaald)./length(Waves.geschaald);


    for i=1:length(Waves.geschaald(1,:))
    [phat, var,ciL,ciU]  = wlognfit(Waves.geschaald(:,i),0); 
    normdistr_5(i,1) = wlogninv(0.05,phat(1,1),phat(1,2));
    normdistr_95(i,1) = wlogninv(0.95,phat(1,1),phat(1,2));
    end
 
    figure(2700)
    for i=1:3:length(Waves.geschaald(1,:))
    [phat, var,ciL,ciU]  = wlognfit(Waves.geschaald(:,i)); hold on; 
    end
  
    s=0;
    figure(2750)
    for i=[1,11,21,31,41,51];
        s=s+1;
        [phat, var,ciL,ciU]  = wlognfit(Waves.geschaald(:,i)); hold on;
        [parmhat,parmci] = lognfit(Waves.geschaald(:,i),1);
        aphat(s,:)=phat;
        avar(s,:)=var;
        aparmhat(s,:)=parmhat;        
    end
    
    clear yas_cdf yas_pdf
    xas=0:100:6000;
for i=1:length(aparmhat)  
    yas_cdf(i,:) = logncdf(xas,aparmhat(i,1), aparmhat(i,2));
    yas_pdf(i,:) = lognpdf(xas,aparmhat(i,1), aparmhat(i,2));
end
% gemiddelde = mean(yas_cdf')';

figure(200+j)
plot(xas,yas_cdf); hold on
xlabel('x'); ylabel('p');

figure(200+j)
plot(xas,yas_pdf); hold on
xlabel('x'); ylabel('p');
    
        
    tijd=(-l:1:l)';

    if toon_figuur==1;
        figure(j)
        plot(-25, 500, 'b','LineWidth', 2); hold on; %enkel voor legenda
        plot(-25, 500, 'r','LineWidth', 2); hold on; %enkel voor legenda
        plot(-25, 500, 'green','LineWidth', 2); hold on; %enkel voor legend
        plot(-25, 500, 'black--','LineWidth', 2); hold on; %enkel voor legenda
        plot(-l:l, Waves.geschaald, 'color',[0.68 0.93 1]); hold on;
        plot(-l:l, percentielen(1,:), 'green','LineWidth', 2); hold on;
        plot(-l:l, percentielen(2,:), 'r','LineWidth', 2); hold on;
        plot(-l:l, percentielen(3,:), 'b','LineWidth', 2); hold on;
        plot(-l:l, percentielen(4,:), 'r','LineWidth', 2); hold on;
        plot(-l:l, percentielen(5,:), 'green','LineWidth', 2); hold on;
        plot(-l:l, gemiddelde, 'black--','LineWidth', 2); hold on;
        ylabel('discharge (m^3/sec)')
        xlabel('time (days)')
        title (['standard hydrograph (vertical averaging), interval= ' num2str(minimum) ' - ' num2str(maximum) ' m^3/s']);
        legend('50%','25% and 75%','5% and 95%','mean','GRADE waves');
        hold off
        %opslaan figuur
        plotfile=strcat('./figuren/Design_hydrograph_average_Q_',num2str(j),'.jpg');
        % print('-dpdf', '-noui', '-cmyk', '-painters', 'fig.pdf');
        print -djpeg90  fig.jpg;
        copyfile('fig.jpg', plotfile);
        delete('fig.jpg');
        %     close (j)

        figure(j+10)
        plot(-l:l, Waves.geschaald(1:10,:)); hold on;
        ylabel('discharge (m^3/sec)')
        xlabel('time (days)')
        title (['ten random waves in interval= ' num2str(minimum) ' - ' num2str(maximum) ' m^3/s']);
        hold off
        plotfile=strcat('./figuren/Waves_geschaald',num2str(j),'.jpg');
        print -djpeg90  fig.jpg;
        copyfile('fig.jpg', plotfile);
        delete('fig.jpg');
        %     close (j+10)
    end

    %-------------------------------------------------------------------------
    %-------------------------------------------------------------------------
    %%
    %methode HKV: middelen over duur per afvoer
    % schalen naar 1,
    % nevenpieken eruit halen
    % doortrekken van de golf
    % middelen en 5%, 50% en 95% bepalen
    Waves_t.org=Waves.org;
    [Q,t_rechts,t_perc_rechts,t_average_rechts,t_links,t_perc_links,t_average_links] =  middelen_t(Waves_t, l, average);

    if toon_figuur==1;
        figure(j+100)
        plot (-25, 500,'b', 'linewidth',2);hold on; % voor legenda
        plot (-25, 500,'r', 'linewidth',2);hold on; % voor legenda
        plot (-25, 500,'g', 'linewidth',2);hold on; % voor legenda
        plot (-25, 500,'black--', 'linewidth',2);hold on; %voor legenda
        plot(-l:l, Waves.geschaald, 'color',[0.68 0.93 1]); hold on;
        plot (t_perc_links,Q,'g', 'linewidth',2);hold on;
        plot (t_perc_rechts,Q,'g', 'linewidth',2);hold on;
        plot (t_perc_links(2:4,:),Q,'r', 'linewidth',2);hold on;
        plot (t_perc_rechts(2:4,:),Q,'r', 'linewidth',2);hold on;
        plot (t_perc_links(3,:),Q,'b', 'linewidth',2);hold on;
        plot (t_perc_rechts(3,:),Q,'b', 'linewidth',2);hold on;
        plot (t_average_rechts(1,:),Q,'black--', 'linewidth',2);hold on;
        plot (t_average_links,Q,'black--', 'linewidth',2);hold on;
        ylabel('discharge (m^3/sec)')
        xlabel('time (days)')
        %     legend('gemiddelde golf',datestr(datum_piek(1,1)),datestr(datum_piek(2,1)),datestr(datum_piek(3,1)),datestr(datum_piek(4,1)),datestr(datum_piek(5,1)));
        title (['Standard hydrograph (horizontal averaging), interval= ' num2str(minimum) ' - ' num2str(maximum) ' m^3/s']);
        legend('50%','25% and 75%','5% and 95%','mean','GRADE waves');
        xlim([-25 25])
        %     grid on
        hold off
        plotfile=strcat('./figuren/Design_hydrograph_average_t_',num2str(j),'.jpg');
        % print('-dpdf', '-noui', '-cmyk', '-painters', 'fig.pdf');
        print -djpeg90  fig.jpg;
        copyfile('fig.jpg', plotfile);
        delete('fig.jpg');
        %     close (j+100)
    end
    %----------------------------------------------------------------------
    %------------------------------------------------------------------

    %invoer golfgenerator:
    %bepaal helling waarmee de golfgenerator onder de 1000 m3/s wordt aangevuld
    % helling wordt bepaalde uit het drempel niveau en het piek afvoerniveau
    %(Q(tpiek)-Q(tdrempel))/(tpiek-tdrempel).
    Waves.aangepast=Waves.org;
    N_stormen=length(Waves.org);
    t0=l+1;
    for i=1:N_stormen %per storm
        %links
        b2=0;
        b1=0;
        for n=(l-1):-1:1 %per tijdstap
            if Waves.org(i,n)<Qbase_level && b2==0;
                b1=n+1;
                b2=1;
            end
        end
        if b1==0;
        else
            A_wma=(Waves.org(i,t0)-Waves.org(i,b1))/(t0-b1);
            %A_wma=(Waves.org(i,(b1+1))-Waves.org(i,b1))/((b1+1)-b1);
            Aw=A_wma*Waves.org(i,t0)/average;
            for s=(b1-1):-1:1
                Waves.aangepast(i,s)=Waves.aangepast(i,s+1)-Aw;
            end
        end
        %rechts
        b2=0;
        b1=0;
        for n=(l+1):1:length(tijd) %per tijdstap
            if Waves.org(i,n)<1000 && b2==0;
                b1=n+1;
                b2=1;
            end
        end
        if b1==0  || b1>length(tijd) ;
        else
            A_wma=(Waves.org(i,t0)-Waves.org(i,b1))/(t0-b1);
            %A_wma=(Waves.org(i,(b1-1))-Waves.org(i,b1));
            Aw=A_wma*Waves.org(i,t0)/average;
            for s=(b1+1):1:length(tijd)
                Waves.aangepast(i,s)=Waves.aangepast(i,s-1)+Aw;
            end
        end
    end
    B=Waves.aangepast<0;
    Waves.aangepast(B)=0;

    if toon_figuur==1;
        figure(j+10000)
        plot (-25, 500,'r', 'linewidth',2);hold on; %voor legenda
        plot (-25, 500,'blue', 'linewidth',1);hold on; % voor legenda
        plot(-l:l,Waves.aangepast(15:21,:),'r'); hold on;
        plot(-l:l,Waves.org(15:21,:),'b');
        legend('wave extrapolated under baselevel','original wave')
        title('GRADE waves');
        %     plot(-l:l,Waves.aangepast(1,:)); hold on;
        hold off
        plotfile=strcat('./figuren/GRADE_waves_',num2str(j),'.jpg');
        print -djpeg90  fig.jpg;
        copyfile('fig.jpg', plotfile);
        delete('fig.jpg');
        %     close (j+10000)
    end

 
        Waves_t2.org=Waves.aangepast;
        [Q2,t_rechts2,t_perc_rechts2,t_average_rechts2,t_links2,t_perc_links2,t_average_links2] =  middelen_t(Waves_t2, l, average);

    if toon_figuur==1;
        figure(j+1400)
        %eerste alleen voor de legenda
        plot (-25, 500,'m', 'linewidth',2);hold on; %voor legenda
        plot(-25, 500, 'b','LineWidth', 1); hold on; %voor legenda
        %     plot (-25, 500,'m-.', 'linewidth',2);hold on; %voor legenda
        plot(-l:l, Waves.geschaald, 'color',[0.68 0.93 1]); hold on;
        plot (t_average_links,Q,'m', 'linewidth',2);hold on;
        plot (t_average_rechts,Q,'m', 'linewidth',2);hold on;
        plot(-l:l, gemiddelde, 'b','LineWidth', 2); hold on;
        %     plot (t_perc_links2(3,:),Q2,'m-.', 'linewidth',2);hold on;
        %     plot (t_perc_rechts2(3,:),Q2,'m-.', 'linewidth',2);hold on;
        xlim([-25 25]);
        ylabel('discharge(m^3/sec)')
        xlabel('time (days)')
        title (['Standard hydrograph, interval= ' num2str(minimum) ' - ' num2str(maximum) ' m^3/s']);
        legend('mean wave (horizontal averaging)','mean wave (vertical averaging)','GRADE waves');
        grid on
        hold off
        plotfile=strcat('./figuren/Design_hydrograph_all_',num2str(j),'.jpg');
        % print('-dpdf', '-noui', '-cmyk', '-painters', 'fig.pdf');
        print -djpeg90  fig.jpg;
        copyfile('fig.jpg', plotfile);
        delete('fig.jpg');
        %     close (j+1000)

        figure(j+100000)
        plot (-25, 500,'b', 'linewidth',3);hold on; % voor legenda
        plot (-25, 500,'b', 'linewidth',1);hold on; % voor legenda
        plot (-25, 500,'r', 'linewidth',3);hold on; % voor legenda
        plot (-25, 500,'r', 'linewidth',1);hold on; % voor legenda
        plot(-l:l, Waves.geschaald, 'color',[0.68 0.93 1]); hold on;
        plot (t_perc_links,Q,'b', 'linewidth',1);hold on;
        plot (t_perc_rechts,Q,'b', 'linewidth',1);hold on;
        plot (t_perc_links(3,:),Q,'b', 'linewidth',3);hold on;
        plot (t_perc_rechts(3,:),Q,'b', 'linewidth',3);hold on;
        plot (t_perc_links2,Q2,'r', 'linewidth',1);hold on;
        plot (t_perc_rechts2,Q2,'r', 'linewidth',1);hold on;
        plot (t_perc_links2(3,:),Q2,'r', 'linewidth',3);hold on;
        plot (t_perc_rechts2(3,:),Q2,'r', 'linewidth',3);hold on;
        ylabel('discharge(m^3/sec)');
        xlabel('time (days)');
        legend('50%','5%,25%,75%,95%','50%:cut off','5%,25%,75%,95%:cut off', 'Grade waves');
        title (['Standard hydrograph (horizontal averaging), interval= ' num2str(minimum) ' - ' num2str(maximum) ' m^3/s']);
        xlim([-25 25]);
        hold off
        plotfile=strcat('./figuren/Design_hydrograph_average_t_3_',num2str(j),'.jpg');
        % print('-dpdf', '-noui', '-cmyk', '-painters', 'fig.pdf');
        print -djpeg90  fig.jpg;
        copyfile('fig.jpg', plotfile);
        delete('fig.jpg');
%         close(j+100000)
    end

    %---------------------------------------------------------------------
    %---------------------------------------------------------------------
    %volume uitrekenen
    dQ1=Q(2)-Q(1);
    dQ2=Q2(2)-Q2(1);
    %     for i=1:5
    %         volume_t1(i,1)=(sum(t_perc_rechts(i,:))+sum(t_perc_links(i,:))).*(dQ1*24*3600); %dt =1 dag
    %         volume_t2(i,1)=(sum(t_perc_rechts2(i,:))+sum(t_perc_links2(i,:))).*(dQ2*24*3600); %dt =1 dag
    %     end

    t_perc_rechts_sec= t_perc_rechts*24*3600;
    t_perc_links_sec= t_perc_links*24*3600;
    t_perc_rechts2_sec= t_perc_rechts2*24*3600;
    t_perc_links2_sec= t_perc_links2*24*3600;


    %     for i = 1:5
    %         volume_t1(i,1)=round(polyarea(t_perc_rechts_sec(i,:),Q))+round(polyarea(t_perc_links_sec(i,:),Q)); %volume golf
    %         volume_t2(i,1)=round(polyarea(t_perc_rechts2_sec(i,:),Q))+round(polyarea(t_perc_links2_sec(i,:),Q)); %volume golf
    %     end

    %hieronder worden de golven weer omgezet, dus om per tijdstip een
    %bijbehorende afvoer te genereren.
    dt=1;
    t_t_links=(-l:dt:0)';
    n=max(find(t_perc_links(3,:)<-25));
    Q_t_links= INTERP1(t_perc_links(3,n:end),Q(n:end),t_t_links,'linear');
    Q_t_av_links= INTERP1(t_average_links(1,n:end),Q(n:end),t_t_links,'linear');
    t_t_rechts=(dt:dt:l)';
    n=max(find(t_perc_rechts(3,:)>25));
    Q_t_rechts= INTERP1(t_perc_rechts(3,n:end),Q(n:end),t_t_rechts,'linear');
    Q_t_av_rechts= INTERP1(t_average_rechts(1,n:end),Q(n:end),t_t_rechts,'linear');
    Q_t=[Q_t_links; Q_t_rechts];
    Q_t_av=[Q_t_av_links; Q_t_av_rechts];
    t_t=[t_t_links; t_t_rechts];

    %zelfde alleen dan voor t2
    %     t_t_links2=(min(t_perc_links2(3,:)):dt:0)';
    t_t_links2=(-l:dt:0)';
    Q_t_links2= INTERP1(t_perc_links2(3,:),Q,t_t_links2,'linear');
    %     t_t_rechts2=(dt:dt:max(t_perc_rechts2(3,:)))';
    t_t_rechts2=(dt:dt:l)';
    Q_t_rechts2= INTERP1(t_perc_rechts2(3,:),Q,t_t_rechts2,'linear');
    Q_t2=[Q_t_links2; Q_t_rechts2];
    t_t2=[t_t_links2; t_t_rechts2];
    b=isnan(Q_t2);
    Q_t2(b)=0;


      %kansdichtheid berekenen, aantal keer van voorkomen.
    for i=1:length(Q) %per afvoerstap
        for n=1:length(t_t)-1 %per tijdstap
            aantal3(i,n)=length(find(t_links(:,i)<=t_t(n+1) & t_links(:,i)>t_t(n)));
            aantal4(i,n)=length(find(t_rechts(:,i)<=t_t(n+1) & t_rechts(:,i)>t_t(n)));
            aantal5(i,n)=length(find(t_links2(:,i)<=t_t(n+1) & t_links2(:,i)>t_t(n)));
            aantal6(i,n)=length(find(t_rechts2(:,i)<=t_t(n+1) & t_rechts2(:,i)>t_t(n)));
        end
    end

     
    %______________________________________________________________________
    dtop=5; % volume wordt bepaald 15 dagen voor en na de top
    %_____________________________________________________________________
    %_

    % Volume (gemiddelde Q
    a=ceil((length(percentielen(3,:))/2));
    xv1=[-dtop (tijd(a-dtop:a+dtop)') dtop -dtop];
    yv1=[0 percentielen(3,a-dtop:a+dtop) 0 0];
    volume_Q=(round(polyarea(xv1,yv1)))*3600*24; %tijdstap is een dag.

    % Volume (gemiddelde t
    a=ceil((length(Q_t)/2));
    xv2=[-dtop t_t(a-dtop:a+dtop)' dtop -dtop -dtop];
    yv2=[0 Q_t(a-dtop:a+dtop)' 0 0 0];
    volume_t=(round(polyarea(xv2,yv2)))*3600*24*dt;

    %volume bepalen, tijdstap is dt=1 dag.
    a=ceil((length(Q_t2)/2));
    xv3=[-dtop t_t2(a-dtop:a+dtop)' dtop -dtop];
    yv3=[0 Q_t2(a-dtop:a+dtop)' 0 0];
    volume_t2=(round(polyarea(xv3,yv3)))*3600*24*dt;
    % figure(33)
    %     plot(xv1,yv1,'r'); hold on;
    %     plot(xv2,yv2,'g--'); hold on;
    %     plot(xv3,yv3, 'b'); hold on;


    %     figure(3) %controle
    %     plot(tijd_stap,Q_nieuw);hold on;
    %     plot(t_perc_links(3,:),Q,'r'); hold on
    %     plot(t_perc_rechts(3,:),Q,'r'); hold on

    result{j}.volume_t=volume_t;
    result{j}.volume_t2=volume_t2;
    result{j}.volume_Q=volume_Q;
    result{j}.t_t=t_t;
    result{j}.t_t2=t_t2;
    result{j}.Q_t=Q_t; %mediaan
    result{j}.Q_t_av=Q_t_av; %mean
    result{j}.Q_t2=Q_t2;
    result{j}.Q_Q=gemiddelde;%mean
    result{j}.percentielen=percentielen; %5%,25%,mediaan, 75%,95%
    result{j}.t_Q=-l:l;
    result{j}.min=minimum;
    result{j}.max=maximum;
    result{j}.normdistr_5=normdistr_5;
    result{j}.normdistr_95=normdistr_95;

    %%% plotjes maken van volume voor verschillende dtop
    start=1;
    einde=15;
    dtop_all=start:1:einde;
    legenda=num2str(start);
    for top =start:1:einde %volume voor 1 tot 15 dagen voor en na de top
        [volume_t] = volumes_t(Q_t, t_t, top, dt); %mediaan(percentielen)
        volume_dtop(top,1)=volume_t;
        [volume_t] = volumes_t(Q_t_av, t_t, top, dt); %average
        volume_dtop(top,2)=volume_t;
        %         [volume_t2] = volumes_t2(Q_t2, t_t2, top, dt);
        %         volume_dtop(top,3)=volume_t2;
        mediaan=percentielen(3,:);
        [volume] = volumes(mediaan, top, tijd);  %percentielen
        volume_dtop(top,3)=volume;
        [volume] = volumes(gemiddelde, top, tijd); %average
        volume_dtop(top,4)=volume;
        
        %volume gesimuleerde golven
        for a=1:1:length(Waves.geschaald);
        golf=Waves.geschaald(a,:);
        [volume] = volumes(golf, top, tijd); %average
        volume_synthethisch(top,a)=volume;
        end
        volume_synthethisch(top,:)=sort(volume_synthethisch(top,:));
    end
    
    if toon_figuur==1;
    n=(1:length(Waves.geschaald))-0.5;
    Pz  = 1-(n/length(Waves.geschaald));  %probability of exceedance 
    figure();
    plot(volume_synthethisch,1-Pz); hold on;
    plot(volume_dtop(:,1),0.5,'.');hold on; %median
    plot(volume_dtop(:,2),0.5,'o');hold on;    %average
    plot(volume_dtop(:,3),0.5,'+');hold on; %median
    plot(volume_dtop(:,4),0.5,'x');hold on;    %average
%     plot([volume_dtop(:,3),volume_dtop(:,3)],[0,1],'--');hold on; %median
%     plot([volume_dtop(:,4),volume_dtop(:,4)],[0,1],'.-');hold on;    %average
    legend('dt=1day','dt=2days','dt=3days','dt=4days','..');
    end
    
    if toon_figuur==1;
        b=0;
        figure(a+2100);
        for a=[1,5,10,15];
            b=b+1;            
            subplot(2,2,b);plot(volume_synthethisch(a,:),Pz); hold on;
            plot(mean(volume_synthethisch(a,:)), 0.5,'o'), hold on;
            plot(volume_dtop(a,1),0.5,'r.');hold on; %median
            plot(volume_dtop(a,2),0.5,'ro');hold on;    %average
            plot(volume_dtop(a,3),0.5,'r+');hold on; %median
            plot(volume_dtop(a,4),0.5,'rx');hold on;    %average
            if b==4;
            legend('distribution of volume','average volume','horizonal averaging mediaan','horizonal averaging mean','vertical averaging mediaan','vertical averaging mean');
            end
            title( ['dt= ' num2str(a) 'days'])
            ylabel('Probablility of exceedance (-)')
            xlabel('Volume (m^3)')
        end
    end

 
    if toon_figuur==1;
        figure(j+1900)
        bar (volume_dtop); hold on; colormap summer;%winter;
        boxplot(volume_synthethisch');hold on
        legend ('horizonal averaging median','horizonal averaging mean','vertical averaging median','vertical averaging mean', 'box plot synthetic waves')
        %     legend ('method 1: average Q per timestep','method: average time per dischargestep','volume (average time, adapted)')
        title (['Volume calculated , interval= ' num2str(minimum) ' - ' num2str(maximum) ' m^3/s']);
        ylabel('Volume (m^3)')
        xlabel('days prior and after the peak')
        % set(gca,'XTickLabel',tekst)
    end
end




kleur= [1 0 0;0 0 1;0.8 0.8 1;0 0.5 0;0.5 0.1 0.9;1 0.7 0.4; 1 0 1;0.6 0.6 1;0.2 0.4 1;0.6 0.6 0.1;0.3 0.3 1 ];


%figuur plotten met
figure(2000)
for i=1:j
    plot(result{i}.t_t, result{i}.Q_t_av,'color',kleur(i,:),'linewidth',2,'linestyle','--'); hold on;
    plot(result{i}.t_Q, result{i}.Q_Q,'color',kleur(i,:),'linewidth',2,'linestyle','-'); hold on;
    %     plot(result{i}.t_t2, result{i}.Q_t2,'color',kleur(i,:),'linestyle','-.'); hold on;
    %     legend_text(i)= (['average time' num2str(minimum) ' - ' num2str(maximum) ' m^3/s'], ['average Q' num2str(minimum) ' - ' num2str(maximum) ' m^3/s'])
end
% legend('average Q per timestep','average time per Qlevel','average time per Qlevel, adapted')
legend('horizontal averaging','vertical averaging')
title ('mean wave per interval')
ylabel('discharge (m^3/sec)')
xlabel('time (days)')


schaal_Q=result{j}.Q_Q.*(max(result{1}.Q_Q)/max(result{j}.Q_Q));
%figuur plotten met
figure(3000)
plot(result{i}.t_Q, schaal_Q,'r','linestyle','-','LineWidth', 2); hold on;
plot(result{j}.t_Q, result{j}.Q_Q,'r--'); hold on;
for i=1:j
    plot(result{i}.t_Q, result{i}.Q_Q,'b','linestyle','-'); hold on;
end
plot(result{j}.t_Q, result{j}.Q_Q,'r--'); hold on;
legend('1900 m^3/s wave scaled up','1900 m^3/s wave','wave per interval')
title ('design wave per interval (average Q per timestep)')
ylabel('discharge (m^3/sec)')
xlabel('time (days)')

%figuur plotten met
figure(3500)
% plot(result{i}.t_Q, schaal_Q,'r','linestyle','-','LineWidth', 2); hold on;
% plot(result{j}.t_Q, result{j}.Q_Q,'r--'); hold on;
for i=1:j
    plot(result{i}.t_Q, result{i}.Q_Q); hold on;%,'b','linestyle','-'); hold on;
end
% plot(result{j}.t_Q, result{j}.Q_Q,'r--'); hold on;
% legend('1900 m^3/s wave scaled up','1900 m^3/s wave','wave per interval')
title ('design wave per interval (vertical averaging)')
ylabel('discharge (m^3/sec)')
xlabel('time (days)')


load design_hydrograph
schaal_Q=result{1}.Q_Q.*(3800/max(result{1}.Q_Q));
schaal_percentielen=result{1}.percentielen.*(3800/max(result{1}.Q_Q));
% schaal_percentielen2=result{1}.percentielen2.*(3800/max(result{1}.Q_Q));
figure(4000)
plot(result{1}.t_Q, schaal_Q,'b','Linewidth',2); hold on;
plot(result{1}.t_Q, result{j}.normdistr_5,'b--','Linewidth',1); hold on; % log normal distributed
plot(result{1}.t_Q, schaal_percentielen(3,:),'m','Linewidth',2); hold on;    %percentielen  
plot(result{1}.t_Q, schaal_percentielen(1,:),'m--','Linewidth',1); hold on;    %percentielen 
plot(result{1}.t_Q, result{j}.normdistr_95,'b--','Linewidth',1); hold on; % log normal distributed
plot(result{1}.t_Q, schaal_percentielen(end,:),'m--','Linewidth',1); hold on;     %percentielen 
legend('mean ','90% uncertainty interval (log normal)','median','90% uncertainty interval (percentiles)')
% title ('design wave per interval (average over Q)')
ylabel('discharge (m^3/sec)')
xlabel('time (days)')





for i=1:j
    a(i,1)=result{i}.volume_t;
    a(i,2)=result{i}.volume_Q;
%     a(i,3)=result{i}.volume_t2;

    d(i,1)=result{i}.min;
    d(i,2)=result{i}.max;
end

% tekst=[num2str(result{i}.min) ' - ' num2str(result{i}.min) ' m^3/s'];
% for i=2:j
%     tekst={tekst; [num2str(result{i}.min) ' - ' num2str(result{i}.min) ' m^3/s']};
% end

figure(5000)
bar (a); hold on;
legend('horizontal averaging','vertical averaging')
colormap winter
title (['Volume calulated ' num2str(dtop) ' days prior and after the peak'] )
ylabel('Volume (m^3)')
xlabel('Class')
% set(gca,'XTickLabel',tekst)
%
