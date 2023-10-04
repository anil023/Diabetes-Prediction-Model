# Diabetes Prediction Model
<!--DEFINE DIABETES-->
Diabetes is a health condition that affects how your body manages sugar, also known as glucose. When you consume food, your body breaks it down into glucose, which serves as an energy source. To facilitate glucose entry into cells where it's needed, your body relies on a hormone called insulin. In diabetes, there's an issue related to insulin: either your body doesn't produce insulin at all, or it doesn't effectively utilize the insulin it produces, and in some cases, it may not produce enough.
<!--DEFINE GDM-->
Pregnancy-induced diabetes, also known as gestational diabetes mellitus (GDM), is a type of diabetes that develops during pregnancy. It occurs when the body cannot produce enough insulin to meet the increased demands brought on by pregnancy, resulting in elevated blood sugar levels. GDM typically arises in the second or third trimester and poses several risks to both the mother and the baby. Uncontrolled GDM can lead to high blood pressure, preeclampsia, birth injuries, the necessity of cesarean sections, or an increased risk of stillbirth. Women with GDM also have an elevated risk of developing type 2 diabetes later in life. Babies are at risk of low blood sugar (hypoglycemia), jaundice, and respiratory distress syndrome.
<!--WHY PREDICTIVE MODELS-->
Pregnancy-induced diabetes presents significant risks, and thus, it requires careful management to ensure the health of both the mother and the baby. Managing GDM involves monitoring blood sugar levels, making dietary adjustments, and, in some cases, using insulin or other medications as prescribed by a healthcare provider. Predictive models can play a crucial role in identifying individuals at risk and providing personalized care to mitigate these risks, ultimately leading to healthier pregnancies and improved outcomes for both mothers and newborns.


## THE PROBLEM
<!--OBJECTIVE-->
Data sourced from the National Institute of Diabetes and Digestive and Kidney Diseases is accessible on Kaggle through the following [(link)](https://www.kaggle.com/datasets/uciml/pima-indians-diabetes-database "Kaggle Link to the Dataset"). This dataset pertains to females aged at least 21 years from the Pima Indian heritage. The primary objective of this repository is to employ machine learning models in the R language to diagnostically predict whether a patient has diabetes. This prediction is based on the dataset's provided characteristic measurements. We will explore various classification models, both linear and nonlinear, suitable for binary classification and some appropriate for multiple-class classification, for the purpose of comparison.
<!--EVALUATION CRITERIA-->
To evaluate the performance of these models, we will employ Receiver Operating Characteristic (ROC) Curves and the Area Under the Curve (AUC) metric along with sensitivity and specificity. The AUC metric quantifies the degree of separability between classes and their distinguishability. Comparing sensitivity and specificity will help us optimize for false negatives and false positives. Subsequently, the top two models selected from the training dataset models will undergo evaluation using the test dataset. The final choice of the best model will be based on the comparison in a similar fashion.


## UNDERSTANDING THE DATA
<!--FILES IN THE REPOSITORY-->
- **[Diabetes-Prediction-Model.R](https://github.com/anil023/R_Diabetes-Prediction-Model/blob/fd39aeecc75a8d1fda166d1b0c648c6e55619c49/Diabetes-Prediction-Model.R "Link to the File")** : R-code file from the analysis
- **[diabetes.csv](https://github.com/anil023/R_Diabetes-Prediction-Model/blob/fd39aeecc75a8d1fda166d1b0c648c6e55619c49/diabetes.csv "Link to the File")** : raw data file exported from Kaggle
<!--DATA TYPES-->
The raw dataset contains data from 768 patients, comprising 8 predictor variables and one response variable. In our model, the response variable of interest is labeled as Outcome. It is initially presented as a binary numerical variable but is later transformed into a categorical variable during our analysis. In this transformation, a value of 0 signifies the absence of diabetes, while a value of 1 indicates that the patient has diabetes. There are no categorical predictors and eight (8) continuous predictors: 
|PREDICTOR VARIABLES|DESCRIPTION|DATA TYPE|RANGE|
|:--:|:--|:--:|:--:|
Pregnancies|Number of times pregnant|Numeric|[0,17]|
Glucose|Plasma glucose concentration(mmol/L)|Numeric|[0,199]|
BloodPressure|Diastolic Blood Pressure(mm Hg)|Numeric|[0,122]|
SkinThickness|Triceps skin fold thickness(mm)|Numeric|[0,99]|
Insulin|Serum insulin levels(µh/ml)|Numeric|[0,846]|
BMI|Body mass index(kg/m)|Numeric|[0,67.1]|
DiabetesPedigreeFunction|Diabetes pedigree function|Numeric|[0.078,2.42]|
Age|Age(years)|Numeric|[21,81]|
<!--NUMERICAL DATA DISTRIBUTION-->
Numerical Summary:  
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/d9772cc5-99a6-48de-9d1f-87f18a46380b "Numerical Summary of all Variables")  
<!--GRAPHICAL DATA DISTRIBUTION-->
Graphical Summary:
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/de8a5227-185f-42d8-be2d-be310a3eedf9 "Scatter-Plot Matrix")  
Upon observing the scatterplot matrix, we notice a slight positive correlation between [Glucose and Insulin] and [SkinThickness and BMI]. We should investigate this further during the data pre-processing stage.  
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/2d94504d-b05b-4e85-acf5-56ab10a617a2 "Histogram of Predictors")  
It's evident that most variables exhibit a skewed distribution in the histogram plot above. In the next step, we should assess the skewness values and, if necessary, proceed with data transformation to mitigate the skewness.  
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/2164886c-cd16-40be-8d00-54f4bdad3226 "BoxPlot of Predictors")  
We can conclude that the majority of predictors have outliers in the data. To mitigate the impact of these outliers, we will standardize the data during the pre-processing stage.  
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/87bb5d28-23bf-4360-9c29-1de6e4330662 "Response Variable: Class Distributions")  


