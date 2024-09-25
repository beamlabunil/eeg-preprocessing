% Initialization script
% BMT project - UNIL 2023


% Scripts folder
cfgFolder = [ '..' filesep 'Cfg' ];
preprFolder = [ '..' filesep 'Prepr' ];
utilsFolder = ['..' filesep 'Utils' ];

% Add paths
addpath( cfgFolder );
addpath( preprFolder );
addpath( utilsFolder );

conf = loadCfgEEGprepr();
loadPathsEEGprepr

addpath('/Users/pruggeri/Documents/MATLAB/toolbox/eeglab2023.0/plugins/ICLabel1.4/viewprops')

