000101231102      //********************************************************************************************
000102231031
000103231025      //                                                                                           *
000104231025      //  System Name .....:                                                                       *
000105231025      //                                                                                           *
000106231025      //  Program Name ....: Module 1                                                              *
000107231025      //                                                                                           *
000108231025      //  Program No. .....: PMODULEP                                                              *
000109231025      //                                                                                           *
000110231025      //  Description .....:  General Procedures for Library Config Program                        *
000111231025      //                                                                                           *
000112231025      //  Created .........: 25.10.2023                                                            *
000113231025      //  by ..............: Tomas Porubsky                                                        *
000114231030      //                                                                                           *
000115231025      //********************************************************************************************
000116231025      //                                                                                           *
000117231025      //  MODIFICATION CONTROL                                                                     *
000118231025      //  ====================                                                                     *
000119231025      //  FIXNO      BY     DD/MM/YYYY  COMMENT                                                    *
000120231025      //  ---------  -----  ----------  ---------------------------------------------------------- *
000121231025      //============================================================================================
000122231025     hNOMAIN
000123231023       // (RetrieveJobLibl) Declare variables for the parameters
000124231023       dcl-s SysLibl char(5000) inz('');
000125231023       dcl-s CurLib char(10) inz('');
000126231023       dcl-s UsrLibl char(5000) inz('');
000127231023
000128231023       // (SplitStringIntoSegments) Variables to split the library list by 10s
000129231023       dcl-s NumSegments int(3);
000130231023       dcl-s Segments char(10) dim(999);
000131231023       dcl-s i int(3);
000132231023
000133231023       // (ExecuteCLCommand) Variables
000134231108       dcl-s cmd char(300);
000135231023
000136231023       // Prototype for the CL program
000137231023       dcl-pr RetrieveJobLibl extpgm('RTVJOBLIBL');
000138231023         SYSLIBL char(5000);
000139231023         CURLIB char(10);
000140231023         USRLIBL char(5000);
000141231023       end-pr;
000142231023
000143231023       dcl-pr QCMDEXC extpgm('QCMDEXC');
000144231108          *n char(300) const options(*varsize);
000145231023          cmdLen packed(15:5) const;
000146231023       end-pr;
000147231025
000153231023       // Procedures
000154231023       dcl-proc ExecuteCLCommand export;
000155231023         dcl-pi *n;
000156231108           cmd char(300) const;
000157231023         end-pi;
000158231023
000159231023         dcl-s cmdLength packed(15:5);
000160231023
000161231023         // Calculate the length of the command string
000162231023         cmdLength = %len(%trimr(cmd));
000163231025
000164231025         // Call QCMDEXC
000165231025         QCMDEXC(cmd : cmdLength);
000167231023
000168231023         return;
000169231025       end-proc;
000170231025
000171231025       // Check if object exists in the library (To check if Aldon/S21 exists on the system for exam
000172231025       dcl-proc CheckObjExists export;
000173231025         dcl-pi *n;
000174231025           Library char(10);
000175231025           Success char(1);
000176231025           ObjectType char(7);
000177231025           ObjectName char(10);
000178231025         end-pi;
000179231025
000180231025         cmd = 'CHKOBJ OBJ(' + Library + '/' + ObjectName + ')'
000181231025         + ' OBJTYPE(' + ObjectType + ')';
000184231025
000185231025         ExecuteCLCommand(cmd);
000186231025
000187231025         if %error;
000188231025           Success = '0';
000189231025         else;
000190231025           Success = '1';
000191231025         endIf;
000193231025
000194231025         return;
000195231025
000196231025        end-proc;
000197231023
000198231023       // Procedure to split a string into segments and return an array
000199231023       dcl-proc SplitStringIntoSegments export;
000200231023         dcl-pi *n;
000201231023           Source char(5000);
000202231023           Segments char(10) dim(999);
000203231023           NumSegments int(3);
000204231023         end-pi;
000205231023
000206231023         dcl-s StartPos int(5);
000207231023         dcl-s EndPos int(5);
000208231023         dcl-s i int(3);
000209231023         dcl-s segment char(10);
000210231023         dcl-s Length int(3) inz(11);
000211231023
000212231023         // Initialize variables
000213231023         StartPos = 1;
000214231023         i = 1;
000215231023
000216231023         // Loop to split the string into segments
000217231023         dow StartPos <= %len(Source);
000218231023
000219231023           // Calculate the end position for the substring
000220231023           EndPos = StartPos + Length - 1;
000221231023
000222231023           // Ensure we don't go beyond the string length
000223231023           if EndPos > %len(Source);
000224231023             EndPos = %len(Source);
000225231023           endif;
000226231023
000227231023           // Extract a segment
000228231023           segment = %trim(%subst(Source: StartPos: Length));
000229231023
000230231023           if segment = '';
000231231023               leave;
000232231023           endIf;
000233231023
000234231023           Segments(i) = segment;
000235231023
000236231023           // Update the start position for the next iteration
000237231023           StartPos = EndPos + 1;
000238231023           i += 1;
000239231023         enddo;
000240231023
000241231023         NumSegments = i - 1;
000242231023
000243231023         return;
000244231023       end-proc;
000245231023
000246231023       // Clear Library List
000247231023       dcl-proc ClearLibrariesOfTypeFromLibl export;
000248231023          dcl-pi *n;
000249231023            LibraryType char(10);
000250231023          end-pi;
000251231023
000252231023          // Call the CL program with variables
000253231023          RetrieveJobLibl(SysLibl : CurLib : UsrLibl);
000254231023
000255231023          if LibraryType = '*USR' or LibraryType = '*ALL';
000256231023               SplitStringIntoSegments(UsrLibl: Segments: NumSegments);
000257231023
000258231023               for i = 1 to NumSegments;
000259231023                 cmd = 'RMVLIBLE LIB(' + Segments(i) + ')';
000260231023                 ExecuteCLCommand(cmd);
000261231023                 // dsply ('Removed *USR LIB: ' + Segments(i));
000262231023               endfor;
000263231023          endIf;
000264231023
000265231023          if LibraryType = '*SYS' or LibraryType = '*ALL';
000266231023               SplitStringIntoSegments(SysLibl: Segments: NumSegments);
000267231023
000268231023               for i = 1 to NumSegments;
000269231023                 if Segments(i) = 'QSYS';
000270231023                    // Skip QSYS
000271231023                 else;
000272231023                    cmd = 'CHGSYSLIBL LIB(' + Segments(i)
000273231023                    + ')' + ' OPTION(*REMOVE)';
000274231023                    ExecuteCLCommand(cmd);
000275231023                    // dsply ('Removed *SYS LIB: ' + Segments(i));
000276231023                 endIf;
000277231023               endfor;
000278231023          endIf;
000279231023
000280231023          return;
000281231023
000282231023       end-proc;
