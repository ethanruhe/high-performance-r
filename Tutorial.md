# High Performance R

#### Motivation
I spent several years exploring and building models of empirical consumer behavior data alongside economists and statisticians. Most of this work was in the statistical analysis software [Stata](http://www.stata.com/).

For the past couple years, I helped teach an introductory class to new Stata users who were quantitatively savvy, but had little programming experience. I found the process of teaching to be a great vehicle for extending my own knowledge: discovering new ways to leverage the language's characteristics and build a better intuition for analyzing data efficiently (both in terms of writing concise code as well as parsimonious use of computational resources).

I want to learn R because of its broad popularity and deeper extensibility, so I'm writing this guide for my own edification and future reference. It will lean heavily on Hadley Wickham's [Advanced R](http://adv-r.had.co.nz/) for both structure and content.

I assume the user has already installed R and is using the IDE [RStudio](https://www.rstudio.com/).

Code block example:
```{r}

a <- c(1,2,3,4)
a  # returns values of vector a
```


## 1. Fundamentals
## Data structures
There are five data types that are most often used in R analysis. These are either used directly or are the foundations upon which other objects are built. They differ in their dimensionality and whether or not all of their contents must be of the same type (e.g., homogenous vs. heterogeneous).

|       | Homogeneous   | Heterogeneous|
| :---: |:-------------:| :-----------:|
| 1D    | Atomic Vector | List         |
| 2D    | Matrix        | Data Frame   |
| nD    | Array         |              |

``` str([object]) ``` will tell you an object's type.
```
ER: remove line above

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
```is.character()```, ```is.double()```, ```is.integer()```, and ```is.logical()``` allow you to test the vectors.
```

Note that both doubles and integers return true for ```is.numeric()```.

###### Coercion
R has a natural order of least to most flexible types of atomic vectors. If you try to combine them, they will be coerced to the least flexible necessary. From least to most flexible, these are: logical, integer, double, and character.

For example:
```{r}
male <- c(T, F, T, T, F)

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

```c()``` will combine a passed combination of vectors and lists into a single list.
```
ER: remove line above
Similar to atomic vectors, ```is.list()``` tests if an object's type and ```as.list()``` coerces it.

Lists are a frequent building block of more complicated structures in R (e.g., data frames and linear models).

### Matricies and Arrays
A matrix in R is an two dimensional atomic vector. Arrays of higher dimensions are possible, though used much less frequently. Dimensions are defined in the ```dim()``` attribute.

```{r}
# Define a 5x2 matrix with 1-5 in first column and 6-10 in second
X <- matrix(1:10, ncol=2, nrow=5)

# Define 2x2x2 array
Y <- array(1:8, c(2, 2, 2))

# If it's not referenced elsewhere, you can modify a vector in place by adding dim() to it
z <- 1:4
dim(z) <- c(2,2)
```

```rownames()``` and ```colnames()``` allow you to name rows and columns using vectors of strings.
```
ER: remove line above
###### Testing
```length()``` gives the number of cells in an array. ```nrow()```, and ```ncol()``` give the row and columns counts respectively.

```is.matrix()``` and ```is.array()``` test the type of the object.


###### Coercion
```as.matrix()``` and ```as.array()``` turn a vector or list into a matrix or array. It's most common to see vectors coerced.
```
ER: remove line above
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
```as.data.frame()``` coerces objects into a data frame. A vector becomes a one column data frame. A list must have elements of equivalent length as they'll each be turned into a var.

```cbind()``` and ```rbind()``` combine data frames column wise and row wise. In the former, the number of rows must match. In the later the number and name of columns must match.

See ```plyr::rbind.fill()``` to combine data frames that don't have the same columns.
