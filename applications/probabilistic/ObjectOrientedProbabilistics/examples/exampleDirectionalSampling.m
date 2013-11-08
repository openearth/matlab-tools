%% DirectionalSampling.m example problem

%% Defining your problem in a LimitState
% First, the random variables used in your limit state function need to be
% created, this is done an Mx1 RandomVariable object (where M is the number
% of random variables needed)

NrOfRandomVariables = 2;
MyVariables(NrOfRandomVariables,1) = RandomVariable; %Calling the RandomVariable constructor method

% Each variable needs a distribution and parameters (and optionally a
% name). The parameters needed depend on the distribution your select.
% Examples of distributions are: @norm_inv, @logn_inv, @gumbel_inv, etc.
% (this are function handels relating to functions in OET)

for i=1:NrOfRandomVariables
    % This is done for each variable (of course distribution and parameters
    % can differ between the random variables).
    MyVariables(i,1).Name                     = ['U' num2str(i)];
    MyVariables(i,1).Distribution             = @norm_inv;
    MyVariables(i,1).DistributionParameters   = {0 1};
end

% The limit state as a whole is definied within the LimitState object, it
% contains the LimitStateFunction as a function handle (so you have to
% define it as a seperate function, follow the templateLimitStateFunction
% for that).
MyLimitState                    = LimitState; %Calling the LimitState constructor method
MyLimitState.Name               = 'Z';
MyLimitState.LimitStateFunction = @prob_grooteman_05_concave_x2z_test;
MyLimitState.RandomVariables    = MyVariables; %The LimitState also contains the variables we've just defined

%% Solving your problem with DirectionalSampling

% DirectionalSampling uses an algorithm to find the location of the zero
% crossing of the LimitStateFunction in a chosen direction (the LineSearch
% algorithm). Different algorithms could be used to do this, however
% currently there is only one available (LineSearch.m, also an object)
MyLineSearcher  = LineSearch;

% We have to set the accuracy and the confidence interval we want to
% calculate with, and optionally choose a Seed for reproducability
MyAccuracy      = 0.95;
MyConfidence    = 0.2;
ChosenSeed      = 67;

% Then we have all we need to construct our DirectionalSampling object
MyDirectionalSamplingObject     = DirectionalSampling(...
    MyLimitState, MyLineSearcher, MyAccuracy, MyConfidence, ChosenSeed); %Calling the DirectionalSampling constructor method


% The DirectionalSampling object is now created, however no calculation has
% been done yet. This can be done by calling the CalculatPf method (this
% name is the same regardless of which probabilistic method you use)
MyDirectionalSamplingObject.CalculatePf;

%% Looking at the results
% Because of the nature of the DirectionalSampling, CalculatePf does not
% result in direct output variables. They are all stored within the object
% itself.

% Failure probability
MyDirectionalSamplingObject.Pf

% We can also plot the result
MyDirectionalSamplingObject.plot

% Or look at how many evaluations were needed to obtain the result
MyDirectionalSamplingObject.LimitState.NumberExactEvaluations