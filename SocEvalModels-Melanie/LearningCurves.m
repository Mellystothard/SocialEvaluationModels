pRet=0.25;  
totRep = 5; %total no. of trial is 20 but I put 5 so it's faster to run for testing purposes
partno = 3; %participant number, small value just for faster checks
for partrows = 1:partno 
    selfpRef= [0.55,    1,     5,   1/5,    8,   2,   4,  0.1]; 
            %attr0,dInitEv,aInitEv,uPrec,wAttr,w0,lrnR,desBias
    
    w0 = normrnd(-0.32, 0.84, 1, totRep); %this follows the method in forTest1 
     MDPs = {};      Inp  = {};       Resp = {};   

    for rep = 1:totRep

          selfp = selfpRef; 
          selfp(6)= w0(rep); 

          [MDPs{rep},modStruc,Inp{rep},Resp{rep}] = ...
                              learnReport01(selfp,pRet,0); %this only has rows
          disp(['Simulated ' num2str(rep) ' out of ' num2str(totRep)]); %just shows on display what rep u r on out of the total reps

          AllResp = {partrows,Resp{rep}}; %i have difficulty with trying to put each of the 20 trials on each row,
                                 %this stores the very last participant
       
          MeanTrialResps = mean(AllResp(:,1:rep));%this extracts all the data from the participants from trial 1,2,3...etc. to obtain mean
                                                  %this is assuming all the trial 1 data is the first col, 2nd trial on 2nd col etc.
                                                  %I have tested the code line 23 seperately with
                                                  %a made up 'AllResp' and i think
                                                  %the problem is with the codes that come before line 23 
                              
    end
end

