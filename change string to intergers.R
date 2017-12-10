library(stringr)
library(dplyr)
library(tm)
library(RWeka)
options(mc.cores=1)

# helper functions
removeHashTags <- function(x) gsub("#\\S+", " ", x)
removeTwitterHandles <- function(x) gsub("@\\S+", " ", x)
removeURL <- function(x) gsub("http:[[:alnum:]]*", " httpurl ", x)
removeApostrophe <- function(x) gsub("'", "", x)
removeNonLetters <- function(x) gsub("[^a-zA-Z\\s]", " ", x)
removeSingleChar <- function(x) gsub("\\s\\S\\s", " ", x)
removeMoreSpace <- function(x) gsub("\\s+", " ", x)

# cleaning function
CleanIt <- function(input){
  input <- removeHashTags(input)
  input <- removeTwitterHandles(input)
  input <- removeURL(input)
  input <- removeApostrophe(input)
  input <- removeNonLetters(input)
  input <- tolower(input)
  input <- removeSingleChar(input)
  input <- removeMoreSpace(input)
  return(input)
}

# sample funciton
SampleIt <- function(lines){
  lines <- CleanIt(lines)
  MyCorpus <- VCorpus(VectorSource(lines))
  rm(lines)
  
  SingleTokenTDM <- TermDocumentMatrix(MyCorpus,control = list(wordLengths =  c(2, Inf)))
  unifreq <- sort(rowSums(as.matrix(SingleTokenTDM)),decreasing = TRUE)
  unifreqdf <- data.frame(word=names(unifreq), freq=unifreq)
  rm(SingleTokenTDM)
  rm(unifreq)
  
  rm(MyCorpus)
  output <- unifreqdf

  return(output)
}

## custom join to add freq df together
myJoin <- function(x,y){
  if (dim(x)[1] == 0){
    out <- y
  }else if (dim(y)[1] == 0){
    out <- x
  }else{
    out <- full_join(x,y,by="word")
    out[is.na(out)] <- 0
    out <- transmute(out,word = word,freq = freq.x+freq.y)
  }
  return(out)
}

SMS <- read.csv('spam.csv')

SMSdata <- SMS[,1:2]
SMSdata$v2 <- sapply(SMSdata$v2,CleanIt)

unigram <- data.frame(word=character(), freq=numeric())
for(i in 1:length(SMSdata$v2)){
  unigram <- myJoin(unigram,SampleIt(SMSdata$v2[i]))
}

unigramSort <- unigram[order(unigram$freq,decreasing = TRUE),]

## write freqs into csv files
write.csv(unigramSort,file = "unigramDictionary.csv",row.names = FALSE)

## Change label to 0/1 0=ham 1=spam
SMSdata$v1 <- as.integer(SMSdata$v1)-1

## splint train/test set as we got 747/5572 spam 
## we haev to make sure the distribution is the same

trainRatio <- .7
Spam <- SMSdata[SMSdata$v1==1,]
Ham <- SMSdata[SMSdata$v1==0,]

splitIdx <- as.integer(nrow(Spam)*trainRatio)
train <- Spam[1:splitIdx,]
test <- Spam[(splitIdx+1):nrow(Spam),]

splitIdx <- as.integer(nrow(Ham)*trainRatio)
train <- rbind(train,Ham[1:splitIdx,])
test <- rbind(test,Ham[(splitIdx+1):nrow(Ham),])

#shuffle train data to make sure no leaking when train
train <- train[sample(nrow(train)),]
test <- test[sample(nrow(test)),]

findWord <- function(x){
  x <- paste("^",x,"$",sep = "", collapse = "")
  return(grep(x, unigramSort$word)[1])
}

codeWords <- function(input){
  inputWords <- str_split(input,"\\s+")[[1]]
  output <- sapply(inputWords, findWord)
  output <- output-1
  return(output[!is.na(output)])
}

y_train <- train$v1
y_test <- test$v1

x_train <- sapply(train$v2,codeWords)
x_test <- sapply(test$v2,codeWords)

write.table(y_train, "y_train.csv", row.names = F, col.names = F, sep=',')
write.table(y_test, "y_test.csv", row.names = F, col.names = F, sep=',')

lapply(x_train, function(x) write.table(paste(x,sep=",",collapse=","), 'x_train.csv', append= T, row.names = F, col.names = F, sep=',',quote = F))
lapply(x_test, function(x) write.table(paste(x,sep=",",collapse=","), 'x_test.csv', append= T, row.names = F, col.names = F, sep=',' ,quote = F))

