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

interevent.times <- function(separated, nruns = 8, time = "BCBP") {
        
        if(time == "BCBP") {
                BCBP.times <- sapply(sepnames,function(x) NULL)
                for(i in 1:nruns) {
                        BCBP.time <- separated[[i]][2] - separated[[i]][1]
                        interevent.times[[i]] <- BCBP.time
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
                        BMBC.times[[i]] <- BMBC.timesvector
                }
                return(BMBC.times)
        }
}