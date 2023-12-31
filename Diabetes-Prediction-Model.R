##Install and load required packages----
# install.packages(c("caret","e1071"))
# library(caret)
# library(e1071)
# library(corrplot)
# library(pls)
# library(dplyr)
# library(pROC)
# library(nnet)
# library(mda)
# library(earth)
# library(MASS)
# library(kernlab)
# library(klaR)
# library(glmnet)


#install.packages("pacman")
library(pacman)
pacman::p_load(caret, e1071, corrplot, pls, dplyr, pROC, nnet, mda, earth, MASS, kernlab, klaR, glmnet, ggcorrplot)

#Read the data file 
#set working directory where the R and csv file is saved
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
Diab <- read.csv("diabetes.csv")

# Check Data ---------------------------------------------------------

#numerical summary
summary(Diab)

#visual summary
plot(Diab, main = "Scatter Plot Matrix")

par(mfrow=c(2,4))
for(xx in 1:8){
  boxplot(Diab[xx],main = colnames(Diab[xx]))
}

#checking for near zero variance:
nearZeroVar(Diab)
# 0 means no variable with near zero variance

#check for any missing values:
sum(is.na(Diab))
#0 means no missing values, so we don't have to impute values

#checking for distribution/center and skewness:
#Histogram plots of the 8 predictors, to show distribution and skewness
par(mfrow=c(4,2))
hist(Diab[,1], xlab = "Age", ylab = "Frequency", main = "Age")
hist(Diab[,2], xlab = "Pregnancies", ylab = "Frequency", main = "# of Pregnancies")
hist(Diab[,3], xlab = "Glucose", ylab = "Frequency", main = "Glucose")
hist(Diab[,4], xlab = "BloodPressure", ylab = "Frequency", main = "Blood Pressure")
hist(Diab[,5], xlab = "SkinThickness", ylab = "Frequency", main = "Skin Thickness")
hist(Diab[,6], xlab = "Insulin", ylab = "Frequency", main = "Insulin")
hist(Diab[,7], xlab = "BMI", ylab = "Frequency", main = "BMI")
hist(Diab[,8], xlab = "DiabetesPedigreeFunction", ylab = "Frequency", main = "Diabetes Pedigree Function")
#many variables are not centered and has a skew in the distribution

#checking for skewness:
skewValues <- apply(Diab[1:8], 2, skewness)
head(skewValues)  #for all variables
#couple of the variables are extremely skewed

#checking for correlated predictors:
par(mfrow=c(1,1))
segDiab <- Diab[1:8]
correlations <- cor(segDiab, use = "na.or.complete")
ggcorrplot(correlations, hc.order = TRUE, type = "lower", lab = TRUE)
corrplot(as.matrix(correlations), order = "alphabet", method = "number", is.corr = FALSE)
highCorr <- findCorrelation(correlations, cutoff = .85)
length(highCorr) # zero - no correlated predictors
#no two predictors seems to be highly correlated and hence none of the variables are removed

#checking for outliers:
par(mfrow=c(2,4))
for(xx in 1:8){
  boxplot(Diab[xx],main = colnames(Diab[xx]))
}
#many variables shows strong outliers

#check if the distribution among the response variable classes is not vastly different
par(mfrow=c(1,1))
Diab$Outcome <- factor(Diab$Outcome, labels = c("NonDiabetic","Diabetic"))

plot(Diab$Outcome, xlab = "Outcome", ylab = "Frequency", main = "Diabetes Outcome")
#the distribution is unbalanced and hence use stratified sampling with ROC 

# Transform and Plot ------------------------------------------------------

#Transform the data to resolve issues
trans <- preProcess(Diab[,1:8], method = c("nzv", "BoxCox", "center", "scale", "spatialSign"))  ## need {caret} package
tDiab <- predict(trans, Diab[,1:8])
XX <- tDiab
YY <- (Diab[,9])
plot(XX, main = "Transformed Variables")
plot(YY, main = "Outcome")

#checking for distribution/center and skewness after the transformation:
#Histogram plots of the 8 predictors, to show distribution and skewness
par(mfrow=c(4,2))
hist(tDiab[,1], xlab = "Age", ylab = "Frequency", main = "Age")
hist(tDiab[,2], xlab = "Pregnancies", ylab = "Frequency", main = "# of Pregnancies")
hist(tDiab[,3], xlab = "Glucose", ylab = "Frequency", main = "Glucose")
hist(tDiab[,4], xlab = "BloodPressure", ylab = "Frequency", main = "Blood Pressure")
hist(tDiab[,5], xlab = "SkinThickness", ylab = "Frequency", main = "Skin Thickness")
hist(tDiab[,6], xlab = "Insulin", ylab = "Frequency", main = "Insulin")
hist(tDiab[,7], xlab = "BMI", ylab = "Frequency", main = "BMI")
hist(tDiab[,8], xlab = "DiabetesPedigreeFunction", ylab = "Frequency", main = "Diabetes Pedigree Function")

