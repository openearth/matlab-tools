%% Tests for getDuneErosion_Additional
getDuneErosion_additional_testdir = fileparts(mfilename('fullpath'));
disp('Precision / TargetVolume:');

%% case 1: normal dune erosion calculation with reference profile
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case1.mat'));
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 1: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 2: valley in the dune profile
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case2.mat'));
maxRetreat = [];
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 2: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 3: restricted in the valley
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case2.mat'));
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 3: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 4: DUROS calculation in the valley (not restricted)
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case4.mat'));
maxRetreat = [];
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 4: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 5: DUROS calculation in the valley (restricted)
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case4.mat'));
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 5: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 6: Positive TargetVolume
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case1.mat'));
TargetVolume = 200;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 6: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 7: Positive TargetVolume large
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case1.mat'));
TargetVolume = 380;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 7: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 8: Positive TargetVolume too large
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_case1.mat'));
TargetVolume = 600;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 8: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);
