% Split data set loaded by getData(). Sentences in test and training set are disjoint.
% Because individuals have read all sentences, all individuals occur in test
% and training set.
function [trainId testId trainSentences testSentences] = splitData(dataChosen,seed,numTrainSentences,numTestSentences)    
    fractionTraining = 0.5;        
    %RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));       
    rng(seed);
    sentences = unique(dataChosen.senId);   
    sentences = sentences(randperm(length(sentences)));   
    
    split = fix(length(sentences)*fractionTraining);
    trainSentences = sentences(1:numTrainSentences);
    testSentences = sentences(split+1:(split+numTestSentences));
%    fprintf('TrainSentences: \n');
%    display(trainSentences);
    
    testId  = ismember(dataChosen.senId,testSentences);
    trainId = ismember(dataChosen.senId,trainSentences);
    
    fprintf('Split into %i training sentences and %i test sentences\n',length(trainSentences),length(testSentences));
end