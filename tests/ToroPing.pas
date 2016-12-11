//
// Toro Ping example.
//
// Changes :
// 08 / 12 / 2016 : First Version by Matias Vara
//
// Copyright (c) 2003-2016 Matias Vara <matiasevara@gmail.com>
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

program ToroPing;

{$IFDEF FPC}
 {$mode delphi}
{$ENDIF}

// Adding support for FPC 2.0.4 ;)
{$IMAGEBASE 4194304}

// They are declared just the necessary units
// The units used depend on the hardware in which you run the application
uses
  Kernel in 'rtl\Kernel.pas',
  Process in 'rtl\Process.pas',
  Memory in 'rtl\Memory.pas',
  Debug in 'rtl\Debug.pas',
  Arch in 'rtl\Arch.pas',
  Filesystem in 'rtl\Filesystem.pas',
  Network in 'rtl\Network.pas',
  Console in 'rtl\Drivers\Console.pas',
  Ne2000 in 'rtl\Drivers\Ne2000.pas';

const 
  MaskIP: array[0..3] of Byte   = (255, 255, 255, 0);
  Gateway: array[0..3] of Byte  = (192, 100, 200, 1);
  LocalIP: array[0..3] of Byte  = (192, 100, 200, 100);
  PingIP: array[0..3] of Byte  = (192, 100, 200, 10);
  // wait for ping in seconds
  WAIT_FOR_PING = 2; 
var  
  PingIPDword: Dword;
  PingPacket: PPacket;
  PingContent: Pchar = 'abcdefghijklmtororstuvwabcdefghi';
  seq: word = 90;
  IP: PIPHeader;
  ICMP: PICMPHeader;
begin
  // Dedicate the ne2000 network card to local cpu
  DedicateNetwork('ne2000', LocalIP, Gateway, MaskIP, nil);
  
  // I convert the IP to a DWord
  _IPAddress (PingIP, PingIPDword);
  
  // I keep sending ICMP packets and waiting for an answer
  WriteConsole ('\c\t ToroPing: This test sends ICMP packets every %ds\n',[WAIT_FOR_PING]);
  while true do 
  begin
   WriteConsole ('\t ToroPing: /Vsending/n ping to %d.%d.%d.%d, seq: %d\n',[PingIP[0],PingIP[1],PingIP[2],PingIP[3],seq]);
   ICMPSendEcho (PingIPDword,PingContent, 32,seq,0);
   PingPacket := ICMPPoolPackets;
   if (PingPacket <> nil) then 
   begin 
    IP := Pointer(PtrUInt(PingPacket.Data)+SizeOf(TEthHeader));
	ICMP := Pointer(PtrUInt(PingPacket.Data)+SizeOf(TEthHeader)+SizeOf(TIPHeader));
	if ((IP.SourceIP = PingIPDword) and (ICMP.seq = SwapWORD(seq))) then
	begin
	    WriteConsole ('\t ToroPing: /areceived/n ping from %d.%d.%d.%d\n',[PingIP[0],PingIP[1],PingIP[2],PingIP[3]]);
	end else WriteConsole ('\t ToroPing: /rwrong/n received ping\n',[]);
   end else WriteConsole ('\t ToroPing: /rno received/n ping from %d.%d.%d.%d\n',[PingIP[0],PingIP[1],PingIP[2],PingIP[3]]);
   // I increment the seq for next packet
   seq := seq + 1;
   // I free the packet
   ToroFreeMem(PingPacket);
   // I wait WAIT_FOR_PING seconds
   sleep (WAIT_FOR_PING * 1000);
  end; 
end.
