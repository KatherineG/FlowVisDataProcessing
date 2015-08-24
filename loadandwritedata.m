function loadandwritedata(expName, SubNum)
%% loadandwritedata is a function to organize data files from the FLOWVIS & 
%% FLOWVISE experttrain experiments, run in 2014-2015.
%% It calls function importfileSinglePhase.m and importfileNamePhase.m to grab data from each 
%% subject's different phase files and write them to different sheets of
%% Excel spreadsheets.
%%There are separate excel sheets for odd and even numbered subjects.
%%
%% it needs the subject number (SubNum) in order to write to the correct
%% spreadsheet, as odd and even numbered subjects were trained with 
%% different image sets (VStreet_ and General_ / Plain_)
%%
%% initialize variables (DO I NEED TO DO THIS?)

%% read in expName (experiment name, either FLOWVIS or FLOWVISE)
%% read in SubNum (subject number)
%% define the correct directory, will be of the format:
%% pwd\FlowVis\expNameSubNum\session_1
%

% move use to the path with all the data for this subject
% note that all data for a subject is in session 1, since this is a single
% session experiment

%pathname = sprintf('%s%s\\%s%s\\session_1',expName,SubNum,expName,SubNum);
pathname = sprintf('%s%s\\session_1',expName,SubNum);

cd (pathname);

% odd or even subject number

if mod(str2double(SubNum),2) == 0
  isEven = true;
else
  isEven = false;
end

% assign file name differently if even or odd
% assign row number based upon subject number to prevent overwriting
%
if strcmp(expName,'FLOWVIS') == 1
    if isEven == true
        outputfile = 'C:\Users\Kate\Desktop\EvSubjectdata.xlsx';
        Row = ((str2double(SubNum))/2)+1;
    else
        outputfile = 'C:\Users\Kate\Desktop\OddSubjectdata.xlsx';
        Row = ((str2double(SubNum))/2)+1.5;
    end
else
    if isEven == true
        outputfile = 'C:\Users\Kate\Desktop\EXPERTEvSubjectdata.xlsx';
        Row = ((str2double(SubNum))/2)+1;
    else
        outputfile = 'C:\Users\Kate\Desktop\EXPERTOddSubjectdata.xlsx';
        Row = ((str2double(SubNum))/2)+1.5;
    end
end
% put header row on each sheet of outputfile

HEADER = {'SUBJECT', 'PHASE','HITS', 'MISSES', 'CORRECT REJECTIONS', 'FALSE ALARMS'};
NAMEHEAD = {'SUBJECT', 'CORRECT'};
xlswrite(outputfile,HEADER, 1);
xlswrite(outputfile,HEADER, 2);
xlswrite(outputfile,HEADER, 3);
xlswrite(outputfile,NAMEHEAD, 4);

% create string for Row so it can be appended to Xcel cell ID
RowName = num2str(Row);
%disp(RowName);

% Call importfileSinglePhase
% need to pass it 3 inputs, raw data file, starting row, ending row
[DATAWRITE] = importfileSinglePhase ('phaseLog_pilot_match_match_1.txt', 2, 132);

% write DATAWRITE to the correct sheet for this phase of data

xlRange = strcat('A', RowName);
%disp(xlRange);
xlswrite(outputfile,DATAWRITE,1,xlRange);
   
[DATAWRITE] = importfileSinglePhase ('phaseLog_pilot_match_match_2.txt', 2, 132);
xlRange = strcat('A', RowName);
sheet = 2;
xlswrite(outputfile,DATAWRITE,sheet,xlRange);

[DATAWRITE] = importfileSinglePhase ('phaseLog_pilot_match_match_3.txt', 2, 132);
xlRange = strcat('A', RowName);
sheet = 3;
xlswrite(outputfile,DATAWRITE,sheet,xlRange);

[DATAWRITE] = importfilenamePhase ('phaseLog_pilot_name_name_1_b1.txt', 2, 132);
xlRange = strcat('A', RowName);
sheet = 4;
xlswrite(outputfile,DATAWRITE,sheet,xlRange);

% Need to get from it, the matrix containing the summarized data
% with hits, misses, correct rejections, and false alarms

%Reset file path to main data folder
cd ..;
cd ..;
%cd ..;

