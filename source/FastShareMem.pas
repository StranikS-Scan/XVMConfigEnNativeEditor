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
  GetAllocMemCount: function: integer;
  GetAllocMemSize : function: integer;

implementation

uses Windows;

const ClassName  = '_com.codexterity.fastsharemem.dataclass';

type
  TFastSharememPack = record
    MemMgr: TMemoryManager;
    _GetAllocMemSize  :function :integer;
    _GetAllocMemCount :function :integer;
  end;

  function _GetAllocMemCount: Integer;
  begin
    Result := System.AllocMemCount;
  end;

  function _GetAllocMemSize: Integer;
  begin
    Result := System.AllocMemSize;
  end;

var
  MemPack: TFastSharememPack;
  OldMemMgr: TMemoryManager;
  wc: TWndClass;
  isHost: boolean;

initialization

  if (not GetClassInfo(HInstance, ClassName, wc)) then
  begin
    GetMemoryManager(MemPack.MemMgr);
    MemPack._GetAllocMemCount := @_GetAllocMemCount;
    MemPack._GetAllocMemSize  := @_GetAllocMemSize;
    GetAllocMemCount := @_GetAllocMemCount;
    GetAllocMemSize  := @_GetAllocMemSize;
    FillChar(wc, sizeof(wc), 0);
    wc.lpszClassName := ClassName;
    wc.style := CS_GLOBALCLASS;
    wc.hInstance := hInstance;
    wc.lpfnWndProc := @MemPack;
    if RegisterClass(wc)=0 then
    begin
      MessageBox( 0, 'Shared Memory Allocator setup failed: Cannot register class.', 'FastShareMem', 0 );
      Halt;
    end;
    isHost := true;
  end else
  begin
    GetMemoryManager(OldMemMgr); // optional
    SetMemoryManager(TFastSharememPack(wc.lpfnWndProc^).MemMgr);
    GetAllocMemCount := TFastSharememPack(wc.lpfnWndProc^)._GetAllocMemCount;
    GetAllocMemSize  := TFastSharememPack(wc.lpfnWndProc^)._GetAllocMemSize;
    isHost := false;
  end;

finalization
  if isHost then UnregisterClass(ClassName, HInstance)
  else SetMemoryManager(OldMemMgr); // optional

end.
