function natP = tr2nat_mdp_L_xii(P)
% tr2nat_mdp_L_xii - to bring param for ONE 'rater' BLOCK of SEL modelling
%                 to native space. P and natP are structures w named fields.
% test/demo with tr2nat_mdp_L_xii(nat2tr_mdp_L_xi(nativePar))
%__________________________________________________________________________

% Complicated if statement to transform inputted parameters 
field = fieldnames(P);  
for i = 1:length(field)
    % first, log-transformed: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if strcmp(field{i},'dInitEv')
        natP.dInitEv = exp(P.dInitEv);   
    elseif strcmp(field{i},'aInitEv')
        natP.aInitEv = exp(P.aInitEv);        
    elseif strcmp(field{i},'alphaPrec')
        natP.alphaPrec = exp(P.alphaPrec);    
    % logit-transformed: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elseif strcmp(field{i},'posi0')
        pNat = P.posi0;       natP.posi0 = 1/(1+exp(-pNat));   
    elseif strcmp(field{i},'mem')  
        pNat = P.mem;       natP.mem = 1/(1+exp(-pNat));   
   elseif strcmp(field{i},'lps')  
        pNat = P.lps;       natP.mem = 1/(1+exp(-pNat));   
    % and scaled-logit transformed: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     elseif strcmp(field{i},'desBias')
%         pNat =  P.desBias;  natP.desBias = -1 + 2/(1+exp(-pNat)); 
    % Already in nativ space ~~~~~~~~~~~~~~~~~~~~~~~~~~
    elseif strcmp(field{i},'wp0')  
        natP.wp0 = P.wp0;  
    elseif strcmp(field{i},'wAttr')  
        natP.wAttr = P.wAttr;  
    % NO DEFAULTS - IF NOT CONTAINS EXTRA TERMS, ABORT:
    else
       error([field{i} ' not catered for.']);
   end
end
  

return;
