#!/usr/bin/env Rscript

library("jsonlite")
library("ggplot2")
library("collapse")

thread_counts <- c(1, 4, 16, 64, 256, 1024, 2048, 4096)

print("Reading from freshdata/")
print("Please ensure only one file from each test is included")
print("Checking these connection counts:")
print(thread_counts)

#read files
axum_files <- Sys.glob(file.path("freshdata/data_axum*.json"))
dotnet_files <- Sys.glob(file.path("freshdata/data_dotnet*.json"))
express_files <- Sys.glob(file.path("freshdata/data_express*.json"))
gin_files <- Sys.glob(file.path("freshdata/data_gin*.json"))

#extract json
axum_data <- lapply(axum_files, fromJSON)
dotnet_data <- lapply(dotnet_files, fromJSON)
express_data <- lapply(express_files, fromJSON)
gin_data <- lapply(gin_files, fromJSON)

#consolidate
data <- list("axum" = axum_data, "dotnet" = dotnet_data, "express" = express_data, "gin" = gin_data)

# helper functions:
make_four <- function(el) {rep(el,4)}
make_string <- function(num) {paste(num, "", sep="")}

# the four endpoints (will make four separate graphs)
endpoint <- c("hello", "static", "dynamic", "hash")

# x axis: 1 1 1 1 4 4 4 4 16 16 16 16 ...
connections <- unlist(lapply(lapply(thread_counts, make_string), make_four))

# x axis: axum .net express gin axum .net express gin ...
framework <- rep(c("Axum (Rust)", "ASP.NET (C#)", "Express (JavaScript)", "Gin (Go)"), 8)

# for each endpoint (each graph .png)
for(endpnt in endpoint){
  
  # initialize values list
  # y axis, latency avgs
  value <- c()

  # for each connection count, in order
  for(conn in thread_counts){

    # for each framework, in order
    for(frmwrk in data){
      
      # get the appropriate data for the current connection count
      current_data <- frmwrk[[
        # regex string: checks for the connection count in between _ and -,
        # with zero or more leading zeroes
        # grep returns index that matches on 'test' (testname)
        grep(paste("_[0]*",conn,"-",sep=""),
          # get_elem returns a list of the test names
          get_elem(frmwrk, 'test'))
      ]]

      data_point <- current_data[['tests']][[endpnt]][['data']][['latency_avg']]

      if(is.null(data_point)){
        stop("NULL value found! Data is bad!")
      }

      # append data to values list
      value <- append(value, data_point)

    }# end frmwrk
  }# end conn
  
  print(value)
  print(connections)

  # store in a dataframe
  df <- data.frame(connections, framework, value)

  # print the df, to make sure everything is okay
  print(df)

  # create and save the png
  ggsave(
         # file name uses endpoint name
         paste(endpnt,"_data.png", sep=""), 

         # plot the df
         ggplot(df,
                # color based on framework, y=data, x=conn count
                aes(fill=framework, y=value, x=connections)
                ) + 
         # bar graph
         geom_bar(position="dodge", stat="identity") + 
         # title based on endpoint
         ggtitle(paste("/",endpnt,"\nEndpoint",sep="")) +
         # x axis label
         xlab("Concurrent Connection Count") +
         # y axis label
         ylab("Average Response Latency (ms)") +
         # order x axis based on connections list (in order)
         scale_x_discrete(limits=connections) +
         # y axis tick every 100ms
         scale_y_continuous(breaks=seq(0,4000,100))
  )
}
