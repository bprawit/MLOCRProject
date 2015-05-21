%% Image Category Classification Using Bag of Features
clc; close all; clear
%% Load Image Sets
% rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Img\GoodImg\Msked');
% rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Img\BadImag\Msked');
% rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Img\AllImg\Msked');

% rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Hnd\ImgShrink');
% rootFolder = fullfile(pwd, 'The Chars74K dataset\English\FntShrink');
rootFolder = fullfile(pwd, 'The Chars74K dataset\English\ImgHndFnt');

%% Save all data
% fileSave = 'goodImg.mat';
% fileSave = 'badImg.mat';
% fileSave = 'allImg.mat';
% fileSave = 'hnd.mat';
% fileSave = 'fnt.mat';
fileSave = 'imgHndFnt.mat';
%%
% Construct an array of image sets based on the following categories from
% Caltech 101: 'airplanes', 'ferry', 'laptop'. Use |imageSet| class to help
% you manage the data. Since |imageSet| operates on image file locations,
% and therefore does not load all the images into memory, it is safe to use
% on large image collections.
imgSets = imageSet(fullfile(rootFolder), 'recursive');

%%
% Each element of the |imgSets| variable now contains images associated
% with the particular category.  You can easily inspect the number of
% images per category as well as category labels as shown below:

% { imgSets.Description } % display all labels on one line
% [imgSets.Count]         % show the corresponding count of images

%%
% Note that the labels were derived from directory names used to construct
% the image sets, but can be customized by manually setting the Description
% property of the imageSet object.

%% Prepare Training and Validation Image Sets
% Since |imgSets| above contains an unequal number of images per category,
% let's first adjust it, so that the number of images in the training set is balanced.

minSetCount = min([imgSets.Count]); % determine the smallest amount of images in a category

% Use partition method to trim the set.
imgSets = partition(imgSets, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
% [imgSets.Count]

%%
% Separate the sets into training and validation data. Pick 30% of images
% from each set for the training data and the remainder, 70%, for the 
% validation data. Randomize the split to avoid biasing the results.

[trainingSets, validationSets] = partition(imgSets, 0.7, 'randomize');

%%
% The above call returns two arrays of imageSet objects ready for training
% and validation tasks. Below, you can see example images from the three
% categories included in the training data.

charA = read(trainingSets(1),1);
charB = read(trainingSets(2),1);
charC = read(trainingSets(3),1);

figure

subplot(1,3,1);
imshow(charA);
subplot(1,3,2);
imshow(charB)
subplot(1,3,3);
imshow(charC)

%% Create a Visual Vocabulary and Train an Image Category Classifier
% Bag of words is a technique adapted to computer vision from the
% world of natural language processing. Since images do not actually
% contain discrete words, we first construct a "vocabulary" of 
% <matlab:doc('extractFeatures'); SURF> features representative of each image category.

%%
% This is accomplished with a single call to |bagOfFeatures| function,
% which:
%
% # extracts SURF features from all images in all image categories
% # constructs the visual vocabulary by reducing the number of features
%   through quantization of feature space using K-means clustering
bag = bagOfFeatures(trainingSets);

%%
% Additionally, the bagOfFeatures object provides an |encode| method for
% counting the visual word occurrences in an image. It produced a histogram
% that becomes a new and reduced representation of an image.

img = read(imgSets(1), 1);
featureVector = encode(bag, img);

% Plot the histogram of visual word occurrences
figure
bar(featureVector)
title('Visual word occurrences')
xlabel('Visual word index')
ylabel('Frequency of occurrence')

%%
% This histogram forms a basis for training a classifier and for the actual
% image classification. In essence, it encodes an image into a feature vector. 
%
% Encoded training images from each category are fed into a classifier
% training process invoked by the |trainImageCategoryClassifier| function.
% Note that this function relies on the multiclass linear SVM classifier
% from the Statistics and Machine Learning Toolbox(TM).

categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

%%
% The above function utilizes the |encode| method of the input |bag| object
% to formulate feature vectors representing each image category from the 
% |trainingSets| array of imageSet objects.

%% Evaluate Classifier Performance
% Now that we have a trained classifier, |categoryClassifier|, let's
% evaluate it. As a sanity check, let's first test it with the training
% set, which should produce near perfect confusion matrix, i.e. ones on 
% the diagonal.

confMatrixTrain = evaluate(categoryClassifier, trainingSets);

errorTrain = mean(diag(confMatrixTrain));

%%
% Next, let's evaluate the classifier on the validationSet, which was not
% used during the training. By default, the |evaluate| function returns the
% confusion matrix, which is a good initial indicator of how well the
% classifier is performing.

confMatrixValidation = evaluate(categoryClassifier, validationSets);

% Compute average accuracy
errorVal = mean(diag(confMatrixValidation));

%%
% Additional statistics can be derived using the rest of arguments returned
% by the evaluate function. See help for |imageCategoryClassifier/evaluate|.
% You can tweak the various parameters and continue evaluating the trained
% classifier until you are satisfied with the results.

%% Try the Newly Trained Classifier on Test Images
% You can now apply the newly trained classifier to categorize new images.

predictedImgPath = validationSets(1, 1).ImageLocation{1, 1};
% predictedImgPath = trainingSets(1, 2).ImageLocation{1, 1};
img = imread(predictedImgPath);
[labelIdx, scores] = predict(categoryClassifier, img);

figure, hist(scores), title('Histrogram Score predicted character.');

% Display the string label
predictedLabel = categoryClassifier.Labels(labelIdx);

figure, imshow(img), title(predictedImgPath), text(size(img, 1)/2,size(img, 2)/2,predictedLabel, 'FontSize', 20, ...
    'Color', 'blue');

save(fileSave);
