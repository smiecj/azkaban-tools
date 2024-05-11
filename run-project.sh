#!/bin/bash
#set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

input_flow_name=""
if [ $# -eq 1 ] && [ -n $1 ]; then
	input_flow_name=$1
fi

# start all flow by project name
start_all_flow() {
    eval $(login $exec_env_name)
    session_id=$tmp_session_id
    azkaban_address=$tmp_azkaban_address
    ## protect produce env
    if [ "$produce_azkaban_address" != "$azkaban_address" ]; then
        if [ -n "${input_flow_name}" ]; then
            start_flow_by_project_name_and_flow_name $execute_project_name $input_flow_name $session_id $azkaban_address
        else
            start_all_flow_by_project_name $execute_project_name $session_id $azkaban_address
        fi
    else
        log_error "produce environment is not allow to start flow!"
    fi
}

start_all_flow
