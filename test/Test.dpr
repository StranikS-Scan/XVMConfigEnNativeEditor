program Test;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, Classes;

procedure XCTextReplace(FileName, OldText, NewText: PChar; allReplace: Boolean); external '..\source\XVMConfigEnNativePatcher.dll';

begin
XCTextReplace(PChar(ExtractFilePath(ParamStr(0))+'xvm.xc'),PChar('.xc'),PChar('hello'),True);
end.