## DATA PRE-PROCESSING
<!--MISSING VALUES/PREDICTOR REDUCTION-->
In the dataset, there were no missing values; therefore, no imputation or deletion was necessary. Investigating predictors with zero or near-zero variance is a useful procedure to determine whether any predictor should be removed. Since all predictors in this dataset were continuous, there were no predictors with variances close to zero. Another technique to assess the need for predictor reduction is Principal Component Analysis (PCA). After applying PCA to the Pima Indian data, the results revealed that 8 components were needed to explain 95% of the variance. Consequently, no predictors were removed.
<!--SKEWNESS-->
One of the assumptions for the linear relationship models is that predictors have a symmetric distribution. The table below shows the skewness statistics for the original raw dataset:
<!--SKEWNESS TABLE BEFORE TRANSFORMATION
|PREDICTOR VARIABLES|RAW DATA SKEWNESS|
|:--:|:--:|
Pregnancies|0.9|
Glucose|0.17|
BloodPressure|$${\color{red}-1.8}$$|
SkinThickness|0.11|
Insulin|$${\color{red}2.2}$$|
BMI|-0.4|
DiabetesPedigreeFunction|$${\color{red}1.9}$$|
Age|$${\color{red}-1.1}$$|
-->  
|PREDICTOR VARIABLES|RAW DATA SKEWNESS|TRANSFORMED DATA SKEWNESS|
|:--:|:--:|:--:|
Pregnancies|0.9|0.5|
Glucose|0.17|0.2|
BloodPressure|$${\color{red}-1.8}$$|-0.75|
SkinThickness|0.11|-0.14|
Insulin|$${\color{red}2.2}$$|-0.96|
BMI|-0.4|-0.06|
DiabetesPedigreeFunction|$${\color{red}1.9}$$|0.02|
Age|$${\color{red}-1.1}$$|0.01|
<!--SKEWNESS-CORRECTION-->
In the table above, Glucose, Skin Thickness, and BMI exhibit approximate symmetry. Pregnancies, as a predictor, displays moderate symmetry. However, Blood Pressure is significantly skewed to the left, while the remaining three variables are highly skewed to the right. To address this skewness, we applied the Box-Cox transformation method. The skewness values for the transformed data are presented in the table above as well. When comparing the data from the table above with the histogram plots below, it is evident that the distribution is fairly normal, being symmetrical and not skewed.
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/0b1de3f8-3beb-439e-bbc3-0915d18ad3db "Histogram: After Box Cox Transformation")  
<!--OUTLIERS-->
For linear models, outliers could introduce bias into responses and impact the model's performance. In this dataset, almost all predictors had a few outliers; however, Insulin and the pedigree function had the greatest number. Consequently, we used the spatial sign method to remove these outliers. The following figures show box plots after the transformation (please refer above for the box plots before the transformation):
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/a27612e2-d566-4ee9-b310-28790eec0711 "BoxPlot: After Transformation")
<!--CORRELATION-->
Another assumption related to a linear relationship is the absence of multicollinearity. Based on the correlation matrix below, there do not appear to be any highly correlated variables with a threshold set at r=0.85. Hence, no predictors were excluded.
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/1f8b046b-f4aa-48b7-8392-c8b9d8e6bf8c "Correlation Plot")


