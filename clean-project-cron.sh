#!/bin/bash
# set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

main() {   
    ## get all source project scheduler. logic is same as show-project-cron.sh 
    eval $(login $exec_env_name)
    exec_azkaban_address=$tmp_azkaban_address
    exec_session_id=$tmp_session_id

    ## project produce env
    if [ "$produce_azkaban_address" == "$exec_azkaban_address" ]; then
        log_error "[clean cron] produce env is not allowed to clean cron!"
        exit
    fi

    flow_name_join_str=""
    flow_count=""
    project_id=""
    execute_project_id=""

    eval $(get_project_flow "$execute_project_name" $exec_session_id $exec_azkaban_address)
    execute_project_id=$project_id

    log_info "[clean cron] project name: ${execute_project_name}, project id: ${execute_project_id}"

    flow_name_arr=($(echo "$flow_name_join_str" | tr "," "\n"))
    for flow_name in ${flow_name_arr[@]}
    do
        if [ -n "${flow_name_allowlist}" ] && [[ ! ${flow_name_allowlist} =~ $flow_name ]]; then
            log_info "[clean cron] flow name: $flow_name, not in allow list, will not sync"
            continue
        fi

        cron=""
        schedule_id=""
        eval $(get_flow_schedule_and_id $execute_project_id $flow_name $exec_session_id $exec_azkaban_address)

        if [ -n "${cron}" ]; then
            log_info "[clean cron] flow name: $flow_name, current cron: $cron"
            delete_cron_ret=$(delete_flow_schedule $schedule_id $exec_session_id $exec_azkaban_address)
            log_info "[clean cron] flow name: $flow_name, delete cron result: $delete_cron_ret"
        else
            log_info "[clean cron] flow name: $flow_name, cron empty"
        fi
    done
}

main
