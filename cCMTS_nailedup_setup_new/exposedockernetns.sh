#!/bin/bash
exposedockernetns () {
	if [ "$1" == "" ]; then
  	  echo "usage: $0 <container_name>"
	  echo "Exposes the netns of a docker container to the host"
          exit 1
        fi

        pid=`docker inspect -f '{{.State.Pid}}' $1`

	if [ $? -ne 0 ];
	then
		printf "error in docker inspect. $1 container does not exist\n"
		exit 1
	fi

	if [ ! -d /var/run/netns ];
	then
		mkdir /var/run/netns
	fi
	if [ ! -f /var/run/netns/$1 ];
	then
        	ln -s /proc/$pid/ns/net /var/run/netns/$1
	fi

        echo "netns of ${1} exposed as /var/run/netns/${1}"
        echo "try:"

        echo "ip netns exec ${1} ip addr list"
   return 0
}
exposedockernetns $1