## MODEL DEVELOPMENT
<!--DATA SPLITTING-->
Splitting a dataset into training and testing sets is a critical step in machine learning to prevent overfitting, assess model performance and make informed decisions about model selection and parameter tuning. After preprocessing the data, we partition the dataset, allocating 80% to the training set and 20% to the testing set. This split resulted in 615 observations in the training set.
<!--RESAMPLING METHODOLOGY-->
Stratified Random Sampling was employed based on the response variable(Outcome) because the distribution among the classes in the response variable is imbalanced (as shown below). The training set plot below illustrates that the classes have a similar distribution to the full dataset. Given the small sample size, the choice of 'leave-group-out' cross-validation was made to mitigate bias and maintain low variance.
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/32ae8533-6d78-4c0d-b71d-bbca58c5b711 "Full vs Training Dataset: Class Distribution")    
<!--TRAINING MODELS--> 
Each of the machine learning/statistical models has its strengths and weaknesses, making them suitable for different types of problems and datasets. The choice of model depends on the specific problem, namely the nature of the data, the desired trade-offs between factors like interpretability, accuracy, and computational complexity. We will train several models on the training dataset and compare them on the basis of ROC and few other metrics:  
- **Logistic Regression (Logistic)**: Logistic regression is a powerful statistical model used for binary classification. It is computationally efficient and the model coefficients are interpretable. It'll be suitable for our dataset as it's pre-processed to remove outliers and doesn't have high correlation among variables. 
- **Linear Discriminant Analysis (LDA)**: LDA is a dimensionality reduction and classification model used for binary classification and is interpretable. It finds linear combinations of features that best separate different classes while preserving as much variance as possible within each class.
- **Partial Least Squares Discriminant Analysis (PLSDA)**: PLSDA is also a dimensionality reduction supervised model used for classification and regression. It combines features into linear combinations to maximize the covariance between classes and the features. The model requires parameter tuning: number of variables to use.
- **Penalized Generalized Linear Model (Penalized GLM)**: This is a statistical model which extends traditional GLM models by adding penalties to the loss function to control model complexity. The penalty terms help with variable selection, prevents overfitting and helps handling multicollinearity. Tuning parameter process is more complex for the model and assumes linear relationship between predictors and response variable.
- **Mixture Discriminant Analysis (MDA)**: MDA is an extension of LDA that can handle multiple classes. Its a reliable and interpretable statistical model that achieves dimensional reduction and variable selection optimaly. But these models need large datasets and are computationally intensive.
- **Neural Network (NN)**: NN are powerful tools for two-class classification tasks due to their ability to model complex relationships and learn features from data. However, models with multiple layers are computationally expensive and need substatntial amount of data and may lack interpretability.
- **Flexible Discriminant Analysis (FDA)**: FDA finds a linear combination of the original variables such that the variance between the classes is maximized while the variance within each class is minimized. The model is interpretable and also helps noise reduction through dimensionality reduction. It is sensitive to outliers, non-linear relationships in the data and assumes gaussian distribbution within each class.
- **Support Vector Machine (SVM)**: SVM is a powerful supervised machine learning model for classification and regression that seeks to find an optimal hyperplane that maximizes the margin between two classes in the feature space. It is robust to outliers, non-linear and high dimesnional data. The model is sensitive to parameter tuning and computationally intensive hence not suitable for large datasets.
- **k-Nearest Neighbors (k-NN)**: k-NN is a machine learning model for classification and regression tasks; it finds the k nearest data points(neighbors) to a given data point in the feature space and then making a prediction based on the majority class of those k neighbors. It's a simple, adaptable, versatile and interpretable model but computationally complex, sensitive to high dimensional and noisy data and imbalance in the classes.
- **Naive Bayes**: Naive Bayes is a probabilistic machine learning classification model based on Bayes' theorem. It assumes that the presence or absence of a particular feature is unrelated to the presence or absence of any other feature, given the class label. It's a simple and computationally efficient, interpretable model. It is sensitive to imbalanced data within classes, continuos data, scaling of the data.  
<!--TRAINING MODEL COMPARISON-->
Training Model Comparison:
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/a18e1d0d-f0d7-48ef-99da-183e2d3802d8 "Training: ROC Curve Comparison")
<!--TABLE: TRAINING MODEL COMPARISON-->
|MODEL|SENSITIVITY(in%)|SPECIFICITY(in%)|AUC(in%)|ACCURACY(in%)|
|:--:|:--:|:--:|:--:|:--:|
LOGISTIC|86|60.9|83.6|77.3|
**$${\color{lime}LDA}$$**|85.2|64.5|84.2|78.1|
PLSDA|84.9|62|83|77|
PENALIZED GLM|86.3|60.2|38.7|77.2|
MDA|81.9|66.9|83.1|76.7|
NEURAL NETWORK|86.2|60.1|79.3|77.2|
FDA|83.8|66.2|82.6|77.7|
SVM|84.3|60.7|81.7|76.1|
KNN|84.5|61.7|80.6|76.6|
NAIVE BAYES|77.9|74.4|82.9|76.7|  
<!--ANALYSIS-->
We will compare the various models based on ROC curves and a few other metrics. For this problem, we would like to optimize both false positives and false negatives. Comparing the ROC plots for all the models in conjunction with sensitivity, specificity, and AUC metrics proves that the LDA and Logistic models are the best-performing training models. Penalized GLM and Neural Network models achieve the highest sensitivity levels but also have about a 10% lower specificity among the models, thus increasing the chances of false positives. 
<!--TESTING MODEL COMPARISON-->
Testing Model Comparison:
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/8337828a-6de7-4d54-a917-8b80b2f0aaa0 "Testing: ROC Curve Comparison")
<!--TABLE: TESTING MODEL COMPARISON-->
|MODEL|SENSITIVITY(in%)|SPECIFICITY(in%)|AUC(in%)|ACCURACY(in%)|
|:--:|:--:|:--:|:--:|:--:|
**$${\color{lime}LOGISTIC}$$**|62.3|87|80.6|78.4|
LDA|62.3|84|81.2|76.5|
<!--ANALYSIS-->
We will compare the performance of the logistic and LDA models on the test set based on ROC curves and a few other metrics, similar to the evaluation of the training set models. Since both sensitivity and AUC metrics are similar between the two models, we conclude that the Logistic Regression model is the better choice, as it provides higher specificity and, therefore, predicts with fewer false positives.. 


## SUMMARY
The final model chosen was the Logistic Regression Model, with an accuracy rate of 78.4%, sensitivity of 62.3%, and specificity of 87%. We should understand that due to the relatively low sensitivity, the model is prone to producing many false negatives, an outcome that should be avoided. On the other hand, the specificity is considerably higher, which means the model would produce fewer false positive results, aligning with one of the goals of a useful model.

![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/69420f12-92d9-4188-97aa-665ebf98a940 "Imprtant Variables")

Predicting the onset of gestational diabetes among Pima women, who have historically been the most susceptible, is of immense significance. Since at a minimum, BMI and glucose levels can be controlled, preventive measures such as nutrition and weight counseling can be widely implemented among the population to prevent future high-risk pregnancies.

---

THANKS  
Anil Raju  
[LinkedIn](https://www.linkedin.com/in/rajuanil/)



