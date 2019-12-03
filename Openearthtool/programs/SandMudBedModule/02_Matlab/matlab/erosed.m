function [sink, sinkf, sour, sourf] = erosed(morlyr    ,filesed, nmlb      , nmub  ,  ...
                 ws        , umod      , h     , chezy , taub  , r0    , ...
                 nfrac     , rhosol    , d50   , d90   , sedtyp )
%----- LGPL --------------------------------------------------------------------
%                                                                               
%   Copyright (C) 2011-2012 Stichting Deltares.                                     
%                                                                               
%   This library is free software; you can redistribute it and/or                
%   modify it under the terms of the GNU Lesser General Public                   
%   License as published by the Free Software Foundation version 2.1.                         
%                                                                               
%   This library is distributed in the hope that it will be useful,              
%   but WITHOUT ANY WARRANTY; without even the implied warranty of               
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU            
%   Lesser General Public License for more details.                              
%                                                                               
%   You should have received a copy of the GNU Lesser General Public             
%   License along with this library; if not, see <http://www.gnu.org/licenses/>. 
%                                                                               
%   contact: delft3d.support@deltares.nl                                         
%   Stichting Deltares                                                           
%   P.O. Box 177                                                                 
%   2600 MH Delft, The Netherlands                                               
%                                                                               
%   All indications and logos of, and references to, "Delft3D" and "Deltares"    
%   are registered trademarks of Stichting Deltares, and remain the property of  
%   Stichting Deltares. All rights reserved.                                     
%                                                                               
%-------------------------------------------------------------------------------
%   http://www.deltaressystems.com
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/matlab/erosed.m $
%   $Id: erosed.m 7697 2012-11-16 14:10:17Z boer_aj $
%%--description-----------------------------------------------------------------
%
%    Function: Computes sedimentation and erosion fluxes
%
%% executable statements ------------------
%
    %
    istat   = 0;
    % 
    %   User defined parameters
    %
    % FORTRAN
    %     message = 'initializing fluff layer'
    %     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'Flufflyr' , flufflyr)
    %     if (flufflyr>0 .and. istat == 0) istat = bedcomp_getpointer_realfp (morlyr, 'mfluff'   , mfluff)
    %     if (flufflyr==1) then
    %         if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'Bfluff0'            , bfluff0)
    %         if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'Bfluff1'            , bfluff1)
    %     endif
    %     if (istat /= 0) call adderror(messages, message)
    % FORTRAN
    if (morlyr.flufflayer_model_type>0 && istat == 0) 
        mfluff = morlyr.fluff_mass;
    end
    %
    % FORTRAN
    % call initsed(nmlb,   nmub,   nfrac, flufflyr, &
    %              & alf1,    betam,  rksc,   pmcrit, bfluff0, bfluff1, &
    %              & depeff,  depfac, eropar, parfluff0,  parfluff1, &
    %              & tcrdep,  tcrero, tcrfluff)
    % FORTRAN
    %
    eval(filesed);
    %
    %   Determine fractions of all sediments in the top layer and compute the mud fraction. 
    %
    % FORTRAN
    %   call getfrac(morlyr, frac, anymud, mudcnt, mudfrac, nmlb, nmub)
    % FORTRAN
    %
    frac = morlyr.mass_fraction(:,1,:);
    %
    %   Initialization
    %
    mudfrac     = zeros(1,nmlb:nmub); 
    fixfac      = zeros(nfrac,nmlb:nmub)+1; 
    rsedeq      = zeros(nfrac,nmlb:nmub);
    ssus        = 0.0;
    sour        = zeros(nfrac,nmlb:nmub);
    sink        = zeros(nfrac,nmlb:nmub);
    sinkf       = zeros(nfrac,nmlb:nmub);
    sourf       = zeros(nfrac,nmlb:nmub);
    %
    %   Compute change in sediment composition (e.g. based on available fractions and sediment availability)
    %    
    for nm = nmlb:nmub
        mfltot = 0.0;
        if (morlyr.flufflayer_model_type>0) 
            for l = 1: nfrac
                mfltot = mfltot + mfluff(l,nm);
            end
        end   
        for l = 1 : nfrac
            if (sedtyp(l)==2)
                mudfrac(nm) = mudfrac(nm) + frac(l,nm);
            end
        end
        for l = 1: nfrac
            if (sedtyp(l)==2) 
                %
                %   Compute source and sink fluxes for cohesive sediment (mud)
                %
                fracf   = 0.0;
                if (mfltot>0.0) 
                    fracf   = mfluff(l,nm)/mfltot;
                end
                %
                % FORTRAN
                %     call eromud(ws(l,nm)      , fixfac(l,nm)  , taub(nm)      , frac(l,nm)     , fracf  , &
                %               & tcrdep(l,nm)  , tcrero(l,nm)  , eropar(l,nm)  , flufflyr       , mfltot , &
                %               & tcrfluff(l,nm), depeff(l,nm)  , depfac(l,nm)  , parfluff0(l,nm), parfluff1(l,nm) , &
                %               & sink(l,nm)    , sour(l,nm)    , sinkf(l,nm)   , sourf(l,nm)   )  
                % FORTRAN
                %
                [sink(l,nm), sour(l,nm), sinkf(l,nm), sourf(l,nm) ] = eromud(ws(l,nm)      , fixfac(l,nm)  , taub(nm)      , frac(l,nm)     , fracf  , ...
                                                                             tcrdep(l,nm)  , tcrero(l,nm)  , eropar(l,nm)  , morlyr.flufflayer_model_type       , mfltot , ...
                                                                             tcrfluff(l,nm), depeff(l,nm)  , depfac(l,nm)  , parfluff0(l,nm), parfluff1(l,nm));
            else
                %
                % Compute correction factor for critical bottom shear stress with sand-mud interaction
                %
                if ( pmcrit(nm) > 0.0) 
                    smfac = ( 1.0 + mudfrac(nm) )^betam;
                else
                    smfac = 1.0;
                end
                %
                %   Apply sediment transport formula ( in this case vanRijn (1984) )
                %
                % FORTRAN
                %     call vanRijn84(umod(nm)  ,d50(nm)   ,d90(nm),h(nm)     ,ws(l,nm)   , &
                %                  & rhosol(l) ,alf1      ,rksc      , &
                %                  & sbot      ,ssus      ,smfac     )
                % FORTRAN
                %
                [sbot,ssus] = vanRijn84(umod(nm)   ,d50(nm)   ,d90(nm),h(nm)     ,ws(l,nm)   , ...
                              rhosol(l) ,alf1      ,rksc      ,smfac     );
                %
                ssus =  ssus * rhosol(l);
                %
                %   Compute reference concentration
                %
                if (umod(nm)*h(nm))>0
                    rsedeq(l,nm) = frac(l,nm) * ssus / (umod(nm)*h(nm));
                end
                %
                %   Compute suspended sediment fluxes for non-cohesive sediment (sand)
                %     
                % FORTRAN
                %     call erosand(umod(nm)    ,chezy(nm)     ,ws(l,nm)  ,rsedeq(l,nm),  &
                %                & sour(l,nm)  ,sour          ,sink(l,nm) )
                % FORTRAN
                %
                [sour(l,nm), sink(l,nm)] = erosand(umod(nm), chezy(nm), ws(l,nm), rsedeq(l,nm));
                %
            end
         end      
    end
    %
    % Recompute fluxes due to sand-mud interaction
    %
    for nm = nmlb: nmub
        % Compute erosion velocities
        E = zeros(1,nfrac);
        for l = 1: nfrac
            if (frac(l,nm)>0.0) 
                E(l) = sour(l,nm)/(rhosol(l)*frac(l,nm));
            end
        end
        %
        % Recompute erosion velocities
        %
        % FORTRAN
        %     call sand_mud(nfrac, E, frac(:,nm), mudfrac(nm), sedtyp, pmcrit(nm))
        % FORTRAN
        %
        E = sand_mud(nfrac, E, frac(:,nm), mudfrac(nm), sedtyp, pmcrit(nm));
        %
        % Recompute erosion fluxes
        %
        for l = 1: nfrac
            sour(l,nm) = frac(l,nm)*rhosol(l)*E(l);
        end
    end
    %
    % Add implicit part of source term to sink
    %
    for l = 1: nfrac
        for nm = nmlb: nmub
            sink(l,nm) = sink(l,nm);
        end
    end
    %
end
