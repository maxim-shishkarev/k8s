#!/bin/bash

terraform plan --var myip=$(curl -s http://whatismyip.akamai.com/)"/32" 
