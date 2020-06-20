# **pdfminer**

The **R** package **pdfminer** provides an interface to low level functionality
of the **Python** package **pdfminer**.

## Installation
### **Python**
```{shell}
pip install pdfminer.six
pip install pandas
```

### **R**
```{r}
remotes::install_github("FlorianSchwendinger/pdfminer")
```

## Basic usage
```{r}
library("pdfminer")

args(read_chars)
#R> function (file, pages = integer(), method = c("csv", "sqlite", 
#R>     "PythonInR"), laycntrl = layout_control(), encoding = "utf8", 
#R>     strip_control = FALSE, password = "", caching = TRUE, maxpages = Inf, 
#R>     rotation = 0L, image_dir = "", pyexe = "python3") 
```

```{r}
file <- system.file("pdfs/cars.pdf", package = "pdfminer")
d <- read_chars(file, method = "csv")
#R> A pdf document with 2 pages and
#R>   metainfo text line rect curve figure textline textbox textgroup image
#R> 1        2  469    0    0     0      0      155      10         8     0
#R> elements.
```
The function `read_chars()` returns an object of class `pdf_document`
(a list containing `data.frame`'s). Each object of class `pdf_document`
contains the elements:

- `"metainfo"`
- `"text"`
- `"line"`
- `"rect"`
- `"curve"`
- `"figure"`
- `"textline"`
- `"textbox"`
- `"textgroup"`
- `"image"`

The elements can be accessed as by each other list.
```{r}
head(d[["text"]])
#R>   pid block text         font size colorspace     color    x0      y0    x1      y1
#R> 1   1     1    s Courier-Bold   12 DeviceGray [0, 0, 0]  77.2 751.272  84.4 763.272
#R> 2   1     1    p Courier-Bold   12 DeviceGray [0, 0, 0]  84.4 751.272  91.6 763.272
#R> 3   1     1    e Courier-Bold   12 DeviceGray [0, 0, 0]  91.6 751.272  98.8 763.272
#R> 4   1     1    e Courier-Bold   12 DeviceGray [0, 0, 0]  98.8 751.272 106.0 763.272
#R> 5   1     1    d Courier-Bold   12 DeviceGray [0, 0, 0] 106.0 751.272 113.2 763.272
#R> 6   1    NA                     NA                         NA      NA    NA      NA
``` 

The **R** package **pdfminer** only returns raw data extracted from the
**PDF**-file. To refine this raw data into a format usable for data analysis
the **pdfmole** can be used.
 

### Details on the data exchange
The data exchange between **Python** and **R** can be executed by 
one of the methods `"csv"`, `"sqlite"` or `"PythonInR"`.
The methods `"csv"` and `"sqlite"` call **Python** via the `system2`
command and the data is written out to temporary files.
The **Python** version called by `system2` can be changed by changing the
`pyexe` argument. For example if a specific conda environment (in this
example the `pdf` environment) should be used. Obtain the path to
the **Python** executable
```{python}
import sys
sys.executable
#Py> '/home/f/anaconda3/envs/pdf/bin/python'
```
and specify it via the `pyexe` argument.
```{r}
pyexe <- '/home/f/anaconda3/envs/pdf/bin/python'
d <- read_chars(file, method = "sqlite", pyexe=pyexe)
```
