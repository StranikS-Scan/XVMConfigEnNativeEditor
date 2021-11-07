## XVMConfigEnNativeEditor

Library for working with **XVM-config** from **"InnoSetup"**:

### Text replacement functions

```
function XCTextReplace(FileName, OldText, NewText: PAnsiChar; AllReplace: Boolean): Boolean; external 'XCTextReplace@files:XVMConfigEnNativeEditor.dll stdcall';

OldText:='battle';
NewText:='bottle';
XCTextReplace(FileName, OldText, NewText, True);
```

```
function XCTextReplaceExt(FileName, OldText, NewText: PAnsiChar; SkipLineNumbers: PAnsiChar; AllReplace: Boolean): Boolean; external 'XCTextReplaceExt@files:XVMConfigEnNativeEditor.dll stdcall';

OldText:='    // false - Disable tank icon mirroring (good for alternative icons).'#13#10
         '    // false - отключить зеркалирования иконок танков'#13#10
         '    //         (полезно для альтернативных иконок).'#13#10
         '    "mirroredVehicleIcons": true,';
NewText:='    // false - Disable tank icon mirroring (good for alternative icons).'#13#10
         '    // false - отключить зеркалирования иконок танков'#13#10
         '    //         (полезно для альтернативных иконок).'#13#10
         '    "mirroredVehicleIcons": false,';
SkipLines:='[2,3]'; //The skipped line can not be the first
XCTextReplaceExt(FileName, OldText, NewText, SkipLines, False);

OldText:='    // false - Disable pop-up panel at the bottom after death.'#13#10
         ''#13#10
         '    "showPostmortemTips": true';
NewText:='    // false - Disable pop-up panel at the bottom after death.'#13#10
         ''#13#10
         '    "showPostmortemTips": false';
SkipLines:='[2]'; //The skipped line can not be the first
XCTextReplaceExt(FileName, OldText, NewText, SkipLines, False);
```