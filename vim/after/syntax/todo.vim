" Vim syntax file
" Language: todo list
" Maintainer: duanjuntao

if version < 600
 finish
endif
if exists("b:current_syntax")
 syntax clear
endif
let b:current_syntax = "todo"
syn             match           todoKeyWord     "\(info:\|sub:\|branch:\|system:\|desc:\)" 
syn             match           todoTitle       "\(COMPLETED TASK\|CURRENT TASK\|BACK_LOG TASKS\|INFO ENTRY\)"
syn             match           todoWeek        "^\(week:\)"
syn             match           todoTaskInfo    "\(product:\|staging:\|[^ ]\+user:\|[^ ]\+password:\|user:\|password:\)"
syn             match           todoTaskTitle   "^\*).*$"
syn             match           todoTaskState   "\(-->\)\(TODO\|DONE\|PENDING\|SCHEDULE\|INVALID\)"

hi def link todoKeyWord         Special 
hi def link todoTitle           Comment 
hi def link todoWeek            String 
hi def link todoTaskInfo        Function
hi def link todoTaskTitle       Comment
hi def link todoTaskState       String 
