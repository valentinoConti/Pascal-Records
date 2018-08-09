program Project;
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
    modif: Integer;
    ownerS:String[30];
    accountNumS:Integer;
    cashS:Double;
    overwrite: Integer;

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
      writeln('4. Modify/Delete data');
      writeln('9. Exit');
      writeln;
      readln(option);
      clrscr;

      case option of

      1,3: //Create file and/or Modify data
        begin
          ready:=False;
          case option of
          1: begin
               {$I-}
               Reset(file_cli);
               {$I+}
               if IOResult = 0 then begin
                 repeat
                   writeln('File already exist! Are you sure you want to erase it all? (1-Yes  2-DONT!):');
                   readln(overWrite);
                 until ((overWrite = 1) or (overwrite = 2));
                 if overwrite = 2 then halt(1) else begin
                   Rewrite(file_cli);
                   writeln('File is now empty! Add data:');
                 end;
               end else begin
                 Rewrite(file_cli);
                 writeln('Empty file created! Add data:');
               end;
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
            if IOResult = 0 then begin                     //If there was not errors (somethings was readed):
              if cliCod = rec_cli.codClient then begin    //If that client already had at least one account:
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
                write('Account number (8 digits): ');readln(accountNumS);
              until ((accountNumS >= 10000000) and (accountNumS <= 99999999));
              rec_cli.accountNum := accountNumS;
              repeat
                write('Cash: ');readln(cashS);
              until (cashS <= 999999999.99);
              rec_cli.cash := cashS;
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

        4:    //Modify Record data
        begin
          repeat
            writeln('Edit specific client');
            writeln;
            write('Client code to search: ');readln(cliCod);
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
          GotoXY (73, 1);
          write('Code');
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
                GotoXY(76, i);
                write(k);
                i:=i+1;
              end;
            end;
          end;

          if (i-3) = 0 then
          begin
            writeln;
            writeln;
            writeln('There are no accounts with that client number.');
            write('Press ENTER to come back');
            readln;

          end else begin

            repeat
              GotoXY(1, i+1);
              writeln('Insert the code of the account you wanna edit or delete');
              GotoXY(1, i+3);Delline;
              read(modif);
            until ((modif > -1) and (modif < (i-3)));

            clrScr;
            seek(file_cli, cliCod+modif*1000);
            {$I-}
            read(file_cli, rec_cli);
            {$I+}
            if IOResult = 0 then begin
              if rec_cli.codClient = cliCod then begin
                repeat
                  clrScr;
                  writeln('Modifying data');
                  writeln('-----------------------------');
                  writeln;
                  writeln('Actual data:');
                  writeln;

                  writeln('Client: '); GotoXY(20, 6); writeln(rec_cli.codClient);
                  writeln('Owner: '); GotoXY(20, 7); writeln(rec_cli.owner);
                  writeln('Account Number: '); GotoXY(20, 8); writeln(rec_cli.accountNum);
                  writeln('Cash: '); GotoXY(20, 9); writeln(rec_cli.cash:0:2);
                  writeln;
                  writeln('New data:');
                  writeln;
                  writeln('Client:            ',cliCod);
                  writeln('Owner: ');
                  writeln('Account Number: ');
                  writeln('Cash: ');
                  writeln;

                  readln;

                  GotoXY(20, 14); readln(ownerS);
                  GotoXy(20, 15); readln(accountNumS);
                  GotoXy(20, 16); readln(cashS);

                until (((accountNumS >= 10000000) and (accountNumS <= 99999999)) and (cashS <= 999999999.99));
                rec_cli.owner := ownerS;
                rec_cli.accountNum := accountNumS;
                rec_cli.cash := cashS;
                seek(file_cli, FilePos(file_cli)-1);
                write(file_cli, rec_cli);

              end;
            end;
          end;

          i:=1;

        end;

      9:   //Exit program
        begin
          exit:=True;
        end;

      end;
    until (exit = True);
end.


