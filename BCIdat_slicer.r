prepare_matlab <- function(filename)
{
library(bcidat)
library(R.matlab)

file <- load_bcidat(filename);
data <- file$signal;

marks <- c();
for (i in (1:dim(data)[1]))
{
	if (data[i, 15] != 0)
		marks <- append(marks, c(i))
}
# return(marks)
for (m in (1:length(marks)))
  {
  if ((data[marks[m], 15] == 2) & (data[marks[m+1], 15] != 2))
      {
      datares = data[(marks[m]+1):dim(data)[1], ]
      break
      }
  }
#return(datares)
# matname = 
writeMat(sprintf("%s.mat", filename), data = datares)
}
