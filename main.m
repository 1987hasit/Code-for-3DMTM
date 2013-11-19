%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bin Liang (bin.liang.ty@gmail.com)
% Charles Sturt University
% Created:	September 2013
% Modified:	November 2013
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparing for running
% clear variables
clear all; close all; clc;

% add to path
this_dir = pwd;
addpath(genpath(this_dir));

% set dataset path
data_path = 'D:\\Research\\Projects\\Dataset\\MSR Action3D\\dataset\\';

% specify the paths to training and  test data
test_subsets = {'test_one\\', 'test_two\\', 'cross_subject_test\\'};
action_subsets = {'AS1\\', 'AS2\\', 'AS3\\'};

training_data_dir = [data_path test_subsets{2} 'training\\' action_subsets{3}];
test_data_dir = [data_path test_subsets{2} 'test\\' action_subsets{3}];

%% Load training data
d = dir(training_data_dir);
isfile = [d(:).isdir] ~= 1;
files = {d(isfile).name}';

TR_Gestures = struct;

%% Feature extraction for training dataset
fprintf('Loading training data:\n');
for i=1:length(files)
    fprintf([files{i}, '...']);
    
    % load data as a video sequence
    SEQUENCE = readDepthDataset([training_data_dir files{i}]);  % frame scale: [1 552]        

    % gesture representation using 3D-MTM
    representation = compute3DMTM(SEQUENCE);
   
    % feature extraction using HOG (fast one)
    features = feature_extraction_v3(representation);
    
    %% additional information
    name = files{i};
    id = name(2:3);

    %% save data
    TR_Gestures(i).Features = features;
    TR_Gestures(i).Name = name;
    TR_Gestures(i).Id = str2double(id);
    
    fprintf('done.\n');        
end

% %% PCA
% NORM_TR_FEATURES = zscore(TR_FEATURES);
% [COEFF, Proj_TR_Features, latent] = pca(NORM_TR_FEATURES);
% 
% for i=1:length(latent)
%     if latent(i) / sum(latent) > 0.99
%         break;
%     end
% end
% 
% pc_num = i;
% 
% REDUCED_TR_Features = Proj_TR_Features(:, 1:pc_num);

% save training data as .mat file
save('TR_Gestures.mat', 'TR_Gestures');

% format to SVM file
TR_SVM_file = 'TR_Gestures.svm';
% mat2SVMfile(TR_Gestures, TR_SVM_file);

% format normalized features
X = [tr_lables zscore(TR_FEATURES)];
mat2SVMfile_norm(X, TR_SVM_file);

%pause;

%% load test data
d = dir(test_data_dir);
isfile = [d(:).isdir] ~= 1;
files = {d(isfile).name}';

TE_Gestures = struct;

%%
TE_FEATURES = zeros(length(files), num_features);
te_lables = zeros(length(files), 1);
%%
fprintf('Loading test data:\n');
for i=1:length(files)
    fprintf([files{i}, '...']);
    
    SEQUENCE = readDepthDataset([test_data_dir files{i}]);    
    [SEQUENCE_XOZ, SEQUENCE_YOZ] = projectVideo(SEQUENCE);
    
    %% video filtered by LoG
    FilteredVideo_XOY = LoGFilterVideo(SEQUENCE);
    FilteredVideo_XOZ = LoGFilterVideo(SEQUENCE_XOZ);
    FilteredVideo_YOZ = LoGFilterVideo(SEQUENCE_YOZ);
    
    %% generate representation for each gesture
    % load data and extract features
    
    % video filtered by Gaussian filter [1 4 6 4 1]
%     FilteredVideo = GaussianFilterVideo(SEQUENCE);
%     FilteredVideo_XOZ = GaussianFilterVideo(SEQUENCE_XOZ);
%     FilteredVideo_YOZ = GaussianFilterVideo(SEQUENCE_YOZ);

    %% gesture representation
    %3D-MTM
%     representation = compute3DMTM_v2(SEQUENCE);   
%     features = feature_extraction_v2(representation);
%     representation = compute3DMTM_v3(FilteredVideo, FilteredVideo_XOZ, FilteredVideo_YOZ);
   
    representation = compute3DMTM_v4(FilteredVideo_XOY, FilteredVideo_XOZ, FilteredVideo_YOZ);
    features = feature_extraction_v3(representation);

%     % MHI
%     representation = computeMHI(SEQUENCE);
%     features = HOG(representation);
    %% additional information
    name = files{i};
    id = name(2:3);

    %% save data
    TE_Gestures(i).Features = features;
    TE_Gestures(i).Name = name;
    TE_Gestures(i).Id = str2double(id);

    fprintf('done.\n');

    %% save to file
    te_lables(i, :) = str2double(id);
    TE_FEATURES(i, :) = features;
end

% %% PCA
% NORM_TR_FEATURES = zscore(TE_FEATURES);
% Proj_TE_Features = bsxfun(@minus, NORM_TR_FEATURES, mean(NORM_TR_FEATURES)) * COEFF;
% REDUCED_TE_Features = Proj_TE_Features(:, 1:pc_num);

% save test data as .mat file
save('TE_Gestures.mat', 'TE_Gestures');

% format to SVM file
TE_SVM_file = 'TE_Gestures.svm';
%mat2SVMfile(TE_Gestures, TE_SVM_file);

% format normalized features
X = [te_lables zscore(TE_FEATURES)];
mat2SVMfile_norm(X, TE_SVM_file);

%pause;

%% recognition
%[predict_label, accuracy] = recognize(TR_Gestures, TE_Gestures);
pause(0.5);beep; pause(0.5);beep; pause(0.5);beep;