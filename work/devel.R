q("no")
R

library(pdfminer)

file <- system.file("pdfs/cars.pdf", package = "pdfminer")

pyexe <- '/home/f/anaconda3/envs/pdf/bin/python'

d1 <- read.pdf(file, method = "csv", pyexe = pyexe)
d2 <- read.pdf(file, method = "sqlite", pyexe = pyexe)
d3 <- read.pdf(file, method = "PythonInR")

d1
d2
d3

names(d1)
names(d2)
names(d3)

dims1 <- do.call(rbind, lapply(d1, dim))
dims2 <- do.call(rbind, lapply(d2, dim))
dims3 <- do.call(rbind, lapply(d3, dim))

max(abs(dims1 - dims2))
max(abs(dims1 - dims3))

cn1 <- lapply(d1, colnames)
cn2 <- lapply(d2, colnames)
cn3 <- lapply(d3, colnames)
all(mapply(all.equal, cn1, cn2))
all(mapply(all.equal, cn1, cn3))

str(d1[['text']])
str(d2[['text']])
str(d3[['text']])


head(d3[['text']])