#!/bin/bash

# Bookinfo Rating Service
cd ~/ratings
# Build Docker Image for rating service
docker build -t ratings .

# Run MongoDB with initial data in database
docker run -d --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2

# Run ratings service on port 8080
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb \
  -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings



# Bookinfo Details Service
cd ~/details
# Build Docker Image for details service
docker build -t details .

# Run details service on port 8081
docker run -d --name details -p 8081:8081 details


# sitkmutt-bookinfo-reviews
cd ~/reviews
# Build Docker Image for reviews service
docker build -t reviews .

# Run ratings service on port 8082
docker run -d --name reviews -p 8082:8082 --link ratings:ratings -e ENABLE_RATINGS=true -e 'RATINGS_SERVICE=http://ratings:8080' reviews



# Bookinfo Productpage Service
cd ~/productpage
# Build Docker Image for productpage service
docker build -t productpage .

# Run productpage service on port 8083
docker run -d --name productpage -p 8083:8083 --link details:details --link ratings:ratings --link reviews:reviews -e 'DETAILS_HOSTNAME=http://details:8081' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'REVIEWS_HOSTNAME=http://reviews:9080' productpage

