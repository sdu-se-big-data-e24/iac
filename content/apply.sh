#!/usr/bin/env bash

../scripts/portforward/terminate.sh
../scripts/portforward/all.sh

terraform apply
