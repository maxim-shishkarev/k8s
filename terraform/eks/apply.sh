#!/bin/bash

terraform apply --var myip=$(curl -s http://whatismyip.akamai.com/)"/32" --auto-approve
