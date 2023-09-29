clear

chosenData = getFixationData();


durations = chosenData.X(:,2);
amplitudes = chosenData.X(:,3);
wordlengths = chosenData.X(:,4);
frequencies = chosenData.X(:,5);

lengths = unique(wordlengths);
%wordlengths = [0;wordlengths(1:end-1)]; % last word
%wordlengths = [0; 0; wordlengths(1:end-2)]; % last last word


for i=1:length(lengths)
   data(i) = mean(durations(wordlengths==lengths(i)));  
   support(i) = length(durations(wordlengths==lengths(i)));
end

data = data(support>50);
lengths = lengths(support>50);

plot(lengths,data);