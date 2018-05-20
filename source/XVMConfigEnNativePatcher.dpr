library XVMConfigEnNativePatcher;

uses
  FastShareMem, SysUtils;

{FileName - Full name of the xc-file
 OldText, NewText - Replaceable text and replacement text
 AllReplace - Replace all occurrences}
function XCTextReplace(FileName, OldText, NewText: PAnsiChar; AllReplace: Boolean): Boolean; stdcall;
var F: File;
    i,j,k: Integer;
    Changed, Coincided: Boolean;
    Buffer: array of Byte;
begin
Result:=False;
if not FileExists(FileName) then
 Exit;
if (Length(OldText)=0)or(Length(NewText)=0) then
 Exit;
try
AssignFile(f, FileName);
Reset(F, 1);
SetLength(Buffer, FileSize(f));
if Length(Buffer)>0 then
 BlockRead(F, Buffer[0], Length(Buffer));
CloseFile(F);
if Length(Buffer)>0 then
 begin
 j:=0;
 Changed:=False;
 while j<(Length(Buffer)-Length(OldText)-1) do
  begin //Verify with signature
  Coincided:=True;
  for i:=0 to Length(OldText)-1 do
   if Buffer[j+i]<>Ord(OldText[i]) then
    begin
    Coincided:=False;
    Break;
    end;
  if Coincided then
   begin //Replace strings
   if Length(NewText)>Length(OldText) then //If the new is longer than the old one, we insert the nops
    begin
    k:=Length(NewText)-Length(OldText);
    SetLength(Buffer, Length(Buffer)+k);
    for i:=Length(Buffer)-1 downto j+k do
     Buffer[i]:=Buffer[i-k];
    end
   else if Length(NewText)<Length(OldText) then //If the new is shorter than the old one, then delete the extra positions
         begin
         k:=Length(OldText)-Length(NewText);
         for i:=j to Length(Buffer)-k-1 do
          Buffer[i]:=Buffer[i+k];
         SetLength(Buffer, Length(Buffer)-k);
         end;
   for i:=0 to Length(NewText)-1 do //Making a replacement
    Buffer[i+j]:=Ord(NewText[i]);
   if not Changed then
    begin
    Changed:=True; //Note to overwrite the entire file
    if not AllReplace then Break;
    end;
   j:=j+Length(NewText)-1;
   end;
  Inc(j);
  end;
 if Changed then
  begin //File overwrite
  Rewrite(F, 1);
  Seek(F, 0);
  BlockWrite(F, Buffer[0], Length(Buffer));
  CloseFile(F);
  end;
 SetLength(Buffer, 0);
 Buffer:=nil;
 end;
except
end;
end;

{FileName - Full name of the xc-file
 OldText, NewText - Replaceable text and replacement text
 AllReplace - Replace all occurrences
 SkipLines - Ñomma separated list with line numbers, meaning that it should be skipped}
function XCTextReplaceExt(FileName, OldText, NewText: PAnsiChar; SkipLineNumbers: PAnsiChar; AllReplace: Boolean): Boolean; stdcall;
var F: File;
    i,j,k,m, OldLinesCount, NewLinesCount: Integer;
    Changed, Coincided: Boolean;
    OldPatternSimple, OldPatternReal, NewPatternReal: array of Integer;
    OldPatternExt, NewPatternExt, SkipPatternExt: array of array of Byte;
    SkipedLinesIndexes: array of Integer;
    Buffer: array of Byte;
    S: string;
    Skip: Boolean;
begin
Result:=False;
if Length(Trim(SkipLineNumbers))=0 then
 begin
 Result:=XCTextReplace(FileName, OldText, NewText, False);
 Exit;
 end;
