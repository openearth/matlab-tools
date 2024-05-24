function [fsS,fnS] = scbsol(U,H,R,ust,z0,alfs,z,fse,fne);
%% User settings;
karman = 0.4;
nu_num = 1e-16;
g      = 9.81;
acceps = 1e-6;%


Cf  = ((log(H/z0) - (H-z0)/H)/karman)^(-2);
J = length(z)-1;
    %% Solve streamwise solution
%    count = count + 1;
%    z=makegrid(J,gridtype,z0,H);
    %Build matrix
 [B,ddz] = makematrix2(z,H,nu_num);
    %Calculate friction factor
%    Cf2 = ((log(H/z0) - (H-z0)/H)/karman)^(-2);
    %Cf2 = (log(H/ks)/karman+8.5)^(-2);
    %Calculate equilibrium slope since we ignore convective terms u*dudx;
    Sb2 = -Cf*U^2/g/H;
    %Determine exact solutions.
%    [fse,fne,Sne,ee] = fsfnexact(H,g,Sb2,R,sqrt(Cf2)*U,nu,nu_num,karman,z0,z,ddz);
    %Build righthand side
%     [c] = makerhs(Sb2,g,H,J,karman,sqrt(Cf)*U,U);
%     %Solve matrix
%     fs = tdsol(B,c');
%     %Calculate mean velocity;
%     X1  = (fs(1:end-1)+fs(2:end))*ddz*0.5/H;
%     %Adjust slope such that mean velocity u = 1;
%     knt = 0;
%     Sb3 = Sb2*U/X1;
%     [c] = makerhs(Sb3,g,H,J,karman,sqrt(Cf)*U,U);
%     fs = tdsol(B,c');
%     %Solve transverse solution
%     %Solve rhs
%     d1  = makerhn1(karman,sqrt(Cf2)*U,fs,R);
%     fn1 = tdsol(B,d1);
%     d2  = makerhn2(1,g,J,karman,sqrt(Cf2)*U);
%     fn2 = tdsol(B,d2);
%     Y1  = (fn1(1:end-1)+fn1(2:end))*ddz*0.5/H;
%     Y2  = (fn2(1:end-1)+fn2(2:end))*ddz*0.5/H;
%     %Adjust slope such that mean transverse velocity u_n = 0;
%     Sn = -Y1/Y2;
%     fn = fn1 + Sn*fn2;
%     %
%     error(count,1) = 0.5*abs((fse(2:end)+fse(1:end-1))-(fs(2:end)+fs(1:end-1))).^2*ddz/H; %
%     error(count,2) = 0.5*abs((fne(2:end)+fne(1:end-1))-(fn(2:end)+fn(1:end-1))).^2*ddz/H; %
%     maxerror(count,1) = max(abs(fse-fs));%
%     maxerror(count,2) = max(abs(fne-fn));%
%     fnmcb = fn;
%     fsmcb = fs;
%     SnC(count) = Sn;
%     SneC(count) = Sne;
%     acceps = error(count,1); %1e-15;%
% 
%     fsn = fs.*fn;
%     fsnda(1)=(fsn(1:end-1)+fsn(2:end))*ddz*0.5/H;
%     fss= (fs).^2;
%     fssda(1)=(fss(1:end-1)+fss(2:end))*ddz*0.5/H;
%     taubs0 = H*g*Sb2;                            %rho neglected
%     taubn0 = 0;%*(H*g*Sn  -            fssda(1)*H/R);  %rho neglected
%     taumcb= sqrt(taubs0^2+taubn0^2);
% 
%     ZS0 = (fsn(1:end-1)+fsn(2:end))*ddz*0.5/H;
%     %% Solve nonlinear solution
     count2 = 0;

    %            ffe = sqrt(fse.^2+fne.^2);
    %            pffe = polyfit(z(1:3),(ffe(1:3)),2);
    %            pffe2= [2*pffe(1),pffe(2)];
    %            psie = polyval(pffe2,z0);
    %for alphas = [-1:0.005:-0.96,-0.95:0.1:0.95,1:0.2:12.5];
    %alfs = 2*abs(R/W);
    Cf3 = Cf;
    for alphas = [alfs,alfs,alfs]; %[-1:0.001:-0.99,-0.98:0.01:-0.9,-0.6:0.3:3,4:12];%12.5];
        count2 = count2+1;
        acc = 2;
        %X1  = (fs(1:end-1)+fs(2:end))*ddz*0.5/H/U;
        Sb3 = Sb2;%/(X1);
        knt = 0;
        maxiter = 200;
        %fs0 = fse;
        %fn0 = fne;
        fs  = fse;
        fn  = fne;
        while (abs(acc) > acceps & knt < maxiter); %for kk = 1:21;
            knt = knt+1;
            fsn = fs.*fn;
            [c1] = makerhs(Sb3,g,H,J,karman,sqrt(Cf3)*U,U);
            fs1  = tdsol(B,c1');
            [c2] = makerhs3(0,g,H,J,karman,sqrt(Cf3)*U,U,fsn,alphas,R);
            fs2  = tdsol(B,c2');
            X1  = (fs1(1:end-1)+fs1(2:end))*ddz*0.5/H;
            X2  = (fs2(1:end-1)+fs2(2:end))*ddz*0.5/H;
            Sb3 = Sb3*(U-X2)/X1;
            t = 0.975;%+0.05*rand();   %Relaxation behaviour
            fs0  = fs;
            fs  = t*fs0+(1-t)*(fs2+((U-X2)/X1)*fs1);
            XS  = (fs(1:end-1)+fs(2:end))*ddz*0.5/H;
            %                 figure(5)
            %                 subplot(2,2,1:2);
            %                 hold on;
            %                 plot(taubs,taubn,'x')
            %                 subplot(223);
            %                 hold off;
            %                 plot(fse,z,fs0,z,fs,z);
            %                 subplot(224);
            %                 hold off;
            %                 plot(fne,z,fn0,z,fn,z);
            %acc = (U-X2)/X1-1;
            acc = max(fs0-fs);
            %acc = trapz(z,abs(fs0-fs));
            d1  = makerhn1(karman,sqrt(Cf3)*U,fs,R);
            %d3  = makerhn1(karman,sqrt(Cf3)*U,fn0,R);
            fn1 = tdsol(B,d1);%+tdsol(B,d3);
            d2  = makerhn2(1,g,J,karman,sqrt(Cf3)*U);
            fn2 = tdsol(B,d2);
            Y1  = (fn1(1:end-1)+fn1(2:end))*ddz*0.5;
            Y2  = (fn2(1:end-1)+fn2(2:end))*ddz*0.5;
            Sn  = -Y1/Y2;
            fn  = fn1 + Sn*fn2;
            fn0 = fn;
           % YS  = (fn(1:end-1)+fn(2:end))*ddz*0.5;
           % ff  = sqrt(fs.^2+fn.^2);
            %                    pff = polyfit(z(1:3),(ff(1:3)),2);
            %                    pff2= [2*pff(1),pff(2)];
            %                    psi = (polyval(pff2,z0))/psie;

            fsn = fs.*fn;
            fsnda(count2)=(fsn(1:end-1)+fsn(2:end))*ddz*0.5/H;
            fss= (fs).^2;
            fssda(count2)=(fss(1:end-1)+fss(2:end))*ddz*0.5/H;
            taubs = (H*g*Sb3 + (alphas+1)*fsnda(count2)*H/R);  %rho neglected (sign correct?)
            taubn = (H*g*Sn  -            fssda(count2)*H/R);
            tauscb= sqrt(taubs^2+taubn^2);
            psi   = tauscb/(Cf*U^2);%tauscb/abs(taubs0); %taubs/taubs0; %1; %%taumcb; %% Cf2/U/U*H;
%            alft  = atan(sqrt(abs(taubs/taubn)));%psi = sqrt(fs(2).^2+fn(2).^2)/sqrt(fse(2).^2);
            %psi = sqrt(fs(2).^2)/sqrt(fse(2).^2);
            Cf3 = psi*Cf; %
            %                phis = fs(2)/sqrt(fs(2).^2+fn(2).^2);
            %                phin = fn(2)/sqrt(fs(2).^2+fn(2).^2);
        end
%            disp(['Psi = ', num2str(psi)])
%        disp(num2str(1/sqrt(Cf3)));
%        betat(count2)= sign(alphas+1)*((H/R)^2/Cf3^1.1*abs(alphas+1))^0.25;
%        betaq(count2)= sign(alphas+1)*((H/R)^2/Cf3^1.1*abs(alphas+1))^0.25*Cf3^0.15;
%        beta2(count2)= sign(alphas+1)*((H/R)^2/Cf2^1.0*abs(alphas+1));
%        psi2(count2)  = sqrt(psi);
%        alft2(count2) = alft;
%        ustb(count2) = sqrt((fs(2))^2+(fn(2))^2)/ddz(1);
%        alftau(count2) = (fn(2))^2/(fs(2))^2;
%        conver(count2) = knt;

 %       if sum(isnan(fs))==0;
 %           disp([alphas,acc,knt])
 %       end
    end
%end
%end
% fsne= fse.*fne;
%
% betaS = betat(end);
% usunS = fsnda(end);
% usunM = (fsne(1:end-1)+fsne(2:end))*ddz*0.5/H;
%
% fssq= (fs-U).^2;
% usS = (fssq(1:end-1)+fssq(2:end))*ddz*0.5/H;
% fnnq= fn.*fn;
% unS = (fnnq(1:end-1)+fnnq(2:end))*ddz*0.5/H;
%
% fsseq= (fse-U).^2;
% useS = (fsseq(1:end-1)+fsseq(2:end))*ddz*0.5/H;
% fnneq= fne.*fne;
% uneS = (fnneq(1:end-1)+fnneq(2:end))*ddz*0.5/H;
%
%
 fnS = fn;
 fsS = fs;

% fseS= fse;
% fneS= fne;
% zS  = z;
% Cf  = Cf3;

% if length(Jcnt)>1
%     %     figure(2)
%     %     loglog(Jcnt,error,'-s',Jcnt,maxerror,'-o')
%     %     axis tight
%     %     xlabel('Number of grid points')
%     %     ylabel('L^2 error')
%     %     legend('Streamwise L2 error',...
%     %         'Transverse L2 error','Streamwise Max error',...
%     %         'Transverse Max error','Location','NorthEast')
%     %
%     %     figure(3)
%     %     semilogx(Jcnt,SnC,'-s',[min(Jcnt),max(Jcnt)],[Sne,Sne])
%     %     ylabel('Sn')
%     %     ylabel('Transverse slope (Sn)')
%     %     xlabel('Number of grid points')
%     %     legend('Numerical','Exact')
%
%     %    figure(5);
%     %    plot(18*log10(12*H./[0.1*2.^(-1.*(-2:0.1:6))]),betat)
% end

%145 degrees, (channel axis), Blokland.
%z = [0.35, 0.59, 0.95, 1.35 1.85, 2.50, 3.20, 3.85, 4.45, 4.85]/100;
%u = [22.51, 24.46, 26.05, 27.45, 28.38, 29.04, 29.18, 28.90, 28.56, 28.47]/100;
%v = [-2.728, -2.728, -2.115, -1.559, -0.825, 0.203, 1.077, 1.655, 1.956, 2.062]/100;
%figure(1)
%subplot(121)
%hold on; plot(u,z,'x');
%subplot(122)
%hold on; plot(v,z,'x');

% figure(4);
% plot(-SsC.*g.*HH./UU.^2,CCf,'o');
% xlabel('-SsC.*g.*HH./UU.^2')
% ylabel('Cf')
%
% figure(5);
% plot(UU.*HH./RR,II,'o');
%
% figure(101)
% hold on;
% plot(betat,fsnda/fsnda(1),'.');
% xlabel('Bend parameter (\beta)')
% ylabel('<u_su_n>_infty/<u_su_n>_0')
% ylabel('<u_su_n>_\infty/<u_su_n>_0')
% plot([0.4 0.4],[0 1],'r-')
% plot([0.8 0.8],[0 1],'r-')
% grid on;
% ylim([0 1]);
% xlim([0 2.5]);
%
% figure(111)
% hold on;
% plot(betat,(fsnda/fsnda(1)),'.');
% %plot(xb,0.5*xb.*exp(-(2.5*xb).^(-1.5))+1,'k-')
% xlabel('Bend parameter (\beta)')
% ylabel('<u_su_n>_infty/<u_su_n>_0')
% ylabel('<u_su_n>_\infty/<u_su_n>_0')
% plot([0.4 0.4],[0 1],'r-')
% plot([0.8 0.8],[0 1],'r-')
% grid on;
% ylim([0 1]);
% xlim([0 2.5]);
%
% figure(102)
% hold on;
% plot(beta2,fsnda/fsnda(1),'.');
% xlabel('[(H/R)^2(\alpha_s+1)]^{0.25}')
% ylabel('<u_su_n>_infty/<u_su_n>_0')
% ylabel('<u_su_n>_\infty/<u_su_n>_0')
% grid on;
% ylim([0 1]);
% xlim('auto');
%
% figure(103);
% hold on;
% %                plot(((H/R)^2/Cf3^1.1*(alphas+1))^0.25*Cf3^0.15,sqrt(psi),'b.')
% plot(betaq,psi2,'b.')
% ylim([1 1.5])
% xlabel('\beta*C_f^{0.15}')
% ylabel('(\Psi_\infty)^{0.5} = (\tau_{bs}/\tau_{bs0})^{0.5}');%ylabel('(\Psi_\infty)^{0.5}')
% grid on;
%
% figure(104);
% hold on;
% %                plot(((H/R)^2/Cf3^1.1*(alphas+1))^0.25*Cf3^0.15,sqrt(psi),'b.')
% plot(beta2,psi2,'b.')
% ylim([1 1.5])
% xlim([0 0.6])
% xlim('auto')
% xlabel('[(H/R)^2(\alpha_s+1)]^{0.25}')
% ylabel('(\Psi_\infty)^{0.5} = (\tau_{b}/\tau_{b0})^{0.5}');%ylabel('(\Psi_\infty)^{0.5}')
% grid on;
%
%
% figure(105);
% %                plot(((H/R)^2/Cf3^1.1*(alphas+1))^0.25*Cf3^0.15,sqrt(psi),'b.')
% taumcb= sqrt(taubs0^2+taubn0^2);
% tauscb= sqrt(taubs^2+taubn^2);
% subplot(221)
% hold on;
% grafac = 1000;
% b = Cf2*U^2*H/R*2/karman/karman*(1-sqrt(Cf2)/karman)*grafac;
% plot(b,abs(taubn0)*grafac,'b.',b,abs(taubn)*grafac,plotstr)
% xlabel('C_fU^2 2H/R/\kappa^2*(1-C_f^{0.5}/\kappa)*10^3')
% ylabel('\tau_{bn}*10^3')
% grid on;
% axis equal
% axis square
% subplot(222)
% hold on;
% b = Cf2*U^2*grafac;
% plot(b,abs(taubs0)*grafac,'b.',b,abs(taubs)*grafac,plotstr)
% xlabel('C_fU^2*10^3')
% ylabel('\tau_{bs}*10^3');%ylabel('(\Psi_\infty)^{0.5}')
% grid on;
% axis equal
% axis square
% subplot(2,2,3)
% hold on;
% b = Cf2*U^2*sqrt(1+(H/R*2/karman/karman*(1-sqrt(Cf2)/karman))^2)*grafac;
% plot(b,abs(taumcb)*grafac,'b.',b,abs(tauscb)*grafac,plotstr)
% xlabel('C_fU^2(1+(2H/R/\kappa^2*(1-C_f^{0.5}/\kappa))^2)^{0.5}*10^3')
% ylabel('\tau_b*10^3')
% grid on;
% axis equal
% axis square
% subplot(2,2,4)
% hold on;
% b = Cf2*U^2*grafac;
% plot(b,abs(taumcb)*grafac,'b.',b,abs(tauscb)*grafac,plotstr)
% xlabel('C_fU^2 *10^3')
% ylabel('\tau_b *10^3')
% grid on;
% axis equal
% axis square
%
% %
% % figure(105);
% % hold on;
% % %                plot(((H/R)^2/Cf3^1.1*(alphas+1))^0.25*Cf3^0.15,sqrt(psi),'b.')
% % plot(betat,psi2,'b.')
% % ylim([1 1.5])
% % xlim([0 2.5])
% % xlabel('\beta')
% % ylabel('(\Psi_\infty)^{0.5} = (\tau_{b}/\tau_{b0})^{0.5}');%ylabel('(\Psi_\infty)^{0.5}')
% % grid on;
%
% figure(107);
% hold on;
% plot(betat,alft2,'b.')
%
