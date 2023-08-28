% sel8bl02_demo is a demonstration generates participant responses based on a an
% example of blocks sequence, and calculates the log-likelihood etc. first on
% the generated data directly and then provides the same data to the likelihood
% function to check. 

% '***8' in this file mostly refers to the 8-block experiment
%  A parameter vector in native space:
%         1          2        3      4         5        6       7        8     9    10   11     12      
%      posiSelf  posiOther  dEvSelf dEvOther aEvSelf aEvOther alphaPrec genLR repLR wp0 wAttr  mem      
par8 =  [0.75,     0.5,       1,     1,       2,       2,        5,     0.1,  0.5,   0,  6,   0.9999 ]; 
% Same in transformed space:
pTr8 = nat2tr_SEL_i(par8,1);  % map to transformed space. Transforms all the params, not just for each block.
pLen = length(par8); 
% backup
par8bak = par8;

toPlot = 0;
load('noLearnSEL8bl.mat');  % load modStruc8, mdp8, inp8, resp8,pPosGen,par8hd,selfpHd
% Default priors, for general use and to test likelihood function:
%                     1       2        3      4         5        6       7        8     9    10   11      12      
% fields:         posiSelf posiOther dEvSelf dEvOther aEvSelf aEvOther alphaPrec genLR repLR wp0   wAttr  mem    
modStruc8.priPar=[[1.01,  1.01,     1.01,    1.01,  1.01,    1.01,     1.01,   1.01, 1.01, 10,    1.2,  1.01]; ...  % A
                    [1.01,  1.01,      2,       2,      2,       2,        2,    1.01, 1.01, 10,  5.8,  1.01]; ...  % B
                    [ 0,     0,        0,       0,      0,       0,        0,     0,   0,   -46,   0,    0   ]; ...  % lo
                    [ 1,     1,        100,    100,    100,     100,     100,     1,   1,    46   100,   1   ]];     % hi
%                                    <-  max             at 1                >            <SD ~10> <max at 4>

details = 1;    % produce detailed output, but don't plot
disp(['Input stimuli will be according to blocks (ratee-positivity-repetition) : ' num2str(inp8{1}.allCodes{1})]);
[fitM, Par8, MDP8] = sel8bl02( pTr8, inp8, resp8, modStruc8, details);
disp(['inp8{1}.allCodes{1} : ' num2str(inp8{1}.allCodes{1})]);
disp('Inputted respones (they do not necessarily correspond to the parameters here in insel8bl02_demo):');
blResp8 = nan(8,20); for blN=1:8; for trN=1:20; blResp8(blN,trN)= resp8{blN}.posRep{trN}(2,1); end; end
disp(blResp8);
disp('Fit measures:'); disp(fitM);

disp('Running generative model to create synthetic data ...');
[fitMsy1, Par8sy1, MDP8sy1] = sel8bl02( pTr8, inp8, [], modStruc8, details);
disp('Done! Generated respones:');
blResp8sy1 = nan(8,20); for blN=1:8; for trN=1:20; blResp8sy1(blN,trN)=MDP8sy1{blN}.Resp.posRep{trN}(2,1); end; end
disp(blResp8sy1);
disp('Fit measures for generative run:'); disp(fitMsy1);

disp('Now using the generated data to see if they they have the right log lik etc...');
syResp1 = resp8; for blN=1:8; for trN=1:20; syResp1{blN}.posRep{trN} = MDP8sy1{blN}.Resp.posRep{trN}; end; end
[fitMsy2, Par8sy2, MDP8sy2] = sel8bl02( pTr8, inp8, syResp1, modStruc8, details);
disp('Done. Fit measures for run based on previously generated data:'); disp(fitMsy2);
disp('Parameters for each block, which have been affected by learning:');
disp('     posi0    dInitEv   aInitEv  alphaPrec   wAttr        wp0     mem');
disp(Par8sy2.trialP);

