#!/bin/bash
bash bash/prereqs.sh
echo "-------------------------"
echo "choose an option"
echo "[1]. Generate variables"
echo "[2]. Provision nodes"
echo "[3]. Base node configuration"
echo "[4]. Bootstrap cluster"
read -n 1 option
if [ $option == "1" ]
then
    bash bash/regen_vars.sh
elif [ $option == "2" ]
then
    bash bash/provision.sh
elif [ $option == "3" ]
then
    bash bash/config.sh
elif [ $option == "4" ]
then
    bash bash/bootstrap.sh
else
    echo "wrong option"
fi