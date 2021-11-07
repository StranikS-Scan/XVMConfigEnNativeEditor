{ *********************************************************************** }
{                                                                         }
{ Delphi / Kylix Cross-Platform Runtime Library                           }
{                                                                         }
{ Copyright (c) 1995-2008 Borland Software Corporation                    }
{                                                                         }
{ *********************************************************************** }

unit FastShareMem;

interface

var
  GetAllocMemCount: function: Integer;
  GetAllocMemSize : function: Integer;

implementation

uses Windows;

const ClassName = '_com.codexterity.fastsharemem.dataclass';

type
  TFastSharememPack = record
    MemMgr: TMemoryManager;
    _GetAllocMemSize:  function: Integer;
    _GetAllocMemCount: function: Integer;
  end;

  function _GetAllocMemCount: Integer;
  begin
  Result:=System.AllocMemCount;
  end;

  function _GetAllocMemSize: Integer;
  begin
  Result:=System.AllocMemSize;
  end;

var MemPack: TFastSharememPack;
    OldMemMgr: TMemoryManager;
    WndClass: TWndClass;
    isHost: Boolean;

initialization

if not GetClassInfo(HInstance, ClassName, WndClass) then
 begin
 GetMemoryManager(MemPack.MemMgr);
 MemPack._GetAllocMemCount:=@_GetAllocMemCount;
 MemPack._GetAllocMemSize:=@_GetAllocMemSize;
 GetAllocMemCount:=@_GetAllocMemCount;
 GetAllocMemSize:=@_GetAllocMemSize;
 FillChar(WndClass, SizeOf(WndClass), 0);
 with WndClass do
  begin
  lpszClassName:=ClassName;
  style:=CS_GLOBALCLASS;
  hInstance:=hInstance;
  lpfnWndProc:=@MemPack;
  end;
 if RegisterClass(WndClass)=0 then
  begin
  MessageBox(0, 'Shared Memory Allocator setup failed: Cannot register class.', 'FastShareMem', 0);
  Halt;
  end;
 isHost:=True;
 end
else begin
     GetMemoryManager(OldMemMgr); //Optional
     SetMemoryManager(TFastSharememPack(WndClass.lpfnWndProc^).MemMgr);
     GetAllocMemCount:=TFastSharememPack(WndClass.lpfnWndProc^)._GetAllocMemCount;
     GetAllocMemSize:=TFastSharememPack(WndClass.lpfnWndProc^)._GetAllocMemSize;
     isHost:=False;
     end;

finalization

if isHost then
     UnregisterClass(ClassName, HInstance)
else SetMemoryManager(OldMemMgr); //Optional

end.
