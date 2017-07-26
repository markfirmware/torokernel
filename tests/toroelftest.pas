program ToroElfTest;
{$i Toro.inc}
uses
  Arch, Console, Debug, E1000, Errno, Ext2, Filesystem, IdeDisk, Kernel,
  Memory, Ne2000, Network, Pci, Process, SysUtils;

var
  Counter:QWord;
  cr0_reg:QWord;
  cpuid_eax:LongWord;
begin
  asm
    mov rax, cr0
    mov cr0_reg, rax
    mov eax, 0
    cpuid
    mov cpuid_eax, eax
  end;
  Counter:=$7fffffff;
  while True do
    Inc(Counter,1);
end.
