% BMT project - UNIL 2023


clc
clearvars
close all

%% Initialize the script
addpath('..');
initEEGprepr;

%% 2. Run ICA
intrawInspFiles = dir([conf.intrawInsp,'*.set']);
intrawInspFiles = {intrawInspFiles.name};
intrawInspFiles = intrawInspFiles(~startsWith(intrawInspFiles,'.'));

for ii = 1:length(intrawInspFiles)

    filename = intrawInspFiles{ii};
    filenameChannel = ['channel_',filename(1:9),'.mat'];
    filenameelToInt = [filename(1:9),'.txt'];

    % Verify if data were already processed for this file
    if exist([conf.ICA,filename(1:end-20),'_ICA.set'],'file') == 2
        process_bool = false;
        disp('File already processed. Erase it to process again')
    else
        process_bool = true;
    end


    if process_bool
        saveName = filename(1:end-19);

        % load dataset
        EEG = pop_loadset('filename',filename,'filepath',conf.intrawInsp);

        %% computing ICA
        fprintf('.......... \n.......... \n Computing ICA starting from filename %s ......... \n', filename)

        % Load chanlocs
        load([conf.elPosition filenameChannel])

        % Load the txt file containing the electrodes to interpolate and get the corresponding index list
        rejected = importdata([conf.elToInt filenameelToInt]);

        % run ICa
        if ~isempty(rejected)
            % get index of the electrodes to interpolate w.r.t. this new channel list
            ind_el_rej = [];
            for el_int = 1:length(rejected)
                ind_el_rej(1, el_int) = find(strcmp({Channel.Name}, rejected{el_int}) == 1);
            end

            % run ICA (exclude bad channel from - i.e., those interpolated - from the ICA computation
            n_channels = size(EEG.data,1);
            EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','chanind',setdiff(1:n_channels,ind_el_rej));
        else

            EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');

        end

        % Save data
        pop_saveset(EEG, 'filename', [saveName,'ICA.set'], 'filepath',conf.ICA,'version','7.3');

    end
end


