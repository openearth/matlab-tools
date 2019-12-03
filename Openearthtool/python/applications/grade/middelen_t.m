function [Q,t_rechts,t_perc_rechts,t_average_rechts,t_links,t_perc_links,t_average_links] =  middelen_t(Waves, l, average)

%schalen golven naar 1
    for i=1:length(Waves.org)
        Waves.geschaald1(i,:)=Waves.org(i,:)./(Waves.org(i,l+1)) ;
    end
    
    %interpoleren naar kleinere tijdsstappen
    N_stormen=length(Waves.geschaald1);
    tijd=(-l:1:l)';
    dt=0.01;
    tijd_stap=(-l:dt:l)';
    % clear pieken;
    for i=1:N_stormen
        pieken.org(:,i)= INTERP1(tijd,Waves.geschaald1(i,:),tijd_stap,'linear');     
    end

    %check
    %     plot(tijd_stap,pieken(:,1)); hold on; plot(tijd,Waves.geschaald(1,:),'r-')

    max_wave=max(max(Waves.geschaald1));
    dQ1=0.01;
    Q1=0:dQ1:max_wave;
    tnul=ceil((length(tijd_stap))/2);

    %     %aanpassen golven 1cm onder top optrekken naar top vanaf 0.1 cm onder
    %     %top. Dit is alleen nodig voor uurdata, dus niet van belang.
    %     pieken.aangepast1=pieken.org;
    %     for i=1:1%N_stormen
    %         %links
    %         b1=min(find(pieken.aangepast1(1:tnul,i)>0.99));
    %         for s=(tnul-1):-1:b1
    %             pieken.aangepast1(s,i)=1;
    %         end
    %         b2=min(find(pieken.aangepast1(1:tnul,i)>0.9));
    %         dQl=0.1/(b2-b1);
    %         for s=(b1+1):-1:b2;
    %             pieken.aangepast1(s,i)=pieken.aangepast1(s+1,i)+dQl;
    %         end
    %         %rechts
    %         a1=(max(find(pieken.aangepast1(tnul:end,i)>0.99)))+tnul;
    %         for s=(tnul+1):1:a1
    %             pieken.aangepast1(s,i)=1;
    %         end
    %         a2=(max(find(pieken.aangepast1(tnul:end,i)>0.9)))+tnul;
    %         dQr=0.1/(a2-a1);
    %         for s=(a1+1):a2;
    %             pieken.aangepast1(s,i)=pieken.aangepast1(s-1,i)-dQr;
    %         end
    %     end
    %
    %     figure(12)
    %     plot(tijd_stap,pieken.org(:,1:1),'r'); hold on;
    %     plot(tijd_stap,pieken.aangepast1(:,1:1),'b');
    %     legend ('org', 'aangepast');

    %turven van aantal dagen dat golf boven X uitkomt

    %     %links golf
    %     for i=1:length(Q1) % per afvoer:
    %         Nt_links(i,1)=length(find(pieken(1:tnul,:)>=Q1(i)));
    %     end
    %     %rechts golf
    %     for i=1:1:length(Q1)
    %         Nt_rechts(i,1)=length(find(pieken((tnul):length(tijd_stap),:)>=Q1(i)));
    %     end
    %     golf_links=-(Nt_links*dt)./N_stormen;
    %     golf_rechts=(Nt_rechts*dt)./N_stormen;

    %links golf
    for k=1:N_stormen % per storm
        for i=1:length(Q1) % per afvoer:
            Nt_links(i,k)=length(find(pieken.org(1:tnul,k)>Q1(i)));
        end
    end
    t_links=-(dt.*Nt_links);
    t_perc_links = (prctile(t_links',[5 25 50 75 95]));
    t_average_links=mean(t_links');

    %rechts golf
    for k=1:N_stormen % per storm
        for i=1:length(Q1) % per afvoer:
            Nt_rechts(i,k)=length(find(pieken.org(tnul:length(tijd_stap),k)>Q1(i)));
        end
    end
    t_rechts=(dt.*Nt_rechts);
    t_perc_rechts = (prctile(t_rechts',[5 25 50 75 95]));
    t_average_rechts=mean(t_rechts');

    Q=Q1*average;

    
    