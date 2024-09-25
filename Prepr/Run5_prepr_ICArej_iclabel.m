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

% load dataset
EEG = pop_loadset('filename',filename,'filepath',conf.ICA);

%% run ICA pruning
fprintf('Loading ICA components for you to select %s ...\n', filename)

endloop = 1;
while endloop

    % ask whether to visualize component activity relative to a specific event or not
    % select the participant and session you want to process
    [indx,tf] = listdlg('PromptString',{'Want to viz comp activity w.r.t. a specific event ?',''},...
        'SelectionMode','single','ListString',{'YES','NO'});


    if indx == 1  % we want to visualize component activity relative to a specific epoch
        % get necessary info for epoching
        prompt = {'Marker type (e.g. 241)','pre-stim period in s (e.g.: -0.1)','post-stim period in s (e.g.: 3'};
        defaultanswer = {'241','-0.1','3'};
        title_prompt = 'Define your epoch';
        userinput = inputdlg(prompt,title_prompt,1,defaultanswer,'on');
        marker = userinput{1,1};
        prestim = str2double(userinput{2,1});
        poststim = str2double(userinput{3,1});

        % epoching
        EEGepoch = pop_epoch( EEG, {  marker }, [prestim  poststim], 'newname', 'epoched', 'epochinfo', 'yes');

        % run automatic labeling and show components
        nICAcomMax = size(EEG.icaweights,1);

        prompt = {['Comp to viz; max is ',num2str(nICAcomMax)]};
        defaultanswer = {num2str(nICAcomMax)};
        title_prompt = ['Select Comp to viz'];
        userinput = inputdlg(prompt,title_prompt,1,defaultanswer,'on');
        nICAcom = str2double(userinput{1,1});

        EEGepoch = pop_iclabel(EEGepoch, 'default');
        pop_viewprops_PR( EEGepoch, 0, [1:nICAcom], {'freqrange', [2 40]}, {}, 1, 'ICLabel' )
        %pop_selectcomps(EEG, [1:nICAcom] );

    elseif indx == 2

        % run automatic labeling and show components
        nICAcomMax = size(EEG.icaweights,1);

        prompt = {['Comp to viz; max is ',num2str(nICAcomMax)]};
        defaultanswer = {num2str(nICAcomMax)};
        title_prompt = ['Select Comp to viz'];
        userinput = inputdlg(prompt,title_prompt,1,defaultanswer,'on');
        nICAcom = str2double(userinput{1,1});

        EEG = pop_iclabel(EEG, 'default');
        pop_viewprops_PR( EEG, 0, [1:nICAcom], {'freqrange', [2 40]}, {}, 1, 'ICLabel' )
        %pop_selectcomps(EEG, [1:nICAcom] );

    end

    pause(60)

    % are you ready to reject components ?
    waitlist = 1;
    while waitlist
        [indx,tf] = listdlg('PromptString',{'Ready to reject components from EEG ?',''},...
            'SelectionMode','single','ListString',{'YES','NO, want to viz them with different epoching'});

        if ~tf
            waitlist = 1;
            pause(60)
        else
            waitlist = 0;
        end
    end

    if indx == 1
        endloop = 0;

        prompt = {'Enter component numbers to reject (space separated)'};
        defaultanswer = {''};
        title_prompt = ['component to reject list'];
        userinput = inputdlg(prompt,title_prompt,1,defaultanswer,'on');
        compRej = userinput{1,1};
        compRej = str2double(split(compRej))';

        % reject component
        EEG = pop_subcomp( EEG, compRej, 0);

        %%
        % interpolate electrodes (indeed electrodes excluded from ICA seems noisy after component pruning
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

            % interpolate 
            EEGint = pop_interp(EEG, ind_el_rej, 'spherical');
            eegplot(EEG.data, 'data2',EEGint.data , 'srate',conf.srate/conf.dsfactor,'title','EOG cleaned vs interp','winlength',5,'dispchans',32)
            EEG = EEGint;

        end
 
        % !!!!
        % avg ref PR: see whether to do this when epoching.. in case we want to interpolate electrodes within each epoch..
        % EEG = pop_reref( EEG, []);

        % save the components that were rejected to the EEG structure
        EEG.componentRejected = compRej;

        % save
        pop_saveset(EEG, 'filename', [saveName,'_ICApruning.set'], 'filepath',conf.ICApruning,'version','7.3');


        % PR: double check that things are properly cleared when looping
        % over multiple subjects !!!

    elseif indx == 2
        endloop = 1;
    end
end


