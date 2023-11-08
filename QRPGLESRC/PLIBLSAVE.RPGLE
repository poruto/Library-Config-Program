000103231025      //********************************************************************************************
000104231025      //                                                                                           *
000105231025      //  System Name .....:                                                                       *
000106231025      //                                                                                           *
000107231025      //  Program Name ....: Library Config Save Program                                           *
000108231025      //                                                                                           *
000109231025      //  Program No. .....: PLIBLSAVE                                                             *
000110231025      //                                                                                           *
000111231025      //  Description .....:                                                                       *
000112231025      //                                                                                           *
000113231025      //  Created .........: 25.10.2023                                                            *
000114231025      //  by ..............: Tomas Porubsky                                                        *
000115231025      //                                                                                           *
000116231025      //********************************************************************************************
000117231025      //                                                                                           *
000118231025      //  MODIFICATION CONTROL                                                                     *
000119231025      //  ====================                                                                     *
000120231025      //  FIXNO      BY     DD/MM/YYYY  COMMENT                                                    *
000121231025      //  ---------  -----  ----------  ---------------------------------------------------------- *
000122231025      //============================================================================================
000123231025     H BndDir('PBNDDIR')
000124231023     H DFTACTGRP(*NO)
000125231023     FLIBLLF    O    E             DISK
000126231019        // Program parameters
000127231023
000128231019        dcl-pi *n;
000129231019          PKeyName char(10); // Under what key name the library list will be saved to physical file
000130231019        end-pi;
000131231019
000132231019       // Sequence number (for the user part of library list)
000133231019       dcl-s SqNbUsr packed(4:0) inz(10);
000134231019
000135231019       // Declare variables for the parameters
000136231019       dcl-s SysLibl char(5000) inz('');
000137231019       dcl-s CurLib char(10) inz('');
000138231019       dcl-s UsrLibl char(5000) inz('');
000139231019
000140231019       // Prototype for the CL program
000141231019       dcl-pr RetrieveJobLibl extpgm('RTVJOBLIBL');
000142231019         SYSLIBL char(5000);
000143231019         CURLIB char(10);
000144231019         USRLIBL char(5000);
000145231019       end-pr;
000146231023
000147231023       // Variables to split the library list by 10s
000148231023       dcl-s NumSegments int(3);
000149231023       dcl-s Segments char(10) dim(999);
000150231023       dcl-s i int(3);
000151231023
000152231023       dcl-pr SplitStringIntoSegments;
000153231023           Source char(5000);
000154231023           Segments char(10) dim(999);
000155231023           NumSegments int(3);
000156231023       end-pr;
000186231019
000187231019       // Call the CL program with variables
000188231019       RetrieveJobLibl(SysLibl : CurLib : UsrLibl);
000189231019
000190231019       // SysLibl Part
000191231019       SplitStringIntoSegments(SysLibl: Segments: NumSegments);
000192231019
000193231019       KEYNAME = 'TEST';
000194231019
000195231019       for i = 1 to NumSegments;
000196231023         if Segments(i) = 'QSYS';
000197231023           // Skip if the library is QSYS
000198231023         else;
000200231023           dsply ('SYS: ' + Segments(i));
000201231023           LIBRARY = Segments(i);
000202231023           TYPE = '*SYS';
000203231023           SEQNO = -1;
000204231023           write LIBLREC;
000205231023           endIf;
000206231019       endfor;
000207231019
000208231019       // UsrLibl Part
000209231019       SplitStringIntoSegments(UsrLibl: Segments: NumSegments);
000210231019
000211231019       for i = 1 to NumSegments;
000212231019         dsply ('USR: ' + Segments(i) +
000213231019         ' (' + %char(SqNbUsr) + ')');
000214231019
000215231019         LIBRARY = Segments(i);
000216231019         TYPE = '*USR';
000217231019         SEQNO = SqNbUsr;
000218231019         write LIBLREC;
000219231019
000220231019         SqNbUsr += 10;
000221231019       endfor;
000222231019
000223231019       // Current Libl
000224231019       dsply ('CUR: ' + CurLib);
000225231019       LIBRARY = CurLib;
000226231019       TYPE = '*CURRENT';
000227231019       SEQNO = -1;
000228231019       write LIBLREC;
000229231019
000230231019       *inlr = *on;
000231231023        return;
