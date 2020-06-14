#' @importFrom checkmate assert check_file_exists check_directory_exists check_integerish check_character check_logical
#' @importFrom jsonlite toJSON
#' @importFrom utils read.csv

#  ---------------------------------------------------------
#  layout_control
#  ==============
#' @title Read a \code{PDF} document.
#' @description Extract  \code{PDF} document
#' @param line_overlap a double, if two characters have more overlap than this 
#'     they are considered to be on the same line. The overlap is specified
#'     relative to the minimum height of both characters.
#' @param char_margin a double, if two characters are closer together than this
#'     margin they are considered part of the same line. The margin is
#'     specified relative to the width of the character.
#' @param line_margin a double, if two characters on the same line are further 
#'     apart than this margin then they are considered to be two separate words, 
#'     and an intermediate space will be added for readability. The margin is
#'     specified relative to the width of the character.
#' @param word_margin a double, if two lines are are close together they are
#'     considered to be part of the same paragraph. The margin is specified 
#'     relative to the height of a line.
#' @param boxes_flow a double, Specifies how much a horizontal and vertical 
#'     position of a text matters when determining the order of text boxes. 
#'     The value should be within the range of \code{-1.0} (only horizontal 
#'     position matters) to \code{+1.0} (only vertical position matters). 
#'     You can also pass \code{NULL} to disable advanced layout analysis, 
#'     and instead return text based on the position of the bottom left corner 
#'     of the text box.
#' @param detect_vertical a logical, If vertical text should be considered during
#'     layout analysis
#' @param all_texts a logical, If layout analysis should be performed on text 
#'     in figures.
#' @return Returns a list with the layout control variables.
#' @examples
#' layout_control()
#' @export
##  ---------------------------------------------------------
layout_control <- function(line_overlap = 0.5, char_margin = 2.0, line_margin = 0.5,
    word_margin = 0.1, boxes_flow = 0.5, detect_vertical = FALSE, all_texts = FALSE) {
    cntrl <- as.list(environment())
    return(cntrl)
}


#  ---------------------------------------------------------
#  read.pdf
#  ========
#' @title Read a \code{PDF} document.
#' @description Extract  \code{PDF} document
#' @param file a character string giving the name of the \code{PDF}-file the data are 
#'     to be read from.
#' @param pages an integer giving the pages which should be extracted 
#'     (default is \code{integer()}).
#' @param laycntrl a list of layout options, created by the function \code{layout_control}.
#' @param method a character string giving the data transfer method. Allowed values
#'     are \code{"csv"} (default), \code{"sqlite"} and \code{"PythonInR"} (recommended).
#' @param encoding a character string giving the encoding of the output 
#'     (default is \code{"utf8"}).
#' @param password a character string giving the password necessary to access 
#'     the \code{PDF} (default is \code{""}).
#' @param caching a logical if \code{TRUE} (default) \pkg{pdfminer} is faster but 
#'     uses more memory.
#' @param maxpages an integer giving the maximum number of pages to be extracted
#'     (default is \code{Inf}).
#' @param rotation an integer giving the rotation of the page, allowed values
#'     are \code{c(0, 90, 180, 270)}.
#' @param image_dir a character string giving the path to the folder, where the images
#'     should be stored (default is \code{""}).
#' @param pyexe a character string giving the path to the python executable 
#'     (default is \code{"python3"}). Only used when \code{method} is 
#'     \code{"csv"} or \code{"sqlite"}.
#' @examples
#' if (is_pdfminer_installed()) {
#' pdf_file <- system.file("pdfs/cars.pdf", package = "pdfminer")
#' read.pdf(pdf_file)
#' }
#' @return Returns a object of class \code{"pdf_document"}.
#' @export
##  ---------------------------------------------------------
read.pdf <- function(file, pages = integer(), method = c('csv', 'sqlite', 'PythonInR'),
    laycntrl = layout_control(), encoding = 'utf8', password = '', caching = TRUE, 
    maxpages = Inf, rotation = 0L, image_dir = '', pyexe='python3') {

    cntrl <- as.list(environment())
    cntrl <- cntrl[!names(cntrl) %in% c('method', 'pyexe')]

    method <- match.arg(method)
    if (is.infinite(maxpages)) cntrl$maxpages <- 0L

    assert(check_file_exists(file), check_integerish(pages), 
           check_character(encoding), check_character(password), 
           check_logical(caching), check_integerish(maxpages), 
           check_integerish(rotation), check_character(image_dir))

    if (!rotation %in% (seq.int(0, 3) * 90L)) {
        stop("invalid rotation value! Allowed rotation values are c(0, 90, 180, 270).")
    }

    pdf_elements <- c('metainfo', 'text', 'line', 'rect', 'curve', 'figure', 
        'textline', 'textbox', 'textgroup', 'image')

    rpdfmine_file <- system.file("python/rpdfmine.py", package = "pdfminer")
    cntrl$pages <- as.list(pages - 1L)
    cntrl$strip_control = FALSE  # not used in XMLConverter2
    names(cntrl) <- gsub("encoding", "codec", names(cntrl), fixed = TRUE)

    if (method %in% c("csv", "sqlite")) {    
        if (method == "csv") {
            output_file <- tempfile()
            file_names <- sprintf("%s_%s.csv", output_file, pdf_elements)
            on.exit(unlink(file_names))
        } else {
            output_file <- sprintf("%s.sqlite", tempfile())
            on.exit(unlink(output_file))
        }
        json_cntrl <- shQuote(toJSON(cntrl, auto_unbox = TRUE))
        cmd <- sprintf("%s %s %s %s", rpdfmine_file, method, output_file, json_cntrl)
        suppressWarnings(msg <- system2(pyexe, cmd, stdout=TRUE, stderr=TRUE))
        if (!is.null(attr(msg, "status"))) stop(paste(msg, collapse = "\n"))
        if (method == "csv") {
            dat <- lapply(file_names, read.csv, stringsAsFactors = FALSE)
            names(dat) <- gsub("(.*_|.csv)", "", file_names)
        } else {
            dat <- read_sqlite_tables(output_file)
        }
    } else if (method == "PythonInR") {
        require_PythonInR()
        script_folder <- system.file('python', package = 'pdfminer') 
        PythonInR::pyExec(sprintf('sys.path.append("%s")', script_folder))
        PythonInR::pyExec('import rpdfmine as rpdf')
        PythonInR::pySet('cntrl', cntrl)
        PythonInR::pyExec('x = rpdf.read_pdf(**cntrl).to_dict(dtype="data.frame")')
        dat <- PythonInR::pyGet("x")
        dat <- lapply(dat, to_data_frame)
    }
    dat <- dat[pdf_elements]
    class(dat) <- "pdf_document"
    return(dat)
}
