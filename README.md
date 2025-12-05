# A Performance Comparison of Modern Web Frameworks
### Arthur Petroff, USC Upstate CSCI 599 - Senior Seminar, Spring 2025

This is a study into web back-end framework performance and efficiency. Four frameworks were selected to develop small testing APIs, which were then benchmarked across four different tests of varying computational requirements. The four frameworks are as follows:

- ASP.NET (C#)
- Axum (Rust)
- Express (JavaScript)
- Gin Gonic (Golang)

Testing was done using [rewrk](https://github.com/lnx-search/rewrk), automated through shell scripts, with data plotted using R.

The four endpoints are:

- `/hello` - Responds with a json `{message: "Hello World!"}`
- `/static` - Responds with an HTML file from local storage
- `/dynamic` - Loads data from a request header and renders it into an HTML template
- `/hash` - Hashes a password and generates a UUID

## Procedure:

### 0. Prerequisites

`Docker version 28+`
`https://github.com/lnx-search/rewrk`

### 1. Setup

- Clone this repo (https://github.com/apetbrz/framework-project.git) onto the hosting server device and the latency testing client device.
- On the server, run `build.sh` to build the docker image, then `run.sh` to start it up.

### 2. Running a test

- On the interactive docker container, use `runserver [framework name]` to start each server.
  - `axum`, `asp.net`, and `gin` can all be shut down with CTRL+C
  - `express` can be stopped with `runserver stopexpress`
- Monitor resource usage on the server with the `test_scripts/watchresources.sh` script. Attach a second shell with `docker exec -it [container] bash`. Run `watchresources.sh` just before commencing a test.
- On the testing client, use `test_scripts/runtests.sh` to start each benchmark.

### 3. Analyzing Data

Requires `R` installation: `https://cloud.r-project.org/`

- To plot latency data, use `test_scripts/plotlatency.R`. It takes data from `freshdata/`.
- To plot resource utilization data, use `test_scripts/parseusage.sh` on the resource usage log file, and then use `test_scripts/plotusage.R`.

## Example Results:

![static endpoint latency](https://github.com/apetbrz/framework-project/blob/main/test_scripts/graphs/static_data_low.png)

![static endpoint resource utilization](https://github.com/apetbrz/framework-project/blob/main/test_scripts/graphs/static_resources.png)