if not FileExists(FileName) then Exit;
if (Length(OldText)=0)or(Length(NewText)=0) then Exit;
//------------------- Parse skiped line numbers -------------------
SetLength(SkipedLinesIndexes, 0);
S:='';
for i:=0 to Length(SkipLineNumbers)-1 do //SkipedLinesIndexes: (X,X,X)
 begin
 if SkipLineNumbers[i] in ['(','['] then
  Continue;
 if SkipLineNumbers[i] in [' ',',',')',']'] then
  begin
  if S='' then Continue;
  SetLength(SkipedLinesIndexes, Length(SkipedLinesIndexes)+1);
  SkipedLinesIndexes[Length(SkipedLinesIndexes)-1]:=StrToIntDef(S,1)-1;
  S:='';
  end
 else begin
      S:=S+SkipLineNumbers[i];
      if i=(Length(SkipLineNumbers)-1) then
       begin
       SetLength(SkipedLinesIndexes, Length(SkipedLinesIndexes)+1);
       SkipedLinesIndexes[Length(SkipedLinesIndexes)-1]:=StrToIntDef(S,1)-1;
       end;
      end;
 end;
if (Length(SkipedLinesIndexes)=0)or(SkipedLinesIndexes[0]=0) then Exit;
//------------------- Parse the strings to patterns without skipped lines -------------------
OldLinesCount:=1;
SetLength(OldPatternExt, OldLinesCount);
k:=0; //Symbol number in xSimple: (X,X-1,X)
j:=0; //Symbol number in xExt: ((X,X),(),(X))
Skip:=False;
for i:=0 to Length(OldText)-1 do
 begin
 if not Skip then
  begin
  Inc(k);
  SetLength(OldPatternSimple,k);
  OldPatternSimple[k-1]:=Ord(OldText[i]);
  Inc(j);
  SetLength(OldPatternExt[OldLinesCount-1],j);
  OldPatternExt[OldLinesCount-1][j-1]:=OldPatternSimple[k-1];
  end;
 if (i>0)and(OldText[i-1]=#13)and(OldText[i]=#10) then
  if i<(Length(OldText)-1) then
   begin
   Inc(OldLinesCount);
   Skip:=False;
   for j:=0 to Length(SkipedLinesIndexes)-1 do
    if SkipedLinesIndexes[j]=(OldLinesCount-1) then
     begin
     Skip:=True;
     Break;
     end;
   if Skip then
    begin
    Inc(k);
    SetLength(OldPatternSimple,k);
    OldPatternSimple[k-1]:=-1;
    end;
   j:=0;
   SetLength(OldPatternExt, OldLinesCount);
   end;
 end;
NewLinesCount:=1;
SetLength(NewPatternExt, NewLinesCount);
j:=0; //Symbol number in xExt: ((X,X),(),(X))
Skip:=False;
for i:=0 to Length(NewText)-1 do
 begin
 if not Skip then
  begin
  Inc(j);
  SetLength(NewPatternExt[NewLinesCount-1],j);
  NewPatternExt[NewLinesCount-1][j-1]:=Ord(NewText[i]);
  end;
 if (i>0)and(NewText[i-1]=#13)and(NewText[i]=#10) then
  if i<(Length(NewText)-1) then
   begin
   Inc(NewLinesCount);
   Skip:=False;
   for j:=0 to Length(SkipedLinesIndexes)-1 do
    if SkipedLinesIndexes[j]=(NewLinesCount-1) then
     begin
     Skip:=True;
     Break;
     end;
   j:=0;
   SetLength(NewPatternExt, NewLinesCount);
   end;
 end;
if OldLinesCount<>NewLinesCount then Exit;
//------------------- Replace text -------------------
try
AssignFile(f, FileName);
Reset(F, 1);
SetLength(Buffer, FileSize(f));
if Length(Buffer)>0 then
 BlockRead(F, Buffer[0], Length(Buffer));
CloseFile(F);
if Length(Buffer)>0 then
 begin
 j:=0; //Symbol number in Buffer
 Changed:=False;
 while j<(Length(Buffer)-Length(OldPatternSimple)-1) do
  begin //Verify with pattern
  Coincided:=True;
  k:=0; //Symbol offset about j in Buffer
  OldLinesCount:=0;
  SetLength(SkipPatternExt, OldLinesCount);
  for i:=0 to Length(OldPatternSimple)-1 do
   begin
   if OldPatternSimple[i]<>-1 then
    begin                                    //Buffer: (X,X,S,S,13,10,X)
    if Buffer[j+k]<>OldPatternSimple[i] then //           ^
     Coincided:=False
    else if (i>0)and(OldPatternSimple[i-1]=13)and(OldPatternSimple[i]=10) then
          begin
          Inc(OldLinesCount);
          SetLength(SkipPatternExt, OldLinesCount);
          end;
    Inc(k);
    end
   else begin
        Inc(OldLinesCount);
        SetLength(SkipPatternExt, OldLinesCount);
        m:=0; //Symbol number in xExt: ((),(S,S,13,10),())
        while (Buffer[j+k-1]<>13)or(Buffer[j+k]<>10) do //Buffer: (X,X,S,S,13,10,X)
         begin                                          //             ^
         Inc(m);
         SetLength(SkipPatternExt[OldLinesCount-1], m);
         SkipPatternExt[OldLinesCount-1][m-1]:=Buffer[j+k];
         Inc(k);
         if (j+k)=Length(Buffer) then
          begin
          Coincided:=False;
          Break;
          end;
         end;
        if Coincided then
         begin
         Inc(m);
         SetLength(SkipPatternExt[OldLinesCount-1], m);
         SkipPatternExt[OldLinesCount-1][m-1]:=10;
         end;
        Inc(k);
        end;
   if not Coincided then Break;
   end;
  if Coincided then
   begin //Replace strings
   k:=0;
   SetLength(OldPatternReal, k); //Create OldPatternReal: (X,X,X,S,S,X)
   for i:=0 to NewLinesCount-1 do
    if Length(OldPatternExt[i])>0 then
     for m:=0 to Length(OldPatternExt[i])-1 do
      begin
      Inc(k);
      SetLength(OldPatternReal, k);
      OldPatternReal[k-1]:=OldPatternExt[i][m];
      end
    else if (i<OldLinesCount)and(Length(SkipPatternExt[i])>0) then
          for m:=0 to Length(SkipPatternExt[i])-1 do
           begin
           Inc(k);
           SetLength(OldPatternReal, k);
           OldPatternReal[k-1]:=SkipPatternExt[i][m];
           end;
   k:=0;
   SetLength(NewPatternReal, k); //Create NewPatternReal: (X,S,S,X,X,X,X)
   for i:=0 to NewLinesCount-1 do
    if Length(NewPatternExt[i])>0 then
     for m:=0 to Length(NewPatternExt[i])-1 do
      begin
      Inc(k);
      SetLength(NewPatternReal, k);
      NewPatternReal[k-1]:=NewPatternExt[i][m];
      end
    else if (i<OldLinesCount)and(Length(SkipPatternExt[i])>0) then
          for m:=0 to Length(SkipPatternExt[i])-1 do
           begin
           Inc(k);
           SetLength(NewPatternReal, k);
           NewPatternReal[k-1]:=SkipPatternExt[i][m];
           end;
   if Length(NewPatternReal)>Length(OldPatternReal) then //If the new is longer than the old one, we insert the nops
    begin
    k:=Length(NewPatternReal)-Length(OldPatternReal);
    SetLength(Buffer, Length(Buffer)+k);
    for i:=Length(Buffer)-1 downto j+k do
     Buffer[i]:=Buffer[i-k];
    end
   else if Length(NewPatternReal)<Length(OldPatternReal) then //If the new is shorter than the old one, then delete the extra positions
         begin
         k:=Length(OldPatternReal)-Length(NewPatternReal);
         for i:=j to Length(Buffer)-k-1 do
          Buffer[i]:=Buffer[i+k];
         SetLength(Buffer, Length(Buffer)-k);
         end;
   for i:=0 to Length(NewPatternReal)-1 do //Making a replacement
    Buffer[i+j]:=NewPatternReal[i];
   if not Changed then
    begin
    Changed:=True; //Note to overwrite the entire file
    if not AllReplace then Break;
    end;
   j:=j+Length(NewPatternReal)-1;
   end;
  Inc(j);
  end;
 if Changed then
  begin //File overwrite
  Rewrite(F, 1);
  Seek(F, 0);
  BlockWrite(F, Buffer[0], Length(Buffer));
  CloseFile(F);
  end;
 SetLength(Buffer, 0);
 Buffer:=nil;
 end;
except
end;
end;

exports XCTextReplace,
        XCTextReplaceExt;

begin
end.
