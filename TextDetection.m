%% Automatically Detect and Recognize Text in Natural Images
% and recognize character using model from The Chars74K dataset
% trained by bag of visual word method.
clc; close all; clear;

%% Step 1: Load image

% colorImage = imread('imgs/testPic1.jpg');
% colorImage = imread('imgs/testPic2.jpg');
% colorImage = imread('imgs/testPic3.jpg');
% colorImage = imread('imgs/testPic4.jpg');
colorImage = imread('imgs/testPic5.jpg');
% colorImage = imread('imgs/testPic6.png');

% colorImage = imread('imgs/testFont1.jpg');
% colorImage = imread('imgs/testFont2.jpg');
% colorImage = imread('imgs/testFont3.jpg');


figure; imshow(colorImage); title('Original image')

%% Step 2: setup parameter called helperDetectText
textPolarity = 'DarkTextOnLight';
sizeRange = [30, 10000];
eccentricityThreshold = 0.99;
maxStrokeWidthVariation = 0.35;
solidityRange = [0, 1];
morphologyOpenRadius = 25;
morphologyCloseRadius = 7;
%% Step 3: call helperDetectText
[boundingBoxesDark,segmentedCharacterMaskDark] = helperDetectText(colorImage,...
    'TextPolarity',textPolarity,...
    'SizeRange', sizeRange,...
    'MaxEccentricity', eccentricityThreshold,...
    'MaxStrokeWidthVariation', maxStrokeWidthVariation,...
    'SolidityRange', solidityRange,...
    'MorphologyOpenRadius', morphologyOpenRadius,...
    'MorphologyCloseRadius', morphologyCloseRadius);
%% Step 4: display result from helperDetectText
label_str_box = cell(1,1);
for i = 1:size(boundingBoxesDark, 1)
    label_str_box{i} = ['Box: ' num2str(i)];
end
Ibox = insertObjectAnnotation(colorImage, 'rectangle', boundingBoxesDark, ...
    label_str_box, 'Color', 'yello');
figure; imshow(Ibox), title('boundingBoxes');

figure; imshow(segmentedCharacterMaskDark); title('segmentedCharacterMask'); 

%% Step 5: list charactor from helperDetectText and label to display
connCompDark = bwconncomp(segmentedCharacterMaskDark);
statsDark = regionprops(connCompDark,'BoundingBox','Area');

bboxesDark = vertcat(statsDark.BoundingBox);
label_str_dark = cell(1,1);
for i = 1:connCompDark.NumObjects
    label_str_dark{i} = ['' num2str(i)];
end
%% Step 6: Display candidate character
IresultCandidate = insertObjectAnnotation(colorImage, 'rectangle', bboxesDark, ...
    label_str_dark, 'Color', 'yello');
figure; imshow(IresultCandidate), title('Result candidate character');
%% Step 7: Load model
load('imgHndFnt.mat', 'categoryClassifier');
% load('fnt.mat', 'categoryClassifier');
% load('hnd.mat', 'categoryClassifier');
% load('goodImg.mat', 'categoryClassifier');
%% Step 8: Define map
k = {'Sample001', 'Sample002', 'Sample003', 'Sample004', 'Sample005',...
    'Sample006', 'Sample007', 'Sample008', 'Sample009', 'Sample010',...
    'Sample011', 'Sample012', 'Sample013', 'Sample014', 'Sample015',...
    'Sample016', 'Sample017', 'Sample018', 'Sample019', 'Sample020',...
    'Sample021', 'Sample022', 'Sample023', 'Sample024', 'Sample025',...
    'Sample026', 'Sample027', 'Sample028', 'Sample029', 'Sample030',...
    'Sample031', 'Sample032', 'Sample033', 'Sample034', 'Sample035',...
    'Sample036', 'Sample037', 'Sample038', 'Sample039', 'Sample040',...
    'Sample041', 'Sample042', 'Sample043', 'Sample044', 'Sample045',...
    'Sample046', 'Sample047', 'Sample048', 'Sample049', 'Sample050',...
    'Sample051', 'Sample052', 'Sample053', 'Sample054', 'Sample055',...
    'Sample056', 'Sample057', 'Sample058', 'Sample059', 'Sample060',...
    'Sample061', 'Sample062'};

v = {'0', '1', '2', '3', '4',...
    '5', '6', '7', '8', '9',...
    'A', 'B', 'C', 'D', 'E',...
    'F', 'G', 'H', 'I', 'J',...
    'K', 'L', 'M', 'N', 'O',...
    'P', 'Q', 'R', 'S', 'T',...
    'U', 'V', 'W', 'X', 'Y',...
    'Z', 'a', 'b', 'c', 'd',...
    'e', 'f', 'g', 'h', 'i',...
    'j', 'k', 'l', 'm', 'n',...
    'o', 'p', 'q', 'r', 's',...
    't', 'u', 'v', 'w', 'x',...
    'y', 'z'};

charactorMap = containers.Map(k, v);
%% Step 8: Character recognition

bboxesRecognize = [];
label_str_result = cell(0,0);
maxScores = [];
for i = 1:connCompDark.NumObjects
    ITmpCrop = imcrop(colorImage, bboxesDark(i, :));
    [labelIdx, scores] = predict(categoryClassifier, ITmpCrop);
    predictedLabel = categoryClassifier.Labels(labelIdx);
    predictedLabelCharacter = charactorMap(predictedLabel{1});
    
    maxScores(end+1) = max(scores);
    % Remove score <= -0.5
    if max(scores) >= -0.5
        bboxesRecognize(end+1,:) = bboxesDark(i, :);
        label_str_result{end+1} = ['' predictedLabelCharacter];
    end
end

IresultRecognize = insertObjectAnnotation(colorImage, 'rectangle', bboxesRecognize, ...
    label_str_result, 'Color', 'yello');

figure, imshow(IresultRecognize), title('Result recognized character');

figure, hist(maxScores), title('Histrogram Score predicted character.');

