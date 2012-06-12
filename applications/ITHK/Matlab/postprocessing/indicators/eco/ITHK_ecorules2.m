function ITHK_ecorules2
% function ecorules2
%
% Computes the impact of measurements on the population of species at the coast.
%
% Typical measures are : Nourishments (Mega, Foreshore or Beach)
%                        Revetments
%                        Groynes
%
% The impact is computed with a logistic growth function (Shepard, J.J. & 
% L. Stojkov, 2007. The logistic population model with slowly varying 
% carrying capacity. ANZIAM J. 47 (EMAC2005), pp. C492-C506).
% 
% The logistic growth function uses a time variable carrying capacity (CC) 
% for the recovery of benthic communities that denotes the 'habitat quality'
% that needs to recover.
% 
% INPUT:
%   time       Timeframe
%   isoort     Type of nourishment (1:beach, 2:foreshore, 3:mega, 4:revetment, 5:groyne, 6:other)
%   P0         Initial value for population (used for time-dependent P) (read from 'eco_input.txt')
%   K0         Initial value for carrying capacity (used for time-dependent CC : K) (read from 'eco_input.txt')
%   k_meastype Reduction of population (%) as a result of typical measurements (read from 'eco_input.txt')
%
% OUTPUT:
%   S.ECO(kk)  Structure with ecological information for all species (kk)
%         .P   Field with population in time 
%

global S

%% READ INPUT VARIABLES from a settings file
% Ecological parameters are read from the file 'eco_input.txt':
%   r  = growth rate
%   P0 = starting population size
%   Ks = limiting value for K(et) as t --> infinity
%   k_meastype  = reduction of population (%) as a result of this measurement

ECO=read_eco_input([S.settings.basedir 'Matlab/postprocessing/indicators/eco/eco_input.txt']);


%% COMPUTE IMPACT ON POPULATION (for species 1:kk and coastal section 1:nrsections in time 1:nryears)
pptype = {'UBmapping','GEmapping'};
for pp = 1:2
    ppmapping  = S.PP.(pptype{pp});
    nryears    = S.userinput.duration+1;                                   % dirty way to get the time length (tend - t0)
    nrsections = size(ppmapping.supp_beach,2);                                   % dirty way to get the nr. of coastline sections (i.e. grid cells) along the Holland coast
    P = [];K0 = [];
    for kk = 1: length(ECO)                                                    % nr. of species.
        Ks     = ECO(kk).k_s;                                                  % default carrying capacity (CC) of the system
        P0     = ECO(kk).p0;                                                   % in initial population (used as reference only)
        r      = ECO(kk).r;                                                    % logistic growth rate benthic community (polychaetes: r = 4, bivalves r = 2).
        e      = [2 , 1 , 0.5, 1, 1, 1]; epsval=2;                             % epsilon determines recovery time of CC. Beach e = 2, shoreface e = 1, mega e = 0.5.
        s      = 1.;                                                           % sigma, where sigma = s = 1 
        for ii = 1: nrsections                                                 % nr. of coastline sections (i.e. grid cells) along the Holland coast
            K0(ii,1) = Ks;                                                     % set initial carrying capacity (CC0)
            P(ii,1)  = P0;                                                     % set initial population (P0)
            tsub=  0;
            for tt = 1:nryears                                                 % timeframe of simulation
                K0red = 0.;
                P0red = 0.;

                % check if there is a nourishment (or construction)
                % which reduces the population and carrying capacity
                FLDname_measures = {'k_beach_nourishment','k_foreshore_nourishment','k_mega_nourishment','k_revetment','k_groyne','k_others'};
                FLDsupps = {'supp_beach','supp_foreshore','supp_mega','rev','gro'};  % Type of nourishemnt that is used! (isoort = 1=beach, 2=foreshore, 3=mega)
                for jj=1:length(FLDsupps)
                    supp2 = ppmapping.(FLDsupps{jj});
                    if  supp2(tt,ii)==1                                             % t==S.userinput.suppletion.start+1 && i>=idsth && i<=idnrth
                        P0red = ECO(kk).(FLDname_measures{jj});                % reduction in pop. size after nourishment is 1%
                        K0red = ECO(kk).(FLDname_measures{jj});                % reduction in CC after nourishment (e.g. mega: back to 5%, beach/shoreface back to 50%)
                        P(ii,tt) = P(ii,tt)*(100-P0red)/100;
                        K0(ii,tt) = K0(ii,tt)*(100-K0red)/100;
                        tsub = tt-1;
                        epsval = min(epsval,e(jj));
                    end
                end

                % Equation 17 in Shepard & Stojkov, 2007: 
                K = Ks/(1+((Ks/K0(ii,1+tsub))^s-1)*exp(-s*epsval*(tt-tsub))).^(1/s);% compute carrying capacity in next timestep

                % Equation 18 of Shepard & Stojkov, 2007:
                %    a = alpha in Eq. 18
                %    b = beta in Eq. 18
                % a = r/(r-e)*((Ks/K0(tt,ii)).^s-1);
                % b = (K0(tt,ii)/P0).^s-1;                                     % different from Eq. 18 which is probably wrong. Ks instead of K0 !!
                %P(tt+1,ii) = Ks./(1+a*exp(-e*s*tt)+(b-a)*exp(-r*s*tt)).^(1/s);% time variable pop. size
                P(ii,tt+1) = (K*P(ii,tt)*exp(r*(tt-tsub))) ...
                             ./ (K+P(ii,tt)*(exp(r*(tt-tsub))-1));             % compute population in next time step

                % time variable pop. size
                K0(ii,tt+1) = K;
            end
        end
        ppmapping.eco(kk).name   = ECO(kk).name; 
        ppmapping.eco(kk).P0     = ECO(kk).p0;
        ppmapping.eco(kk).Ks     = ECO(kk).k_s;
        ppmapping.eco(kk).r      = ECO(kk).r;
        ppmapping.eco(kk).xindex = [1:1:nrsections];
        ppmapping.eco(kk).time   = [0:1:nryears];
        ppmapping.eco(kk).P      = P;
        ppmapping.eco(kk).K0     = K0;
    end
    S.PP.(pptype{pp}) = ppmapping;
end

%% Write to kml
%HKtool_eco_to_kml
ITHK_kmlbarplot(S.PP.coast.x0_refgridRough,S.PP.coast.y0_refgridRough,S.PP.GEmapping.eco(1).P*5,str2double(S.settings.indicators.eco.offset));

%% PLOT THE POPULATION IN TIME
% figure;
% plot(1:21,P(1:21,11),'-or');hold on;
% plot(1:21,K0(1:21,11),'-+g');grid on;

