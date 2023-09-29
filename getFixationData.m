% - load data set 
% - remove instances with missing values
% - project to individuals that have read all sentences
% - extract fixation type, duration; saccade amplitude
% - also save limits for truncated distributions
function chosenData = getFixationData()

fprintf('Reading data\n');

load('data/fixation_data');


data = FIXATION.feature;
wordLengths = SENTENCE.wordLengths;

indIds = unique(data(:,1));
senIds = unique(data(:,2));


% choose individuals that have read all sentences
chosenIndividuals = [];
for i = indIds'
   sentencesIndividual = unique(data(data(:,1)==i,2));
   if (length(sentencesIndividual)==length(senIds)) 
        chosenIndividuals = [chosenIndividuals; i];
   end
end
data = data(ismember(data(:,1),chosenIndividuals),:);
fprintf('Projected to individuals that have read all sentences (%i left)\n',length(chosenIndividuals));

% Move fixation durations back by one step - would like to have duration
% associated with incoming saccade, not outgoing.
for i = unique(data(:,1))'
    fprintf('.');
    for j = unique(data(:,2))'
        filter = data(:,1)==i & data(:,2)==j;
        A = data(filter,:);
        if size(A,1)>0
            startingPoint = A(1,:);
            startingPoint(:,3:6) = zeros(size(startingPoint(:,3:6))); % starting fixation: has no incoming saccade type
            A(1:end,7) = [A(2:end,7);-1];    %move durations back by one step, last one fill with -1 (will be removed)
            A = [startingPoint; A(1:end-1,:)];  %remove last line - this has no (outgoing) amplitude. Append line with starting duration instead
            data(filter,:) = A;
        end
    end
end
fprintf('\n\n');


% remove fixation records with missing value for type of movement
data = data(~isnan(data(:,6)),:); 
data = data(~isnan(data(:,7)),:);
data = data(~isnan(data(:,8)),:);
data = data(~isnan(data(:,9)),:);

chosenData.indId      = data(:,1);
chosenData.senId      = data(:,2);

chosenData.y          =  data(:,1); % subject id

for i=1:size(data,1)
    chosenData.y(i,1) =  find(chosenIndividuals==data(i,1)); % convert subject id to lie between 1 and 20
end

chosenData.X(:,1)     =  data(:,3)+data(:,4).*2+data(:,5).*3+data(:,6).*4; % type of fixation
chosenData.X(:,[2,3]) =  [data(:,7) data(:,8).*data(:,12)];                % duration, amplitude

limits = zeros(size(chosenData.X(:,1),1),4,2);

% Compute limits for saccade types
for i = 1:size(chosenData.X,1)
    sentence = data(i,2);
    wlengths = wordLengths{sentence};
    wordNumber = data(i,11);
    fixationInWord = data(i,13);
    if length(wlengths)>wordNumber
        % not last word in sentence
        % next word movement
        limits(i,1,1) = wlengths(wordNumber)-fixationInWord+1;
        limits(i,1,2) = wlengths(wordNumber)-fixationInWord+1+wlengths(wordNumber+1);
        % forward skip
        limits(i,2,1) = wlengths(wordNumber)-fixationInWord+1+wlengths(wordNumber+1)+1;
        % "end of sentence"
        limits(i,2,2) = realmax;
    else
        % next word movement
        limits(i,1,1) = wlengths(wordNumber)-fixationInWord+1;
        limits(i,1,2) = wlengths(wordNumber)-fixationInWord+1;
        % forward skip
        limits(i,2,1) = NaN;
        limits(i,2,2) = NaN;
    end
    
    %refixation
    limits(i,3,1) = -fixationInWord;
    limits(i,3,2) = wlengths(wordNumber)-fixationInWord;
    
    %regression
    if wordNumber>1
       % "beginning of sentence"
       limits(i,4,1) = -realmax;
       limits(i,4,2) = -(fixationInWord+1);
    else
       limits(i,4,1) = NaN;
       limits(i,4,2) = NaN;
    end
    chosenData.X(i,4) = limits(i,1,1);
    chosenData.X(i,5) = limits(i,1,2);
    chosenData.X(i,6) = limits(i,2,1);
    chosenData.X(i,7) = limits(i,2,2);
    chosenData.X(i,8) = limits(i,3,1);
    chosenData.X(i,9) = limits(i,3,2);
    chosenData.X(i,10) = limits(i,4,1);
    chosenData.X(i,11) = limits(i,4,2);    
    chosenData.X(i,12) = data(i,13);    
   
end


