program RecordsProject;
Uses crt, sysutils;

Type

  Client = Record
    codClient:smallint;
    owner:String[30];
    accountNum:Integer;
    cash:Double;
  end;

var
    rec_cli:Client;
    file_cli:file of Client;
    exit: Boolean;
    ready: Boolean;
    option: Integer;
    showw: Integer;
    page: Integer;
    i,j,k: Integer;
    cliCod:Integer;

begin
    Assign(file_cli, 'Rdata.dat');
    exit:=False;
    page:=1;

    repeat

      clrscr;
      writeln('What do you wish to do?');
      writeln;
      writeln('1. Create/CleanAll the file');
      writeln('2. Show file data');
      writeln('3. Add data to the file');
      writeln('9. Exit');
      writeln;
      readln(option);
      clrscr;

      case option of

      1,3: //Generar archivo y/o Agregar Datos
        begin
          ready:=False;
          case option of
          1: begin
             Rewrite(file_cli);
             writeln('Empty file created! Add data:');
             end;
          3: begin
             Reset(file_cli);
             writeln('File opened! Add data:');
             end;
          end;
          writeln;

          repeat

            repeat
              write('Client Code (1 - 1000): '); readln(cliCod); //Ask for client number (1-1000)
            until ((cliCod > 0) and (cliCod < 1001));

            seek(file_cli, cliCod);                        //Search that position on the file
            {$I-}                                          //Ignore errors
            read(file_cli, rec_cli);                       //Read what is in that position (errors ignored)
            {$I+}                                          //Detect errors
            if IOResult = 0 then begin                     //If there was not errors:
              if cliCod = rec_cli.codClient then begin    //If that client already had at least one account
                rec_cli.codClient := cliCod;
                cliCod:=cliCod+1000;
                seek(file_cli, cliCod);                    //Search for that position +1000 (2nd account)
                {$I-}
                read(file_cli, rec_cli);
                {$I+}
                if IOResult = 0 then begin
                  if cliCod = rec_cli.codClient+1000 then begin     //If that client already had two accounts
                    cliCod:=cliCod+1000;
                    seek(file_cli, cliCod);                //Search for that position +1000 (3rd account)
                    {$I-}
                    read(file_cli, rec_cli);
                    {$I+}
                    if IOResult = 0 then begin
                      if cliCod = rec_cli.codClient+2000 then begin     //Client with 3 accounts.
                        writeln('This client already have 3 account! You cannot add more.');     //Cannot add anymore.
                        option:=6;
                        readln;
                      end else begin
                        rec_cli.codClient := cliCod-2000;
                        writeln('Third account for this client will be added ',rec_cli.codClient);
                      end;
                    end else begin
                      rec_cli.codClient := cliCod-2000;
                      writeln('Third account for this client will be added ',rec_cli.codClient);
                    end;
                  end else begin
                    rec_cli.codClient := cliCod-1000;
                    writeln('Second account for this client will be added ',rec_cli.codClient);
                  end;
                end else begin
                  rec_cli.codClient := cliCod-1000;
                  writeln('Second account for this client will be added ',rec_cli.codClient);
                end;
              end else begin
                rec_cli.codClient := cliCod;
                writeln('First account for this client will be added ',rec_cli.codClient);
              end;
            end else begin
              rec_cli.codClient := cliCod;
              writeln('First account for this client will be added ',rec_cli.codClient);

            end;

            if option <> 6 then begin
              write('Owner: ');readln(rec_cli.owner);
              repeat
                write('Account number (8 digits): ');readln(rec_cli.accountNum);
              until ((rec_cli.accountNum >= 10000000) and (rec_cli.accountNum <= 99999999));
              write('Cash: ');readln(rec_cli.cash);
              writeln;

              seek(file_cli, cliCod);
              Write(file_cli, rec_cli);

            end;

            write('Add more data? (1: Yes 2: No): '); readln(option);
            if (option = 2) then ready:=True;

          until (ready = True);

          Close(file_cli);
        end;

      2:  //show data
        begin
          showw:=0;
          repeat
            writeln('Select your option');
            writeln;
            writeln('1. Search for a specific client');
            writeln('2. Show ALL the records');
            writeln('9. Come back');
            writeln;
            readln(showw);
            clrscr;
          until ((showw=1) or (showw=2) or (showw=9));

          case showw of
          1:begin                  //Search specific
              repeat
                writeln('Search for a specific client');
                writeln;
                write('Client-code to search: ');readln(cliCod);
              until ((cliCod > 0) and (cliCod <= 1000));

              clrscr;
              Reset(file_cli);
              GotoXY (1, 1);
              write('Client');
              GotoXY (9, 1);
              write('Owner');
              GotoXY (39, 1);
              write('Account');
              GotoXY (49, 1);
              write('Cash');
              i:=3;

              for k:=0 to 2 do
                begin
                  seek(file_cli, cliCod+k*1000);
                  {$I-}
                  read(file_cli, rec_cli);
                  {$I+}
                if IOResult = 0 then begin
                  if rec_cli.codClient <> 0 then begin
                    GotoXY (2, i);
                    write(rec_cli.codClient);
                    GotoXY (9, i);
                    write(rec_cli.owner);
                    GotoXY (38, i);
                    write(rec_cli.accountNum);
                    GotoXY (49, i);
                    write(rec_cli.cash:0:2);
                    i:=i+1;
                  end;
                end;
              end;
              writeln;
              writeln;
              write('Press ENTER to come back');
              i:=1;
              Close(file_cli);
              readln;

            end;

          2:begin                //Show all
              Reset(file_cli);
              GotoXY (1, 1);
              write('Client');
              GotoXY (9, 1);
              write('Owner');
              GotoXY (39, 1);
              write('Account');
              GotoXY (49, 1);
              write('Cash');
              i:=3;

              for j:=1 to 1000 do
              begin
                for k:=0 to 2 do
                begin
                  seek(file_cli, j+k*1000);
                  {$I-}
                  read(file_cli, rec_cli);
                  {$I+}
                  if IOResult = 0 then begin
                    if (rec_cli.codClient <> 0) then begin
                      if (i <= 25) and (page = 1) then begin
                        GotoXY (2, i);
                        write(rec_cli.codClient);
                        GotoXY (9, i);
                        write(rec_cli.owner);
                        GotoXY (38, i);
                        write(rec_cli.accountNum);
                        GotoXY (49, i);
                        write(rec_cli.cash:0:2);
                        i:=i+1;
                      end else begin
                        if(page = 1) then begin
                          repeat
                          GotoXY(2, 27);
                          write('1: Next page');
                          GotoXY(2, 28);
                          write('2: Back');
                          GotoXY(2, 29);
                          Delline;
                          read(page);
                          until ((page = 1) or (page = 2));
                          clrscr;
                          if(page = 1) then begin
                            GotoXY (1, 1);
                            write('Client');
                            GotoXY (9, 1);
                            write('Owner');
                            GotoXY (39, 1);
                            write('Account');
                            GotoXY (49, 1);
                            write('Cash');
                            i:=3;

                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
              if page=1 then begin
                writeln;
                writeln;
                write('Press ENTER to come back');
                readln;
              end;
              readln;
              page:=1;
              i:=1;
              Close(file_cli);

            end;
          end;
        end;

      9:   //Exit program
        begin
          exit:=True;
        end;

      end;
    until (exit = True);
end.


