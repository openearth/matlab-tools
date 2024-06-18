
%close all;
clear;

U = 0.1;
karman = 0.4;
H = 1;
R = -719.9989; %inf; %10000000; %719.9989; %-500;
ks = 0.05;
nu_num = 1e-16;
g      = 9.81;
anglat = 52; % angle of latitude

[ust,z0] = calcz0min(H,U);
if ks > 30*z0;
    z0  = ks/30;
    Cf  = ((log(H/z0) - (H-z0)/H)/karman)^(-2);
    ust = sqrt(Cf)*U;
else
    [ust,z0] = calcz0min(H,U);
end
gridtypes = 7; %[1:2,4:7];
for j = 3:6;
    for gridtype = gridtypes

        z{j,gridtype} = makegrid(20*2^j,gridtype,z0,H);
        Ss0 = -Cf*U^2/g/H;
        N(j,gridtype) = length(z{j,gridtype})-1;

        [A,ddz] = makematrix2(z{j,gridtype},H,nu_num);
        [d] = makerhs(Ss0,g,H,N(j,gridtype),karman,ust,U);
        [fs{j,gridtype}] = tdsol(A,d);

        X1  = (fs{j,gridtype}(1:end-1)+fs{j,gridtype}(2:end))*ddz*0.5/H;

        %Adjust slope such that mean velocity u = 1;
        Ss1 = Ss0*U/X1;
        [c] = makerhs(Ss1,g,H,N(j,gridtype),karman,sqrt(Cf)*U,U);
        fs{j,gridtype} = tdsol(A,c);

        d1  = makerhn1(karman,sqrt(Cf)*U,fs{j,gridtype},R);
        fn1 = tdsol(A,d1);
        d2  = makerhn2(1,g,N(j,gridtype),karman,sqrt(Cf)*U);
        fn2 = tdsol(A,d2);
        d3  = makerhn3(karman,ust,fs{j,gridtype},anglat);
        %d3  = makerhn4(karman,ust,U,N(j,gridtype),anglat);
        fn3 = tdsol(A,d3);
        Y1  = (fn1(1:end-1)+fn1(2:end))*ddz*0.5/H;
        Y2  = (fn2(1:end-1)+fn2(2:end))*ddz*0.5/H;
        Y3  = (fn3(1:end-1)+fn3(2:end))*ddz*0.5/H;
        %Adjust slope such that mean transverse velocity u_n = 0;
        Sn = -(Y1+Y3)/Y2;
        fn{j,gridtype} = fn1 + fn3 + Sn*fn2; 

        [fse{j,gridtype},fne{j,gridtype}] = fsfnexact(H,R,ust,z0,karman,z{j,gridtype});

        figure(j);
        
        subplot(121)
        title('Streamwise velocity')
        plot(fse{j,gridtype},z{j,gridtype}, 'displayname','exact')
        hold on;
        plot(fs{j,gridtype},z{j,gridtype},'displayname','solution')
        grid on; 
        box on;
        legend;
        xlabel('u_s (m/s)')
        ylabel('elevation (m)')
        subplot(122)
        title('Transverse velocity')
        plot(fne{j,gridtype},z{j,gridtype}, 'displayname','exact')
        hold on;
        plot(fn{j,gridtype},z{j,gridtype},'displayname','solution')
        grid on; 
        box on;
        legend;
        xlabel('u_n (m/s)')
        ylabel('elevation (m)')

        Es(j,gridtype) = trapz(z{j,gridtype},abs(fs{j,gridtype}-fse{j,gridtype}));
        En(j,gridtype) = trapz(z{j,gridtype},abs(fn{j,gridtype}-fne{j,gridtype}));
    end
end
%%
figure;
clf;
hold on;
for gridtype = gridtypes;
    plot(N(:,gridtype),Es(:,gridtype),'DisplayName',sprintf('gridtype = %i', gridtype));
end
hold off;
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('grid points')
ylabel('error')
legend
grid on;
box on;
print( '-dpng', '-r300', 'streamwise_convergence.png')

figure;
clf;
hold on;
for gridtype = gridtypes;
    plot(N(:,gridtype),En(:,gridtype),'DisplayName',sprintf('gridtype = %i', gridtype));
end
hold off;
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('grid points')
ylabel('error')
legend
grid on;
box on;
print( '-dpng', '-r300', 'transverse_convergence.png')
%%
figure;
clf;
hold on;
j = 2;
for gridtype = gridtypes;
    plot(z{j,gridtype},'.-','DisplayName',sprintf('gridtype = %i', gridtype));
end
%xlim([1 N(j, gridtype)])
xlabel('grid index')
ylabel('elevation')
legend('Location', 'Best')
grid on;
box on;
print( '-dpng', '-r300', 'gridtypes.png')


% subplot(122)
% title('Transverse velocity')
% plot(fne,z,fnS,z)