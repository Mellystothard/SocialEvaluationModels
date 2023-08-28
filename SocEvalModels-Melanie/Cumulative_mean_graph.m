%cumulative sum of the negativity attribution graph
%the mAtTr for like,dislike,neutral,low and high conditions for both self
%and other conditions have been collected and saved.


%meancumsum was calculated before hand using:
% meancumsum = cumsum(mAtTr) ./ (1:length(mAtTr));
%and changed into it's specific acronym indicating what condition it belongs to.
% ex. Other Like Low fear of negative evaluation would be 'OL_LNFE'

%6 conditions for self-ref graph. 
figure(1)
plot(SN_LNFE);
hold on
plot(SN_HNFE)
hold on
plot(SD_LNFE)
hold on
plot(SD_HNFE)
hold on
plot(SL_LNFE)
hold on
plot(SL_HNFE)
xlabel("Trial number");
ylabel("Cumulative Mean Negative Responses");
title("Self-Referential");
ylim([0 1]);
legend('Neutral LFNE', 'Neutral HFNE','Dislike LFNE','Dislike HFNE','Like LFNE','Like HFNE');

%%

%6 conditions for other-ref graph. 
figure(2)
plot(ON_LNFE);
hold on
plot(ON_HNFE)
hold on
plot(OD_LNFE)
hold on
plot(OD_HNFE)
hold on
plot(OL_LNFE)
hold on
plot(OL_HNFE)
title("Other-Referential");
xlabel("Trial Number");
ylabel("Cumulative Mean Negative Responses");
ylim([0 1])
legend('Neutral LFNE','Neutral HFNE','Dislike LFNE','Dislike HFNE','Like LFNE','Like HFNE');


