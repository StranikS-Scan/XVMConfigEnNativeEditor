## XVMConfigEnNativePatcher

Library for working with **XVM-config** from **"InnoSetup"**:

### Text replacement functions

```
function XCTextReplace(FileName, OldText, NewText: PAnsiChar; AllReplace: Boolean): Boolean; external 'XCTextReplace@files:XVMConfigEnNativePatcher.dll stdcall';

OldText:='battle';
NewText:='bottle';
XCTextReplace(FileName, OldText, NewText, True);
```

```
function XCTextReplaceExt(FileName, OldText, NewText: PAnsiChar; SkipLineNumbers: PAnsiChar; AllReplace: Boolean): Boolean; external 'XCTextReplaceExt@files:XVMConfigEnNativePatcher.dll stdcall';

OldText:='    // false - Disable tank icon mirroring (good for alternative icons).'#13#10
         '    // false - отключить зеркалирования иконок танков'#13#10
         '    //         (полезно для альтернативных иконок).'#13#10
         '    "mirroredVehicleIcons": true,';
NewText:='    // false - Disable tank icon mirroring (good for alternative icons).'#13#10
         '    // false - отключить зеркалирования иконок танков'#13#10
         '    //         (полезно для альтернативных иконок).'#13#10
         '    "mirroredVehicleIcons": false,';
SkipLines:='[2,3]'; //Since these lines are not analyzed, they can contain any text and can be left empty in OldText and NewText 
XCTextReplaceExt(FileName, OldText, NewText, SkipLines, False);
```