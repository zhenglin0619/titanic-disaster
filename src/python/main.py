import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

# Load the training data from the CSV file
print("Question 13: Load the training data")
train = pd.read_csv("src/data/train.csv")
print(f"train.csv contains {train.shape[0]} rows, {train.shape[1]} columns")


# Explore the training data to understand its structure and missing values
print("\nQuestion 14: Explore and prepare the data")
print(f"Training survival rate: {train['Survived'].mean():.4f}")
print("\nSurvival rate by sex:\n", train.groupby("Sex")["Survived"].mean())
print("\nSurvival rate by passenger class:\n", train.groupby("Pclass")["Survived"].mean())

# Select features for the model and prepare the data for training
features = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked"]
X = train[features]
y = train["Survived"]
print("\nSelected features:", features)
print("\nMissing values before preprocessing:\n", X.isna().sum())

# Define preprocessing pipelines for numeric and categorical features
numeric_features = ["Age", "SibSp", "Parch", "Fare"]
categorical_features = ["Pclass", "Sex", "Embarked"]
numeric = Pipeline([
    ("impute", SimpleImputer(strategy="median")),
    ("scale", StandardScaler()),
])
categorical = Pipeline([
    ("impute", SimpleImputer(strategy="most_frequent")),
    ("encode", OneHotEncoder(handle_unknown="ignore")),
])
preprocessor = ColumnTransformer([
    ("numeric", numeric, numeric_features),
    ("categorical", categorical, categorical_features),
])
print("\nNumeric changes: replace missing values with training-data medians, then standardize.")
print("Categorical changes: replace missing values with training-data modes, then one-hot encode.")


# Build and fit a logistic regression model using the preprocessing pipeline
print("\nQuestion 15: Build a logistic regression model")
model = Pipeline([
    ("prepare", preprocessor),
    ("model", LogisticRegression(max_iter=2000, random_state=42)),
])
model.fit(X, y)
print("Fitted preprocessing and logistic regression on all training rows.")


# Measure accuracy on the same training data used to fit the model
print("\nQuestion 16: Measure training accuracy")
train_predictions = model.predict(X)
print(f"Training accuracy: {accuracy_score(y, train_predictions):.4f}")


# Load the test data and make predictions using the trained model
print("\nQuestion 17: Load test.csv and predict survival")
test = pd.read_csv("src/data/test.csv")
print(f"test.csv contains {test.shape[0]} rows, {test.shape[1]} columns")

# Make predictions on the test set using the trained model
predictions = model.predict(test[features])
print("\nTest passenger predictions:")
print(pd.DataFrame({
    "PassengerId": test["PassengerId"],
    "PredictedSurvived": predictions,
}).to_string(index=False))
print(f"Predicted survivors: {(predictions == 1).sum()}")
print(f"Predicted non-survivors: {(predictions == 0).sum()}")
