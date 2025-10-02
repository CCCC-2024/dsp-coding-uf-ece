% =========================================================================
% Main Script for Coding Assignment #04: Fourier Transforms
% Case File #4 - The Spy Who Played
% =========================================================================

clear;
clc;
close all;

% --- Step 1: Load Classified Intelligence Data ---
% Use your UFID to get the specific audio data for the assignment.
ufid = '22806708'; % Your UFID
[X, zn, freq, Fs] = get_spy_audio(ufid);

fprintf('Data loaded successfully.\n');
fprintf('Sampling Frequency (Fs): %.0f Hz\n', Fs);
fprintf('Number of known sequences: %d\n', size(X, 2));
fprintf('Number of frequencies to analyze: %d\n', length(freq));

% --- Step 2: Identify the Matching Audio Sequence ---
% Call your function to find the index of the matching column in X.
% This function internally calls partialDTFT.
indexMatch = findMatchingAudio(X, zn, freq, Fs);

fprintf('\nAnalysis complete.\n');
fprintf('The matching audio sequence is in column: %d\n', indexMatch);

% --- Step 3: Save Deliverable ---
% Save the final indexMatch variable to a .mat file for submission.
save('A.mat', 'indexMatch');

fprintf('Result saved to A.mat. You are ready to submit.\n');