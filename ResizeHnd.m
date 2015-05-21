clc; close all; clear
%% Root folder
rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Hnd\Img');
targetDirPath = fullfile(pwd, 'The Chars74K dataset\English\Hnd\ImgShrink');

%%
sampleDir = dir(rootFolder);
for i = 3:numel(sampleDir)
    sampleDirPath = fullfile(rootFolder, sampleDir(i, 1).name);
    sampleFiles = dir(sampleDirPath);
    
    targetCurrentDirPath = fullfile(targetDirPath, sampleDir(i, 1).name);
    mkdir(targetCurrentDirPath);
    
    for j = 3:numel(sampleFiles)
        currentPngFile = sampleFiles(j, 1).name;
        currentPngPath = fullfile(sampleDirPath, currentPngFile);
        
        targetPngPath = fullfile(targetCurrentDirPath, sampleFiles(j, 1).name);
        
        currentPngImg = imread(currentPngPath);
        
        ITmpResize = imresize(currentPngImg, 0.1);
        imwrite(ITmpResize, targetPngPath, 'png');
    end
end