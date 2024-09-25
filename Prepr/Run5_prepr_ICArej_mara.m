 % BMT project - UNIL 2023

%% READ THIS: https://labeling.ucsd.edu/tutorial/labels %%

clc
clearvars
close all

%% Initialize the script
addpath('..');
initEEGprepr;

%% Run ICA pruning
ICAFiles = dir([conf.ICA,'*.set']);
ICAFiles = {ICAFiles.name};
ICAFiles = ICAFiles(~startsWith(ICAFiles,'.'));

% select the participant and session you want to process
[indx,tf] = listdlg('PromptString',{'Select a file.',...
    'Only one file can be selected at a time.',''},...
    'SelectionMode','single','ListString',ICAFiles);

filename = ICAFiles{indx};
filenameChannel = ['channel_',filename(1:9),'.mat'];
filenameelToInt = [filename(1:9),'.txt'];

% name of the file that will be saved
saveName = filename(1:end-8);

%% load dataset
EEG = pop_loadset('filename',filename,'filepath',conf.ICA);

%% load electrodes to interpolate, if any
% Load chanlocs
load([conf.elPosition filenameChannel])

% Load the txt file containing the electrodes to interpolate and get the corresponding index list
rejected = importdata([conf.elToInt filenameelToInt]);

%% run ICA pruning
fprintf('Loading ICA components for you to select %s ...\n', filename)

% to modify here for info on channels not to interpolate
good_chans = zeros(EEG.nbchan,1);
good_chans(EEG.icachansind) = 1;

%==========================================================================
[windex,maxv] = compsort(EEG.data(good_chans==1,:),EEG.icaweights,EEG.icasphere,1);% Sort components

%varexp = find(cumsum(maxv./sum(maxv)) > 0.9,1);% Option retained by D. Pascucci threshold at varexp_thr (mark components that explain >= varexp_thr)
varexp = find((maxv./sum(maxv)) < 0.001 ,1);% Our criteria. threshold below 0.1% of explained variance. Components bewlo 0.1% of explained variance are left even if signalled by MARA as bad

% PR
EEGmara = EEG;
EEGmara.data(good_chans == 0,:) = []; 


%==========================================================================
% Run MARA automatic classificaion (defaults)
[artcomps, info] = MARA(EEGmara);

%==========================================================================
% Crossing variance explained and MARA results
rej              = EEGmara.reject.gcompreject;
rej(artcomps)    = 1; 

rej(windex(1:varexp))          = rej(windex(1:varexp))+1;
EEGmara.reject.gcompreject(rej==2) = 1;

% store results
EEGmara.MARA.info     = info; 
EEGmara.MARA.artcomps = artcomps;
EEGmara.windex        = windex;
EEGmara.maxvar        = maxv;    

% visualize components 
EEGcompToPlot = EEGmara; % assign new dataset to manipulate for the sake of viz components. This is done to remove in the next step the locations of the channels not considered in the ICA
EEGcompToPlot.chanlocs(setdiff(1:EEG.nbchan,EEGcompToPlot.icachansind)) = []; % remove locations of channels nn contained in the ICA (ICA components don't have these channels)
pop_selectcomps_MARA(EEGcompToPlot);
pause

% reject components
listcomp = 1:size(EEGmara.icaact,1);
EEGmara = pop_subcomp(EEGmara, listcomp(logical(EEGcompToPlot.reject.gcompreject)), 0); % note that data and chanlocs go back to 128 after this step. Electrodes that were not considered in the ICA needs interpolation

% assign back the EEG dataset to "EEG"
EEG = EEGmara;


%%
% interpolate electrodes (indeed electrodes excluded from ICA seems noisy after component pruning
fprintf('Interpolating %s ...\n', filename)

% get index of the electrodes to interpolate
if ~isempty(rejected)
    ind_el_rej = [];
    for el_int = 1:length(rejected)
        ind_el_rej(1, el_int) = find(strcmp({Channel.Name}, rejected{el_int}) == 1);
    end

    % interpolate
    EEGint = pop_interp(EEG, ind_el_rej, 'spherical');
    eegplot(EEG.data, 'data2',EEGint.data , 'srate',conf.srate/conf.dsfactor,'title','EOG cleaned vs interp','winlength',5,'dispchans',32)
    EEG = EEGint;

end

% save
pop_saveset(EEG, 'filename', [saveName,'_ICApruning.set'], 'filepath',conf.ICApruning,'version','7.3');






