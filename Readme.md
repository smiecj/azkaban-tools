# azkaban_tools

This is a azkaban tools mainly used for execute all azkaban project, sync scheduler or others.
azkaban version: [3.90](https://github.com/azkaban/azkaban/tree/3.90.0)
how to work: access azkaban interface. Refer: [azkaban API documentation](https://azkaban.readthedocs.io/en/latest/ajaxApi.html)

## usage

### get task crontab info by project name
```
make show_cron
```

### sync task crontab info by project name
```
make set_cron
```

### kill current running jobs by project name
```
make kill
```

### run project's all flow
```
make run
```

## configuration
All configuration is in env.sh


### 

| group | configuration | usage | example |
|----------|-----------------------|-------------------------------|---------------------------------|
| **env**     | search_env_name | config and data search from this env , usually test env | test |
|             | exec_env_name | execute env name, usually pre env or produce env | produce |
|             | ${env_name}_azkaban_address | the azkaban address in specify env, eg: test_azkaban_address | localhost:18888
|             | ${env_name}_azkaban_user | the azkaban login username in specify env, eg: test_azkaban_user | admin |
|             | ${env_name}_azkaban_password | the azkaban login password in specify env, eg: test_azkaban_password | admin123 |
| **task**    | search_project_name | start project name, eg: sync crontab, the origin project name | stg |
|             | target_project_name | execute project name, eg: sync crontab, the target project name | stg |
|             | fix_schedule_cron | sync crontab task: if you need set all project flow to a specific crontab, please use this param | "0 0 18 * * ?" |
|             | execute_block_flow_names | run task: block flow name | "(not_execute_task1|not_execute_task2)" |
|             | execute_allow_flow_names | run task: to execute task | "(to_execute_task1|to_execute_task2)" |