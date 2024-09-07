#!/bin/bash

mc mb data/medusa &&\
minio server /data --console-address ":10001" --address ":10000"