%% Import data from text file
% Script for importing data from the following text file:
%    filename: C:\Users\User\Desktop\UCL\Dissertation code files\SocEvalModels_(not_git)_rough_work-20230307T220354Z-001\SocEvalModels_(not_git)_rough_work\Carlisi_team_work-20230512T122649Z-001\Carlisi_team_work\NormanLau30Apr23\Data\Data\raw data\Evaluation_PARTICIPANT_SESSION_2023-04-27_19h40.58.765.csv

% %% Set up the Import Options and import the data
% opts = delimitedTextImportOptions("NumVariables", 35);
% 
% % Specify range and delimiter
% opts.DataLines = [2, Inf];
% opts.Delimiter = ",";
% 
% % Specify column names and types
% opts.VariableNames = ["width", "height", "subject_nr", "avatar_file", "gender", "other_ratee", "block_nr", "rater_name", "rater_file", "ratee_type", "ratee_name", "ratee_file", "liking", "trial_nr", "positive_left", "positive_correct", "pos_word", "neg_word", "correct_word", "left_word", "right_word", "response", "choice", "chose_positive", "accuracy", "comment", "t_start_experiment", "t_start_block", "t_start_trial", "t_response", "likes_on_left", "evaluation", "t_ask_eval", "t_eval_resp", "rater_avatar"];
% opts.VariableTypes = ["double", "double", "double", "double", "categorical", "string", "double", "string", "string", "categorical", "string", "double", "categorical", "double", "double", "double", "string", "string", "string", "string", "string", "double", "string", "categorical", "categorical", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% 
% % Specify file level properties
% opts.ExtraColumnsRule = "ignore";
% opts.EmptyLineRule = "read";
% 
% % Specify variable properties
% opts = setvaropts(opts, ["other_ratee", "rater_name", "rater_file", "ratee_name", "pos_word", "neg_word", "correct_word", "left_word", "right_word", "choice", "comment"], "WhitespaceRule", "preserve");
% opts = setvaropts(opts, ["gender", "other_ratee", "rater_name", "rater_file", "ratee_type", "ratee_name", "liking", "pos_word", "neg_word", "correct_word", "left_word", "right_word", "choice", "chose_positive", "accuracy", "comment"], "EmptyFieldRule", "auto");
% opts = setvaropts(opts, ["avatar_file", "ratee_file", "rater_avatar"], "TrimNonNumeric", true);
% opts = setvaropts(opts, ["avatar_file", "ratee_file", "rater_avatar"], "ThousandsSeparator", ",");

%CODE BEGINS HERE
% Import the data and set folder path

% comment out as necessary. Rough and ready indicators of where we are working:
% machine = 'MSlaptop';     % indicator that file is to be found in Melanie's laptop ...
% machine = 'MMlaptop';     % ... or Michael's laptop
machine = 'MSlaptop';     % ... etc.
if strcmp(machine,'MMdesktop')
   folderPath = '/home/michael/googledirs/MM/SocEvalModels_(not_git)_rough_work/Carlisi_team_work/NormanLau30Apr23/raw data/';
elseif strcmp(machine,'MSlaptop')
   folderPath = 'C:\Users\User\Desktop\UCL\Dissertation code files\SocEvalModels_(not_git)_rough_work-20230307T220354Z-001\SocEvalModels_(not_git)_rough_work\Carlisi_team_work-20230512T122649Z-001\Carlisi_team_work\NormanLau30Apr23\Data\Data\raw data';
else
    error(['machine ' machine ' not provied for']);
end
    
%NOTE: if you are preallocating a size for an array, create array for
 %strings not an numerical array for data like names etc.
 %so this means don't use zeros or ones to preallocate.
 %functions like zeros/ones creates a numerical array automatically.

fileList = dir(fullfile(folderPath)); %An attempt to get a list of all the files in the folder

% Create an empty structure to store the extracted column data
%this is to initialise the variables before the loop begins
selD = {};
rowsPerBlock = 20; 
ptN = 0;               % counts valid participant files.

for i = 1:numel(fileList) %iterate thorugh each file in the folder. New part starts here.

    fileName = fileList(i).name; %This line retrieves the name of the current file being processed in the loop and assigns it to the variable fileName.

    if ( length(fileName) > 11 && ...
         strcmp(fileName(1:11), 'Evaluation_')) %This line checks if the length of the file name is greater than 11 characters and if the first 11 characters of the file name are equal to the string 'Evaluation_'.
%It combines two conditions using the logical AND (&&) operator.
%This condition is used to identify files that meet the criteria of being evaluation files.
    
        filePath = fullfile(folderPath, fileName); % To construct the full file path, 
                                               % so each file can be read indivdually
                                               % in the order of the fileList
                                              
   
        dataTable = readtable(filePath);  % Read the Excel file as a table. Each participant data is referred to as dataTable
        % Once we have successfully read in the the data, we can be 
        % confident to augment the participant number:
        ptN = ptN + 1; %This line increments the value of ptN by 1.
%It is used to track the participant number and ensure each participant's data is stored separately.

raterNames = dataTable(:,'rater_name');%extract data from table read. if this doesn't work try 'raterNames = dataTable.rater_name';

%This section is to code for numID which is the sixth and last field in selD.
%numID is the last 6 digits according to the timestamp of the excel sheet
    % Extract the last six numeric characters from the file name
    numericChars = [];
    count = 0;
    for numcounter = length(fileName):-1:1 %codes starts at the end of filename and then works it's way forward
        if isnumeric(fileName(numcounter)) %code now checks if the current indexed character from the filename is a numeric value
                                           %returns true if it is, false if not
            numericChars = [fileName(numcounter), numericChars]; %if true then the loop continues and the index number is put into numericChars
            count = count + 1; %then counter +1 to keep track how many numbers have been extracted
        end
        
        if count > 6 %stops extracting numbers from the filename once 6 numeric values have been extracted.
            break; %break will cause the loop to stop once there are 6 numeric values
        end
    end

    % Assign numID data taken from the numericChars variable to the 'numID' field of selD
    selD{ptN}.numID = numericChars;


%initialise the neccesary variables to keep track of raterID
raterID = cell(size(raterNames));
uniqueRaters = {};  
currentID = 0;

% Convert 'raterNames' to a cell array because the previous lines of code
% make it into a table. some codes don't work when trying to compare between tables and cells. so raterNames is made into a cell.
raterNames = table2cell(raterNames);

% Iterate over each rater name. this gets the rater names from the 'rater_name' column
for raterNameCount = 1:numel(raterNames) %this goes through the list of rater names, and iterates
    rater = raterNames{raterNameCount,1};   
    % Check if the rater has already been assigned an ID
    if isempty(uniqueRaters) || ~ismember(rater, uniqueRaters) %isempty would return a value 1 if it is empty, and 0 if not empty.
        %ismember would check if that particular rater(in the first element), is part of 'uniqueRaters'.
        %returns 1 if yes, returns 0 if not.                                                                             

        % Assign a new ID if the rater is new
        currentID = currentID + 1;
        uniqueRaters{end+1,1} = rater; %'end' in Matlab indexes the last element in the array 'uniqueRaters'. So we would be adding any new
        %raters to the end of the list of uniqueRaters without actually specifying the exact row/col or knowing the size of the array.
    end  

    % Assign the rater ID to the rater
    raterID{i} = currentID;
                                                      
end                                                  

%This section codes for the second element in allCodes.To assign 1(negative stimuli) or 2(positive stimuli) in the Hub.
% And to initialize a counter for each rater name for conCode. Specifically to
% keep track of the third digit where I have to look for repeats.
raterCounter = containers.Map();

 % Initialize variables for third element in allCodes(ratee names).
    ACrateeNames = cell(20, 1);
    subjectNumbers = cell(20, 1);

%Prepare the values for to calculate the binScore required for posRep
VASmin = 1;
VASmax = 100;
resolutionNumber = 6;

% Initialize ACRaters as an empty cell array before the loop. To be used later
ACRaters = {};

for blockno = 1:8 % Iterate over the blocks. 
    startRow = (blockno - 1) * 20 + 2; %block starts at 1 according to counter but -1 to get a 0 based index.
                                       %multiplication by 20 gives the number of rows to skip to reach the start of the current block (since each block has 20 rows/trials).
                                       %shifts the starting row index by 2 because the trial data starts from
                                       %the 2nd row in the raw data.
    
    endRow = startRow + 19; %endRow is calculated by adding 19(since each block has 20 trials, and this accounts for the starting row).

    % Extract the relevant rows for the current block
    blockData = dataTable(startRow:endRow, :); %the aim of this code is to go through 20 rows in the excel sheet 8 times(for 8 blocks)
    
    allCodesraterNames = dataTable(startRow:endRow, 'rater_name').Variables; %goes through the first row for each block to find the rater name.
     ACRaters = [ACRaters; allCodesraterNames];  % Concatenate new rater names to the ACRaters cell array in each loop.
    % So each new rater name processed is just added onto ACRaters. Should
    % result in a 1x8 cell array.

    selD{ptN}.Inp{blockno}.allCodes{2} = ACRaters; %puts rater names for each block into the second element of allCodes for each ptN.

  %This section codes for the ratee_name in selD 'Inp'
   ratee_type = dataTable(startRow:endRow, 'ratee_type');
   avatarFile = dataTable.avatar_file{startRow:endRow};
   rateeName = dataTable.ratee_name{startRow:endRow};
 % Process the 'ratee_type' and store the corresponding 'ratee_names'
    if strcmp(ratee_type, 'you') %for 'you' conditions, take the ratee name from the 'avatar_file' column
        selD{ptN}.Inp{block}.ratee_name = avatarFile;
    elseif strcmp(ratee_type, 'other') %for 'other' conditions, take the ratee name from the 'ratee_name' column
        selD{ptN}.Inp{block}.ratee_name = rateeName;
    else 
     warning('error in extracting ratee name, please check excel files or the code.');
    end
 
    % Check each row under the 'positive_correct' column and assign values to 'Hub'
    hub = cell(1, 20); %(1,20) because the Hub is 1x20 according to the template. 20 trials
    for trialcount = 1:20
        if blockData.positive_correct(trialcount) == 0
            hub{trialcount} = 1;
        elseif blockData.positive_correct(trialcount) == 1
            hub{trialcount} = 2;
        end
    end
    % Store the 'Hub' in the 'selD' structure for the current block
    selD{ptN}.hub{blockno} = hub; 

%this section codes for ratee_type, a field in Inp in selD.
rateeTypedata = dataTable(startRow:endRow, 'ratee_type'); %each block of 20 trials is either self or other
 if strcmp(rateeTypedata, 'you')  
    selD{ptN}.Inp{block}.ratee_type = 'you'; 
 elseif strcmp(rateeTypedata, 'other') 
    selD{ptN}.Inp{block}.ratee_type = 'other'; 
 else  
    warning('ratee type unknown - please investigate'); %This line generates a warning message to draw attention to the fact that the ratee name is unknown and requires investigation.                                                 

end


%Now this section codes for the third element in allCodes. Which contains all the
%ratee names according to if it was a SELF or OTHER condition.
 ACrateeType = dataTable(startRow:endRow, 'ratee_type').Variables;
        rateeNamesBlock = dataTable(startRow:endRow, 'ratee_name').Variables;
        subjectNumbersBlock = dataTable(startRow:endRow, 'subject_nr').Variables;
        
        % Extract values based on ratee_type
       if strcmp(ACrateeType,'other')
          ACrateeNames = rateeNamesBlock;
        %The line above assigns values from rateeNamesBlock(which is from 'ratee_name') to ACrateeNames when string values under rateeType is equal to 'other'.
       
       elseif strcmp(ACrateeType, 'you')
          ACrateeNames = subjectNumbersBlock;
        %The line above assigns values from subjectNumbersBlock(which is from 'subject_nr') to ACrateeNames when string values under rateeType is equal to 'you'.
       
       else 
           ACrateeerror = 'ratee name not found';
           disp(ACrateeerror);
      
       end
 % Store the extracted ratee values in the selD structure. This is for the
 % third element in allCodes.
    selD{ptN}.Inp{blockno}.allCodes{3} = ACrateeNames;


 %this section is for the 4th element in allCodes in selD. Which is the block type in chronological order.
 %additionally it codes for the 6th element in allCodes in selD. Because
 %the 6th element contains a 2x8 array. where the second row is a 1x8 list of
 %all the block types, and 'you' in excel file would result in '1' and 'other' would result in '2'.
 ACblockType = dataTable(startRow:endRow, 'ratee_type').Variables;
 ACblockTypeList = cell(1,8);
 SecRowforsixthAC = cell(1,8);
  if strcmp(ACblockType, 'other')
     ACblockTypeList{blockno} = 'other';
     SecRowforsixthAC(end + 1) = 2; %for each loop identify the block type and assign either 1 or 2 to the end of the array.
  elseif strcmp(ACblockType, 'you')
      ACblockTypeList{blockno} = 'you';
     SecRowforsixthAC(end + 1) = 1;
  end %this is the end for the loop finding the block type for allCodes.
selD{ptN}.Inp{blockno}.allCodes{4} = ACblockTypeList; %to put the list of block types in chronological order into allcodes{4}
%SecRowforsixthAC is only to be used later on when coding for the sixth element in AC.

%this section is for the 5th element in allCodes in selD. This is to store the generative percentages 0.2,0.5 and 0.8 which 
%is constant for all blocks and participants.
ACgenerativepercentages = [0.2000, 0.5000, 0.8000];
selD{ptN}.Inp{blockno}.allCodes{5} = ACgenerativepercentages;

%this is for the first row for the 6th element in allCodes.
%It identifies the names in the variable ACRaters and assisgns a unique number to each name.
%If a name is repeated, the number it was previously given would be used again.
%Only firstly encountered names would be given a new number.

% Create a lookup table
MapforRaterNames = containers.Map();
% Initialize the assigned numbers for each rater
assignedRaterNumbers = zeros(1, length(ACRaters));
% Assign numbers to names
currentNumber = 1;
for namecounter = 1:length(ACRaters) % 'name counter' would be the loop counter to go through the list of rater names.
    name = ACRaters{namecounter}; %'name' variable pulls out the Rater names individually to check if it has a unique no., if not code assigns a no.
     % Check if the name is already in the lookup table
    if isKey(MapforRaterNames, name)
        assignedRaterNumbers(namecounter) = MapforRaterNames(name);
    else
        % Assign a new number and update the lookup table
        if currentNumber <= 6
            MapforRaterNames(name) = currentNumber;
            assignedRaterNumbers(namecounter) = currentNumber;
            currentNumber = currentNumber + 1;
        else
            assignedRaterNumbers(namecounter) = NaN; % Set NaN for names beyond the limit
        end
    end
end

%this is to concatenate the first and second row for the 6th element in allCodes.
%NOTE that the first and second row come from two seperate parts of the codes and they are two different variables.
%first row is 'assignedRaterNumbers' and the second row is 'SecRowforsixthAC'.
concatenatedMatrix = vertcat(assignedRaterNumbers, SecRowforsixthAC);
%now for each participant and block assign the concatenated matrix to it's specific spot in selD.
selD{ptN}.Inp{blockno}.allCodes{6} = concatenatedMatrix;


%This section codes for posRep, which is the positivity rating of each participant. 
%The posRep represents how likely the ratee would perceive that the rater would choose a positive word to describe the ratee.
%This is represented by the second element 'X' in the 2x2 array. Other than 'X' all other elements are identical for all elements and blocks.

%This creates a set of code that calculates the binScore.
% Iterate through each row of the dataTable
for rowCounter = 1:size(dataTable, 1)
    % Get the 'pos-word' and 'left-word' values for the current row
    pos_word = dataTable{rowCounter, 'pos-word'}{1}; %{1} to make sure only the string characters are extracted
    left_word = dataTable{rowCounter, 'left-word'}{1};
    
    % Get the 'response' value for the current row
    response = dataTable{rowCounter, 'response'};
    
    % Check if 'pos_word' is equal to 'left_word' and calculate VAS accordingly
    if strcmp(pos_word, left_word)
        VAS = VASmax - response;
    else
        % Get the 'right-word' value for the current row
        right_word = dataTable{rowCounter, 'right-word'}{1};
        
        % Check if the 'pos-word' is equal to the 'right-word'
        if strcmp(pos_word, right_word)
            VAS = response - VASmin;
        else
            % If neither condition is fulfilled, assign NaN to VAS
            VAS = NaN;
        end
    end

%proceed to use VAS to calculate binFrac
binFrac = VAS ./ (VASmax - VASmin);

%now to calculate the binScore. resolution number is alrdy set to 6 previously. if the resolution number changes edit from before the loop.
binScore = resolutionNumber*binFrac;

if binScore == 0
    binScore = 0.0001; %to change the range of binScore to be 0.0001 to 6 instead of 0 to 6.
end

posRepdata = [ [7 4]' [binScore 2]' ]; % 7,4 and 2 are fixed values for all participants and blocks. Only fill in binScore

%Stores the 2x2 array for posRep for the respective block and participant.
selD{ptN}.Inp{blockno}.posRep = posRepdata;

%this section codes for Resp. it is the output ver of posResp, the code to calc binScore is just reused because binScore for both is the same.

Respdata = [1 ; binScore];
selD{ptN}.Resp{blockno} = Respdata; 

end %this end here is for the row counter to calculate binScore.
end %this end here is the end for the block counter loop. Any variable that needs to go through the 8 blocks
%should be between this particular 'for' and 'end'. 


%This section codes for conCode. First digit in conCode is the ratee type: 1 represents self, 2 repsents other
%second digit is block type: 1,2,3 for neg,neutral,pos respectively
%third digit is repetition: 0 for no repeats, 1 is first repeat, 2 is 2nd repeat

 % Get the ratee type for the block under the 'ratee_type' column
    rateeType = blockData.ratee_type{1};
    if strcmp(rateeType, 'you')
        firstDigit = '1';
    elseif strcmp(rateeType, 'other')
        firstDigit = '2'; %just reads from the excel column to identify ratee type.
    else
        rateetypeerror = 'value in ratee_type column does not have any of the predicted values';
        disp(rateetypeerror);
        firstDigit = 'NaN'; % to protect the code from errors, so if it isn't a number we
        %expect which would be '1' or '2' then the digit would be NaN so we know there is an error.
    end

  % Get the block type for the block. Similar procedure and logic
    blockType = blockData.liking{1};
    if strcmp(blockType, 'dislike')
        secondDigit = '1';
    elseif strcmp(blockType, 'neutral')
        secondDigit = '2';
    elseif strcmp(blockType, 'like')
        secondDigit = '3';
    else
        blocktypeerror = 'value in ratee_type column does not have any of the predicted values';
        disp(blocktypeerror);
        secondDigit = 'NaN'; %if the excel column doesn't have any of the predicted values then NaN would be seen.
    end

    %have to somehow identify if a rater_name would appear just
    %once(0)// OR // appear twice and it is the first time(1) or this is the second time(2)

    % Extract the rater name for the current block
    raterName = dataTable.rater_name{startRow}; %the startRow variable goes through 20 rows at a time. Refer to line 108 to 116.
    %I decided to insert a line of code to put the raterName extracted into the second element of allCodes as well.
    %this is to get a list of rater names in chronological order.
    %So while coding for the data for the other fields in Input, I've decided to also put in a few extra lines of codes in between
    %to take the data to be put into allcodes.
    selD{ptN}.Inp{blockno}.allCodes{2} = raterName;


    % Check if the rater name has been encountered before
    if isKey(raterCounter, raterName) %is the raterCounter in raterName, 1 is true 0 if false
        repeatCount = raterCounter(raterName);
        thirdDigit = num2str(repeatCount + 1);
        raterCounter(raterName) = repeatCount + 1; 
    else
        % Check if the rater name will be encountered again
        remainingData = dataTable(startRow:end, :);
        remainingRaterNames = remainingData.rater_name;
        if sum(strcmp(remainingRaterNames, raterName)) > 1
            thirdDigit = '1'; 
        else
            thirdDigit = '0';
        end
        raterCounter(raterName) = 1; %not too sure about the segment coding for the third digit in conCode
    end
 
    % Assign the combined three-digit code to 'conCode' for the current block
    conCode = strcat(firstDigit, secondDigit, thirdDigit);
     selD{ptN}.Inp{blockno}.conCode = conCode;
     selD{ptN}.Inp{blockno}.allCodes = conCode; %not sure if you'd like the entire code to be redone to avoid mistakes
     %but here since allCodes is a repeat of the data form other fields, I the source of the data from the same set of codes.

    end
end %this is the end for the loop going through each file in a folder 

