% script learningCurves2.m

% Put outputs of learnReport01 etc. to put in array
% and calculate some learning curves. 

% please run this from within SocEvalModels_(not_git)_rough_work

% Example of 50 simulated participants has already been made, 
% so read it from disk, or run another sim if you'd like:
doSim = 1;     % Change this to 1 to re-do the simulated data.

if doSim    % i.e. if re-do the siimulated data ...
            % This block demonstrates how to do it, based on what we
            % thought about today.
    pRet=0.2;   % lower is negatively disposed, higher to positively disposed.
    % Refernece parameters:
    selfpRef = [0.72,    0.7,     6,   1/5,    5.5,   0,   1,  0];
           %attr0,dInitEv,aInitEv,uPrec,wAttr,w0,lrnR,desBias
           %very close attr to pRet reduces learning, almost no learning
           %happens

    partNo = 50;
    w0 = normrnd(-0.32, 0.84, 1, partNo);   % -0.32 and 
         % 0.84 are from are from another 
         % experiment I ran - may not work here :) 

    % tell matlab we'll use some cell arrays ('declare' them):
    MDPs = {};          Inp  = {};           Resp = {}; 

    for part = 1:partNo

          selfp = selfpRef;
          selfp(6)= w0(part);

          [MDPs{part},modStruc,Inp{part},Resp{part}] = ...
                              learnReport01(selfp,pRet,0);
          disp(['Simulated ' num2str(part) ' out of ' num2str(partNo)]);

    end
else      % i.e. don't re-Simulate, read from disk:
    load('.\example50pts\learningcurves09attr0.mat'); % . represents where we r, the folder we r in, look for that file name
    partNo = length(MDPs);
end
    
% Now use the function provided, which re-formats MDP 
% outputs into arrays:
reports = nan(partNo,30);  % array to hold the simulated reports. just contains a bunch of NANs with a specificied no. of rows n cols.

for part = 1:partNo
    % In active inference, actions are often denoted by the symbol u:
    [u,label] = mdp2arr(MDPs{part}.MDPPos,'u'); %took all actions from MDPs

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

    reports(part,:) = u; %for cum graphs divide by the total 6,12,36 etc.
end

mAtTr = (mean(reports));     % This will create the means of each column of 'reports', i.e. a mean for each trial. mean attributes
sdAtTr = sqrt(var(reports)); % Similarly, standard deviation at each trial. 
mAtTr = mAtTr / modStruc.allP.resNRepo;    % lets make them go to max. of 1 rather ... *all parameters, resolution number(if 1-6 then it's 6)
sdAtTr = sdAtTr / modStruc.allP.resNRepo;  %      ... than the size of the Likert.

twentytrialsmean = mean(reports(:,1:20));
thirtytrialsmean = mean(reports(:,1:30));
twentytotalmean = mean(twentytrialsmean);
thirtytotalmean = mean(thirtytrialsmean);

% Unfortunately these values go between a min and a max, so they are not suitable for 
% creating ranges / error bars with Normal distribution statistics.
% We could approximate the histogram of the responses at each point with a beta distribution.
% (this is not guaranteed to always work, but hopefully most of the time it will be OK!)
% Then, we could find the 5th and 95th centiles of this to make a confidence interval.
% First, make some space:
lowerBound = nan * mAtTr;          upperBound = nan * mAtTr;
maxTrN = length(mAtTr);            % reminder of the max. number of trials.

for tr = 1:maxTrN
    [A, B] = betaMS2ab(mAtTr(tr),sdAtTr(tr)); %getting the mAttr and sdAttr of each trial into A rows n B cols(after averaging among all participants)
    lowerBound(tr) = betainv(0.05,A,B);   % 5th centile of the beta distro, see documentation of betainv, *why are we inversing the beta function?, clarity on betaMS2ab
    upperBound(tr) = betainv(0.95,A,B);  %collecting each trial's lower n upper bound mean resp 
end
 
%cum distirbution function is the sum of the whole sample up to that point
%there's going to be a learning curve for the majority n minority
%it's to show you what the rating would be for each percentile
% beta distibution usually has two ends, giving u a dsitribution over the
% we know the bounds
%moment matching: what r the heads n tails that would correspond to an
%appropriate distribution. main reason here is that it's bounded 1-6, other
%distributions r not appropriate.

plot(1:maxTrN,[lowerBound; mAtTr; upperBound]);
hold on
ylabel("Negativity attribution"); %check for scale rating
xlabel("Trial No.");
title("Mean Attribution with upper and lower limits");
legend("Lower limits", "Mean", "Upper limits");

%This section is to collect all the different mAtTr needed to form graph for:
%self-ref=> like high FNE, like low FNE, neutral high FNE, neutral low FNE, dislike high FNE, dislike low FNE
%other-ref => like high FNE, like low FNE, neutral high FNE, neutral low FNE, dislike high FNE, dislike low FNE



% Below is the analysis for the 20- and 30-trial means etc. :
doMeans = 1;    %will only do the rest of the codes if = 1 
if doMeans

    % Now we have our data, we can take the means of the first 10, middle 10 and
    % last 10 trials, as a measure of the beliefs of these simulated participants
    % 
    thirdsM = nan(part,3); %for every participant which would be in the rows, there would be 3 cols for mean resp from 3 parts of the exp
    for part = 1:partNo
        thirdsM(part,1) = mean(reports(part,1:10)); %mean for all participants 3 parts here. first with mean of first 10 from part 1
        thirdsM(part,2) = mean(reports(part,11:20)); %then mean of mid 10 part 1
        thirdsM(part,3) = mean(reports(part,21:30)); %then mean of last 10 part 1. then move onto part 2 same thing.
    end
 
   
    % An approximation of the 'true' value is the grand mean for many-trials
    % version:
    gM3 = mean(thirdsM(:,3)); 

    % Now let's estimate the squared-errors for a 20 vs. 30 trial experiment, 
    % whose comparison will tell us how much better the one is to the other,
    % if at all:
    sqEr20 = (thirdsM(:,2) - gM3) .^ 2 ;  % the dot before ^ means 'for every element'
    sqEr30 = (thirdsM(:,3) - gM3) .^ 2 ; 

    [h,p,ci,stats] = ttest(sqEr20,sqEr30);

    % Visualise:
    boxplot([sqEr20 sqEr30],'whisker',6,'labels',{'sqEr20','sqEr30'})
    
    disp(['sum sqEr20 errors: ' num2str(sum(sqEr20))]);
    disp(['sum sqEr30 errors: ' num2str(sum(sqEr30))]); 
hold on
ylim([0,4])
hold on 
ylabel('RMSE of negativity responses')
    % The square root of the sum of the squared errors ('RMSE') is 
    % a good measure of the total error. 
    
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  end of file ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