#checking for skewness after the transformation:
skewValues <- apply(tDiab[1:8], 2, skewness)
head(skewValues)

#checking for outliers after the transformation:
par(mfrow=c(2,4))
for(xx in 1:8){
  boxplot(tDiab[xx],main = colnames(Diab[xx]))
}

# Training Data -----------------------------------------------------------

#Data Splitting
set.seed(1)
trainingRows <- createDataPartition(YY, p = .80, list= FALSE)
trainPredictors <- data.frame(XX[trainingRows,])
trainClasses <- YY[trainingRows]

testPredictors <- data.frame(XX[-trainingRows,])
testClasses <- YY[-trainingRows]

par(mfrow=c(1,2))
plot(Diab$Outcome, main = "Full Dataset")
plot(trainClasses, main = "Training Dataset")


ctrl <- trainControl(method = "LGOCV",
                     summaryFunction = twoClassSummary,
                     classProbs = TRUE,
                     savePredictions = TRUE)

#Logistic Regression Model
Diab_logistic = train( trainPredictors, trainClasses, method="glm", 
                       metric="ROC", trControl=ctrl )
Diab_logistic
confusionMatrix(Diab_logistic)

par(mfrow=c(1,1))
FullRoc_logistic <- roc(response = Diab_logistic$pred$obs,
               predictor = Diab_logistic$pred$Diabetic,
               levels = rev(levels(Diab_logistic$pred$obs)))
plot(FullRoc_logistic, legacy.axes = TRUE, main = "ROC: Logistic Regression Model")
auc(FullRoc_logistic)

#Linear Discriminant Analysis Model
Diab_lda <- train(trainPredictors, trainClasses, method = "lda", 
                  trControl = ctrl, metric = "ROC", 
                  preProc=c("center","scale"))
Diab_lda
confusionMatrix(Diab_lda)

par(mfrow=c(1,1))
FullRoc_LDA <- roc(response = Diab_lda$pred$obs,
                        predictor = Diab_lda$pred$Diabetic,
                        levels = rev(levels(Diab_lda$pred$obs)))
plot(FullRoc_LDA, legacy.axes = TRUE, main = "ROC: Linear Discriminant Analysis Model")
auc(FullRoc_LDA)

#Partial Least Squares Discriminant Analysis Model
Diab_plsda = train( trainPredictors, trainClasses, method="pls",
                    tuneGrid=expand.grid(.ncomp=1:8), 
                    preProc=c("center","scale"), 
                    metric="ROC", trControl=ctrl )
Diab_plsda
confusionMatrix(Diab_plsda)

plot(Diab_plsda, main = "Parameter: Partial Least Squares Discriminant Analysis")
par(mfrow=c(1,1))
FullRoc_plsda <- roc(response = Diab_plsda$pred$obs,
                   predictor = Diab_plsda$pred$Diabetic,
                   levels = rev(levels(Diab_plsda$pred$obs)))
plot(FullRoc_plsda, legacy.axes = TRUE, main = "ROC: Partial Least Squares Discriminant Analysis")
auc(FullRoc_plsda)

#Penalized Generalized Linear Analysis
glmnGrid <- expand.grid(.alpha = c(0, .1, .2, .4, .6, .8, 1),
                        .lambda = seq(0,12, length = 10))
Diab_pglm = train( trainPredictors, trainClasses, 
                   method="glmnet", tuneGrid=glmnGrid, 
                   preProc=c("center","scale"), metric="ROC", 
                   trControl=ctrl )
Diab_pglm
confusionMatrix(Diab_pglm)

plot(Diab_pglm, plotType = "level", main = "Parameter: Penalized Generalized Linear Analysis")
par(mfrow=c(1,1))
FullRoc_pglm <- roc(response = Diab_pglm$pred$obs,
                     predictor = Diab_pglm$pred$Diabetic,
                     levels = rev(levels(Diab_pglm$pred$obs)))
plot(FullRoc_pglm, legacy.axes = TRUE, main = "ROC: Penalized Generalized Linear Analysis")
auc(FullRoc_pglm)

#Nonlinear Mixture Discriminant Analysis Model
set.seed(476)
Diab_mda <- train(trainPredictors, trainClasses,
                method = "mda",
                metric = "ROC",
                tuneGrid = expand.grid(.subclasses = 1:3),
                trControl = ctrl)
