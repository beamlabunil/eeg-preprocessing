% BMT project - UNIL 2023

clc
clearvars
close all

%% Initialize the script
addpath('..');
initEEGprepr;

%% 1. Re-ref at import and Filter
% load set Files list
setfiles = dir([conf.setfilesFold,'*.set']);
setfiles = {setfiles.name};
setfiles = setfiles(~startsWith(setfiles,'.'));

for ii = 1:length(setfiles)

    filename = setfiles{ii};


    % Verify if this file has already been filtered
    if exist([conf.markersFold,filename(1:end-4),'_markers.set'],'file') == 2
        filter_bool = false;
        disp('File already processed. Erase it to process again')
    else
        filter_bool = true;
    end

    if filter_bool

        fprintf('Processing file %s ......... \n', filename)

        % look for behavioural dataset
        session_nr = filename(9);
        if session_nr == 1
            behav_filename = [filename(1:4),'_sessionNr01.mat'];
        elseif session_nr == 2
            behav_filename = [filename(1:4),'_sessionNr05.mat'];
        else
            behav_filename = [filename(1:4),'_sessionNr09.mat'];
        end

        % load set
        EEG = pop_loadset('filename',filename,'filepath',conf.setfilesFold);

        % get trial target latency
        load([conf.behaviourFold behav_filename],'respMat_target_pos','respMat_moveL');
        latency_target_sec = (3 * respMat_target_pos)/(2*pi); % latency of target in seconds, knowing that the circle is done in 3 seconds
        latency_target_timeframes = round(latency_target_sec * conf.srate);

        % modify event list by adding those target latencies
        latency_old = vertcat(EEG.event.latency);
        type_old = vertcat(EEG.event.type);


        idx = find(type_old == 241);
        for nepochs = 1:length(idx) % position of the target on the screen
            latency_add(nepochs,1) = latency_old(idx(nepochs)) + latency_target_timeframes(nepochs);
            type_add(nepochs,1) = 100;
        end


        for nepochs = 1:length(idx) % max of the shooting curve
            latency_temp = find(respMat_moveL(:,nepochs) == max(respMat_moveL(:,nepochs))); % latency in ms
            latency_add = [latency_add; (latency_old(idx(nepochs)) + round(latency_temp(1)/1000 * conf.srate))]; % assign latency in seconds
            type_add = [type_add;101];
        end


        latency_new = [latency_old;latency_add];
        type_new = [type_old;type_add];

        [latency_new,I] = sort(latency_new,'ascend');
        type_new = type_new(I);
        urevent_new = (1:length(type_new))';

        clear EEG.event EEG.urevent

        temp = struct('latency',num2cell(latency_new), 'type',num2cell(type_new), 'urevent', num2cell(urevent_new));
        EEG.event = temp;

        temp1 = struct('latency',num2cell(latency_new), 'type',num2cell(type_new));
        EEG.urevent = temp1;

        % save dataset
        pop_saveset(EEG, 'filename', [filename(1:end-4),'_markers.set'], 'filepath',conf.markersFold,'version','7.3');

        clear EEG latency_new latency_add latency_old type_new type_add type_old urevent_new I idx
    end
end

