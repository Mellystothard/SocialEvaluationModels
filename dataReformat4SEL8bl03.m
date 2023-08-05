function [selD, skippedFiles] = dataReformat4SEL8bl03(inpDir, outFName, outDir)
% [selD, skippedFiles] = dataReformatSEL2xiii(inpDir, outFName, outDir)
%        Reformat Carlisi-Moutoussis labs Social Evaluation Task data
%        for use with active inference modelling, 
%        Likelihood function sel8bl03 spm_mdp_L_xiii 
%        (e.g. as used within fitting fn. SEL2_Grid04a_xiii )

%% Lines useful for checking code %%
% Open the csv e.g. with Libreoffice, then in matlab ...
% To help check manually if correct bin:
% binR = [0 100*( (1:6)/6 )]; binL = fliplr(binR); 
% To check block responses:
% ptN=2; x = []; for i=1:20; x(i,:) = [i+2 selD{ptN}.Resp{8}.posRep{i}' selD{ptN}.Inp{8}.posRep{i}(1,2) ]; end; x
% To help check condition: 
% ptN = 1; blN=8; disp(selD{ptN}.Inp{blN}.allCodes{2}); disp(selD{ptN}.Inp{blN}.allCodes{1}); disp(['row:' num2str((blN-1)*20+3)]); 

%% Orient to which computer and directories we will use ~~~~~~~~~~~~~~~~~~~~

% Use key directory listing to find what which computer we are using
if ~isempty(dir('C:\Users\mmpsy\Nextcloud\MM\googledirs\'))
    machine = 'MMlaptop';  fs = '\';
elseif ~isempty(dir('C:\Users\User\Desktop\UCL\Dissertation code files\'))
    machine = 'MSlaptop';  fs = '\';
elseif ~isempty(dir('/home/michael/googledirs/MM/'))
    machine = 'MMdesktop'; fs = '/';
else
    machine = 'unknown';
    fs = '/' ; % file separator which should work on most operating systems.
end

% Now establish the path where we'll find the csv data files:
try
    folderPath = inpDir;
catch
    if strcmp(machine,'MMdesktop')
        folderPath = '/home/michael/googledirs/MM/SocEvalModels_(not_git)_rough_work/Carlisi_team_work/SELT_RawData/roughWork/';
    elseif strcmp(machine,'MMlaptop')
        folderPath = 'C:\Users\mmpsy\Nextcloud\MM\googledirs\SocEvalModels_(not_git)_rough_work\Carlisi_team_work\SELT_RawData\roughWork\';
    elseif strcmp(machine,'MSlaptop')
        folderPath = 'C:\Users\User\Desktop\UCL\Dissertation code files\SocEvalModels_(not_git)_rough_work-20230307T220354Z-001\SocEvalModels_(not_git)_rough_work\Carlisi_team_work-20230512T122649Z-001\Carlisi_team_work\NormanLau30Apr23\Data\Data\raw data\';
    else
        error([machine ' machine not provied for']);
    end
end

% establish output directory and file name . . . . . . . . . . . . . . . . . . 
cwd = cd;   % make note of where we are.
try
    outFName;
catch
    outFName = 'data4sel8bl03.mat';  % default name for output file.
end
try
    outDir;
catch
    outDir = folderPath;
    disp(' '); warning(['No output directory provided, we''ll try to write results into ' folderPath]); disp(' ');
end
 
%% Read in the crucial list of csv files which should have our data  ~~~~~~~~~~~~~~~
%NOTE: if you are preallocating a size for an array, create array for
%strings not an numerical array for data like names etc.
%so this means don't use zeros or ones to preallocate.
%functions like zeros/ones creates a numerical array automatically.

fileList = dir([fullfile(folderPath) fs '*.csv']); %An attempt to get a list of all 
           % the csv files in the folder

%%  Constants needed to calculate the binScore required for posRep and other measures
%   Place anything non-trivial which is constant in this function here if poss, esp.
%   things that may change in future versions of data.
VASmin = 0;
VASmax = 100;
resolutionNumber = 6;
totRatingN = 8;       % Number of the main data blocks, not counting practice and final single-trial 'blocks'
                      % in the July '23 version of the data.
rowsPerBlock = 20;    trNPerBlock = rowsPerBlock;
rating2ice  = 2;      % This many raters will rate twice. 
% specify the fields for each selD{ptN} etc. so they are constructed in nice order:
selDPtFields =  {'trPar', 'Inp', 'Resp', 'fitM', 'MDP8', 'numID', 'charID','fileName'};
InpFields = {'hub','posRep','condCode','rater_name','ratee_name','ratee_type','selfp','raterID','block','allCodes'};

%%  Main processing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create an empty structure to store the extracted column data
%this is to initialise the variables before the loop begins
skippedFiles = {};
selD = {};
ptN = 0;               % counts valid participant files.

for fileN = 1:numel(fileList) %iterate though each file in the folder. New part starts here.

    fileName = fileList(fileN).name; %This line retrieves the name of the current file being processed in the loop and assigns it to the variable fileName.
    filePath = fullfile(folderPath, fileName); % To construct the full file path, 
                                               % so each file can be read indivdually
                                               % in the order of the fileList
    try                                          
       dataTable = readtable(filePath);  % Read the Excel file as a table. Each participant data is referred to as dataTable
       datSize = size(dataTable);
    catch 
       datSize = 0;
    end

    if ( length(fileName) > 11 && ...
         strcmp(fileName(1:11), 'Evaluation_') && ...
         datSize(1) == (totRatingN*rowsPerBlock+2)) %This line checks if the length of the file name is greater than 11 characters and if the first 11 characters of the file name are equal to the string 'Evaluation_'.
       
        %It combines two conditions using the logical AND (&&) operator.
        %This condition is used to identify files that meet the criteria of being evaluation files.
    
                                           
   
        % Now we can augment the participant number 
        % with more confidence: only once we have successfully read in the data.
        ptN = ptN + 1; %This line increments the value of ptN by 1.
        selD{ptN} = cell2struct(cell(length(selDPtFields),1), selDPtFields); 

        %It is used to track the participant number and ensure each participant's data is stored separately.
        raterNames = dataTable(:,'rater_name');%extract data from table read. if this doesn't work try 'raterNames = dataTable.rater_name';

        %% Code for numID which is the sixth and last field in selD.
        %numID is digits of the timestamp of the excel sheet
        % Extract the last six numeric characters from the file name
        numericChars = [];
        count = 0;
        for numcounter = length(fileName):-1:1 %codes starts at the end of filename and then works it's way forward
            if ~isempty(str2num(fileName(numcounter))) && ...
                ~strcmp(fileName(numcounter), 'i')
                %code now checks if the current indexed character from the filename is a numeric value
                                           %returns true if it is, false if not
                numericChars = [fileName(numcounter), numericChars]; %if true then the loop continues and 
                                                              % the index number is put into numericChars
                count = count + 1; %then counter +1 to keep track how many numbers have been extracted
            end
            if length(numericChars) >= length('20230710152929463')   % using an example timestamp string, just for the clarity
                break;
            end
        end

        % Assign ID data incl. as taken from the numericChars variable to the 'numID' field of selD
        selD{ptN}.numID  = str2num(numericChars);          % Numerical ID
        selD{ptN}.charID = dataTable{2,'subject_nr'}{1};   % Isabel / Jess very complex string ID
        selD{ptN}.fileName = fileName;


        %% Check where data blocks of rowsPerBlock (usu. = 20) each are

        % Convert 'raterNames' to a cell array because the previous lines of code
        % make it into a table. some codes don't work when trying to compare between tables and cells;
        % so raterNames is made into a cell.
        raterNames = table2cell(raterNames);
        % A bit of future-proofing re. data length.
        % In Jul23 data the first data line of the csv
        % and also the last line do not belong to the learning/inference blocks
        % of data and will not be fitted (the last one is worth doing so in future!)
        % So, if the size of the arrays don't match, emit warning and leave, or 
        % otherwise data will be misaligned. 
        % Check total number of rows: . . . . . . . . . . . . . . . . . . . . . . . 
        if length(raterNames) > totRatingN*rowsPerBlock +2 
            disp(['Should have at most totRatingN*rowsPerBlock + 1 practice + 1 final = ' num2str(totRatingN*rowsPerBlock +2) ' rows.']);
            error(['Not ready for dataset with ' num2str(length(raterNames)) ' rows.']);
        end
        % Check practice trial(s): . . . . . . . . . . . . . . . . . . . . . . . 
        practiceRows = 0;
        for ro = 1:numel(raterNames)
            if strcmp(dataTable{ro,'liking'}{1},'practice_neutral')
               practiceRows = practiceRows + 1;
            end
            if practiceRows > 1
               disp(['At csv row= ' num2str(ro+1)])
               error('Not ready for multiple ''practice_neutral'' trials');
            end
        end
        % Finally for this section, record row numbers of the first row of each block:
        blk1stRow = practiceRows + 1 + (0:(totRatingN-1))*rowsPerBlock;
        % Note: according to block counter but starts from 0+offset, ...
        % ... as the first block starts from row 3 or so, not from row 23 or so.
        %multiplication by 20 gives the number of rows to skip to reach the start of the current block (since each block has 20 rows/trials).
        %shifts the starting row index by firstDatRow because the trial data starts from
        %the firstDatRow-th row in the csv.

        %% allCodes, subfields 2-6 . ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % field allCodes will be the same for all the blocks - so fill in fields 2-6 here.
        % Subfield 1 which is the most crucial, coding the experimental condition for
        % each block, will be done later.
        % REM subfields 2: Rater names;  3: Ratee names; 4: 'other' or 'you' condition
        %               5: Generative proportions of pos. ratings for neg, neu, pos raters
        %               6: Array w. rows like 2.plus 3., but using simple numerical IDs for raters and ratees. 
        AllCodes = {};
        raterID = 1;
        AllCodes{6} = nan(2,totRatingN);
        % Subfields 2 and 5 
        for blk = 1:totRatingN
            % disp([num2str([ptN blk]) ' ' fileName]);  % debug line
            AllCodes{2}{blk} = dataTable{blk1stRow(blk),'rater_name'}{1};
            AllCodes{4}{blk} = dataTable{blk1stRow(blk),'ratee_type'}{1};
            AllCodes{5} = [0.20  0.50  0.80]; 

            % Alternative way of doing first row of 6. - replaced with Melanie's 
            % code below. 
%             if blk == 1
%                AllCodes{6}(1,blk) = 1;
%             else
%                repeated = 0;
%                for prev = 1:(blk-1)
%                    if strcmp(AllCodes{2}{prev}, AllCodes{2}{blk}); repeated=prev; end
%                end
%                if repeated > 0
%                    AllCodes{6}(1,blk) = AllCodes{6}(1,repeated);
%                else
%                    raterID = raterID + 1;
%                    AllCodes{6}(1,blk) = raterID;
%                end
%             end
        end
        % Create a lookup table for simple IDs of raters and assign 1st row of 6. :
        ACRaters = AllCodes{2};     % Can initialise it directly :) without making space first.
        MapforRaterNames = containers.Map();
        % Initialize the assigned numbers for each rater (will ---> AllCodes{6}(1,:) )
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
                if currentNumber <= totRatingN - rating2ice
                    MapforRaterNames(name) = currentNumber;
                    assignedRaterNumbers(namecounter) = currentNumber;
                    currentNumber = currentNumber + 1;
                else
                    error(['Should have ' num2str(totRatingN-rating2ice) ' raters only in learning blocks']);
                    % assignedRaterNumbers(namecounter) = NaN; % Set NaN for names beyond the limit
                end
            end
        end
        AllCodes{6}(1,:) = assignedRaterNumbers;
        % Subfields 3 and second row of 6:
        for blk=1:totRatingN
            if strcmp(AllCodes{4}{blk},'you')
                AllCodes{3}{blk} = dataTable{2,'participant_avatar_file'}{1};
                AllCodes{6}(2,blk) = 1;
            else
                AllCodes{3}{blk} = dataTable{2,'other_ratee_file'}{1};
                AllCodes{6}(2,blk) = 2;
            end
        end


        % To assign 1(negative stimuli) or 2(positive stimuli) in the Hub.
        % And to initialize a counter for each rater name for conCode. Specifically to
        % keep track of the third digit where I have to look for repeats.
        raterCounter = containers.Map();


        for blockN = 1:totRatingN % Iterate over the blocks.
            % Initiate so subfields in order etc. : 
            selD{ptN}.Inp{blockN} = cell2struct(cell(length(InpFields),1), InpFields); 

            % All blocks have the same allCodes in field Inp:
            selD{ptN}.Inp{blockN}.allCodes = AllCodes;

            % Extract the relevant rows for the current block
            startRow = blk1stRow(blockN); 
            endRow    = startRow + rowsPerBlock -1; %endRow is calculated by adding e.g. 
               % 19 (if each block has 20 trials, and this accounts for the starting row).
            blockData = dataTable(startRow:endRow, :); %the aim of this code is to go through 20 rows in the excel sheet 8 times(for 8 blocks)
    
            % This section codes for the ratee_name in selD 'Inp'
            % Make use of redundant storage employed :)
            selD{ptN}.Inp{blockN}.ratee_name = selD{ptN}.Inp{blockN}.allCodes{3}{blockN}; 

            % This section codes for ratee_type, a field in Inp in selD.
            selD{ptN}.Inp{blockN}.ratee_type = selD{ptN}.Inp{blockN}.allCodes{4}{blockN}; 

            %% Assign values to field 'hub', using each row under the 'positive_correct' column
            Hub = cell(1, trNPerBlock); %(1,trNPerBlock) because the Hub is 1x20 according to the template. 20 trials
            for trialCount = 1:trNPerBlock
                if blockData.positive_correct(trialCount) == 0
                    Hub{trialCount} = 1;
                elseif blockData.positive_correct(trialCount) == 1
                    Hub{trialCount} = 2;
                end
            end
            % Store the 'Hub' in the 'selD' structure for the current block
            selD{ptN}.Inp{blockN}.hub = Hub; 


            %This section codes for posRep, which is the positivity rating of each participant. 
            %The posRep represents how likely the ratee would perceive that the rater would choose a positive word to describe the ratee.
            %This is represented by the second element 'X' in the 2x2 array. Other than 'X' all other elements are identical for all elements and blocks.

            % This creates a set of code that calculates the binScore.
            % Iterate through each row of the dataTable
            for trialCount = 1:trNPerBlock
                % Get the 'pos-word' and 'left-word' values for the current row
                pos_word  = blockData{trialCount, 'pos_word' }{1}; %{1} to make sure only the string characters are extracted
                left_word = blockData{trialCount, 'left_word'}{1};
                
                % Get the 'response' value for the current row
                response = blockData{trialCount, 'response'};
    
                % Check if 'pos_word' is equal to 'left_word' and calculate VAS accordingly
                if strcmp(pos_word, left_word)
                    % If positive on the left, then the most positive belief
                    % corresponds to response = minimum, at the left end:
                    VAS = VASmax - response;
                else
                    % Get the 'right-word' value for the current row
                    right_word = blockData{trialCount, 'right_word'}{1};
                    
                    % Check if the 'pos-word' is equal to the 'right-word'
                    if strcmp(pos_word, right_word)
                        VAS = response - VASmin;
                    else
                        % If neither condition is fulfilled, assign NaN to VAS
                        VAS = NaN;
                        warning(['Check pos and neg vs. right vs. left words in ' num2str(blockN) ', trial ' num2str(trialCount)]);
                    end
                end

                %proceed to use VAS to calculate binFrac
                binFrac = VAS ./ (VASmax - VASmin);

                %now to calculate the binScore. resolution number is alrdy set to 6 previously. 
                % if the resolution number changes edit from before the loop.
                binScore = resolutionNumber*binFrac;    % fractional number from 1 to resolutionNumber
                % rounding to produce integer response action for modelling:
                likertyChoice = max(ceil(binScore),1);  % Bins go from 1 to resolutionNumber, so if < 1, set to 1.
                
                % This section codes for Resp. it is the output ver of posResp, the code to calc binScore is just reused because binScore for both is the same.
                selD{ptN}.Resp{blockN}.posRep{trialCount} = [1 ; likertyChoice];

                % Also store action within a 2x2 array for posRep in Inp, 
                % which is about agent observing the choice that they made 
                % (may be necessary in Active Inference ...) for the respective block and participant:
                selD{ptN}.Inp{blockN}.posRep{trialCount} = [ [7 4]' [likertyChoice 2]' ]; % 7,4 and 2 are fixed values for all participants and blocks. Only fill in binScore


            end %this end here is for the row counter to calculate Likert-like action.

            %% This section forms the condition code for this block and stores it in AllCodes etc.
            %  first digit is 1=you or 2=other :
            firstDigit = num2str(AllCodes{6}(2,blockN));
            %  second digit is 1=neg, 2=neu, 3=pos :
            blockType = blockData.liking{1};
            if strcmp(blockType, 'dislike')
                secondDigit = '1';
            elseif strcmp(blockType, 'neutral')
                secondDigit = '2';
            elseif strcmp(blockType, 'like')
                secondDigit = '3';
            else
                blocktypeerror = 'value in ratee_type column does not have any of the predicted values';
                disp(''); warning(blocktypeerror); disp('');
                secondDigit = 'NaN'; %if the excel column doesn't have any of the predicted values then NaN would be seen.
            end
            %third digit is repetition: 0 for no repeats, 1 is first repeat, 2 is 2nd repeat
            thirdDigit = '0';   % default
            thisRater = AllCodes{6}(1,blockN);
            ratingBlocks =  find(AllCodes{6}(1,:)==thisRater);  % all the learning blocks with this rater
            if length(ratingBlocks) > 1  % if they rated only once, leave thirdDigit at '0', otherwise ...
                % ... find if the current block is the first or second within ratingBlocks:
                thirdDigit = num2str(find(ratingBlocks == blockN));
            end
            % Store it in 3 places!!
            AllCodes{1}(blockN) = str2double([firstDigit secondDigit thirdDigit]);  % master copy for this block
            selD{ptN}.Inp{blockN}.condCode = AllCodes{1}(blockN);                   % quick specific block reference
            if blockN == totRatingN  % when the master copy is completed, 
                                     % copy it into all the Inp data block subfields:
                for blN = 1:totRatingN
                    selD{ptN}.Inp{blN}.allCodes{1} = AllCodes{1};
                end
            end

            % fill in more quick reference and empty/invalid Inp subfields:
            selD{ptN}.Inp{blockN}.rater_name = AllCodes{2}{blockN};
            selD{ptN}.Inp{blockN}.raterID = AllCodes{6}(1,blockN);
            selD{ptN}.Inp{blockN}.block = blockN;
            selD{ptN}.Inp{blockN}.selfp = nan(1,7); % an invalid value for the parameters for this block.

        end % this end here is the end for the block counter loop, over blockN. 
            % Any variable that needs to go through the 8 blocks
            %should be between this particular 'for' and 'end'.

    else    % Emit warnings that fileName isn't suitable for data reformatting
        skippedFiles{end+1} = fileName;
        if datSize(1) ~= (totRatingN*rowsPerBlock+2)
           warning([fileName ' does not have ' num2str(totRatingN*rowsPerBlock+2) ' rows, hence skipped']);
        else
           warning([fileName ' does not appear to be a valid datafile, hence skipped']);
        end

    end % end check if this looked like a valid data file name.

end %this is the end for the loop going through each file in a folder 

%%  Save and exit to where we came from. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cd(outDir);
skippedFiles = skippedFiles';
save(outFName,'selD','skippedFiles');
disp([outFName ' written to ' outDir]);
cd(cwd);

return; % end of function dataReformat ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
