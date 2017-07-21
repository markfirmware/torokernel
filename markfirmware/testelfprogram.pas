program TestElfProgram;
{$mode delphi}

var
  Counter:Integer absolute $400154;
begin
  Counter:=0;
  while True do
    Inc(Counter);
end.
