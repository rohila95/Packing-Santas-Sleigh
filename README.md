Solution to Packing Santa's sleigh problem (Kaggle). 
Please find the problem description [here](https://www.kaggle.com/c/packing-santas-sleigh#description)  

We are told that the evaluation is done using two metrics:  
1. Compactness of packing and  
2. Ordering sequence of presents

If we carefully look at the metric used for evaluation, one conclusion can be easily drawn which is that the order  
metric has more weight towards the overall metric than the height as the height metric is just twice the  
maximum height of sleigh whereas the order metric is the sum of absolute difference in the order of each present  
and the position of that in the sleigh.

### Naive solution
The idea here is to pack the presents in reverse order from the top to bottom. While doing that we don't care for the  
space that is being created between two layers. First we fill the presents in X direction, then go to Y direction in the  
same plane and when a layer is completely occupied, we try to form a new layer starting at the top of the heighest present 
in the previous layer.

As the order of presents is not disturbed during this process, the order metric would be 0.

Order metric: 0  
Height metric: 5270836

**Overall metric(M) = 5,270,836**

### Rotation of presents
The next easy idea to decrease the overall height without changing the order would be rotating the presents so that the higher 
dimension of present would be parallel to Z axis (height dimension). This is because we are increasing the number of presents in 
the same layer by decreasing the area of presents in XY plane. Also uniform length, width and height are acheived by doing following 
this method. As this is also a basic improvement on the naive method, we don't expect the score to decrease a lot. But to our surprise
the metric was reduced a lot more than what we have imagined.

Order metric: 0  
Height metric: 3,636,298

**Overall metric(M) = 3,636,298**
## Using bin packing and shelf algorithms
#### A. Best Width Fit

Shelf Best Width Fit(SHELF-BWF) algorithm finds the best empty area in a layer which fits the present under consideration that leaves 
minimum amount of remaining width. 

#### B. Best Area Fit
While the best width fit attempts to optimize the width left behind, Best Area Fit(SHELF-BAF) chooses the empty area that minimizes the 
area left behind after placing the present.

*The basic idea of shelf algorithms is taken from [here](http://blog.roomanna.com/09-25-2015/binpacking-shelf)*

### Results

| Algorithm Implemented        | Metric Score  | Rank  |
|:----------------------------:|:-------------:|:-----:|
| Naive                        | 5,270,836     | 281   |
| Rotation Only                | 3,636,298     | 243   |
| Rotation + Best Width Fit    | 3,607,058     | 225   |
| Rotation + Best Area Fit     | 3,519,486     | 211   |

