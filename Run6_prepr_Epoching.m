% BMT project - UNIL 2023

clc
clearvars
close all

%% Initialize the script
addpath('..');
initEEGprepr;

eeglab
clc
close all

%% dataset after ICA pruning
Files = dir([conf.ICApruning,'*.set']);
Files = {Files.name};
Files = Files(~startsWith(Files,'.'));

% select the participant and session you want to process
[indx,tf] = listdlg('PromptString',{'Select a file.',...
    'Only one file can be selected at a time.',''},...
    'SelectionMode','single','ListString',Files);

filename = Files{indx};
filenameChannel = ['channel_',filename(1:9),'.mat'];
filenameelToInt = [filename(1:9),'.txt'];


% Verify if data were already processed for this file
if exist([conf.ICA,filename(1:end-20),'_ICApruning.set'],'file') == 2
    process_bool = false;
    disp('File already processed. Erase it to process again')
else
    process_bool = true;
end

if process_bool
    saveName = [filename(1:5),'S',filename(9)];

    % load dataset
    EEG = pop_loadset('filename',filename,'filepath',conf.ICApruning);

    %% epoching
    fprintf('Epoching %s ...\n', filename)

    % Load chanlocs
    load([conf.elPosition filenameChannel])

    % get epochs

    prompt = {'Marker type (e.g. 241)','pre-stim period in s (e.g.: -0.1)','post-stim period in s (e.g.: 3'};
    defaultanswer = {'241','-0.1','3'};
    title_prompt = 'Define your epoch';
    userinput = inputdlg(prompt,title_prompt,1,defaultanswer,'on');
    marker = userinput{1,1};
    prestim = str2double(userinput{2,1});
    poststim = str2double(userinput{3,1});

    %EEG = pop_epoch( EEG, {  num2str(conf.startTrigger) }, conf.latencyStartTrigger, 'epochinfo', 'yes');
    EEG = pop_epoch( EEG,{marker}, [prestim poststim], 'epochinfo', 'yes');


    % if true, interpolate electrode at the epoch level
    if conf.epochElInt

        nepochs = size(EEG.data,3);

        % !! triple check the following passages

        % average ref just to identify electrode to interpolate (fake avg ref)
        EEGfake = pop_reref( EEG, []);

        for epoch = 1:nepochs

            % identify el. to interpolate
            data = EEGfake.data(:,:,epoch);
            stds = nanstd(data,[],2);
            rej_high = find(isoutlier(stds,'mean','ThresholdFactor',2));

            % interpolate
            EEGmask = EEG;
            EEGmask = pop_interp(EEGmask, rej_high , 'spherical');
            EEG.data(:,:,epoch) = EEGmask.data(:,:,epoch);

        end
    end

    % average ref
    EEG = pop_reref( EEG, []);

    % visualize for manual artifact rejection (to render semi-automatic
    % once the artifact rejection section in eeglab is assimilated
    % :--)) --> follow the gui once you click on reject (i.e., click
    % YES and OK to prompt)
    pop_eegplot( EEG, 1, 1, 1);
    pause
    close all

    idxleft = getEpochOrder(EEG,conf.startTrigger);

    EEG.idxleft = idxleft;

    EEG.setname = [saveName,'_epochs_',marker];

    % Save data
    pop_saveset(EEG, 'filename', [saveName,'_marker_',marker,'.set'], 'filepath',conf.epochFold,'version','7.3');


end


