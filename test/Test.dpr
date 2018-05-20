program Test;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, Classes;

function XCTextReplace(FileName, OldText, NewText: PAnsiChar; AllReplace: Boolean): Boolean; stdcall; external '..\source\XVMConfigEnNativePatcher.dll';
function XCTextReplaceExt(FileName, OldText, NewText: PAnsiChar; SkipLineNumbers: PAnsiChar; AllReplace: Boolean): Boolean; stdcall; external '..\source\XVMConfigEnNativePatcher.dll';

begin
//=================== Example 1: Simple replacement ===================

XCTextReplace(PChar(ExtractFilePath(ParamStr(0))+'xvm.xc'), PChar('battle'), PChar('bottle'), True);

//=================== Example 2: Replacement with skiping lines in non-ASCII ===================

XCTextReplaceExt(PChar(ExtractFilePath(ParamStr(0))+'xvm.xc'),
  PChar('    // false - Disable tank icon mirroring (good for alternative icons).'+#13#10+
        '    // false - отключить зеркалирования иконок танков'+#13#10+
        '    //         (полезно для альтернативных иконок).'+#13#10+
        '    "mirroredVehicleIcons": true'),
  PChar('    // false - Disable tank icon mirroring (good for alternative icons).'+#13#10+
        '    // false - отключить зеркалирования иконок танков'+#13#10+
        '    //         (полезно для альтернативных иконок).'+#13#10+
        '    "mirroredVehicleIcons": false'),
  PChar('[2,3]'),
  False);

XCTextReplaceExt(PChar(ExtractFilePath(ParamStr(0))+'xvm.xc'),
  PChar('    // false - Disable pop-up panel at the bottom after death.'+#13#10+
        ''+#13#10+
        '    "showPostmortemTips": true'),
  PChar('    // false - Disable pop-up panel at the bottom after death.'+#13#10+
        ''+#13#10+
        '    "showPostmortemTips": false'),
  PChar('[2]'),
  False);
end.
