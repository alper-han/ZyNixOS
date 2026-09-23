{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gdb
    lldb
    delve
    netcoredbg
    (python3.withPackages (pythonPackages: [
      pythonPackages.debugpy
    ]))
  ];
}
