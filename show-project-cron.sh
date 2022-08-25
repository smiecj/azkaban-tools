#!/bin/bash
# set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

main() {
    eval $(login $search_env_name)
    azkaban_address=$tmp_azkaban_address
    session_id=$tmp_session_id
    
    if [ -z $session_id ]; then
        echo "Error: login failed, please check user and pwd"
        exit
    fi

    flow_name_join_str=""
    flow_count=""
    project_id=""
    eval $(get_project_flow "$search_project_name" "$session_id" $azkaban_address)

    if [ -z "$project_id" ]; then
        echo "Warning: search project: $search_project_name, can not match any project, will exit"
        exit
    fi

    ## get each flow's schedule, and statistical flow count which has schedule
    flow_name_arr=($(echo "$flow_name_join_str" | tr "," "\n"))
    log_info "Info: search project: $search_project_name, flow count: ${#flow_name_arr[@]}"
    flow_with_scheduler_count=0
    for flow_name in ${flow_name_arr[@]}
    do
        cron_expression=$(get_flow_schedule $project_id $flow_name $session_id $azkaban_address)
        if [ -n "$cron_expression" ]; then
            log_info "flow name: $flow_name, cron: $cron_expression"
            flow_with_scheduler_count=$((flow_with_scheduler_count + 1))
        else
            log_info "flow name: $flow_name, cron empty"
        fi
    done
    log_info "Info: search project: $search_project_name, flow count: ${#flow_name_arr[@]}, with scheduler flow count: $flow_with_scheduler_count"
}

main
