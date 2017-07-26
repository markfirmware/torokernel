program ToroElfTest;
{$i Toro.inc}
uses
  Arch, Console, Debug, Filesystem, Kernel, Memory,
  Ne2000, Network, Pci, Process;

var
  Counter:LongWord;
  cr0_reg:QWord;
begin
  asm
    mov rax, cr0
    mov cr0_reg, rax
  end;
  Counter:=0;
  while True do
    Inc(Counter);
end.
