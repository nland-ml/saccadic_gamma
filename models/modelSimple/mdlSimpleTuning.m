function minSampleSize = mdlSimpleTuning(data, trainId, numFolds)

    trainSentences = unique(data.senId(trainId));
    numFolds = min(numFolds,length(trainSentences));
  
    fprintf('\n\n Tuning minSampleSize on %i training sentences \n\n',length(trainSentences));
    
    minSampleSizes = [10 20 40 80 160];
    for i = 1:length(minSampleSizes)
        for f = 1:numFolds
            testSentencesFold = trainSentences(f:numFolds:length(trainSentences)); 
            trainSentencesFold = trainSentences(~ismember(trainSentences,testSentencesFold));

            testIdFold  = ismember(data.senId,testSentencesFold);
            trainIdFold = ismember(data.senId,trainSentencesFold);
            
            delete('params.mat');
            accuracyFold  = mdlSimple(data, trainIdFold, testIdFold, minSampleSizes(i));
            accuracies(i,f) = accuracyFold(1);
        end
    end
    
    [maximum best] = max(mean(accuracies,2));
    minSampleSize = minSampleSizes(best);
    fprintf('\n\n Tuned minSampleSize = %f\n\n',minSampleSize);
    
%    delete('params.mat');
%    accuracy  = mdlSimple(data, trainIdFold, testIdFold, minSampleSize);
end