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

syn match todoKeyWord       "\c^[ ]*\(info:\|sub:\|branch:\|system:\|desc:\|tip:\|tips:\|anchor:\|[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}:\|AM:\|PM:\)"
syn match todoTitle         "\(ROUTINE TASK:\|COMPLETED TASK:\|CURRENT TASK:\|BACK_LOG TASKS:\|INFO ENTRY:\|PROBLEMS:\|HEDGING OCCURE:\|DAILY REPORT:\)"


syn match todoWeek          "\c^\(week:\)"
syn match todoTaskInfo      "\c^[ ]*\(product:\|staging:\|preview:\|ip:\|port:\|user:\|username:\|passwd:\|password:\|database:\|table:\|sql:\|email:\)"
syn match todoTaskTitle     "^\*)[ ]*[^ ]*"
syn match todoTaskElement   "^[ ]*\.[ ].*"
syn match todoTaskDelimit   "^[ ]*-\+[ ]*$"
syn match todoTaskRef       "\c\(-->\)\([ ]*\)"
syn match todoTaskDone      "\c\(-->\)\(DONE\|FORK\|ROUTINE\|MERGED\)"
syn match todoTaskInvalid   "\c\(-->\)\(INVALID\)"
syn match todoTaskTODO      "\c\(-->\)\(TODO\)"
syn match todoTaskYield     "\c\(-->\)\(PENDING\|SCHEDULE\|HEDGING\)"
syn match todoTaskDOING     "\c\(-->\)\(DOING\)"

hi def link todoKeyWord     Special
hi def link todoTitle       Comment
hi def link todoWeek        String
hi def link todoTaskInfo    Function
hi def link todoTaskTitle   Comment
hi def link todoTaskElement Comment
hi def link todoTaskTODO    Function
hi def link todoTaskDelimit Delimiter
hi def link todoTaskDone    Type
hi def link todoTaskInvalid Special
hi def link todoTaskYield   String
hi def link todoTaskDOING   Todo
hi def link todoTaskRef     String
