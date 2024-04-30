# Symbolic Integration Algorithm Selection with Machine Learning: LSTMs vs Tree LSTMs

Deep Graph Library and Pytorch implementation of the paper [Symbolic Integration Algorithm Selection with Machine Learning: LSTMs vs Tree LSTMs](https://arxiv.org/abs/2404.14973).

## Dataset
The `Dataset` folder contains both train and test data for the five different data generators described in the paper. The data is in JSON format and can be read with the `parse` function in Maple or the `sympify` function in the Python library SymPy. Each data point is in the format `[integrand, integrand_prefix, integral, DAG sizes]`. The integrand_prefix entry is the prefix notation of the integrand (useful for constructing the tree form of the data as well as use in the LSTM) and DAG sizes is a list of each DAG size from all successful algorithms (-1 means the algorithm failed). An example of one entry from the dataset: `[
    "1/5/(2+x)", 
    [
      "mul",
      "div",
      "INT+",
      "1",
      "INT+",
      "5",
      "pow",
      "add",
      "INT+",
      "2",
      "x",
      "INT-",
      "1"
    ],
    "1/5*ln(1+1/2*x)",
    [
      60,
      -1,
      -1,
      60,
      60,
      -1,
      60,
      63,
      -1,
      -1,
      -1,
      -1
    ]`.

The DAG sizes correspond to the following order: "default", "derivativedivides", "parts", "risch", "norman", "trager", "parallelrisch", "meijerg", "elliptic", "pseudoelliptic", "lookup", "gosper". To see these sub-methods that `int` calls in Maple, see the [help page](https://www.maplesoft.com/support/help/maple/view.aspx?path=int%2fmethods). The DAG sizes were acquired by taking the integrand, running the integrand through Maple's `int` command with each available method, and then recording the DAG size of the output.

## Dependencies
See the file `TreeLSTM_DGL.yml` to view all dependencies and create a conda environment with this yml file. In general, these are the main dependencies:
- Python 3.10
- PyTorch
- Tensorflow
- Deep Graph Library
- Pandas
- Swifter

## Training and Models
To train your own model, follow the steps in the Tree-LSTM classification notebook. The guide will get you to train a binary classifier for each of the sub-algorithms which predicts whether that sub-algorithm would output the shortest DAG size or not. There are two main outputs from the notebook: the models which are saved in the `Models` folder, and a probability vector that outputs the probability that the sub-algorithm should be used (stored in `Probabilities`). The probabilities are the important output from the predictions as they are used to rank which algorithm to use. 

## Model Evaluation
The file `Results_test_set.mw` contains Maple code to compare the outputs of the TreeLSTM, LSTM, and Maple's meta-algorithm. The answers are compared by taking the DAG size from each of the three models. These outputs are all loaded from the `Results` folder. This folder was generated by taking the probability vectors in the `Probabilities` folder and then getting the answer from the sub-algorithm with the highest probability. 