Diab_mda
confusionMatrix(Diab_mda)

plot(Diab_mda, main = "Parameter: Mixture Discriminant Analysis")
par(mfrow=c(1,1))
FullRoc_mda <- roc(response = Diab_mda$pred$obs,
                    predictor = Diab_mda$pred$Diabetic,
                    levels = rev(levels(Diab_mda$pred$obs)))
plot(FullRoc_mda, legacy.axes = TRUE, main = "ROC: Mixture Discriminant Analysis")
auc(FullRoc_mda)

#Neural Network Model
nnetGrid <- expand.grid(.size = 1:20, .decay = c(0, .1, .3, .5, 1))
maxSize <- max(nnetGrid$.size)
numWts <- (maxSize * (8 + 1) + (maxSize+1)*2) ## 8 is the number of predictors; 2 is the number of classes
Diab_nnet <- train(trainPredictors, trainClasses,
                 method = "nnet",
                 metric = "ROC",
                 preProc = c("center", "scale", "spatialSign"),
                 tuneGrid = nnetGrid,
                 trace = FALSE,
                 maxit = 2000,
                 MaxNWts = numWts,
                 trControl = ctrl)
Diab_nnet
confusionMatrix(Diab_nnet)

plot(Diab_nnet, main = "Parameter: Neural Network Model")
par(mfrow=c(1,1))
FullRoc_nnet <- roc(response = Diab_nnet$pred$obs,
                   predictor = Diab_nnet$pred$Diabetic,
                   levels = rev(levels(Diab_nnet$pred$obs)))
plot(FullRoc_nnet, legacy.axes = TRUE, main = "ROC: Neural Network Model")
auc(FullRoc_nnet)

#Flexible Discriminant Analysis Model
marsGrid <- expand.grid(.degree = 1:2, .nprune = 2:10)
Diab_fda <- train(trainPredictors, trainClasses,
                  method = "fda",
                  metric = "ROC",
                  tuneGrid = marsGrid,
                  trControl = ctrl)
Diab_fda
confusionMatrix(Diab_fda)

plot(Diab_fda, main = "Parameter: Flexible Discriminant Analysis")
par(mfrow=c(1,1))
FullRoc_fda <- roc(response = Diab_fda$pred$obs,
                    predictor = Diab_fda$pred$Diabetic,
                    levels = rev(levels(Diab_fda$pred$obs)))
plot(FullRoc_fda, legacy.axes = TRUE, main = "ROC: Flexible Discriminant Analysis")
auc(FullRoc_fda)

#Support Vector Machines Model
sigmaRangeReduced <- sigest(as.matrix(trainPredictors))
svmRGridReduced <- expand.grid(.sigma = sigmaRangeReduced[1],
                               .C = 2^(seq(-4, 6)))
set.seed(476)
Diab_svmR <- train(trainPredictors, trainClasses,
                   method = "svmRadial",
                   metric = "ROC",
                   preProc = c("center", "scale"),
                   tuneGrid = svmRGridReduced,
                   fit = FALSE,
                   trControl = ctrl)
Diab_svmR
confusionMatrix(Diab_svmR)

plot(Diab_svmR, main = "Parameter: Support Vector Machines")
par(mfrow=c(1,1))
FullRoc_svm <- roc(response = Diab_svmR$pred$obs,
                   predictor = Diab_svmR$pred$Diabetic,
                   levels = rev(levels(Diab_svmR$pred$obs)))
plot(FullRoc_svm, legacy.axes = TRUE, main = "ROC: Support Vector Machines")
auc(FullRoc_svm)

#K-Nearest Neighbors Model
set.seed(476)
Diab_knn <- train(trainPredictors, trainClasses,
                method = "knn",
                metric = "ROC",
                preProc = c("center", "scale"),
                tuneGrid = data.frame(.k = 1:70),
                trControl = ctrl)
Diab_knn
confusionMatrix(Diab_knn)

plot(Diab_knn, main = "K Nearest Neighbours Model")
par(mfrow=c(1,1))
FullRoc_knn <- roc(response = Diab_knn$pred$obs,
                   predictor = Diab_knn$pred$Diabetic,
                   levels = rev(levels(Diab_knn$pred$obs)))
plot(FullRoc_knn, legacy.axes = TRUE, main = "ROC: K-Nearest Neighbors")
auc(FullRoc_knn)

