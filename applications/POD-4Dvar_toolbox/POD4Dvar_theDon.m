
clc, clear all;

if isunix
    addpath('/p/x0385-gs-mor/ivan/model_reduced_4DVar/Scrpts_Observations/');
    addpath('/p/x0385-gs-mor/ivan/model_reduced_4DVar/delft3D_matlab/');
    addpath('/p/x0385-gs-mor/ivan/model_reduced_4DVar/Scrpts_Reduction/');
    addpath('/p/x0385-gs-mor/ivan/model_reduced_4DVar/Scrpts_D3D-Deal/');
    addpath('/p/x0385-gs-mor/ivan/model_reduced_4DVar/Scrpts_Assimilation/');
    addpath('/p/x0385-gs-mor/ivan/model_reduced_4DVar/');
else
    addpath('p:\x0385-gs-mor\ivan\model_reduced_4DVar\Scrpts_Observations\');
    addpath('p:\x0385-gs-mor\ivan\model_reduced_4DVar\delft3D_matlab\');
    addpath('p:\x0385-gs-mor\ivan\model_reduced_4DVar\Scrpts_Reduction\');
    addpath('p:\x0385-gs-mor\ivan\model_reduced_4DVar\Scrpts_D3D-Deal\');
    addpath('p:\x0385-gs-mor\ivan\model_reduced_4DVar\Scrpts_Assimilation\');
    addpath('p:\x0385-gs-mor\ivan\model_reduced_4DVar\');    
end


% Set the initial guess: put all the prior knowledge into the constructed
% model and make an initial forecast. 

