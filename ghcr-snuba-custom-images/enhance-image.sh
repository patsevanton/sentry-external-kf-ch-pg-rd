#!/bin/bash

#pip install https://github.com/pavels/sentry-s3-nodestore/releases/download/v1.0.3/sentry-s3-nodestore-1.0.3.tar.gz
for c in $(ls -1 /usr/local/share/ca-certificates/)
do
    cat /usr/local/share/ca-certificates/$c >> $(python3 -m certifi) && echo >> $(python3 -m certifi)
done
update-ca-certificates
