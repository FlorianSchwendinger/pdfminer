q("no")
R

library("pdfminer")

pdfminer:::is_pdfminer_installed()

library("PythonInR")

pdfminer:::is_pdfminer_installed("PythonInR")


attach(getNamespace("pdfminer"))

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


is_pdfminer_installed(pyexe="py")

is_pdfminer_installed(pyexe="python")
is_pdfminer_installed(pyexe="python2.7")
is_pdfminer_installed(pyexe="python3")
