#!/bin/bash
#set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

# set project permission
permission="READONLY"
if [ $# -eq 1 ]; then
    permission=$1
fi

set_project_permission() {
    eval $(login $exec_env_name)
    session_id=$tmp_session_id
    azkaban_address=$tmp_azkaban_address
    ## protect produce env
    if [ "$produce_azkaban_address" != "$azkaban_address" ]; then
        for current_project_name in ${execute_project_name_arr[@]}
        do
            if [ "READONLY" == "${permission}" ]; then
                set_project_perm_readonly $current_project_name ${execute_user_name} ${session_id} ${azkaban_address}
            elif [ "READANDWRITE" == "${permission}" ]; then
                set_project_perm_readandwrite $current_project_name ${execute_user_name} ${session_id} ${azkaban_address}
            elif [ "READSCHEDULE" == "${permission}" ]; then
                set_project_perm_readandschedule $current_project_name ${execute_user_name} ${session_id} ${azkaban_address}
            elif [ "WRITEONLY" == "${permission}" ]; then
                set_project_perm_writeonly $current_project_name ${execute_user_name} ${session_id} ${azkaban_address}
            elif [ "DELETE" == "${permission}" ]; then
                delete_project_perm $current_project_name ${execute_user_name} ${session_id} ${azkaban_address}
            fi
        done
    else
        log_error "produce environment is not allow to set permission!"
    fi
}

set_project_permission