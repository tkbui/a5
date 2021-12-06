#!/bin/bash

# Name: T.K. Bui
# Date: 12/5/2021
# Script Description:
# This is a shell script to train a ML model using weka by using helpful
# and unhelpful reviews from the amazon file.

# NOTE: this program assumes that you have the REVIEWS and REVIEWS_UNHELPFUL
# folders with the necessary files/reviews in them, and that these folders
# exist in the second absolute path that is inputted into this script.

# Input:
# 1) absolute path to your weka installation
# 2) absolute path to directory with the classes and files to train upon

# Instructions:
# while in the directory that the script text_binary_classify.sh exists,
# enter "./text_binary_classify.sh input1 input2" where input1 and input2
# are the absolute paths described above.

if [ $# -lt 2 ]; # ensure that the needed input values were passed in
then
 echo "Too few arguments were passed. Please pass in 1)" \
 "the absolute path to your weka installation, and 2) the absolute path to the" \
 "directory with the classes and files to train upon.";
elif [ ! -d "$1" ] || [ ! -d "$2" ]; # one of the paths isn't valid, so return error message
then
 echo "One of the absolute paths inputted is not valid.";
else # the paths are valid, so execute the rest of the script

 # 1) ensure that weka is added to the classpath
 export CLASSPATH=$CLASSPATH:$1/weka.jar:$1/libsvm.jar

 # 2) create the text_example folder, populate it with 2 subdirectories, and
 # populate each subdirectory with reviews or unhelpful reviews.
 # then, convert this entire directory and its files to an .arff file.

 if [ -d "$2/text_example" ]; # remove text_example directory if it exists
 then
  rm -r "$2/text_example"
 fi

 # make the directories that will become the .arff file later
 mkdir "$2/text_example"
 mkdir "$2/text_example/helpful_reviews"
 mkdir "$2/text_example/unhelpful_reviews"

 # copy all helpful and unhelpful reviews into their respective
 # directories in text_example
 for i in `ls "$2/REVIEWS"`; do cp "$2/REVIEWS/$i" "$2/text_example/helpful_reviews" ; done
 for i in `ls "$2/REVIEWS_UNHELPFUL"`; do cp "$2/REVIEWS_UNHELPFUL/$i" "$2/text_example/unhelpful_reviews" ; done

 # convert the text files to an .arff file
 java weka.core.converters.TextDirectoryLoader -dir "$2/text_example" > "$2/text_example.arff"

 # convert the new .arff file to a word vector
 java -Xmx1024m weka.filters.unsupervised.attribute.StringToWordVector -i "$2/text_example.arff" -o "$2/text_example_training.arff" -M 2

 # run the following Weka classifier
 java -Xmx1024m  weka.classifiers.meta.ClassificationViaRegression -W weka.classifiers.trees.M5P -num-decimal-places 4 -t "$2/text_example_training.arff" -d "$2/text_example_training.model" -c 1

fi
