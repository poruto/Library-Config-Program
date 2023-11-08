000100231019             CMD        PROMPT('Library Load Config Program')
000101231019             PARM       KWD(KEYNAME) TYPE(*CHAR) LEN(10) MIN(1) PROMPT('Key name')
000104231023             PARM       KWD(EVENT) TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*ALL) VALUES(*ALL +
000105231023                          *CURRENT *USR *SYS) PROMPT('Library type')
