# High Performance Data Slicing in R

#### Motivation
I spent several years exploring and building models of empirical consumer behavior data alongside economists and statisticians. Most of this work was in the statistical analysis software [Stata](http://www.stata.com/).

For the past couple years, I helped teach an introductory class to new Stata users who were quantitatively savvy, but had little programming experience. I found the process of teaching to be a great vehicle for extending my own knowledge: discovering new ways to leverage the language's characteristics and build a better intuition for analyzing data efficiently (both in terms of writing concise code as well as parsimonious use of computational resources).

I want to learn R because of its broad popularity and deeper extensibility, so I'm writing this guide for my own edification and future reference. It will lean heavily on Hadley Wickham's [Advanced R](http://adv-r.had.co.nz/) for both structure and content.

I assume the user has already installed R and is using the IDE [RStudio](https://www.rstudio.com/).

#### Note on Data
To try to make this a bit more lively, I'll be loading and analyzing real data once I get through the data structures examples. Specifically, I'll be looking at the US Department of Education's College Scorecard data as I go through the tutorial. My hope is that this makes the concepts feel more concrete than purely contrived examples. The full data can be downloaded [here](https://collegescorecard.ed.gov/data/). I'll specifically be working with the 2013 data file ("MERGED2012_PP.csv"). I.e., once downloaded I load ```data <- read.csv("MERGED2013_PP.csv", header=TRUE)```.

## 1. Fundamentals
## Data structures
There are five data types that are most often used in R analysis. These are either used directly or are the foundations upon which other objects are built. They differ in their dimensionality and whether or not all of their contents must be of the same type (e.g., homogenous vs. heterogeneous).

|       | Homogeneous   | Heterogeneous|
| :---: |:-------------:| :-----------:|
| 1D    | Atomic Vector | List         |
| 2D    | Matrix        | Data Frame   |
| nD    | Array         |              |

You can check an object's type with ``` str([object]) ```.

### Vectors
Vectors are the basic data type in R. There are two types of vectors: those that require all elements to be of the same type (atomic vectors) and those that can hold multiple types (lists).

Both have a few key properties:
+ ```typeof()``` tells what kind of elements are inside of a homogenous atomic vector, or identifies a list
+ ```length()``` gives the number of elements in the vector
+ ```attributes()``` gives metadata on the vector
+ ```is.atomic()``` and ```is.list()``` return true if passed the expected object

#### Atomic Vectors
There are four common data types atomic vectors:
```{r}
# Doubles are non-int numerics
double_atomic <- c(10.0, 2, 1)

# Int numeric, denoted with L suffix after value
int_atomic <- c(1L, 2L, 3L)
int_atomic_alt <- 1:6

# Logicals take on either True (T) or False (F)
logical_atomic <- (TRUE, T, FALSE, F)

# Characters
char_atomic <- c("a", "c")
```
Note assignment is done with ```<-``` and not ```=```. The latter will often work, but the reasons why it breaks can often be complicated rules related to compatibility with old versions of S, scope differences in the declaration, or parsing rules. [Here's some short intuition](https://stackoverflow.com/questions/1741820/assignment-operators-in-r-and).

Missing values are specified with the logical vector ```NA``` which will be coerced to the appropriate type if used inside a vector of a different type.

###### Testing
Functions ```is.character()```, ```is.double()```, ```is.integer()```, and ```is.logical()``` allow you to test the vectors.

Note that both doubles and integers return true for ```is.numeric()```.

###### Coercion
R has a natural order of least to most flexible types of atomic vectors. If you try to combine them, they will be coerced to the least flexible necessary. From least to most flexible, these are: logical, integer, double, and character.

For example:
```{r}
male <- c(T, F, T, T,  F)

mean(male)
#> [1] 0.6
```
Most R math functions will attempt to coerce automatically. Use ```as.character()```, ```as.double()```, ```as.integer()```, or ```as.logical``` to explicitly coerce values

Note there are two other types of infrequently used atomic vectors: complex and raw.

#### Lists
Lists can hold multiple types of data (including other lists).
```{r}
x <- list("abc", c(F, F, T), 0:5)
# creates a list of three vectors, each of a different type of attributes
```

A ```c()``` will combine a passed combination of vectors and lists into a single list.

###### Testing and coercion

Similar to atomic vectors, ```is.list()``` tests if an object's type and ```as.list()``` coerces it.

Lists are a frequent building block of more complicated structures in R (e.g., data frames and linear models).

### Matricies and Arrays
A matrix in R is an two dimensional atomic vector. Arrays of higher dimensions are possible, though used much less frequently. Dimensions are defined in the ```dim()``` attribute. Matricies and arrays in R are stored in [column-major order](https://en.wikipedia.org/wiki/Row-major_order#Column-major_order).

```{r}
# Define a 5x2 matrix with 1-5 in first column and 6-10 in second
X <- matrix(1:10, ncol=2, nrow=5)

# Define 2x2x2 array
Y <- array(1:8, c(2, 2, 2))

# If it's not referenced elsewhere, you can modify a vector in place by adding dim() to it
z <- 1:4
dim(z) <- c(2,2)
```

Functions ```rownames()``` and ```colnames()``` allow you to name rows and columns using vectors of strings.

###### Testing
The number of cells in an array can be found with ```length()```. ```nrow()```, and ```ncol()``` give the row and columns counts respectively.

Object's type can be tested with ```is.matrix()``` and ```is.array()```.


###### Coercion
Using ```as.matrix()``` and ```as.array()``` turn a vector or list into a matrix or array. It's most common to see vectors coerced.

Note you can have single dimension matricies or arrays that print similarly to vectors but behave differently.

### Data Frames
Data frames are one of the most common ways to store data in R. Functionally, they are lists of vectors of equal length. Therefore, it has two dimensions.

```{r}
dataframe <- data.frame(
  index <- 1:5,
  value <- c("a", "b", "c", "d", "e")
)
```

###### Testing
A data frame is recognized as a list based on it's ```typeof()```, bot as a ```data.frame``` based on it's ```class```. It can also be identified with ```is.data.frame```.

###### Coercion
Vectors and lists can be coerced into data frames with ```as.data.frame()```. A vector becomes a one column data frame. A list must have elements of equivalent length as they'll each be turned into a var.

Data frames can be combined across either dimension. ```cbind()``` and ```rbind()``` combine data frames column wise and row wise. In the former, the number of rows must match. In the later the number and name of columns must match.

See ```plyr::rbind.fill()``` to combine data frames that don't have the same columns.

## Subsetting
Subsetting data well is necessary for efficient and effective R code. Unfortunately, it's also a difficult task because it involves a number of interrelated concepts. Here we'll introduce some foundational concepts and start to build intuition for mastering subsetting.

### Data Types
There are three subsetting operators in R: ```[]```, ```[[]]```, and ```$```. The first, square brackets is the most common. We'll look at these in practice starting from interactions with simple data types and moving to more complex, multidimensional types.

#### Atomic Vectors
Below are several examples of subsetting a vector:
```{r}
x <- c(-3, -2, -1, 0, 1, 2, 3)

# Passing a vector through [] request by index
x[c(4, 1)]
#> [1] 0 -3

# Order(x) returns the index permutation of smallest to largest ordered values
x[order(x)]
#> [1] -3 -2 -1 0 1 2 3

# Non-ints are truncated to ints before subsetting
x[c(1.4, 2.3)]
#> -3 -2

# Negative numbers return the complimentary set
x[-c(2)]
#> [1] -3 -1 0 1 2 3
# Note you can't mix positive and negative indicies

# Passing nothing returns the entire set
x[]
#> [1] -3 -2 -1 0 1 2 3

# Logical operators
# If the logical vector is shorter than the vector to be subset, it's repeated
x[c(TRUE, FALSE)]
#> [1] -3 -1 1 3

# A missing value in an index always returns an NA in the output

# If a vector is named, index names can be used to subset as well

```

#### Lists
Lists are subset the same way with ```[]```. ```[[]]``` and ```$``` as shown below allow you to extract the components of a list.

#### Matricies and Arrays
Two and higher dimension objects can be subset in three ways:
+ Single vector
+ Multiple vectors
+ Matrix

The most common method is submitting an index for each dimension, separated by a comma.
```{r}
X <- matrix(1:12, nrow=4, ncol=3)
X
#> [,1] [,2] [,3]
#> [1,]    1    5    9
#> [2,]    2    6   10
#> [3,]    3    7   11
#> [4,]    4    8   12

X[1, 1:4]
#> [1] 1 5 9

X[c(1, 5)]
#> 1 5
```

#### Data Frames
Subsetting a single vector (variable) in data frame behaves like a list. Subsetting multiple vectors behaves like a matrix.

```{r}
data <- data.frame(v1 = 1:3, v2 = 0, v3 = letters[1:3])
data
#>   v1 v2 v3
#> 1  1  0  a
#> 2  2  0  b
#> 3  3  0  c

# $ subsets a single vector, which returns as a list
data$v1
#> [1] 1 2 3

# Select a row using matrix notation
data[data$v1 == 1, ]
#>   v1 v2 v3
#> 1  1  0  a

# Select columns like a list; note the result is a dataframe
data[c("v1", "v2")]
#>   v1 v2
#> 1  1  0
#> 2  2  0
#> 3  3  0

# Select columns like a matrix; note the result is not a dataframe
data[, c("v1", "v2")]
#>   v1 v2
#> 1  1  0
#> 2  2  0
#> 3  3  0

```
### Subsetting Operators
#### Simplifying vs. preserving subsetting
Some types of subsetting simplify the output to the most basic type possible, while others preserve the format of the original object. It's important to understand the difference in what you're asking R for.


|           | Simplifying      |	Preserving                          |
|:---------:|:----------------:|:------------------------------------:|
|Vector     | x[[1]]	         | x[1]                                 |
|List	      | x[[1]]	         | x[1]                                 |
|Factor     | x[1:4, drop = T] | x[1:4]                               |
|Array      | x[1, ] or x[, 1] | x[1, , drop = F] or x[, 1, drop = F] |
|Data frame	| x[, 1] or x[[1]] | x[, 1, drop = F] or x[1]             |

#### Subsetting with assignment
Subsetting operators can be used modify selected values of a vector.

```{r}
x <- 0:9
x[c(1, 2, 3)] <- 10:12

x
#> [1] 10 11 12  3  4  5  6  7  8  9
```

## Style Guide
