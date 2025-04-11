# A Performance Comparison of Modern Web Frameworks
### Arthur Petroff, USC Upstate CSCI 599 - Senior Seminar, Spring 2025

This is a study into web back-end framework performance and efficiency. Four frameworks were selected to develop small testing APIs, which were then benchmarked across four different tests of varying computational requirements. The four frameworks are as follows:

- ASP.NET (C#)
- Axum (Rust)
- Express (JavaScript)
- Gin Gonic (Golang)

[more info todo!]

## Procedure:

### 0. Prerequisites

`Docker version 28.0.4`

### 1. Setup

- Clone this repo (https://github.com/apetbrz/framework-project.git) onto both the hosting server device and the latency testing client device.
- On the server, run `build.sh` to build the docker image, then `run.sh` to start it up.

### 2. Running a test

- On the interactive docker container, use `runserver` to start each server.
- - Axum, ASP.NET, and Gin can all be shut down with CTRL+C
- - `runserver stopexpress` can shut down the Express server
- TODO: install tmux on docker, use `watchresources.sh` on server to log resource usage
- On the testing client, use `test_scripts/runtests.sh` to start each benchmark

## Results

graph pictures todo!
