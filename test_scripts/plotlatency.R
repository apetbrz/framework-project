#!/usr/bin/env Rscript

library("jsonlite")
library("ggplot2")
library("collapse")
library("ggrepel")

thread_counts <- list("low" = c(1, 4, 16, 64), "high" = c(256, 1024, 2048, 4096))

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
make_multiple <- function(el, num) {rep(el,num)}
make_string <- function(num) {paste(num, "", sep="")}

# the four endpoints (will make four separate graphs)
endpoint <- c("hello", "static", "dynamic", "hash")

# x axis: 1 1 1 1 4 4 4 4 16 16 16 16 ...
connections <- unlist(lapply(lapply(thread_counts, make_string), make_multiple))

# x axis: axum .net express gin axum .net express gin ...
framework <- c("Axum (Rust)", "ASP.NET (C#)", "Express (JavaScript)", "Gin (Go)")

# for each endpoint (each graph .png)
for(endpnt in endpoint){
  
  tier_index <- 0
  # for each connection count, in order
  for(tier in thread_counts){
    tier_index <- tier_index + 1
    print(endpnt)
    print(tier)
    # initialize values list
    # y axis, latency avgs
    value <- c()
    std_dev <- c()
    for(conn in tier){
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
        std_dev_data_point <- current_data[['tests']][[endpnt]][['data']][['latency_std_deviation']]

        if(is.null(data_point)){
          stop("NULL value found! Data is bad!")
        }

        # append data to values list
        value <- append(value, data_point)
        std_dev <- append(std_dev, std_dev_data_point)

      }# end frmwrk
    }# end conn
  
    connections <- unlist(lapply(lapply(tier, make_string), make_multiple, num=length(framework)))
    framework_axis <- rep(framework,length(tier))

    # store in a dataframe
    df <- data.frame(connections, framework_axis, value, std_dev)

    # print the df, to make sure everything is okay
    print(df)

    # create and save the png
    ggsave(
           # file name uses endpoint name
           paste("graphs/",endpnt,"_data_",names(thread_counts)[tier_index],".png", sep=""), 

           # plot the df
           ggplot(df,
                  # color based on framework, y=data, x=conn count
                  aes(fill=framework_axis, y=value, x=connections)
                  ) + 
           # bar graph
           geom_bar(position=position_dodge(3.1), stat="identity", width=3) + 
           # with std deviation bars
           geom_errorbar(aes(x=connections, ymin=value-std_dev,ymax=value+std_dev), position=position_dodge(3.1), linewidth=0.5) +
           # with labels
           geom_label_repel(aes(label=round(value,2)), position=position_dodge(3.1), size=2) + 
           # title based on endpoint
           ggtitle(paste("/",endpnt,"\nEndpoint",sep="")) +
           # x axis label
           xlab("Concurrent Connection Count") +
           # y axis label
           ylab("Average Response Latency (ms)") +
           # legend label
           labs(fill="Framework") +
           # y limit: 0 and max
           ylim(0,max(value)*1.1) + 
           # order x axis based on connections list (in order)
           scale_x_discrete(limits=connections) #+
           # y axis tick every 100ms
           # scale_y_continuous(breaks=seq(0,max(value)+100,if(tier_index==1) 25 else 200)
    )
  }# end tier
}
