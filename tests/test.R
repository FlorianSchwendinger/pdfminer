
library("pdfminer")

test_read.pdf <- function() {
    if (is_pdfminer_installed()) {    
        pdf_file <- system.file("pdfs/cars.pdf", package = "pdfminer")
        x <- read.pdf(pdf_file)
        if (inherits(x, "pdf_document")) {
            return("Test OK!")
        } else {
            stop("Test failed!")
        }
    } else {
        return("Can't test pdfminer not found!")
    }
}


test_read.pdf()

