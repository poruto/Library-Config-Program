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
000182231108           dcl-s SEQNO packed(4:0);
000184231019
000185231019           // Variable to check success of SetJobLibrary procedure
000186231019           dcl-s Success char(1) inz('0');
000187231108
000188231108           // For executing CL commands
000189231108           dcl-s Cmd char(300);
000190231019
000191231019           // Prototypes
000192231019           dcl-pr SetJobLibrary extpgm('SETJOBLIB');
000193231019             LibraryName char(10);
000194231019             LibraryType char(10);
000195231019             Success char(1);
000196231023           end-pr;
000197231108
000198231108           dcl-pr ExecuteCLCommand;
000199231108             Cmd char(300);
000200231108           end-pr;
000201231023
000202231023           dcl-pr ClearLibrariesOfTypeFromLibl;
000203231023             LibraryType char(10);
000204231023           end-pr;
000205231108
000206231108           // Main
000207231108           select;
000208231108             when PMode = '*USER';
000209231108               exSr RunUserMode;
000210231108             when PMode = '*ALDON';
000211231108               exSr RunAldonMode;
000212231108             other;
000213231108                dsply ('Not a valid Mode');
000214231108           endSl;
000215231108
000237231019           *inlr = *on;
000238231019           return;
000239231108
000240231108           // Soubroutine that runs if the selected run mode is *ALDON
000241231108           begSr RunAldonMode;
000242231108             // Asign data to data structures
000243231108             PAReleaseInfo = PAREL;
000244231108             PAJobDInfo = PAJOBD;
000245231108
000246231108             //dsply (PAReleaseInfo.Release);
000247231108             //dsply (PAReleaseInfo.Application);
000248231108             //dsply (PAJobDInfo.JobDescription);
000249231108
000254231108             exSr BuildACMSLiblCommand;
000324231108             ExecuteCLCommand(Cmd);
000328231108           endSr;
000329231108
000330231108           // Soubroutine that runs if the selected run mode is *USER
000399231108           begSr RunUserMode;
000400231108             open LIBLLF;
000401231108             // Clear Libraries by Type
000402231108             ClearLibrariesOfTypeFromLibl(PLoadType);
000403231108
000404231108             dow 1 = 1;
000405231108
000406231108               read LIBLLF;
000407231108
000408231108               if %eof(LIBLLF);
000409231108                 leave;
000410231108               endIf;
000411231108
000412231108               if KEYNAME = PKeyName;
000413231108
000414231108                 if PLoadType = LOAD_ALL_TYPES or TYPE = PLoadType;
000415231108
000416231108                   SetJobLibrary(LIBRARY : TYPE : Success);
000417231108
000418231108                   if Success = '0';
000419231108                     dsply ('Error occured while setting library.');
000420231108                     leave;
000421231108                   endIf;
000422231108
000423231108                 endIf;
000424231108               endIf;
000425231108
000426231108             endDo;
000427231108
000428231108             if Success = '1';
000429231108                dsply ('Library list set.');
000430231108             endIf;
000431231108
000432231108             close LIBLLF;
000433231108           endSr;
000434231108
000436231108           // Subroutine to build ACMSLIBL Command from Strings
000437231108           begSr BuildACMSLiblCommand;
000438231108             Cmd = 'ACMSLIBL REL(';
000439231108
000440231108             if PAReleaseInfo.Group = '';
000441231108                Cmd = Cmd + '*N';
000442231108             else;
000443231108                Cmd = Cmd + %trim(PAReleaseInfo.Group);
000444231108             endIf;
000445231108
000446231108             Cmd = Cmd + '/';
000447231108
000448231108             if PAReleaseInfo.Application = '';
000449231108                Cmd = Cmd + '*N';
000450231108             else;
000451231108                Cmd = Cmd + %trim(PAReleaseInfo.Application);
000452231108             endIf;
000453231108
000454231108             Cmd = Cmd + '/';
000455231108
000456231108             if PAReleaseInfo.Release = '';
000457231108                Cmd = Cmd + '*N';
000458231108             else;
000459231108               Cmd = Cmd + %trim(PAReleaseInfo.Release);
000460231108             endIf;
000461231108
000462231108             Cmd = Cmd + ')';
000463231108
000464231108             // ENV
000465231108             if PAENV <> '';
000466231108                Cmd = Cmd + ' ';
000467231108                Cmd = Cmd + 'ENV(' + %trim(PAENV) + ')';
000468231108             endIf;
000469231108
000470231108             // DVPNAME
000471231108             if PADVPName <> '';
000472231108                Cmd = Cmd + ' ';
000473231108                Cmd = Cmd + 'DVPNAME(' + %trim(PADVPName) + ')';
000474231108             endIf;
000475231108
000476231108             // EMGCHK
000477231108             if PAEMGCHK <> '';
000479231108                Cmd = Cmd + ' ';
000480231108                Cmd = Cmd + 'EMGCHK(' + %trim(PAEMGCHK) + ')';
000481231108             endIf;
000482231108
000483231108             // JOBD
000484231108             if PAJobDInfo.JobDescription <> '';
000485231108                Cmd = Cmd + ' ';
000486231108                Cmd = Cmd + 'JOBD(';
000487231108
000488231108                if PAJobDInfo.Library = '';
000489231108                  Cmd = Cmd + '*N';
000490231108                else;
000491231108                  Cmd = Cmd + %trim(PAJobDInfo.Library);
000492231108                endIf;
000495231108
000499231108                Cmd = '/' + Cmd + %trim(PAJobDInfo.JobDescription) + ')';
000503231108             endIf;
000504231108
000507231108             // DTASET
000508231108             if PADTASet <> '';
000509231108                Cmd = Cmd + ' ';
000510231108                Cmd = Cmd + 'DTASET(' + %trim(PADTASet) + ')';
000511231108             endIf;
000512231108
000513231108             // EDTLIBL
000514231108             if PAEDTLibl <> '';
000515231108                Cmd = Cmd + ' ';
000516231108                Cmd = Cmd + 'EDTLIBL(' + %trim(PAEDTLibl) + ')';
000517231108             endIf;
000518231108           endSr;
000519231023
