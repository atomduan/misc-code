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

syn             match           todoKeyWord         "\c^[ ]*\(info:\|sub:\|branch:\|system:\|desc:\|tip:\|tips:\|anchor:\)" 
syn             match           todoTitle           "\(COMPLETED TASK:\|CURRENT TASK:\|BACK_LOG TASKS:\|INFO ENTRY:\|QUESTIONS:\)"
syn             match           todoWeek            "\c^\(week:\)"
syn             match           todoTaskInfo        "\c^[ ]*\(product:\|staging:\|ip:\|port:\|user:\|password:\|database:\|table:\|sql:\)"
syn             match           todoTaskTitle       "^\*)[ ]*[^ ]*" 
syn             match           todoTaskElement     "^[ ]*\.[ ][^ ]*" 
syn             match           todoTaskTODO        "\c\(-->\)\(TODO\)"
syn             match           todoTaskDelimit     "^[ ]*-\+[ ]*$"
syn             match           todoTaskDone        "\c\(-->\)\(DONE\|FORK\|MergeDone\)"
syn             match           todoTaskInvalid     "\c\(-->\)\(INVALID\)"
syn             match           todoTaskYield       "\c\(-->\)\(PENDING\|SCHEDULE\)"
syn             match           todoTaskDOING       "\c\(-->\)\(DOING\)"

hi def link todoKeyWord         Special 
hi def link todoTitle           Comment 
hi def link todoWeek            String 
hi def link todoTaskInfo        Function
hi def link todoTaskTitle       Comment
hi def link todoTaskElement     Comment
hi def link todoTaskTODO        Function 
hi def link todoTaskDelimit     Delimiter 
hi def link todoTaskDone        Type 
hi def link todoTaskInvalid     Special 
hi def link todoTaskYield       String 
hi def link todoTaskDOING       Todo 
