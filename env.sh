## env name to switch
search_env_name=produce

exec_env_name=test

## produce env
produce_azkaban_address=produce_host_name:18888
produce_azkaban_user=admin
produce_azkaban_password=admin123

## test env
test_azkaban_address=localhost:18888
test_azkaban_user=azkaban
test_azkaban_password=admin123

## get specific env's information
### output: 
get_azkaban_env_info_by_envname() {
     local env_name=$1
     case "$env_name" in
     "produce")
          echo "tmp_azkaban_address=$produce_azkaban_address"
          echo "tmp_azkaban_user=$produce_azkaban_user"
          echo "tmp_azkaban_password=$produce_azkaban_password"
          ;;
     "test")
          echo "tmp_azkaban_address=$test_azkaban_address"
          echo "tmp_azkaban_user=$test_azkaban_user"
          echo "tmp_azkaban_password=$test_azkaban_password"
          ;;
     "cloud")
          echo "tmp_azkaban_address=$cloud_azkaban_address"
          echo "tmp_azkaban_user=$cloud_azkaban_user"
          echo "tmp_azkaban_password=$cloud_azkaban_password"
          ;;
     esac
}

command_login=login
command_get_project_flows=fetchprojectflows
command_get_flow_exec_history=fetchFlowExecutions
command_get_flow_executing=getRunning
command_get_schedule=fetchSchedule
command_exec_flow=executeFlow
command_cancel_flow=cancelFlow
command_remove_schedule=removeSched

search_project_name="stg"

target_project_name="stg"

flow_name_allowlist="(flow1|flow2)"

# fix_schedule_cron="0 0 18 * * ?"

execute_project_name="dw"
execute_block_flow_names=""
execute_allow_flow_names="(DW_HIVE_CLEAN_DATA)"

# page interface limit
search_limit=10