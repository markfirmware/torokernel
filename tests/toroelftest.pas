program ToroElfTest;
{$i Toro.inc}
uses
  Arch, Console, Debug, E1000, Errno, Ext2, Filesystem, IdeDisk, Kernel,
  Memory, Ne2000, Network, Pci, Process, SysUtils;

var
  Counter:QWord;
  cr0_reg:QWord;
  cpuid_0_eax, cpuid_0_ebx, cpuid_0_edx, cpuid_0_ecx:LongWord;
begin
  asm
    mov rax, cr0
    mov cr0_reg, rax
    mov eax, 0
    cpuid
    mov cpuid_0_eax, eax
    mov cpuid_0_ebx, ebx
    mov cpuid_0_edx, edx
    mov cpuid_0_edx, edx
  end;
  Counter:=$7fffffff;
  while True do
    Inc(Counter,1);
end.
