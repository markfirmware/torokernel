program ToroElfTest;
{$i Toro.inc}
uses
  Arch, Console, Debug, Filesystem, Kernel, Memory,
  Ne2000, Network, Pci, Process;

var
  Counter:QWord;
  cr0_reg:QWord;
begin
  asm
    mov rax, cr0
    mov cr0_reg, rax
  end;
  Counter:=$7fffffff;
  while True do
    Inc(Counter,1);
end.
