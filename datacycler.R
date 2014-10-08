cycle.dat <- function(csv2file)
#####################################################################################
#cycle.dat cycles through BCI2000 .dat files specified in columns of e1.csv (comma
#separated file) and saves .mat files with cut records (using prepare.matlab) to sub-
#folders "wd/experiment_number/fixation_latency
#####################################################################################
{
  source('D:/BCILab/my_progs/BCIdat_slicer.r')
  
  records <- read.csv2(csv2file)
  for (n in 1:length(records$X1200ms))
  {
    folder <- sprintf("%s/1200ms/", substr(records$X1200ms[n], start=1, stop=4))
    dir.create(folder, showWarnings = FALSE, recursive = TRUE)
    name <- sprintf("%s", records$X1200ms[n])
    dirname <- sprintf("%s%s", folder, name)
    prepare.matlab(name, dirname)
  }
  for (n in 1:length(records$X800ms))
  {
    folder <- sprintf("%s/800ms/", substr(records$X800ms[n], start=1, stop=4))
    dir.create(folder, showWarnings = FALSE, recursive = TRUE)
    name <- sprintf("%s", records$X800ms[n])
    dirname <- sprintf("%s%s", folder, name)
    prepare.matlab(name, dirname)
  }
}
