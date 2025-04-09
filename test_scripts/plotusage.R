#!/usr/bin/env Rscript

library("jsonlite")
library("ggplot2")
library("collapse")
library("ggrepel")

thread_counts <- c(1, 4, 16, 64, 256, 1024, 2048, 4096)

print("Reading from freshdata/")
print("Please ensure only one file from each test is included")

#read files
axum_files <- Sys.glob(file.path("freshdata/usage_axum*.csv"))
dotnet_files <- Sys.glob(file.path("freshdata/usage_dotnet*.csv"))
express_files <- Sys.glob(file.path("freshdata/usage_node*.csv"))
gin_files <- Sys.glob(file.path("freshdata/usage_gin*.csv"))

#extract csvs
axum_data <- lapply(axum_files, read.csv, header=FALSE)
dotnet_data <- lapply(dotnet_files, read.csv, header=FALSE)
express_data <- lapply(express_files, read.csv, header=FALSE)
gin_data <- lapply(gin_files, read.csv, header=FALSE)

#read json files
axum_files <- Sys.glob(file.path("freshdata/data_axum*.json"))
dotnet_files <- Sys.glob(file.path("freshdata/data_dotnet*.json"))
express_files <- Sys.glob(file.path("freshdata/data_express*.json"))
gin_files <- Sys.glob(file.path("freshdata/data_gin*.json"))

#extract json
axum_latency_data <- lapply(axum_files, fromJSON)
dotnet_latency_data <- lapply(dotnet_files, fromJSON)
express_latency_data <- lapply(express_files, fromJSON)
gin_latency_data <- lapply(gin_files, fromJSON)

#consolidate
data <- list(axum_data[[1]], dotnet_data[[1]], express_data[[1]], gin_data[[1]])
data <- lapply(data, setNames, nm=c("timestamp","cpupct","memMiB"))
latency_data <- list(axum_latency_data, dotnet_latency_data, express_latency_data, gin_latency_data)

# helper functions:
make_multiple <- function(el, num) {rep(el,num)}
make_string <- function(num) {paste(num, "", sep="")}

# the four endpoints (will make four separate graphs)
endpoint <- c("hello", "static", "dynamic", "hash")

# x axis: axum .net express gin axum .net express gin ...
framework <- rep(c("Axum (Rust)", "ASP.NET (C#)", "Express (JavaScript)", "Gin (Go)"),8)

connections <- unlist(lapply(lapply(thread_counts, make_string), make_multiple, 4))

# for each endpoint (each graph .png)
for(endpnt in endpoint){
  # initialize values list
  # y axis, latency avgs
  cpu_value <- c()
  mem_value <- c()
  # for each connection count, in order
  for(conn in thread_counts){
    print(endpnt)
    print(conn)
    # for each framework, in order
    for(frmwrk_index in 1:4){
      
      # get the appropriate data for the current connection count

      current_data <- data[[frmwrk_index]]

      current_latency_data <- latency_data[[frmwrk_index]][[
        # regex string: checks for the connection count in between _ and -,
        # with zero or more leading zeroes
        # grep returns index that matches on 'test' (testname)
        grep(paste("_[0]*",conn,"-",sep=""),
          # get_elem returns a list of the test names
          get_elem(latency_data[[frmwrk_index]], 'test'))
      ]]
      test_date <- current_latency_data[["date"]]
      test_time <- as.POSIXct(current_latency_data[['tests']][[endpnt]][['time']],format="%H:%M:%S")

      data_point <- subset(current_data,
                           as.POSIXct(timestamp,format="%H:%M:%S") >= test_time &
                           as.POSIXct(timestamp,format="%H:%M:%S") < (test_time + 60)
                         )
      data_point <- data_point[-c(1,length(data_point)),]
      print(data_point)

      if(is.null(data_point)){
        stop("NULL value found! Data is bad!")
      }

    # append data to values list
    cpu_value <- append(cpu_value, mean(data_point$cpupct))
    mem_value <- append(mem_value, mean(data_point$memMiB))

    }# end frmwrk
      
  }# end conn
  

  # store in a dataframe
  df <- data.frame(connections, framework, cpu_value, mem_value)

  # print the df, to make sure everything is okay
  print(df)

  # create and save the png
  ggsave( height=7, width=10,
          # file name uses endpoint name
          paste("graphs/",endpnt,"_resources.png", sep=""), 

          # plot the df
          ggplot() + 
          # bar graph
          geom_bar(
                  data=df,
                  mapping=aes(x=connections, y=(mem_value/25), group=framework), 
                  fill="grey",
                  color="darkgray",
                  linewidth=.5,
                  position=position_dodge(3.2), 
                  stat="identity",
                  width=3.2
                  ) + 
          geom_bar(
                  data=df,
                  mapping=aes(x=connections, y=cpu_value, fill=framework),
                  position=position_dodge(3.2), 
                  color="grey",
                  linewidth=.5,
                  stat="identity",
                  width=1.8
                  ) + 
          # with labels
          #geom_label_repel(aes(label=round(value,2)), position=position_dodge(3.1), size=2) + 
          # title based on endpoint
          ggtitle(paste("/",endpnt," Endpoint\nResource Utilization",sep="")) +
          # x axis label
          xlab("Concurrent Connection Count") +
          # legend label
          labs(fill="Framework") +
          # order x axis based on connections list (in order)
          scale_x_discrete(limits=connections) +
          # y axis tick every 100ms
          scale_y_continuous(
                            breaks=seq(0,100,10),
                            limits=c(0,110),
                            name="CPU Utilization %",
                            sec.axis=sec_axis(~.*25, breaks=seq(0,3000,250), name="Memory Usage (MiB)")
          )
    )
}
