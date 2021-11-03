#!/bin/bash
# set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

main() {   
    ## get all source project scheduler. logic is same as show-project-cron.sh 
    eval $(login $search_env_name)
    search_azkaban_address=$tmp_azkaban_address
    search_session_id=$tmp_session_id

    eval $(login $exec_env_name)
    exec_azkaban_address=$tmp_azkaban_address
    exec_session_id=$tmp_session_id

    ## project produce env
    if [ "$produce_azkaban_address" == "$exec_azkaban_address" ]; then
        log_error "produce env is not allowed to set cron!"
        exit
    fi

    if [ -z $search_session_id ] || [ -z $exec_session_id ]; then
        log_error "login failed, please check user and pwd"
        exit
    fi

    flow_name_join_str=""
    flow_count=""
    project_id=""
    eval $(get_project_flow "$search_project_name" $search_session_id $search_azkaban_address)

    if [ -z "$project_id" ]; then
        log_warn "search project: $search_project_name, can not match any project, will exit"
        exit
    fi

    flow_name_arr=($(echo "$flow_name_join_str" | tr "," "\n"))
    echo "Info: search project: $search_project_name, flow count: ${#flow_name_arr[@]}"
    for flow_name in ${flow_name_arr[@]}
    do
        cron_expression=$(get_flow_schedule $project_id $flow_name $search_session_id $produce_azkaban_address)
        echo "Info: flow name: $flow_name, cron: $cron_expression"
        if [ -n "$cron_expression" ]; then
            ## set flow's scheduler
            ### if fix schedule is set, need set $fix_schedule_cron, but the premise is this flow has
            ### schedule in the source env
            if [ -n "$fix_schedule_cron" ]; then
                set_cron_ret=$(set_flow_schedule $target_project_name $flow_name "$fix_schedule_cron" $exec_session_id $exec_azkaban_address)
            else
                set_cron_ret=$(set_flow_schedule $target_project_name $flow_name "$cron_expression" $exec_session_id $exec_azkaban_address)
            fi
            log_info "flow name: $flow_name: cron: $cron_expression, set result: $set_cron_ret"
        fi
    done
}

main
