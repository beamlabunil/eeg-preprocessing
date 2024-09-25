0% BMT project - UNIL 2023


clc
clearvars


%% Initialize the script
addpath('..');
initEEGprepr;

eeglab
clc
close all

%% 2. interpolation and Raw data inspection
filteredFiles = dir([conf.filteredFold,'*.set']);
filteredFiles = {filteredFiles.name};
filteredFiles = filteredFiles(~startsWith(filteredFiles,'.'));

% select the participant and session you want to process
[indx,tf] = listdlg('PromptString',{'Select a file.',...
    'Only one file can be selected at a time.',''},...
    'SelectionMode','single','ListString',filteredFiles);

filename = filteredFiles{indx};
filenameChannel = ['channel_',filename(1:9),'.mat'];
filenameelToInt = [filename(1:9),'.txt'];


% Verify if data were already processed for this file
if exist([conf.intrawInsp,filename(1:end-13),'_interp_eye_insp.set'],'file') == 2
    process_bool = false;
    disp('File already processed. Erase it to process again')
else
    process_bool = true;
end

if process_bool
    saveName = filename(1:end-12);

    % load dataset
    EEG = pop_loadset('filename',filename,'filepath',conf.filteredFold);



    %% interpolate bad channels
    fprintf('Interpolating %s ...\n', filename)

    % Load chanlocs
    load([conf.elPosition filenameChannel])

    % Load the txt file containing the electrodes to interpolate and get the corresponding index list
    rejected = importdata([conf.elToInt filenameelToInt]);

    % get index of the electrodes to interpolate
    if ~isempty(rejected)
        ind_el_rej = [];
        for el_int = 1:length(rejected)
            ind_el_rej(1, el_int) = find(strcmp({Channel.Name}, rejected{el_int}) == 1);
        end

        % interpolate : this is done - for the moment- just for visualization purposes (i.e., to allow a good raw data inspection).
        % These interpolated electrodes will not be considered in the ICA, and after ICA pruning they
        % may look artifacted again and need interpolation. Another solution would be to remove them here, and interpolate them later by
        % including them again in the scalp electrode array.
        EEGint = pop_interp(EEG, ind_el_rej, 'spherical');
        %eegplot(EEG.data, 'data2',EEGint.data , 'srate',conf.srate/conf.dsfactor,'title','EOG cleaned vs interp','winlength',5,'dispchans',32)
        EEG = EEGint;

    end


    %% label bad periods by eye (such that ICA does not consider them)

    % user should select window length = 30 secs and stack electrodes such that we can easily reject bad periods
    pop_eegplot( EEG, 1, 1, 1);

    clc
    pause
    close all


    % Save data
    pop_saveset(EEG, 'filename', [saveName,'interp_eye_insp.set'], 'filepath',conf.intrawInsp,'version','7.3');


    % PR: double check that things are properly cleared when looping
    % over multiple subjects !!!
end
