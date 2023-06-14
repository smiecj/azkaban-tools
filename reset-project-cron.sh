#!/bin/bash
#set -euxo pipefail

. ./env.sh
. ./log.sh

. ./common.sh

env_target=""
if [ $# -eq 1 ]; then
    env_target=$1
fi

main() {   
    ## get all source project scheduler. logic is same as show-project-cron.sh
    eval $(login $exec_env_name)
    exec_azkaban_address=$tmp_azkaban_address
    exec_session_id=$tmp_session_id

    if [ -n "${env_target}" ]; then
        eval $(get_azkaban_env_info_by_envname $env_target)
        exec_user_azkaban_address=$tmp_azkaban_address
        if [ "${exec_user_azkaban_address}" != "${exec_azkaban_address}" ]; then
            log_warn "to reset cron is not same as exec address, will exit"
            exit 0
        fi
        eval $(login $env_target)
        exec_user_session_id=$tmp_session_id
    fi

    ## project produce env
    if [ "$produce_azkaban_address" == "$exec_azkaban_address" ]; then
        log_error "produce env is not allowed to set cron!"
        exit
    fi

    flow_name_join_str=""
    flow_count=""
    project_id=""
    eval $(get_project_flow "$search_project_name" $exec_session_id $exec_azkaban_address)

    if [ -z "$project_id" ]; then
        log_warn "search project: $search_project_name, can not match any project, will exit"
        exit
    fi

    flow_name_arr=($(echo "$flow_name_join_str" | tr "," "\n"))
    log_info "Info: search project: $search_project_name, flow count: ${#flow_name_arr[@]}"
    for flow_name in ${flow_name_arr[@]}
    do
        if [ -n "${flow_name_allowlist}" ] && [[ ! ${flow_name_allowlist} =~ $flow_name ]]; then
            log_info "flow name: $flow_name, not in allow list, will not sync"
            continue
        fi
        cron=""
        schedule_id=""
        eval $(get_flow_schedule_and_id $project_id $flow_name $exec_session_id $exec_azkaban_address)
        log_info "flow name: $flow_name, cron: $cron, schedule id: $schedule_id"
        if [ -n "$cron" ]; then
            ## reset flow's scheduler
            ### delete scheduler
            delete_cron_ret=$(delete_flow_schedule $schedule_id $exec_session_id $exec_azkaban_address)
            ### set scheduler (target project is same as search project name)
            set_cron_ret=$(set_flow_schedule $search_project_name $flow_name "$cron" ${exec_user_session_id} $exec_azkaban_address)
            log_info "flow name: $flow_name: cron: $cron, delete result: $delete_cron_ret, set result: $set_cron_ret"
        fi
    done
}

main
