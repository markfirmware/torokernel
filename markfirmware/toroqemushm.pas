program ToroQemuShm;

{$IFDEF FPC}
 {$mode delphi}
{$ENDIF}

//{$IMAGEBASE 4194304}

// Configuring the RUN for Lazarus
{$IFDEF WIN64}
          {%RunCommand qemu-system-x86_64.exe -m 512 -smp 2 -drive format=raw,file=ToroQemuShm.img}
{$ELSE}
         {%RunCommand qemu-system-x86_64 -m 512 -smp 2 -drive format=raw,file=ToroQemuShm.img}
{$ENDIF}
{%RunFlags BUILD-}

uses
  Kernel in '..\rtl\Kernel.pas',
  Process in '..\rtl\Process.pas',
  Memory in '..\rtl\Memory.pas',
  Debug in '..\rtl\Debug.pas',
  Arch in '..\rtl\Arch.pas',
  Filesystem in '..\rtl\Filesystem.pas',
  Pci in '..\rtl\Drivers\Pci.pas',
  Console in '..\rtl\Drivers\Console.pas';

const
  MEMORY_EXCHANGE_ADDRESS=ALLOC_MEMORY_START - 1 * MEGABYTES;

const
  Limit=10*1000;

type
  TMemoryExchangeStorage = packed record
    ReservedForHeapManager:array[0..31] of Byte;
    Signature:LongWord;
    Output:array[0..Limit] of LongWord;
  end;
  PMemoryExchangeStorage = ^TMemoryExchangeStorage;

  TMemoryExchange = record
    Valid:Boolean;
    Storage:PMemoryExchangeStorage;
    constructor Create(Where:Pointer);
    procedure Put(Index,Value:Integer);
  end;

constructor TMemoryExchange.Create(Where:Pointer);
const
  InitializationSignature=$73AF72EC;
var
  I:Integer;
begin
  Storage:=PMemoryExchangeStorage(Where);
  Valid:=True;
  if Valid then
    begin
      Storage.Signature:=InitializationSignature;
      for I:= 0 to Limit - 1 do
        Put(I,0);
    end;
end;

procedure TMemoryExchange.Put(Index,Value:Integer);
begin
  if Valid then
    Storage.Output[Index]:=Value;
end;

var
  MemoryExchange:TMemoryExchange;
  I:Integer;
begin
  WriteConsole('\c/Rtorokernel shared memory test\n',[0]);
  MemoryExchange:=TMemoryExchange.Create(Pointer(MEMORY_EXCHANGE_ADDRESS));
  for I:= 0 to Limit - 1 do
    MemoryExchange.Put(I,I);
  while True do
    SysThreadSwitch;
end.
