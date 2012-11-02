    function [estimation] = runrom(rom,x)
    % RUNROM(rom,x) runs a reduced order model for the given state vector
    % x. 
    %
    %  Xk = runrom(ROM,Xo) wehere ROM is a structure as the one produced by
    %  contruct_rom. Xo is the initial state vector. Xk will have the same
    %  forma as the one produced by getrunsinfo.
    %
    %  see also: construct_rom, getrunsinfo
        
        
        %% Run rom
        if false, [rom.Params.bgValue]' + x, end  %Wanna see the updates of the optimization?        
        
        estimation.r(:,1) = zeros(size(rom.P,2),1);
        for iTStep = 1:1:rom.steps, 
            estimation.r(:,iTStep+1) = rom.N{iTStep}*estimation.r(:,iTStep) + rom.dN_dAlpha{iTStep}*x;
        end
        
        %Only sensitivities for rom:   %for iTStep = 1:1:rom.steps, estimation.r(:,iTStep+1) = rom.dN_dAlpha{iTStep}*x; end
        %Another way to run the rom:   %estimation.r{iTStep+1} = %rom.dr_dDa{iTStep}*x;
        

        
        %% Turn rom states into Normal States
        for iTime=2:1:rom.steps+1
            estimation.vectors.dps(:,iTime-1)  = rom.bg.vectors.dps(:,iTime) + rom.P*estimation.r(:,iTime);
            estimation.times(iTime-1,1)        = rom.bg.times(iTime);

            estimation.vectors.x               = rom.bg.vectors.x;
            estimation.vectors.y               = rom.bg.vectors.y;
        end