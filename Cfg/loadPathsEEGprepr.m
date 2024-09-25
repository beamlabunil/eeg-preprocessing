% Loads file paths for EEG preprocessing
% BMT project - UNIL 2023

% Root folder
conf.rootFold = '/Users/pruggeri/Documents/Lavoro/7_Research/2023-BMT/EEG/';

% Folder with EEG raw files (bdf)
conf.rawFold = [conf.rootFold filesep 'BMT_data_EEG' filesep]; 

% Folders for processing steps
conf.ICApruning = [conf.rootFold  'ICApruning' filesep]; % after components removal
conf.ICA = [conf.rootFold  'ICA' filesep]; % where files with ICA weights are computes
conf.intrawInsp = [conf.rootFold  'intrawInsp' filesep]; % where files after interpolation and selection of bad periods (eye inspection)
conf.elToReref = [conf.rootFold  'elRefImport' filesep]; % where files containing the electrode used to re-ref at import 
conf.elPosition = [conf.rootFold  'elPosition' filesep]; % where electrode positions are placed
conf.elToInt = [conf.rootFold  'elToInt' filesep]; % where files containing list of electrode to interpolate is contained
conf.setfilesFold = [conf.rootFold 'setFiles' filesep]; % where .setFiles will be saved by RunMe_CheckEvents
conf.filteredFold = [conf.rootFold 'filtered' filesep];% where filtered files will be saved by RunMe_Preprocessing
conf.epochFold = [conf.rootFold  'epoched' filesep]; % where epoched files will be saved by RunMe_Preprocessing
conf.markersFold = [conf.rootFold  'markers' filesep]; 
conf.behaviourFold = [conf.rootFold  'behaviour' filesep]; 


% Create directories if needed
if ~exist(conf.setfilesFold,'dir'); mkdir(conf.setfilesFold); end
if ~exist(conf.filteredFold,'dir'); mkdir(conf.filteredFold); end
if ~exist(conf.epochFold,'dir'); mkdir(conf.epochFold); end
if ~exist(conf.ICA,'dir'); mkdir(conf.ICA); end
if ~exist(conf.intrawInsp,'dir'); mkdir(conf.intrawInsp); end
if ~exist(conf.ICApruning,'dir'); mkdir(conf.ICApruning); end
if ~exist(conf.markersFold ,'dir'); mkdir(conf.markersFold); end
if ~exist(conf.behaviourFold ,'dir'); mkdir(conf.behaviourFold); end

% fieldtrip toolbox
addpath /Users/pruggeri/Documents/MATLAB/toolbox/fieldtrip-20220104
ft_defaults
