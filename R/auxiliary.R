read_sqlite_tables <- function(output_file) {
    suppressPackageStartupMessages(is_installed <- requireNamespace("RSQLite"))
    if (!is_installed) {
        stop("there is no package called 'RSQLite'")
    }
    conn <- RSQLite::dbConnect(RSQLite::SQLite(), output_file)
    tables <- RSQLite::dbListTables(conn)
    queries <- sprintf("SELECT * FROM %s;", tables)

    get_table <- function(query, conn) {
        d <- RSQLite::dbGetQuery(conn, query)
        d$index <- NULL
        d
    }
    dat <- lapply(queries, get_table, conn = conn)
    names(dat) <- tables
    return(dat)
}


as_integer <- function(x) {
    x <- as.integer(x)
    x[!is.finite(x)] <- NA_integer_
    x
}


as_double <- function(x) {
    x <- as.double(x)
    x[!is.finite(x)] <- NA_real_
    x
}


fix_dtype <- function(x, dtype) {
    if (dtype == "integer") {
        as_integer(x)
    } else if (dtype == "double") {
        as_double(x)
    } else if (dtype == "character") {
        as.character(x)
    }
}


to_data_frame <- function(x) {
    d <- mapply(fix_dtype, x[['data']], x[['dtypes']], SIMPLIFY = FALSE)
    names(d) <- x[['colnames']]
    as.data.frame(d, stringsAsFactors = FALSE)
}


require_PythonInR <- function() {
    suppressPackageStartupMessages(is_installed <- requireNamespace("PythonInR"))
    if (!is_installed) {
        stop("there is no package called 'PythonInR'", call. = TRUE)
    }
    is_installed
}


py_fun_is_pdfminer_installed <- 'try:
    import pdfminer
    is_installed = True
except:
    is_installed = False
'


#  ---------------------------------------------------------
#  is_pdfminer_installed
#  =====================
#' @title Check if \pkg{pdfminer} is Installed
#' @description The function 
#' @param method a character string giving the data transfer method. Allowed values
#'     are \code{"csv"} (default), \code{"sqlite"} and \code{"PythonInR"}.
#' @param pyexe a character string giving the path to the python executable 
#'     (default is \code{"python3"}). Only used when \code{method} is 
#'     \code{"csv"} or \code{"sqlite"}.
#' @return Returns \code{TRUE} if \pkg{pdfminer} is installed.
#' @examples
#' is_pdfminer_installed()
#' @export
##  ---------------------------------------------------------
is_pdfminer_installed <- function(method = c('csv', 'sqlite', 'PythonInR'), pyexe = 'python3') {
    method <- match.arg(method)
    if ( isTRUE(method == 'PythonInR') ) {
        require_PythonInR()
        unname(PythonInR::pyExecg(py_fun_is_pdfminer_installed, "is_installed"))
    } else {
        py_script <- system.file("python/is_pdfminer_installed.py", package = "pdfminer")
        err <- try(out <- system2(pyexe, py_script, stdout=TRUE, stderr=TRUE), silent = TRUE)
        if (inherits(err, "try-error")) return(FALSE)
        isTRUE(trimws(out) == "True")
    }
}
