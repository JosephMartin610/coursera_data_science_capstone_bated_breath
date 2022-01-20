Bated Breath Next Word Generator App
========================================================
author: Joseph P. Martin
date: May 2, 2021
autosize: true
font-family: 'Helvetica'
css: custom.css

Inside the App: N-Gram Model Development and Algorithm
========================================================
- Used random subset of blogs, news, and tweet items (350,000 items) to build a catalog of n-grams (sentence fragment of n words; n = 1:5) and their occurrence counts.
- To implement n-gram model, need to make choice about how to shift counts of observed n-grams to unobserved n-grams. The Simple Good-Turing discounting method is used. Benefits include: defines free model parameters and can be applied before running model.
- The model is of type n-gram with Katz's back-off. The key to getting the model to work well is recursion, that is, calling the model function inside itself on successively smaller n-grams (first word dropped each time in back-off).
- Example: Submit "actually tasted like sweet" to 5-gram model. Finds any 5-grams with "actually tasted like sweet \*" and their probabilities. Next finds any 4-grams with "tasted like sweet \*" and scales that probability, etc., down to unigrams.

Testing
========================================================
- The model was tested for top n-gram levels of 2, 3, 4, and 5 on 100 5-grams that were not used to develop the model:

|Top N-Gram Level | % Predicted Correctly | Mean Perplexity|
|:--------------: | --------------------: | --------------:|
|2                |                     9 |           3.634|
|3                |                    20 |           2.098|
|4                |                    18 |           1.724|
|5                |                    15 |           1.550|

- The percentage of words predicted correctly appears to stabilize at the trigram or 4-gram model. The n-gram model with Katz's back-off and Good-Turing discounting can only ever achieve limited predictive success. There would be gains from adding more n-grams to the catalogs, but with expected diminishing returns, and at a cost of larger memory use and slower speed for the model.
- Perplexity decreases with the top n-gram level, and lower perplexity is considered more desirable. More testing would be needed to see if this result continues with higher n-gram levels.
- As a trade-off among accuracy, speed, and memory use on the app server, the 4-gram model was selected. 

Example #1
========================================================
- Note that the app instructions are built into the app. After submitting text, the user can decide on a word.
- Because the model can only be so successful, we have to give the user options for predicted words. Even the much more advanced text predictions in the iPhone or Google search box provide options. There are many more words beyond the 30 accessible that have small probabilities, but if they are that far down the list, the model is not really predicting them.

![Alt text](example_1.png)

Example #2
========================================================
![Alt text](example_2.png)


