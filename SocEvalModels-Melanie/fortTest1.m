% script fortTest1.m
% Demo to put outputs of learnReport01 etc. to put in array
% so one can take the estimate error for 20-long and 30-long 
% blocks, ready for statistical comparison : 

% please run this from within SocEvalModels_(not_git)_rough_work

% An example of 50 simulated participants has already been made, 
% so read it from disk, or run another sim if you'd like:
doSim = 0;     % Change this to 1 to re-do the simulated data.

if doSim    % i.e. if re-do the siimulated data ...
            % This block demonstrates how to do it, based on what we
            % thought about today.
    pRet=0.2;   % say the rater is negatively disposed.
    % Refernece parameters:
    selfpRef= [0.7, 1,  2,  1/5,  6,  0, 1,  0]; 

    totRep = 50;
    w0 = normrnd(-0.32, 0.84, 1, totRep);   % -0.32 and 
         % 0.84 are from are from another 
         % experiment I ran - may not work here :) 
         %this creates normally distributed random samples
         %mean,SD,row,cols
         %this is a way to simulated many participants

    % tell matlab we'll use some cell arrays ('declare' them):
    MDPs = {};          Inp  = {};           Resp = {}; 

    for rep = 1:totRep

          selfp = selfpRef; %pref is the reference 
          selfp(6)= w0(rep); %we change the value of w0 to be a randomised value, altering the default

          [MDPs{rep},modStruc,Inp{rep},Resp{rep}] = ...
                              learnReport01(selfp,pRet,0); %this only has rows
          disp(['Simulated ' num2str(rep) ' out of ' num2str(totRep)]); %just shows on display what rep u r on out of the total reps

    end
else      % i.e. don't re-Simulate, read from disk:
    load('.\example50pts_01\example50pts.mat'); %example 50 participants in case we don't generate data ourselves
end
    
% Now use the function provided, which re-formats MDP 
% outputs into arrays:
reports = nan(totRep,30);  % array to hold the simulated reports.
%nan will tell u there is an error so we don't mistaken the filled zeros as
%an actual data

for rep = 1:totRep
    % In active inference, actions are often denoted by the symbol u:
    [u,label] = mdp2arr(MDPs{rep}.MDPPos,'u');

    % The simulated reported predictions of positive or negative 
    % likelihood are now in u. MDPs generically produce
    % multi-dimensional output, but here we are only interested
    % in the reported preditions, so we'll drop all the rest:

    u = u(2,1,:);   % second row of the only column
        % is the key repsonse. The ':' means 'all the pages' of 
        % this row,col,page array.

    u = squeeze(u)'; % squeeze out the first two
        % dimensions of the array, and turn it into a 1-row, 
        % rather than 1-column, vector.

    reports(rep,:) = u; %takes output of simulation to be put in the matrix, rep:col,trial:rows
end

% Now we have our data, we can take the means of the first 10, middle 10 and
% last 10 trials, as a measure of the beliefs of these simulated participants
% 
thirdsM = nan(rep,3);
for rep = 1:totRep
    thirdsM(rep,1) = mean(reports(rep,1:10));
    thirdsM(rep,2) = mean(reports(rep,11:20));
    thirdsM(rep,3) = mean(reports(rep,21:30));
end

% An approximation of the 'true' value is the grand mean for many-trials
% version:
gM3 = mean(thirdsM(:,3)); 

% Now let's estimate the squared-errors for a 20 vs. 30 trial experiment, 
% whose comparison will tell us how much better the one is to the other,
% if at all:
sqEr20 = (thirdsM(:,2) - gM3) .^ 2 ;  % the dot before ^ means 'for every element'
sqEr30 = (thirdsM(:,3) - gM3) .^ 2 ; 

% Visualise:
boxplot([sqEr20 sqEr30],'whisker',6,'labels',{'sqEr20','sqEr30'})
disp();
disp(['sum sqEr20 errors: ' num2str(sum(sqEr20))]);
disp(['sum sqEr30 errors: ' num2str(sum(sqEr30))]);

% The square root of the sum of the squared errors ('RMSE') is 
% a good measure of the total error. 
%
% OK, is sqEr30 statisticall significantly smaller than sqEr20 ? 


