#!/bin/bash
#set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

# start all flow by project name
start_all_flow() {
    eval $(login $exec_env_name)
    session_id=$tmp_session_id
    azkaban_address=$tmp_azkaban_address
    ## protect produce env
    if [ "$produce_azkaban_address" != "$azkaban_address" ]; then
        start_all_flow_by_project_name $execute_project_name $session_id $azkaban_address
    else
        log_error "produce environment is not allow to start flow!"
    fi
}

start_all_flow
