# Copyright 2023 Cloudera Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' @include common.R translations.R
NULL

secure_expression <- function(expr, tidyverse) {
  stop_if_bad_funs(bad_funs(expr, tidyverse))
}

stop_if_bad_funs <- function(bad_funs) {
  if (length(bad_funs) > 0) {
    if (length(bad_funs) > 1) {
      stop(
        "Unrecognized functions or operators: ",
        paste(bad_funs, collapse = ", "),
        call. = FALSE
      )
    }
    stop("Unrecognized function or operator: ", bad_funs, call. = FALSE)
  }
}

bad_funs <- function(expr, tidyverse) {
  if (identical(typeof(expr), "language")) {
    if (tidyverse) {
      return(setdiff(tolower(all_funs(expr)), allowed_funs_tidyverse))
    } else {
      return(setdiff(tolower(all_funs(expr)), allowed_funs_base))
    }
  }
  character(0)
}

# the expression is tested against one of these lists of allowed
# functions after the string replacements occur but before the
# environment translations occur

# do not include "%>%"  in any of these lists
# (see issue #7)

allowed_funs_generic <- c(
  "::", ":::", "+", "-", "*", "/", "^", "%/%", "%%",
  "!", "&", "&&", "|", "||",
  "!=",  "<", "<=", "=", "==", ">", ">=",
  "cast", "count_star", "is.na",
  "as.logical", "%in%", "%nin%",  "ifelse",
  "(", "c", "between", "xtfrm",
  sql_data_types_with_args,
  unname(unlist(translations_operators_binary_symbolic)),
  unname(unlist(translations_operators_binary_word)),
  unname(unlist(translations_operators_unary_prefix)),
  names(translations_direct_generic),
  names(translations_indirect_generic),
  names(translations_indirect_generic_agg),
  paste(names(translations_indirect_generic_agg), "distinct", sep = "_")
)

allowed_funs_base <- unique(c(
  allowed_funs_generic,
  names(translations_direct_base),
  names(translations_indirect_base),
  names(translations_indirect_base_agg),
  paste(names(translations_indirect_base_agg), "distinct", sep = "_")
))
allowed_funs_base <- setdiff(
  allowed_funs_base,
  c("count_star_distinct", "count_distinct_distinct")
)

allowed_funs_tidyverse <- unique(c(
  allowed_funs_generic,
  "everything", "dplyr", "desc",
  names(translations_direct_tidyverse),
  names(translations_indirect_tidyverse),
  names(translations_indirect_tidyverse_agg),
  paste(names(translations_indirect_tidyverse), "distinct", sep = "_"),
  paste(names(translations_indirect_tidyverse_agg), "distinct", sep = "_")
))
allowed_funs_tidyverse <- setdiff(
  allowed_funs_tidyverse,
  c("count_star_distinct", "count_distinct_distinct")
)