#Naive Bayes
set.seed(476)
Diab_nb <- train( trainPredictors, trainClasses,
                method = "nb",
                metric = "ROC",
                preProc = c("center", "scale"),
                tuneGrid = data.frame(.fL = 2,.usekernel = TRUE,.adjust = TRUE),
                trControl = ctrl)

Diab_nb
confusionMatrix(Diab_nb)

par(mfrow=c(1,1))
FullRoc_nb <- roc(response = Diab_nb$pred$obs,
                   predictor = Diab_nb$pred$Diabetic,
                   levels = rev(levels(Diab_nb$pred$obs)))
plot(FullRoc_nb, legacy.axes = TRUE, main = "ROC: Naive Bayes")
auc(FullRoc_nb)

par(mfrow=c(1,1))
plot(FullRoc_logistic, legacy.axes = TRUE, main = "ROC Curve: Training Model Comparison", col=c("red"), lty=1, cex=0.4)
lines(FullRoc_LDA, legacy.axes = TRUE, col=c("black"), lty=1, cex=0.4)
lines(FullRoc_plsda, legacy.axes = TRUE, col=c("darksalmon"), lty=1, cex=0.4)
lines(FullRoc_pglm, legacy.axes = TRUE, col=c("chocolate"), lty=1, cex=0.4)
lines(FullRoc_mda, legacy.axes = TRUE, col=c("blue"), lty=1, cex=0.4)
lines(FullRoc_nnet, legacy.axes = TRUE, col=c("cadetblue"), lty=1, cex=0.4)
lines(FullRoc_fda, legacy.axes = TRUE, col=c("cyan"), lty=1, cex=0.4)
lines(FullRoc_svm, legacy.axes = TRUE, col=c("deepskyblue"), lty=1, cex=0.4)
lines(FullRoc_knn, legacy.axes = TRUE, col=c("aquamarine"), lty=1, cex=0.4)
lines(FullRoc_nb, legacy.axes = TRUE, col=c("cornflowerblue"), lty=1, cex=0.4)
legend(0.15, 0.5, legend=c("Logistic Regression Model", "Linear Discriminant Analysis", "Partial Least Squares Discriminant Analysis", "Penalized Generalized Linear Analysis", "Mixture Discriminant Analysis", "Neural Network", "Flexible Discriminant Analysis", "Support Vector Machines", "K-Nearest Neighbors", "Naive Bayes"),
       col=c("red", "black", "darksalmon", "chocolate", "blue", "cadetblue", "cyan", "deepskyblue", "aquamarine", "cornflowerblue"), lty=1, cex=0.8, lwd = 2)


# Testing Data ------------------------------------------------------------

#Logistic Regression Model
Diab_logistic_pred_prob = predict( Diab_logistic, testPredictors, type = "prob")
Diab_logistic_pred = predict( Diab_logistic, testPredictors)
confusionMatrix(Diab_logistic_pred, testClasses, positive = "Diabetic")
par(mfrow=c(1,1))
TestRoc_logistic <- roc(response = testClasses,
                        predictor = Diab_logistic_pred_prob$Diabetic, levels=c("Diabetic", "NonDiabetic"))
plot(TestRoc_logistic, legacy.axes = TRUE, main = "Logistic Regression Model")
auc(TestRoc_logistic)

#Linear Discriminant Analysis Model
Diab_lda_pred_prob <- predict(Diab_lda, testPredictors, type = "prob")
Diab_lda_pred <- predict(Diab_lda, testPredictors)
confusionMatrix(Diab_lda_pred, testClasses, positive = "Diabetic")
par(mfrow=c(1,1))
TestRoc_lda <- roc(response = testClasses,
                        predictor = Diab_lda_pred_prob$Diabetic, levels=c("Diabetic", "NonDiabetic"))
plot(TestRoc_lda, legacy.axes = TRUE, main = "Linear Discriminant Analysis")
auc(TestRoc_lda)

#Important Predictor Variables
plot(varImp(Diab_lda, scale = FALSE), top = 5, scales = list(y = list(cex = .95)), main = " Important Variables: Linear Discriminant Analysis")
plot(varImp(Diab_logistic, scale = FALSE), top = 5, scales = list(y = list(cex = .95)), main = " Important Variables: Logistic Regression Model")

plot(TestRoc_logistic, legacy.axes = TRUE, main = "ROC Curve: Testing Model Comparison", col=c("red"), lty=1, cex=0.4)
lines(TestRoc_lda, legacy.axes = TRUE, col=c("blue"), lty=1, cex=0.4)
legend(0.15, 0.5, legend=c("Logistic Regression Model", "Linear Discriminant Analysis"),
       col=c("red","blue"), lty=1, cex=0.8)
