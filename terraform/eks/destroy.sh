#!/bin/bash

terraform destroy --var myip=$(curl -s http://whatismyip.akamai.com/)"/32" --auto-approve
