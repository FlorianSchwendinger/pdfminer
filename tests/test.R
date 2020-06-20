
library("pdfminer")

test__read_chars <- function() {
    if (is_pdfminer_installed()) {    
        pdf_file <- system.file("pdfs/cars.pdf", package = "pdfminer")
        x <- read_chars(pdf_file)
        if (inherits(x, "pdf_document")) {
            return("Test OK!")
        } else {
            stop("Test failed!")
        }
    } else {
        return("Can't test pdfminer not found!")
    }
}


test__read_chars()

