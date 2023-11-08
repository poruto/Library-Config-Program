000100231023     H BndDir('PBNDDIR')
000101231023     H DFTACTGRP(*NO)
000103231023
000104231019           // Program parameters
000105231019           dcl-pi *n;
000106231019             PKeyName char(10);
000107231019             PLoadType char(10);
000108231019           end-pi;
000109231019
000110231019           // Define Logical File
000111231019           dcl-f LIBLLF usage(*input);
000112231019
000113231019           // Constants
000114231019           dcl-c LOAD_ALL_TYPES '*ALL';
000115231019
000116231019           // Define Variables
000117231019           dcl-s KEYNAME char(10);
000118231019           dcl-s LIBRARY char(10);
000119231019           dcl-s TYPE char(10);
000120231019           dcl-s SEQNO packed(4:0);
000121231019
000122231019           // Variable to check success of SetJobLibrary procedure
000123231019           dcl-s Success char(1) inz('0');
000127231019
000128231019           // Prototypes
000134231019           dcl-pr SetJobLibrary extpgm('SETJOBLIB');
000135231019             LibraryName char(10);
000136231019             LibraryType char(10);
000137231019             Success char(1);
000138231019           end-pr;
000139231023
000140231023           dcl-s cmd char(100);
000141231023
000142231023           dcl-pr ExecuteCLCommand;
000143231023             cmd char(100);
000145231023           end-pr;
000146231023
000147231023           dcl-pr ClearLibrariesOfTypeFromLibl;
000148231023             LibraryType char(10);
000149231023           end-pr;
000150231023
000152231023           // Clear Libraries by Type
000153231023           ClearLibrariesOfTypeFromLibl(PLoadType);
000158231019
000159231019           read LIBLLF;
000160231019           dow not %eof(LIBLLF);
000161231019
000162231019             if KEYNAME = PKeyName;
000163231019
000164231019               if PLoadType = LOAD_ALL_TYPES or TYPE = PLoadType;
000165231019
000166231019                 SetJobLibrary(LIBRARY : TYPE : Success);
000167231019
000168231023                 if Success = '0';
000171231019                   dsply ('Error occured while setting library.');
000172231019                 endIf;
000173231019
000174231019               endIf;
000175231019             endIf;
000176231019
000177231019             read LIBLLF;
000178231019
000179231019           endDo;
000180231019
000181231019           *inlr = *on;
000182231019           return;
000183231023
