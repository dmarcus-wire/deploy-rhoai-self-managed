#!/bin/bash

# Delete the rhods-operator
oc create -f Uninstallation/uninstall-configmap.yaml

# Set an environment variable for the redhat-ods-applications project.
PROJECT_NAME=redhat-ods-applications

# Delete the app project and resources
while oc get project $PROJECT_NAME &> /dev/null; do
echo "The $PROJECT_NAME project still exists"
sleep 1
done
echo "The $PROJECT_NAME project no longer exists"

# Delete the operator project
oc delete namespace redhat-ods-operator

# Verify the cleanup
oc get subscriptions --all-namespaces | grep rhods-operator

# Verify no projects exists
oc get namespaces | grep -e redhat-ods* -e rhods*