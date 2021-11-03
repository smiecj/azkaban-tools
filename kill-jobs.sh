#!/bin/bash
#set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

# stop all flow by project name
stop_all_flow() {
    eval $(login $exec_env_name)
    session_id=$tmp_session_id
    azkaban_address=$tmp_azkaban_address
    ## protect produce env, avoid wrong config
    if [ "$produce_azkaban_address" == "$tmp_azkaban_address" ]; then
        log_error "produce env is not allowed to stop flow!"
        exit
    fi
    
    kill_all_executing_flow_by_project_name $execute_project_name $session_id $azkaban_address
}

stop_all_flow