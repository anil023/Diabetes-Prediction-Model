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
To evaluate the performance of these models, we will employ Receiver Operating Characteristic (ROC) Curves and the Area Under the Curve (AUC) metric. The AUC metric quantifies the degree of separability between classes and their distinguishability. Subsequently, the top two models selected from this training dataset comparison will undergo evaluation using the test set. The final choice of the best model will be based on the comparison of AUC metrics.


## UNDERSTANDING THE DATA
<!--FILES IN THE REPOSITORY-->
- **[Diabetes-Prediction-Model.R](https://github.com/anil023/R_Diabetes-Prediction-Model/blob/fd39aeecc75a8d1fda166d1b0c648c6e55619c49/Diabetes-Prediction-Model.R "Link to the File")** : R-code file from the analysis
- **[Diabetes-Prediction-Model.pdf](https://github.com/anil023/R_Diabetes-Prediction-Model/blob/fd39aeecc75a8d1fda166d1b0c648c6e55619c49/Diabetes-Prediction-Model.pdf "Link to the File")** : report for the analysis
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
<!--DATA DISTRIBUTION-->
Numerical Summary:
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/d9772cc5-99a6-48de-9d1f-87f18a46380b "Numerical Summary of all Variables")  
Visual Summary:
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
One of the assumptions of a linear relationship is that predictors have a symmetric distribution. The table below shows the skewness statistics for the original raw dataset:
<!--
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


<!--
## EDA
      SUMMARIZE
      BETTER UNDERSTANDING OF THE DATA
      UNCOVER RELATIONSHIPS BETWEEN VARIABLES
      EXTRACT VARIABLES
-->
## MODEL DEVELOPMENT
<!--DATA SPLITTING-->
After preprocessing the data, we partition the dataset, allocating 80% to the training set and 20% to the testing set. This split resulted in 615 observations in the training set.
<!--RESAMPLING METHODOLOGY-->
Stratified Random Sampling was employed based on the response variable(Outcome) because the distribution among the classes in the response variable is imbalanced (as shown below). The training set plot below illustrates that the classes have a similar distribution to the full dataset. Given the small sample size, the choice of 'leave-group-out' cross-validation was made to mitigate bias and maintain low variance.
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/32ae8533-6d78-4c0d-b71d-bbca58c5b711 "Full vs Training Dataset: Class Distribution")    
Training Set Evaluation:

       
       
       
       MODEL
       MODEL EVALUATION - VISUALIZATION
       R2 AND MSE FOR EVALUATION
       PREDICTION AND DECISION MAKING

<!---->
![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/9f2319ca-d04c-475c-8a46-172943e3cc42 "Training: ROC Curve Comparison")

![image](https://github.com/anil023/R_Diabetes-Prediction-Model/assets/19195341/8337828a-6de7-4d54-a917-8b80b2f0aaa0 "Testing: ROC Curve Comparison")

