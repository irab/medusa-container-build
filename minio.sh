#!/bin/bash

mc mb data/medusa-exports &&\
minio server /data --console-address ":10001" --address ":10000"