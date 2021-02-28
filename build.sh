#!/bin/sh
echo "BUILD SCRIPT: Script alive!"

echo "BUILD SCRIPT: building with Dockerfile..."
docker build -t docker.luzifer.cloud/antmediaserver:2.3.0 .

echo "BUILD SCRIPT: building done. Pushing..."
 
docker push docker.luzifer.cloud/antmediaserver:2.3.0
 
echo "BUILD SCRIPT: successfully pushed."

return 0