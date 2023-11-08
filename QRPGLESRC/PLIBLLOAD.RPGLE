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
000123231023
000124231019           // Program parameters
000125231019           dcl-pi *n;
000126231019             PKeyName char(10);
000127231019             PLoadType char(10);
000128231019           end-pi;
000129231019
000130231019           // Define Logical File
000131231019           dcl-f LIBLLF usage(*input);
000132231019
000133231019           // Constants
000134231019           dcl-c LOAD_ALL_TYPES '*ALL';
000135231019
000136231019           // Define Variables
000137231019           dcl-s KEYNAME char(10);
000138231019           dcl-s LIBRARY char(10);
000139231019           dcl-s TYPE char(10);
000140231019           dcl-s SEQNO packed(4:0);
000141231019
000142231019           // Variable to check success of SetJobLibrary procedure
000143231019           dcl-s Success char(1) inz('0');
000144231019
000145231019           // Prototypes
000146231019           dcl-pr SetJobLibrary extpgm('SETJOBLIB');
000147231019             LibraryName char(10);
000148231019             LibraryType char(10);
000149231019             Success char(1);
000150231023           end-pr;
000151231023
000152231023           dcl-pr ClearLibrariesOfTypeFromLibl;
000153231023             LibraryType char(10);
000154231023           end-pr;
000155231023
000156231023           // Clear Libraries by Type
000157231023           ClearLibrariesOfTypeFromLibl(PLoadType);
000158231023
000160231023           dow 1 = 1;
000161231023
000162231023             read LIBLLF;
000163231023
000164231023             if %eof(LIBLLF);
000165231023               leave;
000166231023             endIf;
000167231019
000168231019             if KEYNAME = PKeyName;
000169231019
000170231019               if PLoadType = LOAD_ALL_TYPES or TYPE = PLoadType;
000171231019
000172231019                 SetJobLibrary(LIBRARY : TYPE : Success);
000173231019
000174231023                 if Success = '0';
000175231019                   dsply ('Error occured while setting library.');
000176231023                   leave;
000177231019                 endIf;
000178231019
000179231019               endIf;
000180231019             endIf;
000181231019
000182231023           endDo;
000183231023
000184231023           if Success = '1';
000185231023              dsply ('Library list set.');
000186231023           endIf;
000187231023
000188231019
000189231019           *inlr = *on;
000190231019           return;
000191231023
