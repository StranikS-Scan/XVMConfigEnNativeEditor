library XVMConfigEnNativePatcher;

uses
  FastShareMem, SysUtils;

procedure XCTextReplace(FileName, OldText, NewText: PChar; allReplace: Boolean);
var f: File;
    j,k,n: Integer;
    b, b1: Boolean;
    BufW: array of Byte;
begin
if FileExists(FileName) then
 try
 AssignFile(f, FileName);
 Reset(f, 1);
 SetLength(BufW, FileSize(f));
 if Length(BufW)>0 then
  BlockRead(f, BufW[0], Length(BufW));
 CloseFile(f);
 //Search
 if Length(BufW)>0 then
  begin
  k:=0;
  b:=False;
  while k<(Length(BufW)-Length(OldText)-1) do
   begin
   //Verify with signature
   b1:=True;
   for j:=0 to Length(OldText)-1 do
    if BufW[k+j]<>Ord(OldText[j]) then
     begin
     b1:=False;
     Break;
     end;
   if b1 then //Coincided with the signature
    begin //Replace string
    if Length(NewText)>Length(OldText) then //If the new is longer than the old one, we insert the nops
     begin
     n:=Length(NewText)-Length(OldText);
     SetLength(BufW, Length(BufW)+n);
     for j:=Length(BufW)-1 downto k+n do
      BufW[j]:=BufW[j-n];
     end
    else if Length(NewText)<Length(OldText) then //If the new is shorter than the old one, then delete the extra positions
          begin
          n:=Length(OldText)-Length(NewText);
          for j:=k to Length(BufW)-n-1 do
           BufW[j]:=BufW[j+n];
          SetLength(BufW, Length(BufW)-n);
          end;
    for j:=0 to Length(NewText)-1 do //Making a replacement
     BufW[k+j]:=Ord(NewText[j]);
    if not b then
     begin
     b:=True; //Note to overwrite the entire file
     if not allReplace then Break;
     end;
    k:=k+Length(NewText)-1;
    end;
   Inc(k);
   end;
  if b then
   begin //File overwrite
   Rewrite(f, 1);
   Seek(f, 0);
   BlockWrite(f, BufW[0], Length(BufW));
   CloseFile(f);
   end;
  SetLength(BufW, 0);
  BufW:=nil;
  end;
 except
 end;
end;

exports XCTextReplace;

begin
end.
