% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auxiliary.R
\name{is_pdfminer_installed}
\alias{is_pdfminer_installed}
\title{Check if \pkg{pdfminer} is Installed}
\usage{
is_pdfminer_installed(
  method = c("csv", "sqlite", "PythonInR"),
  pyexe = "python3"
)
}
\arguments{
\item{method}{a character string giving the data transfer method. Allowed values
are \code{"csv"} (default), \code{"sqlite"} and \code{"PythonInR"}.}

\item{pyexe}{a character string giving the path to the python executable 
(default is \code{"python3"}). Only used when \code{method} is 
\code{"csv"} or \code{"sqlite"}.}
}
\value{
Returns \code{TRUE} if \pkg{pdfminer} is installed.
}
\description{
The function
}
\examples{
is_pdfminer_installed()
}
