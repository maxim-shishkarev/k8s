#!/bin/bash

help(){
    script_name=$(basename $0)
    echo "${script_name} --install, --start, --help (this message)"
}

case $1 in 
    --install)
        brew install hyperkit minikube
    ;;

    --start)
        minikube start --driver=hyperkit 
        minikube status
    ;;

    --help)
        help
    ;;

    *)
        help
        exit 1
    ;;

esac