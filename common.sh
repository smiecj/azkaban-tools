# login and get session id
login() {
    local env_name=$1
    eval $(get_azkaban_env_info_by_envname $env_name)
    local login_ret=`curl -X POST --data "action=$command_login&username=$tmp_azkaban_user&password=$tmp_azkaban_password" http://$tmp_azkaban_address 2>/dev/null`
    #session_id=`echo "$login_ret" | jq ".status"`
    local tmp_session_id=`echo "$login_ret" | jq '.["session.id"] // empty' | tr -d '"'`
    echo "tmp_azkaban_address=$tmp_azkaban_address"
    echo "tmp_session_id=$tmp_session_id"
}

# get project info
## return:
## project_id
## flow_name_join_str: project's all flow name, join by comma
## flow_count
get_project_flow() {
    local project_name=$1
    local session_id=$2
    local azkaban_address=$3

    local get_project_ret=`curl "http://$azkaban_address/manager?ajax=$command_get_project_flows&project=$project_name&session.id=$session_id" 2>/dev/null`

    local tmp_project_id=`echo "$get_project_ret" | jq '.projectId // empty'`
    local tmp_flow_count=`echo "$get_project_ret" | jq '.flows | length'`
    local tmp_flow_name=`echo "$get_project_ret" | sed "s/ //g" | jq -r '[.flows[].flowId] | join(",")'`
    echo "project_id=$tmp_project_id"
    echo "flow_name_join_str=$tmp_flow_name"
    echo "flow_count=$tmp_flow_count"
}

# get flow execute history
## output:
## exec_count: total execute times
get_flow_exec_history() {
    local project_name=$1
    local flow_name=$2
    local start=$3
    local length=$4
    local session_id=$5
    local azkaban_address=$6

    if [ $length -gt $search_limit ]; then
        echo ""
        return 0
    fi

    local get_project_ret=`curl "http://$azkaban_address/manager?ajax=$command_get_flow_exec_history&project=$project_name&flow=$flow_name&start=$start&length=$length&session.id=$session_id" 2>/dev/null`

    local tmp_exec_count=`echo "$get_project_ret" | jq '.total // empty'`
    echo "exec_count=$tmp_exec_count"
}

# get all executing task ids by project name and flow name
## output: all executing execution ids
get_flow_excuting() {
    local project_name=$1
    local flow_name=$2
    local session_id=$3

    local get_executing_job_ret=`curl "http://$azkaban_address/executor?ajax=$command_get_flow_executing&project=$project_name&flow=$flow_name&session.id=$session_id" 2>/dev/null`
    
    if [ -n "$get_executing_job_ret" ]; then
        local tmp_executing_job_ids_str=`echo "$get_executing_job_ret" | jq -r 'select(.execIds != null) | [ .execIds[] | tostring ] | join(",")'`
        echo $tmp_executing_job_ids_str
    else
        echo ""
    fi
}

# get specify flow cron scheduler by project id and flow name
## output: cron expression
get_flow_schedule() {
    local project_id=$1
    local flow_name=$2
    local session_id=$3
    local azkaban_address=$4
    local get_project_ret=`curl "http://$azkaban_address/schedule?ajax=$command_get_schedule&projectId=$project_id&flowId=$flow_name&session.id=$session_id" 2>/dev/null`
    local tmp_cron_expression=`echo "$get_project_ret" | jq '.schedule.cronExpression // empty'`
    ### crontab has '*' mark, need return string format
    echo "$tmp_cron_expression"
}

# set flow by specify schedule
set_flow_schedule() {
    local project_name=$1
    local flow_name=$2
    local schedule=$3
    local session_id=$4
    local azkaban_address=$5

    schedule=`echo "$schedule" | sed -e 's/"//g'`
    local get_project_ret=`curl -k -d ajax=scheduleCronFlow -d projectName=$project_name -d flow=$flow_name --data-urlencode cronExpression="$schedule" -b "azkaban.browser.session.id=$session_id" http://$azkaban_address/schedule 2>/dev/null`
    echo "$get_project_ret"
}

# start project's all flow
start_all_flow_by_project_name() {
    local project_name=$1
    local session_id=$2
    local azkaban_address=$3

    ## get all flow in specify project
    flow_name_join_str=""
    eval $(get_project_flow $project_name $session_id $azkaban_address)

    flow_name_arr=($(echo $flow_name_join_str | tr "," "\n"))
    for i in "${!flow_name_arr[@]}"
    do
        local current_flow_name=${flow_name_arr[$i]}
        echo "flow_name: $current_flow_name"

        ## block and allow filter
        if [[ $execute_block_flow_names =~ $current_flow_name ]]; then
            echo "block flow name: $current_flow_name"
            continue
        elif [ -n "$execute_allow_flow_names" ] && [[ ! $execute_allow_flow_names =~ $current_flow_name ]] ; then
            echo "allow not contain name: $current_flow_name"
            continue
        fi
        local exec_flow_ret=`curl "http://$azkaban_address/executor?ajax=$command_exec_flow&project=$project_name&flow=$current_flow_name&session.id=$session_id" 2>/dev/null`
        echo "flow execute ret: $exec_flow_ret"
    done
}

# stop project's all executing job
kill_all_executing_flow_by_project_name() {
    local project_name=$1
    local session_id=$2
    local azkaban_address=$3

    flow_name_join_str=""
    eval $(get_project_flow $project_name $session_id $azkaban_address)

    flow_name_arr=($(echo $flow_name_join_str | tr "," "\n"))
    for i in "${!flow_name_arr[@]}"
    do
        local current_flow_name=${flow_name_arr[$i]}
        echo "flow_name: $current_flow_name"
        job_ids_str=$(get_flow_excuting $project_name $current_flow_name $session_id)
        echo "job id: $job_ids_str"

        if [ -n $job_ids_str ]; then
            ## stop all job
            job_id_arr=($(echo $job_ids_str | tr "," "\n"))
            for current_job_id in ${job_id_arr[@]}
            do
                echo "to kill job id: $current_job_id"
                local exec_flow_ret=`curl "http://$azkaban_address/executor?ajax=$command_cancel_flow&execid=$current_job_id&session.id=$session_id" 2>/dev/null`
                echo "kill job id: $current_job_id, ret: $exec_flow_ret"
            done
        fi
    done
}