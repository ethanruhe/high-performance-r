# High-performance R
The following tutorial was completed as part of an independent study project for graduate course credit at Wharton (UPenn), within the Department of Statistics.

#### Motivation
I spent several years exploring and building models of empirical consumer behavior data alongside economists and statisticians. Most of this work was in the statistical analysis software [Stata](http://www.stata.com/).

For the past couple years, I helped teach an introductory class to new Stata users who were quantitatively savvy, but had little programming experience. I found the process of teaching to be a great vehicle for extending my own knowledge: discovering new ways to leverage the language's characteristics and build a better intuition for analyzing data efficiently (both in terms of writing concise code as well as parsimonious use of computational resources).

I want to learn R because of its broad popularity and deeper extensibility, so I'm writing this guide for my own edification and future reference. It will lean heavily on Hadley Wickham's [Advanced R](http://adv-r.had.co.nz/) for both structure and content.

I assume the user has already installed R and is using the IDE [RStudio](https://www.rstudio.com/).

#### Note on Data
To try to make this a bit more lively, I'll be loading and analyzing real data once I get through the brief tutorial (in the file ```explore_college_scorecard_data.R``` in this github repo). Specifically, I'll be looking at the US Department of Education's College Scorecard data. My hope is that this makes the concepts feel more concrete than purely contrived examples. The full data can be downloaded [here](https://collegescorecard.ed.gov/data/). I'll specifically be working with the 2013 data file ("MERGED2012_PP.csv"). I.e., once downloaded I load ```raw.data <- read.csv("MERGED2013_PP.csv", header=TRUE)```.

#### Continued Development
I intend to add and extend this periodically, both going deeper on current topics and covering more breadth. I expect the examples in the ```.R``` file noted above to expand quickest.

# 1. Fundamentals
## Brief Style Guide
First, it's worth mentioning the Google has a very good [R Style Guide](https://google.github.io/styleguide/Rguide.xml). I generally agree with their suggestions, but have added a few points of emphasis.

### Naming
#### File Names
File names should, of course, be descriptive of what the actual file does. The should also end in ```.R```.
For example: ```predict_user_engagement.R```

#### Variable Names
Identifiers should either be (a) all lowercase with words separated by dots (```delta.sales```), or (b) camel case (```deltaSales```).

#### Function Names
The first word of a function name should be a verb. It should also begin with a capital letter, and have words separated by camel case (```CalibrateBetaBinomial```). Note there shouldn't be any punctuation.

#### Constants
Constants should be named like functions, but begin with a ```k``` (```kDiscountRate```).

### Spacing
Indent with two spaces, never tabs.

Use spaces around operators (```+, -, >, <-,``` etc.) and parentheses, except in function calls.

### Braces
An opening curly brace should never go on its own line. A closing curly brace should always be on its own line.

Surround ```else``` statements with curly braces.
```{r}
if (condition) {
  one or more lines
} else {
  one or more lines
}
```

### Commenting
Use a consistent ```TODO``` comment system (```TODO(username)```).

Visually break up your code using commented lines of ```-```.
```{r}
# Load data ------------------------------------------
```

## Data structures
There are five data types that are most often used in R analysis. These are either frequently used directly or are the foundations upon which other objects are built. They differ in their dimensionality and whether or not all of their contents must be of the same type (e.g., homogenous vs. heterogeneous). Note that they're all mutable.

|       | Homogeneous   | Heterogeneous|
| :---: |:-------------:| :-----------:|
| 1D    | Atomic Vector | List         |
| 2D    | Matrix        | Data Frame   |
| nD    | Array         |              |

You can check an object's type with ``` str() ```.

### Vectors
Vectors are the basic data type in R. There are two types of vectors: those that require all elements to be of the same type (atomic vectors) and those that can hold multiple types (lists).

Both have a few key properties:
+ ```typeof()``` tells what kind of elements are inside of a homogenous atomic vector, or identifies a list
+ ```length()``` gives the number of elements in the vector
+ ```attributes()``` gives metadata on the vector
+ ```is.atomic()``` and ```is.list()``` return true if passed the expected object

#### Atomic Vectors
There are four common data types that can be held in atomic vectors:
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
Note assignment is done with ```<-``` and not ```=``` throughout this tutorial. The latter will almost always work, but the reasons why it breaks can be complicated rules related to compatibility with old versions of S (R's predecessor), scope differences in the declaration, or parsing rules. [Here's some short intuition](https://stackoverflow.com/questions/1741820/assignment-operators-in-r-and). To avoid this, it's not a bad idea to default to ```<-``` unless you have a good reason to use ```=```.

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
Most R math functions will attempt to coerce automatically. Use ```as.character()```, ```as.double()```, ```as.integer()```, or ```as.logical``` to explicitly coerce values.

Note there are two other types of infrequently used atomic vectors: complex and raw.

#### Lists
Lists can hold multiple types of data (including other lists).
```{r}
x <- list("abc", c(F, F, T), 0:5)
# creates a list of three vectors, each of a different type of attributes
```

A ```c()``` will combine a passed combination of vectors and lists into a single list. This is called "flattening."

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
A data frame is recognized as a list based on it's ```typeof()```, but as a ```data.frame``` based on it's ```class```. It can also be identified with ```is.data.frame```.

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

X[1, 1:3]
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

# Select columns like a matrix
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
Subsetting operators can be used to modify selected values of a vector.
```{r}
x <- 0:9
x[c(1, 2, 3)] <- 10:12

x
#> [1] 10 11 12  3  4  5  6  7  8  9
```

## Functions
Functions allow you to write reusable code to be applied in a potentially flexible way on a variety of inputs. Functions are a key building block of R. Importantly, they are objects themselves and can be treated as such.

To explore functions, we'll use the package ```pryr```. ```install.packages("pryr")``` if you don't already have it.

There are three parts to each R function:
+ ```body()``` - the code inside the function that gets executed when the function is called
+ ```formals()``` - the arguments of the function
+ ```environment()``` - the locational map of the function's vars (default is global)

Each of the above commands can be used to decompose the stated parts of a function.

Recall all R objects, including functions, have ```attributes()``` as well. ```str()``` will identify a function and list its attributes in human-readable text. ```is.function()``` will identify functions with a Boolean.

### Primitive functions
Primitive functions are an exception to the rules in R. They rely directly on C code and contain no R code. Therefore, they do not contain the three components noted above. They often provide fundamental computation very efficiently (e.g., ```sum()``` is a primitive that adds). They can be identified with ```is.primitive()```.

### Lexical Scoping
[Scoping](https://en.wikipedia.org/wiki/Scope_(computer_science)) is the set of rules that govern how a computer program looks up values, such as variables, when they're referenced by name. Scoping is tightly related to the discussion of environments (below), but we'll discuss it here because it's crucial for writing functions.

Note: when using R's command line interactively, it uses "dynamic scoping." This has it's own rules and issues, but we won't cover them here because the topic is outside the... scope of this tutorial.

With lexical scoping, access to objects (by referencing their names) is determined by where objects are *created* relative to other entities, not by where they're called. Therefore, to know where the value of a function's variable will be looked up, you need to look at its function definition. The following examples demonstrate this principle.

```{r}
a <- 1
f <- function() {
  b <- 2
  c(a, b)
}
f()
# 1 2
```

Because of where the function ```f()``` is created, R first looks for it inside the function's definition. If it can't find it there, it looks in the environment in which that function was defined. In the next example, the value of ```a``` is changed in the environment that ```f()``` will look for its definition, so running ```f()``` yields the updated value.
```{r}
a <- 10
f()
# 10 2
```

Clearly, if a function relies on a variable outside of its definition, then the result of the function can change as that outside variable changes. This can be very dangerous; functions should be self-contained and only be variable depending on values passed as arguments. ```findGlobals()``` identifies global dependencies of a function.

For one last example, look at the following closure definition. (A closure is just a function that results in another function. They are covered in greater detail below.)
```{r}
g <- function(a) {
  b <- 2
  function() {
    c(a, b)
  }
}
h <- g(1)
h()
# 1 2

b <- 10
h()
# 1 2
```
Because ```h()``` preserves the environment in which it was defined, and ```b``` is defined there, the value comes along with the new function.

One exception to strict lexical scoping in R is that the program will ignore non-function objects with a shared name if the object being called is clearly a function.

The function ```exists()``` can be helpful for debugging or building a better intuition about how R is handling scoping.

#### Every Operation is a Function Call
Every operation is a function call in R. This includes things like ```+```, ```(```, and ```if```. Back ticks, ``` ` ```, allow you to override functions with otherwise protected names (e.g., ```+```), but this is obviously very dangerous.

### Function Arguments
#### Calling Functions
Arguments passed with a function, sometimes called "calling arguments," can vary each time you call the function and alter the output depending on chosen parameters.

There are three ways to pass arguments with a function:
+ by position
+ by complete name
+ by partial name

```{r}
ExFunction <- function(arg1, arg2, color) {
  list(x = arg1, y = arg2, color = color)
}

# By position
ExFunction(1, 2, "blue")
#> $x
#> [1] 1
#>
#> $y
#> [1] 2
#>
#> $color
#> [1] "blue"

# By name
ExFunction(arg2 = 2, color = "red", arg1 = 1)
#> $x
#> [1] 1
#>
#> $y
#> [1] 2
#>
#> $color
#> [1] "red"

# By position and partial name
ExFunction(1, c = "green", arg2 = 2)
#> $x
#> [1] 1
#>
#> $y
#> [1] 2
#>
#> $color
#> [1] "green"
# Note the function will return an error if an argument name is given an ambiguous abbreviation (e.g., "arg" in the example above.)

```

As rules of thumb: positional arguments should only be used for the first one or two variables, and open ended lists of arguments passed with ```...``` should be at the end of the argument list.

The ```...``` operator is used to pass an arbitrary number of not explicitly named arguments.

#### Default and Missing Arguments
 When defining functions, arguments can be given default values that are used unless other values are passed when the function is used.

 ```{r}
ExFunction <- function(x = 1, y = 2) {
  c(x, y)
}

z <- ExFunction()
z
#> [1] 1 2

 ```

The ```missing()``` function allows you to test for missing arguments within a function definition. If a default value would take several lines of code, ```missing()``` can allow you to take the missing value equation out of the function's argument definition line.

#### Lazy Evaluation
R uses so called "lazy evaluation" of functions, which means that arguments are only evaluated if they're actually used.

Using ```force()``` on the variable name within the function definition will ensure that they argument is evaluated (e.g., this could ensure an error is thrown for an argument that otherwise wouldn't be evaluated).

#### Return Values
A return value is what results from a function. By default in R, the last evaluated line of a function definition is what is returned. ```return()``` can explicitly define a return value as well. It's good practice to define an explicit return if a function could be finished evaluating before the last written line of code.

```{r}
IsEven <- function(x) {
  if (x %% 2 == 0) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

```

Functions are only able to return one object, so if you want multiple values back, you'll have to pass them through a vector/list/array/etc.

It is also worth being aware that other than return values, functions generally have no other side effects. That is, they won't modify anything outside their scope. There are a few exceptions to this, but these are functions whose sole purpose is to modify the environment (e.g., ```setwd()```) or do something like write to disk (e.g., ```save.csv()```).

### Closures
Closures are functions written (returned by) other functions. Their names reference the fact that they're created by a parent function that encloses their environment. Note that by definition closures have access to all of their parent function's variables.

```{r}
divisible <- function(divisor) {
  function(x) {
    (x %% divisor == 0)
  }
}

DivisibleBy3 <- divisible(3)

DivisibleBy3(99)
#> [1] TRUE
DivisibleBy3(100)
#> [1] FALSE
```

Unfortunately, printing a closure gives the memory address of the enclosing function and not the actual definition (with specified parameters) of itself. This is because the parent function itself isn't actually changing, it just has values passed. You can see the passed parameter(s) by converting the environment of the closure into a list.

```{r}
DivisibleBy3
#> function(x) {
#>         (x %% divisor == 0)
#>     }
#> <environment: 0x111fccf78>

as.list(environment(DivisibleBy3))
#> $divisor
#> [1] 3
```

As noted earlier, execution environments are forgotten after execution. Functions, however, capture their enclosing environments. This is what allows closures to work. In practice, it turns out that most R functions are actually closures and thus remember the environment in which they were created. The only exceptions are primitive functions that are written in C.

## R's Built-in Apply Functions
The ```apply()``` family of functions in R are built to allow you to execute a function over a vector on inputs. For example:
```{r}
A <- matrix(
  c(4, 2, 8, 34, 1, 6),
  nrow = 3, ncol =2)
)

apply(A, 2, min)
# [1]  2 1
```
```apply()``` in this example applied the ```min()``` function to each row of the input matrix A. If we wanted to execute across rows instead of columns, we could have passed ```1``` as the second argument. ```apply()``` expects a matrix or multidimensional object to be passed as the first argument. Avoid using ```apply()``` on data frames, however, as R will first coerce them into a matrix. Instead, look to one of the other functions below.

 The approach of applying functions to entire vectors at a time is called "vectorized" functions. Vectorized functions are frequently the fastest way to calculate in R (see more below in section 3). The ```apply()``` family of functions are generally preferred to writing loops that iterate over an objects indicies. Below we'll explore other types of ```apply()``` functions.

```lapply()``` applies a function to each element of a list and returns a list of the resulting values.
```{r}
x <- list(a = 'a', b = 1:10, c = 10:100)

lapply(x, length)
#$a
#[1] 1
#
#$b
#[1] 10
#
#$c
#[1] 91
```

```sapply()``` applies a function to each element of a list and returns either a vector, or the data type it guesses you might want back. For example ```sapply(1:10,function(x) rnorm(3,x))``` would return a matrix. So, be careful when using ```sapply()``` because it can be great for working quickly in the command line, but may yield unexpected results in production code. (See ```vapply()``` for a similar function that allows you specify exactly what type of object is returned.)

There are several other types of functions in this family that you might find useful: ```tapply()``` applies a function to subsets of a vector where the subsets are defined by some other vector. ```rapply()``` applies a function to each element of a nested list. ```mapply()``` applies a function index-by-index across multiple types of objects and returns a vector.


## Environments
### Overview
Environments are where __bindings__ (links between names and values) are stored. Each name points to a value stored somewhere in memory (e.g., a physical byte address). The addresses are associated with names, so that when you invoke an object, R knows where to go retrieve its value. Environments are data structures that organize scoping and bindings.

Within R, multiple names can point to the same value (by memory address). Multiple names can also point to different addresses that all store the same value.

If there are no names pointing to an object, it is automatically deleted. That is to say, the memory that was holding it is freed to store new information. The underlying mechanism that drives this is called a "garbage collector." See ```?gc()``` for more information on interacting with this behavior.

Every environment in R (except one) has a parent. When you call a function, R will start in the current environment to look for that function's definition. If it doesn't find the definition in the current environment, the search will continue in the current environment's parent, and so on. This search only moves "up" to parent directories. There is no built in way to search "child" directories, and, furthermore, defining which of an arbitrary number of child directories to give priority to wouldn't be straightforward.

There are some basic rules of environments:
+ Each object has a unique name *within* an environment (though the [namespace](https://en.wikipedia.org/wiki/Namespace) allows a name to be used once per environment)
+ Each environment has a parent, with exactly one exception: the empty environment
+ Actual memory location is arbitrary; there is no inherent "order" (you can touch the memory handling directly through C, but that's beyond the scope of this tutorial)

Each environment has two fundamental components:
+ The frame: contains bindings for names and objects
+ The parent environment: confusingly, this can sometimes refer to either the true parent or the "calling" environment as we saw in the Function section

There are four special types of environments:
+ The global environment, ```globalenv()```, is what you normally work and interact with in R. The parent is the most recently loaded ```library()``` or ```require()```
+ The empty environment, ```emptyenv()```, is the highest-level parent and the only env without a parent itself
+ The base environment, ```baseenv()```, is the parent to the empty environment
+ The current environment, ```environment()```

The command ```search()``` lists the search path (e.g., all parents) of the global environment. Any of these environment can be accessed environment with ```as.environment()```. ```new.env()``` will create a new environment.

### Function Environments
Using functions creates new environments.

Specifically, there are four types of environments associated with functions:
+ enclosing: where the function was defined. Each function has only one enclosing environment
+ binding: associates the contents of a function with a name via ```<-```
+ execution: the environment that exists only while a function is being evaluated (and is then destroyed)
+ calling: the environment from which a function was invoked

### Accessing a Parent Environment with <<-
The ```<<-``` operator allows variables within an environment's parent to be manipulated while otherwise maintaining the same "state." This is most useful in functionals. For example:
```{r}
new_counter <- function() {
  i <- 0
  function() {
    # do something useful, then ...
    i <<- i + 1
    i
  }
}

counter_one <- new_counter()
counter_two <- new_counter()

counter_one() # -> [1] 1
counter_one() # -> [1] 2
counter_two() # -> [1] 1
```
Here a child function is able to iterate ```i``` in the parent environment using ```<<-```, effectively creating a count of how many times each child function has been called.
([See Hadley Wickham's stackoverflow answer here for more detail on this example.](https://stackoverflow.com/questions/2628621/how-do-you-use-scoping-assignment-in-r/2630222#2630222))

## Debugging
No matter how advanced of an R coder you become, much of your time is going to be spent investigating and fixing unanticipated errors. This section will give a high-level foundation of how to quickly troubleshoot bugs in your code. Additionally, it will highlight a few tools for communicating expected problems to a user.

### Condition Handling
Exceptions are communicated according to severity in through three functions:
+ Fatal errors, raised through ```stop()```, terminate execution
+ Warnings, raised through ```warning()```, tell the user about potent problems
+ Messages, raised through ```message()```, give the user additional information. These can be ignored by the user with ```suppressMessages()```

There are three functions that allow you to handle conditions:
+ ```try()``` continues execution even if an error is thrown
+ ```tryCatch()``` allows you to define a handler function
+ ```withCallingHandlers()``` is less-used variant of ```tryCatch()```

### Debugging Strategies
Hadely Wicham gives the following helpful four step approach to debugging:
+ Realize that you have a bug: this, he suggests, is one of the reasons automated testing is so important
+ Make it repeatable: isolating exactly what is causing the bug is necessary to hone in on what is failing, so you don't spend time deep diving into superfluous code
+ Figure out where it is: generate hypotheses, design experiments, test them, and record your results. Being systematic here will save you time in the long run
+ Fix it and test it: once you've addressed the problem, test to make sure it is actually gone!

Printing intermediate output, ```print()```, is an easy, if crude, tool for troubleshooting code. Print statements allow you to track intermediate output and, therefore, see where execution diverges from what you expect

RStudio also has useful debugging tools built in:
+ When a function call returns a fatal error, options for "Show Traceback" and "Rerun with Debug" appear on the output window. ```traceback()``` gives the same output as the button: the order of functions called that led to the error. The RStudio debugger steps through the function's execution line-by-line, pausing in the execution environment so that you can interact with it along the way
+ Breakpoints and browsing allow you to arbitrarily pause execution and stay in the executing environment anywhere in your code. Breakpoints can be added by clicking left of the line number in RStudio, or with ```Shift + F9```. ```browse()``` statements can be included anywhere in your code for the same effect; note these support conditional statements where breakpoints do not

For more on debugging in R Studio, see the [documentation](https://support.rstudio.com/hc/en-us/articles/205612627-Debugging-with-RStudio).

### Defensive Programming
[Defensive programming](https://en.wikipedia.org/wiki/Defensive_programming) is the principle that code should be designed and written in a way that exceptions are anticipated to a reasonable degree and conditions are thrown as soon as any one thing goes astray.

In practice, this means keeping in mind common mistakes you or other programmers make and trying to (a) programmatically avoid them or (b) at least make the user aware that they are occurring.

A good way to do this is through tests that verify inputs to functions are as expected and output is structured as anticipated.

The [assertthat](https://github.com/hadley/assertthat) package, ```stop()```, ```stopifnot()```, and simple ```if``` statements are a great place to start.

# Functional Programming
## Introduction
### Overview and Motivation
R is a [functional programming](https://en.wikipedia.org/wiki/Functional_programming) language. It allows you to treat functions just like any other object: bind them to names, create lists of them, pass them as arguments in other functions, use them to create other functions (i.e., return them as the result of other functions) etc. The fact that functions are treated like any other object means they are [first class functions](https://en.wikipedia.org/wiki/First-class_function).

At a high-level, functional programming is motivated by starting with simple, "primitives," and using these building blocks to create more complex functions. This allows you to concisely define any functionality only once. In R, the building blocks are anonymous functions, closures, and lists of functions. These are discussed in more depth below.

R's ```lapply()``` function is a good example of a function with functional programming in mind. It takes two arguments, (1) a list and (2) a function, plus any arguments that have to be passed to (2). The function in (2) is applied to each element of the list in (2). A new list of the resulting values is returned. ```lapply()``` allows you to combine the use of any arbitrary input function with the ability to apply it quickly to a queue of inputs. This is the essence of combining useful primitives: "do this to each item of a list" can be disassociated with any particular "doing" to those items.

## Basic Building Blocks
### Anonymous Functions
If you don't give an R function a name, you get an anonymous function. These are often useful when it isn't necessary to create a named function that will be used repeated throughout your code. (These are analogous to Python's [lambda functions](https://stackoverflow.com/questions/890128/why-are-python-lambdas-useful)). Since these are actual R functions, they have a ```body()```, a parent ```environment()```, and ```formals()``` as the proceeding sections suggest they would.

Note that calling an anonymous function requires an extra set of parentheses to clearly indicate what exactly you're calling. For example:

```{r}
# Raise arg1 to arg2 power with anonymous function
(function(x, y) x^y)(10,6)
#> [1] 1e+06
```

### Lists of Functions
This is pretty straightforward: you can put function definitions in the elements of a list. The structure is easy to understand, but the power of this may be a bit counterintuitive. Let's look at an example benchmarking the run time of an R implementation of summing a vector of numbers vs using the ```sum()``` function. (Because ```sum()``` is a primitive, it is written in C and we'd expect it to be much, much faster than an R implementation.)

```{r}
# Benchmarking the processing time of various implementations of a function
compute_sum <- list(
  base = function(x) sum(x),
  manual = function(x){
    total = 0
    for (i in seq_along(x)) {
      total <- total + x[i]
    }
    total
  }
)

# To run, just extract from list and run
y <- runif(1e7) # create ten million reals w/ mean = 0.5; sum ~5e6

system.time(compute_sum$base(y))
#> user  system elapsed
#> 0.01    0.00    0.01

system.time(compute_sum[[2]](y))
#> user  system  elapsed
#> 4.265  0.030    4.297

# Run each and see if we get the same answer
lapply(compute_sum, function(f) f(y))
#> $base
#> [1] 5000296
#>
#> $manual
#> [1] 5000296

# Time each function with one line
lapply(compute_sum, function(f) system.time(f(y)))
#> $base
#>    user  system elapsed
#>    0.01    0.00    0.01
#>
#> $manual
#>    user  system elapsed
#>   4.157   0.018   4.178
```
Obviously, your exact run times will vary, but the primitive ```sum()``` should run significantly faster.

# Performance
## Introduction
### Overview
R is designed to facilitate easy statistical analysis. Unfortunately, facilitating statistical analysis often comes at the expense of fast processing. Relative to many "lower-level," generalized programming languages, R is not very fast at computation. This is both because priority is typically put on ease of implementation and because a lot of R code is just not written with speed in mind. Much of the R code you'll encounter is written by practicing data analysts (e.g., statisticians, economists, etc.) and not software engineers. Because of this, it is optimized for stable statistics. This means that there is frequently room for significant speed improvement.

In this section, we'll try to start building an intuition for why certain things in R are slow, and how you can write more efficient code.

There are three things that make R particularly slow:
+ Dynamism: because just about everything written in R code can later be modified, it is really difficult for an interpreter or compiler to optimize for speed
+ Name lookup: due to the dynamism of objects and lexical scoping, looking up values by the memory addresses associated with names is quite slow in R relative to many other languages. For example, arithmetic operators are defined in the global environment. Depending on where they are called, R might have to search through dozens of environments before finding their definition to be used in execution. Unfortunately, because of the language's structure, caching (i.e., storing frequently used variables in a "closer," more easily accessible structure) is difficult in R
+ Lazy evaluation: because of the way R evaluates functions lazily, each additional argument slows down execution, even if it isn't actually used in execution

Hadley Wickham notes that though many of the foundational choices in creating R make it inherently slow, it is still nowhere near its theoretical limit. Unfortunately, the source code is unlikely to be sped up as stability is a much higher priority and there isn't enough dev resources to champion both goals. There is currently a group of 20 [Core R](https://www.r-project.org/contributors.html) developers. Maintaining and developing the language isn't anyone's primary responsibility, so development doesn't happen particularly quickly.

### Measuring Performance
The [microbenchmark](https://cran.r-project.org/web/packages/microbenchmark) package allows you to precisely measure R run time. It's a great tool for checking the run time of various code snippets and can give you some quick, empirical information about the speed tradeoffs between alternative implementations.

```{r}
install.packages("microbenchmark")  # run if not yet installed
library(microbenchmark)

x <- runif(1e6)
microbenchmark(
  sqrt(x),
  x ^ 0.5
)

#> Unit: milliseconds
#>     expr       min        lq      mean    median        uq      max neval
#>  sqrt(x)  4.647449  7.428192  8.119408  7.829737  8.447671 46.30399   100
#>    x^0.5 37.067700 42.825133 45.611065 44.510281 46.253518 83.45551   100
```

Note you saw ```system.time()``` as a benchmarking tool earlier. ```microbenchmark()``` is much more precise, in part because it automatically runs multiple trials of your code (100 by default).

### Steps for Writing Faster Code
#### Vectorize
Functions that use R code to iterate over elements of a multi-element object are quite slow. They extract some particular element of an object, execute R code on it, and then iterate. "Vectorizing" (i.e., executing a C based function on an entire vector) is much faster. Try to find the vectorized function that most closely solves your problem and use it to speed up your code (like the ```apply()``` family of functions mentioned above). Useful functions include ```rowSums()```, ```colSums()```, ```rowMeans()```, and ```colMeans()```.

Eventually, you can start writing your own vectorized functions in C++ (see [rcpp](http://www.rcpp.org/)).

#### Avoid Copies
R code that adds to or appends an object is often functionally creating a new object and copying over each old element plus the new ones to a new memory location. This process is particularly slow, so be careful when using ```c()```, ```append()```, ```cbind()```, ```rbind()```, and ```paste()``` to increase the size of existing objects. Certainly try to avoid iterating over multiple size increases!

## How R Uses memory
Building some intuition into how R uses memory will help you better identify bottlenecks and write faster code.

### Object Size
R's built in ```object.size()``` function doesn't count shared elements and environment sizes, so try ```pryr::object_size()``` to get more accurate measurements.

```{r}
library(pryr)

x <- runif(1e6)
object_size(x)
#> 8 MB

object_size(rowSums)
#> 16.8 kB

object_size(sum)
#> 0 b

y <- x
object_size(y)
#> 8 MB

# Passing multiple arguments returns the combined size
object_size(x, y)
#> 8 MB
# Clearly, R doesn't make a copy of x when y is created, y just points to x

x <- runif(1e6)
object_size(x, y)
#> 16 MB
# Assigning a new value to x means that the old value is now only binded to y
```

### Memory Usage and Garbage Collection
You can find out the size of all of the objects R is storing in memory with ```pryr::mem_used()```. ```pryr::mem_change()``` will tell you how much additional memory some action would use (positive number), or how much it would free up (negative number).

```{r}
mem_used()
#> 50.4 MB

mem_change(rm(x))
#> -7.99 MB
```

R is really good about releasing memory once it's no longer needed. The garbage collector automatically releases memory when there are no longer names pointing to an object. There is rarely, if ever, reason to initiate this yourself. That being say, ```gc()``` allows you to do this and the help documentation provides greater detail into how this process works in R.

#### Copy-on-modify and Modification in Place
```{r}
a <- 1:10
a[2] <- 20

a
# [1]  1 20  3  4  5  6  7  8  9 10
```
Functionally there are two possible ways R could create the resulting ```a``` vector: it could modify the original object, or it could create a copy of the object and modify that before having the object's name point to the modified copy. Obviously the latter is much, much slower. Depending on the implementation, R can function either way.

If only one name references the value of an object (i.e., points to the memory address of the value), then R will modify an object in place. If multiple names reference the same value, R will copy the object and then modify it (sometimes called "copy-on-modify").

The function ```refs()``` (from ```library(pryr)```) will list how many names reference a particular value, although this is only an estimate and not completely reliable.
```{r}
a <- 1:10
refs(a)
# [1] 1

b <- a
refs(a)
# [1] 2

```

As a general rule, any non-primitive function run on an object will increase the objects reference count, and thus cause R to create a new copy. Loops in R have a reputation for being slow in large part because their execution often results in one or many copies being created and modified per iteration.

### Miscellaneous Resources
Below is a list of useful performance related R articles I'll update as I come across them:
+ [Evaluating the Design of the R Language](http://r.cs.purdue.edu/pub/ecoop12.pdf)
