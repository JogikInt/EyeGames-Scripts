lapply(lapply(list.files(pattern = ".csv$"), runTimes, time = "BMBC"), function(x) unlist(sprintf("%.1f%%", 100*(length(x[x>30])/length(x)))))
