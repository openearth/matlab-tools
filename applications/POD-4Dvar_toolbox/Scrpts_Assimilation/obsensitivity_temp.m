function [varargout] = obsensitivity(varargin)

        elrom = varargin{1};
        theforecast = varargin{2};
        theparameters = varargin{3};
        
        
        %estimation.theoperator = varargin{3};
        
        %lasvariabilities = elrom.P*theforecast(:,1)-elrom.P*theforecast(:,end);  
        %varindices = find(lasvariabilities == max(lasvariabilities));
        %estimation.theoperator = sparse([1:size(varindices,1)]',varindices,1,size(varindices,1),elrom.bg.n*elrom.bg.m)';
        %estimation.theoperator = (elrom.P'*estimation.theoperator);
        
        a = zeros(elrom.bg.n,elrom.bg.m);
        a (60:80,15:25) = 1;
        estimation.theoperator = reshape(a,elrom.bg.n*elrom.bg.m,1);
        
        estimation.drf_dri{elrom.steps+1} = estimation.theoperator;
        estimation.drf_dDai{elrom.steps+1} = estimation.theoperator;
        
        for iTStep = elrom.steps:-1:1
            estimation.drf_dDai{iTStep} = elrom.P*elrom.dN_dAlpha{iTStep};
            estimation.drf_dri{iTStep} = estimation.theoperator;
            
            for jTStep = iTStep:1:(elrom.steps)
                estimation.drf_dDai{iTStep} = elrom.P*(elrom.N{jTStep}*elrom.P'*estimation.drf_dDai{iTStep}); 
                estimation.drf_dri{iTStep} = ((estimation.drf_dri{iTStep}'*elrom.P*elrom.N{jTStep})*elrom.P')';
            end
        end
        
        for iTStep = elrom.steps+1:-1:1,            
            theweights.vectors.dps(:,iTStep,:) = estimation.drf_dDai{iTStep}(:,1);%*(theparameters/elrom.bg.vectors.dps(varindices,end))';
            theweights.info.dps(iTStep,1) = {elrom.bg.info.dps{iTStep,1}};
            theweights.info.dps(iTStep,2) = {reshape(theweights.vectors.dps(:,iTStep),elrom.bg.n,elrom.bg.m)};
        end


        varargout{1} = estimation;
        varargout{2} = theweights;