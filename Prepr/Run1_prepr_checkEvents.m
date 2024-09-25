% BMT Project - UNIL 2023

clearvars
clc

%% Initialize the script
addpath('..');
initEEGprepr;

eeg_files = dir([conf.rawFold,'*.bdf']);
eeg_files = {eeg_files.name};
eeg_files = eeg_files(~contains(eeg_files,{'._','..'}));


for ii = 1:length(eeg_files)
    filename = eeg_files{ii};
    
    % Verify if the events were already checked for this file
    if exist([conf.setfilesFold, filename(1:end-4),'.set'],'file') == 2
        process_bool = false;
        disp('File already processed. Erase it to process again')
    else
        process_bool = true;
    end
    
    if process_bool
        % Load dataset
        % EEG = pop_biosig(filename); % Issues with event extraction
        fprintf('processing %s.set \n \n',filename(1:end-4))
        
        EEG = pop_readbdf_JM([conf.rawFold,filename]);         % modified version of pop_readbdf, to use last data channel as event channel
        
        % Correct shift in triggers
        if EEG.event(1).type >= conf.triggerShift2
            triggers_corrected = arrayfun(@(x) (x.type)-conf.triggerShift2,EEG.event);
            trig_cell= num2cell(triggers_corrected);
            [EEG.event.type] = deal(trig_cell{:});
        elseif EEG.event(1).type >= conf.triggerShift1
            triggers_corrected = arrayfun(@(x) (x.type)-conf.triggerShift1,EEG.event);
            trig_cell= num2cell(triggers_corrected);
            [EEG.event.type] = deal(trig_cell{:});
        end
        
        [triggerCount,trigger_check] = checkTriggersEEG(EEG,conf);
        if ~trigger_check
            fprintf('Verify triggers!\n \n')
            return
        else
            pop_saveset(EEG,'filename',[filename(1:end-4),'.set'],'filepath',conf.setfilesFold,'version','7.3');
            fprintf('%s saved \n \n',[filename(1:end-4),'.set'])
        end
    end
end



