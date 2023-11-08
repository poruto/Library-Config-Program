000101231025      //********************************************************************************************
000102231025      //                                                                                           *
000103231025      //  System Name .....:                                                                       *
000104231025      //                                                                                           *
000105231025      //  Program Name ....: Library Config Load Program                                           *
000106231025      //                                                                                           *
000107231025      //  Program No. .....: PLIBLLOAD                                                             *
000108231025      //                                                                                           *
000109231025      //  Description .....:                                                                       *
000110231025      //                                                                                           *
000111231025      //  Created .........: 25.10.2023                                                            *
000112231025      //  by ..............: Tomas Porubsky                                                        *
000113231025      //                                                                                           *
000114231025      //********************************************************************************************
000115231025      //                                                                                           *
000116231025      //  MODIFICATION CONTROL                                                                     *
000117231025      //  ====================                                                                     *
000118231025      //  FIXNO      BY     DD/MM/YYYY  COMMENT                                                    *
000119231025      //  ---------  -----  ----------  ---------------------------------------------------------- *
000120231025      //============================================================================================
000121231025     H BndDir('PBNDDIR')
000122231023     H DFTACTGRP(*NO)
000123231108
000124231108           // Data structures
000125231108           dcl-ds PAReleaseInfo qualified;
000126231108             Release char(10);
000127231108             Application char(10);
000128231108             Group char(10);
000129231108           end-ds;
000130231108
000131231108           dcl-ds PAJobDInfo qualified;
000132231108             JobDescription char(10);
000133231108             Library char(10);
000135231108           end-ds;
000149231108
000150231019           // Program parameters
000151231019           dcl-pi *n;
000152231108             PMode char(10);
000153231108
000154231108             // USER MODE
000155231019             PKeyName char(10);
000156231019             PLoadType char(10);
000157231108
000158231108             // ALDON MODE
000159231108             PAREL char(30); // PAReleaseInfo Structure
000160231108
000161231108             PAENV char(3);
000162231108             PADVPName char(10);
000163231108             PAEMGCHK CHAR(4);
000164231108
000165231108             PAJOBD char(20); // PAJobDInfo Structure
000167231108
000168231108             PADTASet char(10);
000169231108             PAEDTLibl char(4);
000170231108           end-pi;
000171231019
000172231019           // Define Logical File
000173231108           dcl-f LIBLLF usage(*input) usropn;
000174231108
000175231019           // Constants
000176231019           dcl-c LOAD_ALL_TYPES '*ALL';
000177231019
000178231019           // Define Variables
000179231019           dcl-s KEYNAME char(10);
000180231019           dcl-s LIBRARY char(10);
000181231019           dcl-s TYPE char(10);
000182231019           dcl-s SEQNO packed(4:0);
000183231019
000184231019           // Variable to check success of SetJobLibrary procedure
000185231019           dcl-s Success char(1) inz('0');
000186231019
000187231019           // Prototypes
000188231019           dcl-pr SetJobLibrary extpgm('SETJOBLIB');
000189231019             LibraryName char(10);
000190231019             LibraryType char(10);
000191231019             Success char(1);
000192231023           end-pr;
000193231023
000194231023           dcl-pr ClearLibrariesOfTypeFromLibl;
000195231023             LibraryType char(10);
000196231023           end-pr;
000197231108
000198231108           // Main
000199231108           if PMode = '*USER';
000200231108             exSr RunUserMode;
000201231108           elseIf PMode = '*ALDON';
000202231108             exSr RunAldonMode;
000203231108           endIf;
000205231108
000237231019           *inlr = *on;
000238231019           return;
000239231108
000240231108           begSr RunAldonMode;
000241231108             // Asign data to data structures
000242231108             PAReleaseInfo = PAREL;
000243231108             PAJobDInfo = PAJOBD;
000244231108
000245231108             //dsply (PAReleaseInfo.Release);
000246231108             //dsply (PAReleaseInfo.Application);
000248231108             //dsply (PAJobDInfo.JobDescription);
000249231108
000250231108           endSr;
000251231108
000252231108           begSr RunUserMode;
000253231108             open LIBLLF;
000254231108             // Clear Libraries by Type
000255231108             ClearLibrariesOfTypeFromLibl(PLoadType);
000256231108
000257231108             dow 1 = 1;
000258231108
000259231108               read LIBLLF;
000260231108
000261231108               if %eof(LIBLLF);
000262231108                 leave;
000263231108               endIf;
000264231108
000265231108               if KEYNAME = PKeyName;
000266231108
000267231108                 if PLoadType = LOAD_ALL_TYPES or TYPE = PLoadType;
000268231108
000269231108                   SetJobLibrary(LIBRARY : TYPE : Success);
000270231108
000271231108                   if Success = '0';
000272231108                     dsply ('Error occured while setting library.');
000273231108                     leave;
000274231108                   endIf;
000275231108
000276231108                 endIf;
000277231108               endIf;
000278231108
000279231108             endDo;
000280231108
000281231108             if Success = '1';
000282231108                dsply ('Library list set.');
000283231108             endIf;
000284231108
000285231108             close LIBLLF;
000286231108           endSr;
000287231023
