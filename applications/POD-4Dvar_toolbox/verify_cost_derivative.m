clc
close all
clear a c stateVector j0 j1 dj0 dj1 idiff ladiffcont x0 x1 romRun divided_by ladiff


for iparam=1:1:elrom.numParam
        a(iparam,1) = elrom.Params(iparam).minValue-elrom.Params(iparam).bgValue;
    	c(iparam,1) = elrom.Params(iparam).maxValue-elrom.Params(iparam).bgValue;
end

stateVector = zeros(elrom.numParam,1) + [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];  %sin transformar!!!

x0 = log(-log((stateVector-a)./(c-a)))';  % Transformado
transformation_derivative = -(c-a).*exp(-exp(x0')+x0');

romRun = runrom(elrom,stateVector);
[j0,dj0]=evalcost_trans(romRun,obs,elrom.initialGuess.matCov,stateVector,elrom.P,elrom.dr_dDa,elrom.Params,transformation_derivative);



cont = 1;
for idiff = 1e-6:1e-8:5e-6

    stateVector = zeros(elrom.numParam,1) + [0;idiff;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];

    x1 = log(-log((stateVector-a)./(c-a)))';
    transformation_derivative = -(c-a).*exp(-exp(x1')+x1');
    
    romRun = runrom(elrom,stateVector);
    [j1,dj1]=evalcost_trans(romRun,obs,elrom.initialGuess.matCov,stateVector,elrom.P,elrom.dr_dDa,elrom.Params,transformation_derivative);
    
    divided_by(cont) = x1(2)-x0(2);
    ladiff(cont) = (j1-j0)./(x1(2)-x0(2));
    cont = cont +1;

end

plot(ladiff); hold on; plot([0,100],[dj0(2),dj0(2)],'-r')