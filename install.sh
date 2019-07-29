#!/bin/bash

echo 'Starting script execution...'
CONTAINER_NAME="webauthn4j123"
STATUS_UP="Up"
STATUS_EXIT="Exited"
STATUS_NOT_CREATED="Not Created"
FINAL_STATUS=""

get_state()
{

	# #IF_ALREADY_RUNNING=`docker inspect -f '{{.State.Running}}' $CONTAINER_NAME`
	IF_ALREADY_RUNNING=`docker ps -a --filter "name=$CONTAINER_NAME" --format '{{.Status}}'`
	if [[ "$IF_ALREADY_RUNNING" == *${STATUS_UP}* ]]; 
	then
		FINAL_STATUS=STATUS_UP
	elif [[ "$IF_ALREADY_RUNNING" == *${STATUS_EXIT}* ]]; 
	then
		FINAL_STATUS=STATUS_EXIT
	else
		FINAL_STATUS=STATUS_NOT_CREATED
	fi
}

get_state

echo "$FINAL_STATUS"

case "$FINAL_STATUS" in
   "STATUS_UP") 
	  echo '*********Container already built and running************'
		##Every time you do the development, just run these two commands. Now all your configurations in keycloack will persisit
		#copy new jar into container
		echo 'Compiling and building the new webauthn4j-ejb jar'
		mvn clean install
		echo 'Deploying webauthn4j-ejb.jar into container...'
		docker cp webauthn4j-ear/target/keycloak-webauthn4j-ear-*.ear $CONTAINER_NAME:/opt/jboss/keycloak/standalone/deployments
		#restart the container
		echo 'Restarting the container...'
		docker restart $CONTAINER_NAME
   ;;
   "STATUS_EXIT") 
	 	echo '********Container is not running***********'
		##Setup and run image
		#Removing exiting container
		echo 'Removing exiting container...'
		docker rm -f webauthn4j123 
		#run the container
		echo 'Running the container...'
		docker run -p 8080:8080 --name $CONTAINER_NAME -d hypermine/webauthn4j
   ;;
   "STATUS_NOT_CREATED") 
		 echo '********Container is not built***********'
		##Setup and run image
		#Building docker image
		echo 'Building the container...'
		docker build -t hypermine/webauthn4j .
		#run the container
		echo 'Running the container...'
		docker run -p 8080:8080 --name $CONTAINER_NAME -d hypermine/webauthn4j
   ;;
	 *) echo "test"
	 ;;
esac

echo 'Exitting script execution...'
exit
