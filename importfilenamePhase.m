function [DATAWRITE] = importfilenamePhase(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [VARNAME1,SUBNUM,VARNAME3,TASK,VARNAME5,VARNAME6,VARNAME7,VARNAME8,TRIALNUM,FAMILY,IMGCAT,IMGNUM,VARNAME13,CORRANSWER,VARNAME15,SUBANSWER,KEYSTRK,CORRECT,VARNAME19]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [VARNAME1,SUBNUM,VARNAME3,TASK,VARNAME5,VARNAME6,VARNAME7,VARNAME8,TRIALNUM,FAMILY,IMGCAT,IMGNUM,VARNAME13,CORRANSWER,VARNAME15,SUBANSWER,KEYSTRK,CORRECT,VARNAME19]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [VarName1,SubNum,VarName3,Task,VarName5,VarName6,VarName7,VarName8,TrialNum,Family,ImgCat,ImgNum,VarName13,CorrAnswer,VarName15,SubAnswer,KeyStrk,Correct,VarName19]
%   = importfile('phaseLog_pilot_name_name_1_b1.txt',1, 44);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/08/23 15:13:19

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

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

for col=[1,2,5,6,8,9,12,13,14,15,16,18]
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
rawNumericColumns = raw(:, [1,2,5,6,8,9,12,13,14,15,16,18]);
rawCellColumns = raw(:, [3,4,7,10,11,17,19]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
VarName1 = cell2mat(rawNumericColumns(:, 1));

%% Subject's number - with FLOWVIS or FLOVISE removed
SubNum = cell2mat(rawNumericColumns(:, 2));
VarName3 = rawCellColumns(:, 1);

%% name of the task - for these files, all name
Task = rawCellColumns(:, 2);
VarName5 = cell2mat(rawNumericColumns(:, 3));
VarName6 = cell2mat(rawNumericColumns(:, 4));
VarName7 = rawCellColumns(:, 3);
VarName8 = cell2mat(rawNumericColumns(:, 5));

%% trials 1-40

TrialNum = cell2mat(rawNumericColumns(:, 6));

%% Plain_ (general flow images) or VStreet_ for vortext streets
Family = rawCellColumns(:, 4); 

%% laminar or turbulent
ImgCat = rawCellColumns(:, 5);

%% individual image numbers
ImgNum = cell2mat(rawNumericColumns(:, 7));
VarName13 = cell2mat(rawNumericColumns(:, 8));

%% the correct answer for the trial (1 or 2)
CorrAnswer = cell2mat(rawNumericColumns(:, 9));
VarName15 = cell2mat(rawNumericColumns(:, 10));


%% the subject's answer for the trial, 1 or 2
SubAnswer = cell2mat(rawNumericColumns(:, 11));

KeyStrk = rawCellColumns(:, 6);

%% whether subject is correct (1) or wrong (0)
Correct = cell2mat(rawNumericColumns(:, 12));
VarName19 = rawCellColumns(:, 7);

%% find all hits (correct trials when images were same category), put in var 'hits'

hits = 0;
for trial = 1:20
    if (Correct(1+2*trial) == 1)
        hits = hits+1;
    end
    
end
% fprintf('total name trial hits');
% disp(hits);

% DATAWRITE contains data from the fileloaded by this function
DATAWRITE = {SubNum(2), hits};
