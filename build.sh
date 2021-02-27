#!/bin/sh
echo "BUILD SCRIPT: Script alive!"

echo "BUILD SCRIPT: building with Dockerfile..."
docker build -t docker.luzifer.cloud/amstest .

echo "BUILD SCRIPT: building done. Pushing..."
 
docker push docker.luzifer.cloud/amstest
 
echo "BUILD SCRIPT: successfully pushed."

return 0