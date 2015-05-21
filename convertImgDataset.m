clc; close all; clear
%% Root folder
rootFolder = fullfile(pwd, 'The Chars74K dataset\English\Img\BadImag');
%%
BmpDirPath = fullfile(rootFolder, 'Bmp');
MskDirPath = fullfile(rootFolder, 'Msk');

targetDirPath = fullfile(rootFolder, 'Msked');

%%
BmpDir = dir(BmpDirPath);
MskDir = dir(MskDirPath);
for i = 3:numel(BmpDir)
    currentBmpDirPath = fullfile(BmpDirPath, BmpDir(i, 1).name);
    currentBmpDir = dir(currentBmpDirPath);
    
    currentMskDirPath = fullfile(MskDirPath, MskDir(i, 1).name);
    currentMskDir = dir(currentMskDirPath);
    
    targetCurrentDirPath = fullfile(targetDirPath, BmpDir(i, 1).name);
    mkdir(targetCurrentDirPath);
    
    
    for j = 3:numel(currentBmpDir)
        currentBmpFile = currentBmpDir(j, 1).name;
        currentBmpImg = imread(fullfile(currentBmpDirPath, currentBmpFile));
        
        currentMskFile = currentMskDir(j, 1).name;
        currentMskImg = imread(fullfile(currentMskDirPath, currentMskFile));
        
        mask_three_chan = repmat(currentMskImg, [1, 1, 3]);
        currentBmpImg(~mask_three_chan) = 0;
        
        imwrite(currentBmpImg, strcat(fullfile(targetCurrentDirPath, currentBmpFile)), 'png')
        
    end
    
end
