##sepRuns separates data from unsorted csv file by runs
sepRuns <- function(data, nruns = 8) {
        
        runStart <- 1
        runEnd <- NULL
        runNumber <- 1
      
        sepnames <<- sprintf(fmt = "Run%02.f", 1:nruns)
        separated <- sapply(sepnames,function(x) NULL)
        
        
        for(i in 1:(nrow(data)-1)) {
                if(data$BC[i] > data$BC[i+1]) {
                        runEnd <- i
                        separated[[runNumber]] <- data[runStart:runEnd,]
                        runStart <- i+1
                        runNumber <- runNumber+1
                }
                else if(i == nrow(data)-1) {
                        runEnd <- i+1
                        separated[[runNumber]] <- data[runStart:runEnd,]
                }
        }
        separated
}

##interevent.times returns list of BCBP or BMBC times separated by runs 
interevent.times <- function(separated, nruns = 8, time = "BCBP") {
        
        if(time == "BCBP") {
                BCBP.times <- sapply(sepnames,function(x) NULL)
                for(i in 1:nruns) {
                        BCBP.time <- separated[[i]][2] - separated[[i]][1]
                        names(BCBP.time) <- 'BCBP'
                        BCBP.times[[i]] <- BCBP.time
                }
                return(BCBP.times)
        }
        
        else if(time == "BMBC") {
                BMBC.times <- sapply(sepnames,function(x) NULL)
                for(i in 1:nruns) {
                        BMBC.timesvector <- vector(mode = "numeric",
                                                   length = nrow(separated[[i]])-1)
                        for(n in 1:(nrow(separated[[i]])-1)) {
                                BMBC.timesvector[n] <- separated[[i]][n+1,1]-
                                        separated[[i]][n,3]
                        }
                        BMBC.times[[i]] <- data.frame(BMBC.timesvector)
                        names(BMBC.times[[i]]) <- "BMBC"
                }
                return(BMBC.times)
        }
}

##sepRunTimes receives csv file name and performs sepRuns nad interevent.times on it
sepRunTimes <- function(filename, nruns = 8, time = "BCBP") {
        data <- read.csv2(file = filename, col.names = c('BC', 'BP', 'BM'), header = FALSE)
        separated <- sepRuns(data, nruns)
        interevent.times <- interevent.times(separated, nruns, time)
}

##runTimes return vector of BCBP or BMBC times not separated by runs (for particular file)
runTimes <- function(filename, nruns = 8, time = "BCBP") {
        separated.times <- sepRunTimes(filename, nruns, time)
        runTimes <- unlist(separated.times, use.names = FALSE)
}

##allRunTimes acts like runTimes, but for file list
allRunTimes <- function(filename.list, nruns = 8, time = "BCBP") {
        allRunTimes <- c()
        for(i in 1:length(filename.list)) {
                allRunTimes <- c(allRunTimes, runTimes(filename.list[i], nruns, time))
        }
        allRunTimes
}