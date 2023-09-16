#!/usr/local/bin/bash

terraform state list | rg module.$1 | xargs -I _ printf '\-target %s ' _
