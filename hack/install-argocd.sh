#!/usr/bin/env bash

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
    --create-namespace \
    --namespace=argocd \
    --values values.yaml \
    --wait

# envsubst <"$DAG_HOME/helm_vars/dag/values.tpl.yaml" >"$DAG_HOME/helm_vars/dag/values.yaml"

# git commit -a -m "Init DAG"
# git push origin "${DAG_TARGET_VERSION}"
google-chrome argo-127.0.0.1.sslip.io
# envsubst <"$DAG_HOME/k8s/dag/app.yaml" | kubectl apply -f -
# ARGOCD_SERVER_HOST=argo-127.0.0.1.sslip.io
# argocd login --plaintext "${ARGOCD_SERVER_HOST}" --insecure --username admin --password='demo@123'

# argocd app sync --assumeYes --timeout=600 dag-apps

# # Patching Gitea with Drone IP for resolving
# DRONE_SERVICE_IP="$(kubectl get svc -n drone drone -ojsonpath='{.spec.clusterIP}')"
# export DRONE_SERVICE_IP
# kubectl patch statefulset gitea -n default --patch "$(envsubst <$DAG_HOME/k8s/gitea/patch.json)"

# kubectl rollout status -n default statefulset gitea --timeout=30s
