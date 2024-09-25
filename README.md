# SEMI-AUTOMATIC EEG PREPROCESSING PIPELINE

## DESCRIPTION 
This README outlines a semi-automatic pipeline customized in MATLAB utilizing scripts from eeglab. The purpose of this pipeline is to automate the ...... 

Features 
.... 

## SUPPORT 

Refer to software documentation for additional details or updates here : https://eeglab.org/

## BUILT WITH
-	Matlab
-	eeglab scripts

## GETTING STARTED
Prerequisites 
-	Matlab
-	eeglab

## Instructions
1. To start the EEG preprocessing, run the initEEGprepr.m script to initialize the preprocessing environment. However, before running it, ensure the following customizations in the Cfg folder:

- Customize the Paths: In the loadPathsEEGprepr.m script, adjust the folder paths (conf.rootFold and conf.rawFold) to match the directories on your system where the raw EEG data and processing files will be stored. 
- Tailor the Configuration: In the loadCfgEEGprepr.m function, modify the configuration to fit your study, including:
Defining trigger types and expected counts (conf.triggerTypes), Adjusting epochs of interest (conf.startTrigger), Setting filtering parameters.

2. In the created folders, you need to load the necessary data :
   - elPosition : load the electrode positions
   - elRefImport : create a text file "participantCode_EEG1.txt" with the electrode you want to use as Reference
   - elToInt : create a text file "participantCode_EEG1.txt" with the electrodes that need to be interpolated because noisy, broken etc

4. In Prep folder, run each script following the order of their titles (Run1 through Run6). These codes preprocess EEG data by verifying triggers, re-referencing, filtering, interpolating bad channels, running ICA for artifact removal, and epoching the data for further analysis.
   Run1 bis is optional - here additional behavioural markers are marked on the EEG files.
   For Run5 - choose the type of ICA rejection algorithm you'd like to use and Run that script only. 


## CONTACT
Kate Schipper : kate.schipper@unil.ch

Paolo Ruggeri : paolo.ruggeri@unil.ch
