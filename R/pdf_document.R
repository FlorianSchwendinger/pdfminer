#' @noRd
#' @export
print.pdf_document <- function(x, ...) {
    n_pages <- max(x$metainfo$pid)
    if ( n_pages == 1L ) {
        writeLines(sprintf("A pdf document with %s page and", n_pages))
    } else {
        writeLines(sprintf("A pdf document with %s pages and", n_pages))
    }
    print(data.frame(lapply(x, nrow)))
    writeLines("elements.")
}
