function conf = loadCfgEEGprepr()
% EEG preprocessing configuration 
% BMT project - UNIL 2023

% Sampling rate
conf.srate = 1024;

% downsampling
conf.dslog = 1; % 0: do not downsample, keep initial sampling rate; 1: downsample
conf.dsfactor = 4; % if conf.dslog = 1, the code implements downsampling (options are 2; 4; 8; etc)

% Trigger types and expected count
% Used in RunMe_checkEvents -> checkTriggersEEG
conf.triggerTypes = ...
    [10,...                  % blank screen
    24,...                   % stimulus apparition: user has to find the correct strength here
    30,...                   % Feedback of trial
    40,...                   % feedback general (summary)
    50,...                   % pause between blocks of trials
    80,81,...                % RS1 start / RS1 stop
    90,91,...                % RS2 start / RS2 stop
    241];                    % Cursor start for a duration of 3 seconds when participant found the correct strength

% epochs of interest
conf.startTrigger = 241;   % cursor start
conf.expectedTriggerCount(conf.startTrigger) = 60;
conf.otherEvents = [4,10,24,30,40,50,80,81,90,91]; % other known events: start, feedback (empty screen and text)
conf.latencyStartTrigger = [-0.2  3]; % e.g., [-1  3] means 1 sec before and 2 secs after the StartTrigger


% Shift applied to (some) trigger events when imported by EEGlab...
conf.triggerShift1 = 15360;
conf.triggerShift2 = 15872;

% Filtering
conf.fHP = 0.5; % high pass cutoff
conf.fNl = 49; % lower cutoff notch
conf.fNh = 51;% higher cutoff notch


% epochs electrode interpolation
conf.epochElInt = true; % if true, interpolate electrodes at the epochs level looking for outliers based on standard deviation of the signal

% wMNE
conf.DepthWeightOrder = 0.5;
conf.DepthWeightMaxAmount = 10;
conf.SNR = 3;


