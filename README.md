# Titanic Survival Prediction — Python and R

This repository provides Python and R implementations of logistic regression to predict passenger survival in the Titanic disaster. Both implementations explore the data, preprocess features, train a model, and print training accuracy and test-passenger predictions in the terminal.

Here, Docker provides the required Python and R environments, so you do not need to install Python, R, or their packages locally.

## 1. Prerequisites

Before starting, install:

- **Git:** https://git-scm.com/downloads
- **Docker Desktop:** https://www.docker.com/products/docker-desktop/

You also need a free **Kaggle account** to download the dataset.

Start Docker Desktop and wait until the Docker engine is running. You can check that Docker is ready by opening a terminal and running:

```sh
docker info
```

The commands below are intended for macOS, Linux, or Windows using WSL with Docker integration enabled.

## 2. Clone the Repository

Open a terminal and run:

```sh
git clone https://github.com/zhenglin0619/titanic-disaster.git
cd titanic-disaster
```

Run all remaining commands from this repository’s root directory, where contains `README.md`.

## 3. Download the Titanic Dataset

The dataset is not included in this repository.

1. Open the [Titanic - Machine Learning from Disaster](https://www.kaggle.com/competitions/titanic/data) Page.
2. Sign in to your Kaggle account.
3. Click **Download All**.
4. Extract the downloaded ZIP file.
5. Create a data directory inside the cloned repository:

```sh
mkdir -p src/data
```

6. Copy the extracted `train.csv` and `test.csv` files into `src/data/`.

Keep the original filenames and column names. The example file `gender_submission.csv` is not required.

Your directory should now look like this:

```text
titanic-disaster/
├── README.md
├── .gitignore
├── requirements.txt
└── src/
    ├── data/
    │   ├── train.csv
    │   └── test.csv
    ├── python/
    │   ├── Dockerfile
    │   └── main.py
    └── r/
        ├── Dockerfile
        ├── install_packages.R
        └── main.R
```

The original Titanic datasets contain:

| File | Rows | Purpose |
| --- | ---: | --- |
| `train.csv` | 891 | Labeled passengers used to train and evaluate the model |
| `test.csv` | 418 | Passengers whose survival outcomes must be predicted |

The training file includes the target column `Survived`:

- `0`: passenger did not survive.
- `1`: passenger survived.

## 4. Build and Run the Python Container

Make sure Docker Desktop is running and both CSV files are in `src/data/`.

Build the Python image:

```sh
docker build -f src/python/Dockerfile -t titanic-python .
```

The Dockerfile uses Python 3.11 and installs the packages specified in `requirements.txt`:

```text
numpy==2.2.6
pandas==2.2.3
scikit-learn==1.6.1
```

Once the build finishes, run:

```sh
docker run titanic-python
```

The program runs automatically and prints its results in the terminal.

## 5. Build and Run the R Container

From the same repository directory, build the R image:

```sh
docker build -f src/r/Dockerfile -t titanic-r .
```

The Dockerfile uses R 4.4.3. During the build, `install_packages.R` checks that the required `stats` and `utils` packages are available. These packages are bundled with R, so no additional R packages need to be downloaded.

Once the build finishes, run:

```sh
docker run titanic-r
```

The R program runs automatically and prints its results in the terminal.

**Note:** The first build of either image may take several minutes because Docker must download the base image and install or verify dependencies, and later builds can reuse cached layers.

## 6. What the Programs Do

Both implementations follow the same workflow:

1. Load `train.csv` and check its dimensions.
2. Print the overall survival rate and survival rates by sex and passenger class.
3. Select features and print their missing-value counts.
4. Replace missing numerical values with training-data medians.
5. Standardize numerical features.
6. Replace missing categorical values with training-data modes and encode the categories.
7. Train logistic regression using all labeled training rows.
8. Predict survival on the training set and print training accuracy.
9. Load `test.csv` and apply preprocessing learned from the training data.
10. Print a survival prediction for every test passenger and the total predicted survivors and non-survivors.

Both models use these features:

| Feature | Description |
| --- | --- |
| `Pclass` | Passenger ticket class |
| `Sex` | Recorded passenger sex |
| `Age` | Passenger age |
| `SibSp` | Number of siblings or spouses aboard |
| `Parch` | Number of parents or children aboard |
| `Fare` | Ticket fare |
| `Embarked` | Port of embarkation |

## 7. Data Handling and Rebuilding

The current Dockerfiles copy the local CSV files into their respective images during the build. Therefore:

- Download and place the data before building either image.
- Rebuild the relevant image after changing its script or the CSV files.
- Keep `src/data/` available to Docker’s build context. If you add a `.dockerignore`, do not exclude this directory while using the current Dockerfiles.

## 8. Troubleshooting

### Docker cannot connect to the engine

Open Docker Desktop and wait for the engine to start, then retry:

```sh
docker info
```

### Docker cannot find `requirements.txt` or a Dockerfile

Make sure your terminal is in the repository root:

```sh
pwd
ls
```

You should see `README.md`, `requirements.txt`, and `src`.

### Docker cannot copy `src/data`

Confirm that both files exist:

```sh
ls src/data
```

The directory must contain:

```text
train.csv
test.csv
```

### Changes do not appear when running the container

Rebuild the image after modifying the script or data:

```sh
docker build -f src/python/Dockerfile -t titanic-python .
docker build -f src/r/Dockerfile -t titanic-r .
```

Then run the relevant container again:

```sh
docker run --rm titanic-python
docker run --rm titanic-r
```
