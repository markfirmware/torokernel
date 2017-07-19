//
// Toro Hello World Example.
// Clasical example using a minimal kernel to print "Hello World"
//
// Changes :
// 
// 16/09/2011 First Version by Matias E. Vara.
//
// Copyright (c) 2003-2017 Matias Vara <matiasevara@gmail.com>
// All Rights Reserved
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

program ToroQemuShm;

{$IFDEF FPC}
 {$mode delphi}
{$ENDIF}

{$IMAGEBASE 4194304}

// Configuring the RUN for Lazarus
{$IFDEF WIN64}
          {%RunCommand qemu-system-x86_64.exe -m 512 -smp 2 -drive format=raw,file=ToroQemuShm.img}
{$ELSE}
         {%RunCommand qemu-system-x86_64 -m 512 -smp 2 -drive format=raw,file=ToroQemuShm.img}
{$ENDIF}
{%RunFlags BUILD-}

// They are declared just the necessary units
// The needed units depend on the hardware where you are running the application
uses
  Kernel in '..\rtl\Kernel.pas',
  Process in '..\rtl\Process.pas',
  Memory in '..\rtl\Memory.pas',
  Debug in '..\rtl\Debug.pas',
  ArchMofified,
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
    Output:array[0..Limit] of Integer;
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
  RemovePageCache(Pointer(Where and not (PAGE_SIZE - 1)));
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
