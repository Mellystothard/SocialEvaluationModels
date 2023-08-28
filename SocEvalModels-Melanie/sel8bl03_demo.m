% sel8bl03_demo is to work with coding different response functions
% using sel8bl03.

repoFun= 1;   % 1 for simple softmax-like
toDisc = 1;   % try to write very simple simulated results to ...\SocEvalModels_(not_git)_rough_work\dataFits\fittingTests

% Derivee from sel8bl02_demo, the demo generating participant responses based on a an
% example of blocks sequence, and calculates the log-likelihood etc. first on
% the generated data directly and then provides the same data to the likelihood
% function to check. 

% '***8' in this file mostly refers to the 8-block experiment
%  A parameter vector in native space:
%         1          2        3      4         5        6       7        8     9    10   11     12      
%      posiSelf  posiOther  dEvSelf dEvOther aEvSelf aEvOther alphaPrec genLR repLR wp0 wAttr  mem      
par8 =  [0.75,     0.5,       1,     1,       2,       2,        5,     0.1,  0.5,   0,  6,   0.9998 ]; 
% Same in transformed space:
pTr8 = nat2tr_SEL_i(par8,1);  % map to transformed space. Transforms all the params, not just for each block.
pLen = length(par8); 
% backup
par8bak = par8;

toPlot = 0;
baseDir = 'C:\Users\mmpsy\Nextcloud\MM\googledirs\SocEvalModels_(not_git)_rough_work'; 
cwd = pwd;  cd(baseDir); 
load('.\simSEL8bl\noLearnSEL8bl.mat');  % load modStruc8, mdp8, inp8, resp8,pPosGen,par8hd,selfpHd
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
[fitM, Par8, MDP8] = sel8bl03( pTr8, inp8, resp8, modStruc8, repoFun, details);
disp(['inp8{1}.allCodes{1} : ' num2str(inp8{1}.allCodes{1})]);
disp('Inputted respones (they do not necessarily correspond to the parameters here in insel8bl02_demo):');
blResp8 = nan(8,20); for blN=1:8; for trN=1:20; blResp8(blN,trN)= resp8{blN}.posRep{trN}(2,1); end; end
disp(blResp8);
disp('Fit measures:'); disp(fitM);

disp('Running generative model to create synthetic data ...');
[fitMsy1, Par8sy1, MDP8sy1] = sel8bl03( pTr8, inp8, [], modStruc8, repoFun, details);
genTrP = nan(1,14);   genTrP(1,1:13) = [1, pTr8];                   genTrP(1,14)= fitMsy1.sLL;      
genNatP = nan(1,14);  genNatP(1,1:13) =[1, tr2nat_SEL_i(pTr8)];     genNatP(1,14)= fitMsy1.sLL;  
disp('Done! Generated respones:');
blResp8sy1 = nan(8,20); for blN=1:8; for trN=1:20; blResp8sy1(blN,trN)=MDP8sy1{blN}.Resp.posRep{trN}(2,1); end; end
disp(blResp8sy1);
disp('Fit measures for generative run:'); disp(fitMsy1);

disp('Now using the generated data to see if they they have the right log lik etc...');
syResp1 = resp8; for blN=1:8; for trN=1:20; syResp1{blN}.posRep{trN} = MDP8sy1{blN}.Resp.posRep{trN}; end; end
[fitMsy2, Par8sy2, MDP8sy2] = sel8bl03( pTr8, inp8, syResp1, modStruc8, repoFun, details);
disp('Done. Fit measures for run based on previously generated data:'); disp(fitMsy2);
disp('Parameters for each block, which have been affected by learning:');
disp('     posi0    dInitEv   aInitEv  alphaPrec   wAttr        wp0     mem');
disp(Par8sy2.trialP);

disp('Running generative model to create synthetic data with modefied params...');
%         1          2        3      4         5        6       7        8     9    10   11     12      
%      posiSelf  posiOther  dEvSelf dEvOther aEvSelf aEvOther alphaPrec genLR repLR wp0 wAttr  mem      
par8 =  [0.5,     0.3,        1,     1,       2,       2,       2.5,     0.1,  0.5,  0,  6,   0.9998 ]; 
pTr8 = nat2tr_SEL_i(par8,1);  % map to transformed space. Transforms all the params, not just for each block.
[fitMsy3, Par8sy3, MDP8sy3] = sel8bl03( pTr8, inp8, [], modStruc8, repoFun, details); %pTr8 is parameters change to see what fits the data best,last 3 things don't change, 
% inp8 what participant saw on the screen, 
syResp3 = resp8; for blN=1:8; for trN=1:20; syResp3{blN}.posRep{trN} = MDP8sy3{blN}.Resp.posRep{trN}; end; end
genTrP(end+1,1:13) = [2, pTr8];      genNatP(end+1,1:13) = [2, tr2nat_SEL_i(pTr8)];
genTrP(end,14)= fitMsy3.sLL;         genNatP(end,14)= fitMsy3.sLL;  
disp('Done! Generated respones:');
blResp8sy3 = nan(8,20); for blN=1:8; for trN=1:20; blResp8sy3(blN,trN)=MDP8sy3{blN}.Resp.posRep{trN}(2,1); end; end
disp(blResp8sy3);
disp('Fit measures for generative run:'); disp(fitMsy3);

selD03 = {};
selD03{1}.inp8 = inp8;       selD03{1}.resp8 = syResp1;    % deliberately skip syResp2
selD03{2}.inp8 = inp8;       selD03{2}.resp8 = syResp3;  
modStruc8.repoFun = repoFun; 


if toDisc
    fitTestDir = 'C:\Users\mmpsy\Nextcloud\MM\googledirs\SocEvalModels_(not_git)_rough_work\dataFits\fittingTests';
    cwd = pwd; 
    cd(fitTestDir);
    hd=  {'numID','posiSelf','posiOther','dEvSelf','dEvOther','aEvSelf','aEvOther','alphaPrec','genLR','repLR','wp0','wAttr','mem','LL'};
    save('selD03_AcIn.mat','selD03');    % very sparce simulated data ...
    save('modStruc8a.mat','modStruc8');
    ldat = genTrP; 
    save('genPar.mat','ldat','hd','genNatP');    % MUST BE IN FORMAT THAT FITTING FUNCTION CAN USE.
    mat2csv2Dfl(genTrP,'genTrP.csv',0,1,hd);
    mat2csv2Dfl(genNatP,'genNatP.csv',0,1,hd);    
    cd(cwd);
    
end

cd(cwd);    % restore the current working directory.

% -------------------------------------- eof -----------------------------------

