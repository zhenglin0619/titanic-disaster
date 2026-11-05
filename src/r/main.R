# Load the training data from the CSV file.
cat("Question 13: Load the training data\n")
train <- read.csv("src/data/train.csv", stringsAsFactors = FALSE,
                  na.strings = c("", "NA"))
cat(sprintf("train.csv contains %d rows, %d columns\n", nrow(train), ncol(train)))


# Explore the training data and summarize survival rates.
cat("\nQuestion 14: Explore and prepare the data\n")
cat(sprintf("Training survival rate: %.4f\n", mean(train$Survived)))

cat("\nSurvival rate by sex:\n")
print(aggregate(Survived ~ Sex, data = train, FUN = mean))

cat("\nSurvival rate by passenger class:\n")
print(aggregate(Survived ~ Pclass, data = train, FUN = mean))


# Use the same features as the Python implementation.
features <- c("Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked")
numeric_features <- c("Age", "SibSp", "Parch", "Fare")
categorical_features <- c("Pclass", "Sex", "Embarked")

X <- train[features]
y <- train$Survived

cat("\nSelected features:", paste(features, collapse = ", "), "\n")
cat("\nMissing values before preprocessing:\n")
print(colSums(is.na(X)))


# Store preprocessing values learned from the training data.
numeric_medians <- list()
numeric_means <- list()
numeric_sds <- list()
categorical_modes <- list()
categorical_levels <- list()

# Replace missing numeric values with training medians,
# then standardize using the training means and standard deviations.
for (feature in numeric_features) {
  numeric_medians[[feature]] <- median(X[[feature]], na.rm = TRUE)
  
  X[[feature]][is.na(X[[feature]])] <- numeric_medians[[feature]]
  
  numeric_means[[feature]] <- mean(X[[feature]])
  numeric_sds[[feature]] <- sd(X[[feature]])
  
  # Avoid division by zero if a numeric feature is constant.
  if (numeric_sds[[feature]] == 0) {
    numeric_sds[[feature]] <- 1
  }
  
  X[[feature]] <- (X[[feature]] - numeric_means[[feature]]) / numeric_sds[[feature]]
}

# Replace missing categorical values with training modes.
# Factors allow glm() to encode categories as indicator variables.
for (feature in categorical_features) {
  values <- as.character(X[[feature]])
  counts <- table(values)
  categorical_modes[[feature]] <- names(counts)[which.max(counts)]
  
  values[is.na(values)] <- categorical_modes[[feature]]
  X[[feature]] <- factor(values)
  
  categorical_levels[[feature]] <- levels(X[[feature]])
}

cat("\nNumeric changes: replace missing values with training-data medians, then standardize.\n")
cat("Categorical changes: replace missing values with training-data modes, then convert to factors.\n")
cat("\nMissing values after preprocessing:\n")
print(colSums(is.na(X)))


# Fit logistic regression using all labeled training rows.
# family = binomial() specifies logistic regression for a binary outcome.
cat("\nQuestion 15: Build a logistic regression model\n")

training_data <- X
training_data$Survived <- y

model <- glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
             data = training_data, family = binomial())

cat("Fitted preprocessing and logistic regression on all training rows.\n")


# Predict survival probabilities and convert them to binary labels.
# A probability of at least 0.5 is classified as survived.
cat("\nQuestion 16: Measure training accuracy\n")

train_probabilities <- predict(model, newdata = training_data, type = "response")
train_predictions <- as.integer(train_probabilities >= 0.5)

training_accuracy <- mean(train_predictions == y)
cat(sprintf("Training accuracy: %.4f\n", training_accuracy))


# Load the test data.
cat("\nQuestion 17: Load test.csv and predict survival\n")

test <- read.csv("src/data/test.csv", stringsAsFactors = FALSE, 
                 na.strings = c("", "NA"))
cat(sprintf("test.csv contains %d rows, %d columns\n", nrow(test), ncol(test)))

X_test <- test[features]

# Apply the numeric preprocessing values learned from training.
for (feature in numeric_features) {
  X_test[[feature]][is.na(X_test[[feature]])] <-
    numeric_medians[[feature]]
  
  X_test[[feature]] <- (X_test[[feature]] - numeric_means[[feature]]) / numeric_sds[[feature]]
}

# Use the same categorical levels as training.
# Replace missing or unseen categories with the training mode.
for (feature in categorical_features) {
  values <- as.character(X_test[[feature]])
  
  replace <- is.na(values) |
    !(values %in% categorical_levels[[feature]])
  
  values[replace] <- categorical_modes[[feature]]
  
  X_test[[feature]] <- factor(values, levels = categorical_levels[[feature]])
}

# Predict survival for every test passenger.
test_probabilities <- predict(model, newdata = X_test, type = "response")
predictions <- as.integer(test_probabilities >= 0.5)

cat("\nTest passenger predictions:\n")
print(data.frame(PassengerId = test$PassengerId, PredictedSurvived = predictions),
      row.names = FALSE, max = 2 * nrow(test))

cat(sprintf("Predicted survivors: %d\n", sum(predictions == 1)))
cat(sprintf("Predicted non-survivors: %d\n", sum(predictions == 0)))

