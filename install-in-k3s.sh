#! /usr/bin/bash

 helm umssqlrade -i chaos-mesh chaos-mesh/chaos-mesh \
     -n chaos-mesh \
    --create-namespace \
    --set dashboard.create=true \
    --set dashboard.securityMode=false \
    --set chaosDaemon.runtime=containerd \
    --set chaosDaemon.socketPath=/run/k3s/containerd/containerd.sock \
    --set chaosDaemon.privileged=true
