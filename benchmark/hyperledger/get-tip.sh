#!/bin/bash
curl -X GET 127.0.0.1:7050/chain 2> /dev/null | cut -d ':' -f 2 | cut -d ',' -f 1
