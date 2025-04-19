%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Install GraFT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This script adds all the necessary subfolders etc. to run GraFT
%
%
% 2021 - Adam Charles & Gal Mishne

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

currentFolder = pwd;                                                       % Get base folder

addpath(genpath([currentFolder,'/dictionary-learning']));                  % Add folder for dictionary learning
addpath(genpath([currentFolder,'/graft-main']));                           % Add folder for Misc files
addpath(genpath([currentFolder,'/graph-sparse-coding']));                  % Add folder for Optics simulation files
addpath(genpath([currentFolder,'/external-code']));                        % Add folder for Time-trace simulation files
addpath(genpath([currentFolder,'/support-functions']));                    % Add folder for various analysis scripts

cd(currentFolder);                                                         % Return to the main folder
clear currentFolder ans                                                        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

