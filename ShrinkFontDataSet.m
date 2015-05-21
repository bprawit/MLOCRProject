clc; close all; clear
%% Root folder
rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Fnt');

targetDirPath = fullfile(pwd, 'The Chars74K dataset\English\FntShrink');

%%
sampleDir = dir(rootFolder);
for i = 3:numel(sampleDir)
    sampleDirPath = fullfile(rootFolder, sampleDir(i, 1).name);
    sampleFiles = dir(sampleDirPath);
    
    targetCurrentDirPath = fullfile(targetDirPath, sampleDir(i, 1).name);
    mkdir(targetCurrentDirPath);
    
    for j = 3:202
        currentPngFile = sampleFiles(j, 1).name;
        currentPngPath = fullfile(sampleDirPath, sampleFiles(j, 1).name);
        
        currentPngImg = imread(currentPngPath);
        targetPngPath = fullfile(targetCurrentDirPath, sampleFiles(j, 1).name);
        
        ITmpResize = imresize(currentPngImg, 0.3);
        imwrite(ITmpResize, targetPngPath, 'png');
%         copyfile(currentPngPath, targetPngPath);
    end
end
