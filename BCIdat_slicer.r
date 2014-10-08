prepare.matlab <- function(filename)
#####################################################################################
#prepare.matlab takes uncut BCI2000 .dat file from e1 experiment and returns .mat file
#with cut record in data variable.
#Uses libraries: bcidat, R.matlab.
#####################################################################################
{
library(bcidat)
library(R.matlab)

#importing signal variable from BCI2000 .dat
file <- load_bcidat(filename);
data <- file$signal;

#loading eyetracker symchroimpulses from channel 15
marks <- c();
for (i in (1:dim(data)[1]))
  {
	if (data[i, 15] != 0)
		marks <- append(marks, c(i))
}

#finding last start impulse and cutting record 
for (m in (1:length(marks)))
  {
  if ((data[marks[m], 15] == 2) & (data[marks[m+1], 15] != 2))
      {
      datares = data[(marks[m]+1):dim(data)[1], ]
      break
      }
  }

#saving to .mat file
writeMat(sprintf("%s.mat", filename), data = datares)
}