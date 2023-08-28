% HARD HAT AREA - PLEASE DON'T EDIT THIS FILE, MICHAEL IS WORKING ON IT.

% '***8' in this file mostly refers to the 8-block experiment
%  A parameter vector in native space:
%         1          2        3      4         5        6       7        8     9    10   11     12       13
%      posiSelf  posiOther  dEvSelf dEvOther aEvSelf aEvOther alphaPrec genLR repLR wp0 wAttr  lrnR    desBias
par8 =  [0.75,      0.5,      1,      1,       2,       2,      5,      0.25,  0.8,  0,  6,   0.9999,     0];
% Same in transformed space:
pTr8 = par8;  
pTr8(1)= log(par8(1)/(1-par8(1)));
pTr8(2)= log(par8(2)/(1-par8(2)));
pTr8(3:7)= log(par8(3:7));
pTr8(8)= log(par8(8)/(1-par8(8)));
pTr8(9)= log(par8(9)/(1-par8(9)));
pTr8(12)= log(par8(12)/(1-par8(12)));
% backup
par8bak = par8; 

toPlot = 0;
load('.\simSEL8bl\noLearnSEL8bl.mat');  % load modStruc8, mdp8, inp8, resp8,pPosGen,par8hd,selfpHd


[fitM, Par8, MDP8] = sel8bl01( pTr8, inp8, resp8, modStruc8, toPlot);

