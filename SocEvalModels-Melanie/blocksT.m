
testCode = 1;

totBlocks = 8;
toPlot = 0;
pRets = [0.2 0.5 0.8];            % for neg, neutr, pos rater blocks.
% Default parameters
defaultPar =  [0.5,   1,      2,     1/5,   6,   0,   1,      0];
w0self = 0;
w0other = -0.2;

blockMDPs = {};   % These will store all blocks
Resp = {};

positivitySeq = [ 1 3 2 2 1 3 2 1];   % neg blocks 1, neutr. 2, pos. 3
ratedSeq      = [ 2 1 1 2 2 1 1 2];   % self is rated = 1, other is rated = 2

for blockN = 2:3  % 1:totBlocks
    selfp = defaultPar;
    
    pRet = pRets(positivitySeq(blockN));
    if ratedSeq(blockN) == 1
        selfp(6) = w0self;
    elseif ratedSeq(blockN) == 2
        selfp(6) = w0other;
    else
        error('aaarrggh');
    end
    
    if testCode
        toPlot = 1;
    else
        toPlot = 0;
    end
    
%create plot for mean positive resp
trialN = 20;
for counter = 1:trialN %to make x axis 1:20/30 as with buttons paper
 CumBlockMeanPosResp(counter) = cumsum(Resp(counter))/(1:counter); %attempt to find the cumulative mean resp for all the trials per block
plot(CumBlockMeanPosResp(counter),trialN,"-")
hold on

    [blockMDPs{ParN, blockN}, modelStructure, Inp,Resp{ParN, blockN}] = learnReport01(selfp, pRet, toPlot);

hold off
end
end
