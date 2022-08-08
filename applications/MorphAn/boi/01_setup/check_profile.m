clear all
close all
%% input
Hm0                 = 9; %10;
Tp                  = 16; %17;
d_profile           = 9; %28;
d_randvoorwaarde    = 20;

%% compute Hm0,shoal
[cg_BC dummy]                   = wavecelerity(Tp, d_randvoorwaarde);
[cg_profile n_profile]          = wavecelerity(Tp, d_profile);

Hm0_shoal                       = Hm0 * sqrt(cg_BC/cg_profile);

%% check

if Hm0_shoal/d_profile<0.3 & n_profile<0.9
    disp('no changes required')
    fprintf('Hm0,shoal=%2.2f\n',Hm0_shoal)
    fprintf('d_{start}=d_{profile}=%2.2f\n',d_profile)
    fprintf('Hm0,shoal/d=%2.2f\n',Hm0_shoal/d_profile)
    fprintf('n=%2.2f\n',n_profile)
else
    % --- compute d_start en Hm0,shoal iterative
    figure()
    d_start = d_profile;
    d_start_previous =  2* d_profile;
    count = 1;
    % --- d_n: depth for which n=0.9
    d_n         = celerity_ratio_equals_09(Tp,d_start);
    while abs(d_start-d_start_previous)>0.05

        % ---
        d_start_previous            = d_start;
        % --- 
        d_start                     = max(3.33333*Hm0_shoal, d_n);
        % --- compute Hm0,shoal
        [cg n_startdepth]           = wavecelerity(Tp, d_start);
        Hm0_shoal                   = Hm0 * sqrt(cg_BC/cg);
        subplot(2,1,1)
        plot(count,Hm0_shoal,'ro'); hold on
        subplot(2,1,2)
        plot(count,d_start,'ro'); hold on
        plot(count,d_start,'bo'); hold on
        count = count + 1;
        if count>20
            disp('error')
            break            
        end
    end
    % ---
    if Hm0_shoal/d_profile>0.3 & n_profile>0.9
        disp('Artificial slope of 1:50')
    else
        disp('Artificial slope of 1:10')
    end
    fprintf('Hm0,shoal=%2.2f\n',Hm0_shoal)
    fprintf('d_{start}=%2.2f\n',d_start)
    fprintf('Hm0,shoal/d_{slope}=%2.2f\n',Hm0_shoal/d_profile)
    fprintf('Hm0,shoal/d_{start}=%2.2f\n',Hm0_shoal/d_start)
    fprintf('n(d_{slope})=%2.2f\n',n_profile)
    fprintf('n(d_{start})=%2.2f\n',n_startdepth)
end

figure;
fill([0 0.3 0.3 0],[0 0 0.9 0.9],'r','facealpha',0.2)
hold on
fill([0.3 1 1 0.3],[0 0 0.9 0.9],'b','facealpha',0.2)
fill([0 0.3 0.3 0],[0.9 0.9 1 1],'m','facealpha',0.2)
fill([0.3 1 1 0.3],[0.9 0.9 1 1],'y','facealpha',0.2)
plot([0 1],[0.9 0.9],'r--','linewidth',2)
plot([0.3 0.3],[0.5 1],'r--','linewidth',2)
plot(Hm0_shoal/d_start,n_startdepth,'o')
hold on
plot(Hm0_shoal/d_profile,n_profile,'o')
ylim([0.5 1])
xlabel('H_{m0,shoal0/d}')
ylabel('n=c_g/c')
%%

function d = celerity_ratio_equals_09(Tp,d_start)
	d_dummy = d_start;
    count2   = 1;
    n       = 1;
    while n>0.9
        [cg n] = wavecelerity(Tp, d_dummy);
        d_dummy = d_dummy + 0.05;
        count2 = count2+1;
        if count2>500
            disp('error')
            break 
        end
    end
    d = d_dummy;
end


function [cg n] = wavecelerity(Tp, d)
    g = 9.81;
    k   = disper(2*pi./Tp, d, g);
    n   = .5*(1+2.*k.*d./sinh(2.*k.*d));
    c   = g.*Tp./(2*pi).*tanh(k.*d);
    cg  = n.*c;

end