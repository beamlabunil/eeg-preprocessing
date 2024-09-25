% checkTriggersEEG.m
%
% SPARK PROJECT 2020.
%
% Function to verify that the number of each type of event in the EEG data is as expected,
% based on task structure
%
% Input: 
% - EEG structure, created when importing raw data file with EEGLab
% - conf structure containing triggerTypes, startStopTriggerTypes,
% otherEvents, expectedTriggerCount
% 
% Output:
% - triggerCount: structure with counts
% - trigger_check: bool, true when all the events required to split data 
% (Resting state start/stop and sequence start/stop) have the expected counts
% 
% - Displays status message in the command window: type of unregistered
% events, status of start/stop events, coherence between error count and
% restart events
% 
% 
%
% Copyright (c) 2020 UNIL
% Paolo Ruggeri (paolo.ruggeri@unil.ch)
% Jenifer Miehlbradt (jenifer.miehlbradt@unil.ch)


function [triggerCount,trigger_check] = checkTriggersEEG(EEG,conf)

fprintf('Checking trigger events...\n')

% Check for unlisted event types
recordedTriggerTypes = unique([EEG.event.type]);
unexpectedEventTypes = setdiff(recordedTriggerTypes, [conf.triggerTypes,conf.otherEvents]);
if ~isempty(unexpectedEventTypes)
    fprintf('Found unregistered events: ')
    fprintf('%2d ', unexpectedEventTypes)
    fprintf('\n -------------------------------------------- \n')
end

% Initialize bool to true
trigger_check = true;

% Verify number of triggers and create structure
triggerCount = struct();
for idx = find(conf.expectedTriggerCount)
    recordedTriggerCount(idx) = numel(find([EEG.event.type] == idx));
    triggerCount(end+1).type = idx;
    triggerCount(end).expectedCount = conf.expectedTriggerCount(idx);
    triggerCount(end).recordedCount = recordedTriggerCount(idx);
end
triggerCount = triggerCount(2:end);

diffTriggerCount = conf.expectedTriggerCount-recordedTriggerCount;

if any(diffTriggerCount)
    % Display errors
    for idx = find(diffTriggerCount)
        fprintf('Trigger type %d : expected %d events, found %d \n',idx,...
            conf.expectedTriggerCount(idx), recordedTriggerCount(idx));
    end
    fprintf('Verify start/stop triggers\n')
    fprintf('\n -------------------------------------------- \n')
    % Set bool to false
    trigger_check = false;
    
else
    fprintf('All expected events found \n')
end

% % Set bool to false only if start/stop triggers have issues
% if any(diffTriggerCount(startStopTriggerTypes))
%     trigger_check = false;
%     fprintf('Verify start/stop triggers\n')
% end


% % Verify number of errors
% errors = find([EEG.event.type] == 77);
% restarts = find([EEG.event.type] == 201 |[EEG.event.type] == 202 |...
%     [EEG.event.type] == 203 | [EEG.event.type] == 204 | [EEG.event.type] == 205 | ...
%     [EEG.event.type] == 206);
% 
% if numel(errors) ~= numel(restarts)
% %     trigger_check = false;
%     fprintf('Found %d errors and %d restarts \n', numel(errors), numel(restarts))
%     l = min([numel(errors), numel(restarts)]);
%     idx_shift = find(errors(1:l)-restarts(1:l)>1,1,'first');
%     fprintf('First shift occurs at error #%d or EEG.event #%d \n ----------------------------------------------------- \n',...
%         idx_shift,errors(idx_shift))
% else
%     fprintf('Error count ok \n')
% end


