run:
	sh run-project.sh

show_cron:
	sh show-project-cron.sh

kill:
	sh kill-jobs.sh

set_cron:
	sh set-project-cron.sh

reset_cron:
	sh reset-project-cron.sh

clean_cron:
	sh clean-project-cron.sh

set_perm:
	sh set-project-permission.sh

set_perm_writeonly:
	sh set-project-permission.sh WRITEONLY

set_perm_readwrite:
	sh set-project-permission.sh READANDWRITE

delete_perm:
	sh set-project-permission.sh DELETE