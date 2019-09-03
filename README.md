
<!-- README.md is generated from README.Rmd. Please edit that file -->

# queryparser

<!-- badges: start -->

<!-- badges: end -->

**queryparser** translates SQL queries into lists of unevaluated R
expressions.

## Installation

Install the released version of **queryparser** from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("queryparser")
```

Or install the development version from [GitHub](https://github.com/)
with:

``` r
# install.packages("devtools")
devtools::install_github("ianmcook/queryparser")
```

## Usage

Call the function `parse_query()`, passing a `SELECT` statement enclosed
in quotes as the first argument:

``` r
library(queryparser)

parse_query("SELECT DISTINCT carrier FROM flights WHERE dest = 'HNL'")
#> $select
#> $select[[1]]
#> carrier
#> 
#> attr(,"distinct")
#> [1] TRUE
#> 
#> $from
#> $from[[1]]
#> flights
#> 
#> 
#> $where
#> $where[[1]]
#> dest == "HNL"
```

Queries can include the clauses `SELECT`, `FROM`, `WHERE`, `GROUP BY`,
`HAVING`, `ORDER BY`, and `LIMIT`:

``` r
parse_query(
" SELECT origin, dest,
    COUNT(flight) AS num_flts,
    round(AVG(distance)) AS dist,
    round(AVG(arr_delay)) AS avg_delay
  FROM flights
  WHERE distance BETWEEN 200 AND 300
    AND air_time IS NOT NULL
  GROUP BY origin, dest
  HAVING num_flts > 5000
  ORDER BY num_flts DESC, avg_delay DESC
  LIMIT 100;"
)
#> $select
#> $select[[1]]
#> origin
#> 
#> $select[[2]]
#> dest
#> 
#> $select$num_flts
#> sum(!is.na(flight))
#> 
#> $select$dist
#> round(mean(distance, na.rm = TRUE))
#> 
#> $select$avg_delay
#> round(mean(arr_delay, na.rm = TRUE))
#> 
#> 
#> $from
#> $from[[1]]
#> flights
#> 
#> 
#> $where
#> $where[[1]]
#> (distance >= 200 & distance <= 300) && !is.na(air_time)
#> 
#> 
#> $group_by
#> $group_by[[1]]
#> origin
#> 
#> $group_by[[2]]
#> dest
#> 
#> 
#> $having
#> $having[[1]]
#> num_flts > 5000
#> 
#> 
#> $order_by
#> $order_by[[1]]
#> num_flts
#> 
#> $order_by[[2]]
#> avg_delay
#> 
#> attr(,"descreasing")
#> [1] TRUE TRUE
#> 
#> $limit
#> $limit[[1]]
#> [1] 100
```

Set the argument `tidyverse` to `TRUE` to use functions from
[tidyverse](https://www.tidyverse.org) packages including
[dplyr](https://dplyr.tidyverse.org),
[stringr](https://stringr.tidyverse.org), and
[lubridate](https://lubridate.tidyverse.org) in the R expressions:

``` r
parse_query("SELECT COUNT(*) FROM t WHERE x BETWEEN y AND z ORDER BY q DESC", tidyverse = TRUE)
#> $select
#> $select[[1]]
#> dplyr::n()
#> 
#> 
#> $from
#> $from[[1]]
#> t
#> 
#> 
#> $where
#> $where[[1]]
#> dplyr::between(x, y, z)
#> 
#> 
#> $order_by
#> $order_by[[1]]
#> dplyr::desc(q)
```

**queryparser** will translate only explicitly allowed functions and
operators, preventing injection of malicious code:

``` r
parse_query("SELECT x FROM y WHERE system('rm -rf /')")
#> Error: Unrecognized function or operator: system
```

## Current Limitations

**queryparser** does not currently support:

  - Joins
  - Subqueries
  - The `WITH` clause (common table expressions)
  - `OVER` expressions (window or analytic functions)
  - `CASE` expressions
  - Some SQL functions and operators

**queryparser** currently has the following limitations:

  - When logical operators (such as `IS NULL`) have unparenthesized
    expressions as their operands, R will interpret the resulting code
    using a different order of operations than a SQL engine would. When
    using an expression as the operand to a logical operator, always
    enclose the expression in parentheses.
  - The error messages that occur when attempting to parse invalid or
    unrecognized SQL are often non-informative.

## Non-Goals

**queryparser** is not intended to:

  - Translate other types of SQL statements (such as `INSERT` or
    `UPDATE`)
  - Customize translations for specific SQL dialects
  - Fully validate the syntax of the `SELECT` statements passed to it
