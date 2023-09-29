fid=fopen('data_adjust2.csv'); 

C=textscan(fid,[repmat('%f,',1,14) '%[^,]' repmat(',%f',1,16) '\n']); 
fclose(fid);

% C{i}
% 01... id - real identifier
% 02... id - subject number (1 ... 275, 2 subjects were deleted: id=149, id=230)
% 03... sn - sentence number (1 ... 144)
% 04... nw - number of words in sentence (often useful); constant across fixs in sn
% 05... wn - word number of fixation 
% 06... let - letter number in word on which fixation was measured; 0 is space before.
% 07... dur - duration of fixation
% 08... ao - amplitude (outgoing) in number of letters
% 09... dir - direction of next saccade: +1: forward; -1: backward
% 10... l - length of word
% 11... f - log10 printed frequency of word (per million words)
% 12... p - predictability of word from prior words of sentence 
% 13... x - lexical status of word (0 = content word, 1 = function word (added Nov 30, 2011)
% 14... wid - unique word number (may repeat in different sentences)
% 15... word - fixated word
% 16... dwn - delta word number: data$dwn <- c(diff(data$wn), NA)
% 17... id_sn - 1000*as.numeric(data$id) + as.numeric(data$sn)
% 18... wtw - word-to-next-word movement   (logical: 0... FALSE, 1... TRUE)
% 19... skp - forward skipping             (logical: 0... FALSE, 1... TRUE)
% 20... rfx - refixation within word       (logical: 0... FALSE, 1... TRUE)
% 21... rgr - regression to previous word  (logical: 0... FALSE, 1... TRUE)
% 22... first - first fixation in sentence (logical: 0... FALSE, 1... TRUE)
% 23... last - last fixation in sentence   (logical: 0... FALSE, 1... TRUE)
% 24... fpf - first-pass fixation (fixations on words read in forward movement) (logical: 0... FALSE, 1... TRUE)
% 25... nf - number of fixations on word; constant across fix in wn
% 26... fn - fixation number on word
% 27... gd - cumulative sum of fixation durations within a word
% 28... age - age of subject  
% 29... voc - vocabulary score of subject
% 30... dss - digit symbol substition score of subject (cognitive status/processing efficiency)
% 31... sex - gender of subject (1=male, 0=female)


% fixation attributes
attrs = [2,3,18,19,20,21,7,8,10,11,5,9,6];
FIXATION.feature=inf(max(C{1}),length(attrs));
for attr = attrs
    FIXATION.feature(C{1},attr==attrs) = C{attr};
end



% word attributes; check for consistency
attrs = [10,11,13];
WORD.feature=inf(max(C{14}),length(attrs));
for attr = attrs 
    for w_id=unique(C{14})'
        if ~(all(isnan(C{attr}(C{14}==w_id))) || length(unique(C{attr}(C{14}==w_id)))==1) 
            switch attr
                case 10 % length
                    tmp=C{15}(C{14}==w_id);
                    C{attr}(C{14}==w_id)=length(tmp{1});
                case 13 % lex status
                    C{attr}(C{14}==w_id)=median(C{attr}(C{14}==w_id));
                otherwise
                    error('not consistent word: %d attribute: %d\n',w_id,attr);
            end
            warning('not consistent word: %d attribute: %d\n',w_id,attr);
        end
    end
    WORD.feature(C{14},attr==attrs) = C{attr};
end
for w_id=unique(C{14})'
    if length(unique(C{15}(C{14}==w_id)))>1
        error('not consistent word: %d\n',w_id);
    end
end
WORD.string(C{14}) = C{15};


% check for consistency (subject)
attrs =28:31;
SUBJECT.feature=inf(max(C{2}),length(attrs));
for attr = attrs
    for sub=unique(C{2})'
        if ~(all(isnan(C{attr}(C{2}==sub))) || length(unique(C{attr}(C{2}==sub)))==1) 
            warning('not consistent subject: %d attribute: %d\n',sub,attr);
        end
    end
    SUBJECT.feature(C{2},attr==attrs) = C{attr};
end

% check for consistency (sentence)
attrs=[4];
SENTENCE.feature=inf(max(C{3}),length(attrs));
for attr = attrs
    for sen=unique(C{3})'
        if ~(all(isnan(C{attr}(C{3}==sen))) || length(unique(C{attr}(C{3}==sen)))==1) 
            warning('not consistent subject: %d attribute: %d\n',sen,attr);
        end
        wordsInSentence = unique(C{5}(C{3}==sen));
        wordLengths = zeros(length(wordsInSentence),1);
        for word = unique(wordsInSentence)'
            wordLength = unique(C{10}(C{3}==sen & C{5} == word));
            assert(length(wordLength)==1);
            wordLengths(word) = wordLength;
        end
        wordLengths
        SENTENCE.wordLengths{sen} = wordLengths;
    end
    SENTENCE.feature(C{3},attr==attrs) = C{attr};
end

SENTENCE.string={};
for sen=unique(C{3})'
    if length(unique(C{5}(C{3}==sen)))~=SENTENCE.feature(sen)
        error('inconsistent sentence');
    end
    [a,b,c] = unique(C{5}(C{3}==sen));
    if ~issorted(a)
        error('not sorted\n');
    end
    tmp=C{15}(C{3}==sen);
    SENTENCE.string{sen} = tmp(b)';
end

% inf... id do not exist; NaN... entry unknown
save fixation_data.mat FIXATION WORD SENTENCE

