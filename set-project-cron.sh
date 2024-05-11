#!/bin/bash
# set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

main() {
    eval $(login $exec_env_name)
    exec_azkaban_address=$tmp_azkaban_address
    exec_session_id=$tmp_session_id

    ## project produce env
    if [ "$produce_azkaban_address" == "$exec_azkaban_address" ]; then
        log_error "produce env is not allowed to set cron!"
        exit
    fi

    if [ -z $exec_session_id ]; then
        log_error "login failed, please check user and pwd"
        exit
    fi

    if [ -z "$fix_schedule_cron" ]; then
        echo "schedule cron not set"
        exit
    fi

    flow_name_join_str=""
    project_id=""

    eval $(get_project_flow "$target_project_name" $exec_session_id $exec_azkaban_address)

    flow_name_arr=($(echo "$flow_name_join_str" | tr "," "\n"))
    for flow_name in ${flow_name_arr[@]}
    do
        if [ -n "${flow_name_allowlist}" ] && [[ ! ${flow_name_allowlist} =~ $flow_name ]]; then
            log_info "flow name: $flow_name, not in allow list, will not sync"
            continue
        fi
        cron_expression=$(get_flow_schedule $project_id $flow_name $exec_session_id $exec_azkaban_address)
        log_info "flow name: $flow_name, current cron: $cron_expression"
        
        ## set flow's scheduler
        ### if current flow already has cron, will not overwrite
        if [ -n "$cron_expression" ]; then
            log_info "flow name: $flow_name: already has cron: $cron_expression, will not set"
            continue
        fi
        set_cron_ret=$(set_flow_schedule $target_project_name $flow_name "$fix_schedule_cron" $exec_session_id $exec_azkaban_address)
        log_info "flow name: $flow_name: cron: $fix_schedule_cron, set result: $set_cron_ret"
    done
}

main
