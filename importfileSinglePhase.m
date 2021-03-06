function [DATAWRITE] = importfileSinglePhase(filename, startRow, endRow)
%function [VarName1,SubNum,VarName3,Task,PhaseNum,VarName6,VarName7,TrialNum,Family,ImgCat,ImgNum,VarName12,VarName13,KeyStrk,Correct,VarName16,VarName17] = importfileSinglePhase(filename, startRow, endRow)
% 
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [VARNAME1,SUBNUM,VARNAME3,TASK,PHASENUM,VARNAME6,VARNAME7,TRIALNUM,FAMILY,IMGCAT,IMGNUM,VARNAME12,VARNAME13,KEYSTRK,CORRECT,VARNAME16,VARNAME17]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [VARNAME1,SUBNUM,VARNAME3,TASK,VARNAME5,VARNAME6,VARNAME7,TRIALNUM,FAMILY,IMGCAT,IMGNUM,VARNAME12,VARNAME13,KEYSTRK,CORRECT,VARNAME16,VARNAME17]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [VarName1,SubNum,VarName3,Task,VarName5,VarName6,VarName7,TrialNum,Family,ImgCat,ImgNum,VarName12,VarName13,KeyStrk,Correct,VarName16,VarName17]
%   = importfile('phaseLog_pilot_match_match_1.txt',2, 123);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/08/11 08:46:57

%% Initialize variables.
delimiter = '\t';
if nargin<=2
startRow = 2;
endRow = 123;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
frewind(fileID);
dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
for col=1:length(dataArray)
dataArray{col} = [dataArray{col};dataArrayBlock{col}];
end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,5,6,8,11,12,15,16,17]
% Converts strings in the input cell array to numbers. Replaced non-numeric
% strings with NaN.
rawData = dataArray{col};
for row=1:size(rawData, 1);
% Create a regular expression to detect and remove non-numeric prefixes and
% suffixes.
regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
try
result = regexp(rawData{row}, regexstr, 'names');
numbers = result.numbers;

% Detected commas in non-thousand locations.
invalidThousandsSeparator = false;
if any(numbers==',');
thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
if isempty(regexp(thousandsRegExp, ',', 'once'));
numbers = NaN;
invalidThousandsSeparator = true;
end
end
% Convert numeric strings to numbers.
if ~invalidThousandsSeparator;
numbers = textscan(strrep(numbers, ',', ''), '%f');
numericData(row, col) = numbers{1};
raw{row, col} = numbers{1};
end
catch me
end
end
end

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,2,5,6,8,11,12,15,16,17]);
rawCellColumns = raw(:, [3,4,7,9,10,13,14]);


%% Replace blank cells with NaN
R = cellfun(@(x) isempty(x) || (ischar(x) && all(x==' ')),rawNumericColumns);
 rawNumericColumns(R) = {NaN}; % Replace blank cells

%% Allocate imported array to column variable names
VarName1 = cell2mat(rawNumericColumns(:, 1));
% subject numbers 
SubNum = cell2mat(rawNumericColumns(:, 2));
VarName3 = rawCellColumns(:, 1);
% task name indicates type whether matching or naming - numbered as phases
Task = rawCellColumns(:, 2);
%phase is the which time through the task (match 1 2 or 3), as PhaseNum
PhaseNum = cell2mat(rawNumericColumns(:, 3));
VarName6 = cell2mat(rawNumericColumns(:, 4));
VarName7 = rawCellColumns(:, 3);
% 40 trials per phase (per data file)
TrialNum = cell2mat(rawNumericColumns(:, 5));
% indicates whether images are Vortex streets or General
Family = rawCellColumns(:, 4);
% indicates whether image is turbulent or laminar flow
ImgCat = rawCellColumns(:, 5);
% individual identifier of image
ImgNum = cell2mat(rawNumericColumns(:, 6));
VarName12 = cell2mat(rawNumericColumns(:, 7));
VarName13 = rawCellColumns(:, 6);
%what key the subject hit - f or j, lined up with same or different, and
%this alternated depending on the subject number
KeyStrk = rawCellColumns(:, 7);
% 1= correct, 0= incorrect
Correct = cell2mat(rawNumericColumns(:, 8));
VarName16 = cell2mat(rawNumericColumns(:, 9));
VarName17 = cell2mat(rawNumericColumns(:, 10));

%% identify this subject, this version of the experiment, and this session
% disp(filename);
% disp(Family(3));
% disp(SubNum(2));

%% find all hits (correct trials when images were same category), put in var 'hits'

hits = 0;
for trial = 1:40
    if (Correct(1+3*trial) == 1)
        if (strncmpi(ImgCat(3*trial), 'Turbulent_',1) && strncmpi(ImgCat(3*trial-1), 'Turbulent_',1));
            hits = hits+1;
        elseif (strncmpi(ImgCat(3*trial), 'Laminar_',1) && strncmpi(ImgCat(3*trial-1), 'Laminar_',1));
            hits = hits+1;
        end
    end
    
end
% fprintf('total hits');
% disp(hits);

%% find all misses (incorrect answers when images were same category, put in var 'misses'
misses = 0;
for trial = 1:40
    if (Correct(1+3*trial) == 0);
        if (strncmpi(ImgCat(3*trial), 'Turbulent_',1) && strncmpi(ImgCat(3*trial-1), 'Turbulent_',1));
            misses = misses+1;
        elseif (strncmpi(ImgCat(3*trial), 'Laminar_',1) && strncmpi(ImgCat(3*trial-1), 'Laminar_',1));
            misses = misses+1;
            
        end
    end
    
end
% fprintf('total misses');
% disp(misses);

%% find all Correct Rejections (correct answers when two images are different categories, put in var 'correj'
correj = 0;
for trial = 1:40
    if (Correct(1+3*trial) == 1)
        if ~(strcmp(ImgCat(3*trial), ImgCat(3*trial-1)));
            correj = correj+1;
        end
    end
end
% fprintf('total correct rejections');
% disp(correj);
%% find all False Alarms (incorrect answers when two images are different categories, put in var 'falalrm'
falalrm = 0;
for trial = 1:40
   if (Correct(1+3*trial) == 0);      
        if ~(strcmp(ImgCat(3*trial), ImgCat(3*trial-1)));
            falalrm = falalrm+1;
        end
   end
end
% fprintf('total false alarms');
% disp(falalrm);

%% total correct trials and put in variable totCorrect
totCorrect = 0;
for trial = 1:40
totCorrect = totCorrect + Correct(1+3*trial);
end
% fprintf('total correct is');
% disp(totCorrect);

%write data to .xlsx for graphs etc to be made, using DATAWRITE as matrix
%containing data to write to excel file
%newfile = 'subjectdata.xlsx';

% DATAWRITE contains data from the fileloaded by this function
DATAWRITE = {SubNum(2), PhaseNum(2), hits, misses, correj, falalrm};