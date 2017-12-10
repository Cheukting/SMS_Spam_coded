# SMS_Spam_coded
Coded SMS Spam data set for Neural Network

Original SMS Spam data set form:
https://www.kaggle.com/uciml/sms-spam-collection-dataset
and
http://www.dt.fee.unicamp.br/~tiago/smsspamcollection/

Prepocessing:
Messages are cleaned by removing hashtags, twitter handles, puntuations, numbers and singer-letter words, http addresses are replaced by the word "httpurl"

Then it is tokenized into unigrams which words will be decending ordered according to their appearance frequency. This unigram is used as a dictionary for coding the messages in the data set.

Train/Test set:
Data set are split approximately into 70% train and 30% test each contain around 13% spam data and shuffled.

Coding:
1. The label for Ham/Spam will be mapped in to 0/1 accordingly, with 0=Ham, 1=Spam
2. Words will be mapped to the index of the word in the dictionary. Each message will be represent by a list of integers.

Files:
**x_train.csv** -  No header, the m-th row corrisponding to a coded SMS message of the m-th sample in the training set. The list of the integers are seperated by a ","

**x_test.csv** -  No header, the m-th row corrisponding to a coded SMS message of the m-th sample in the test set. The list of the integers are seperated by a ","

**y_train.csv** -  No header, the m-th row is either 0/1 corrisponding to the Ham/Spam label of the m-th sample in the training set.

**y_train.csv** -  No header, the m-th row is either 0/1 corrisponding to the Ham/Spam label of the m-th sample in the test set.

**unigramDictionary.csv** - the 1st row is the header, the 1st column 'word' are all the words in the data set, the 2nd column 'freq' are the corrisponding appearing frequency for that word.



