#! /usr/bin/bash

kubectl delete -f k8s/03-job.yaml
kubectl delete -f k8s/04-pvc.yaml

kubectl apply -f k8s/01-configmap.yaml
kubectl apply -f k8s/03-job.yaml
kubectl apply -f k8s/04-pvc.yaml