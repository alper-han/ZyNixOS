# Hyprland Monitor Configuration and Workspace Assignments
# Usage: import ./monitor.nix { }
{ }:
{
  # Monitor configuration
  monitorv2 = [
    {
      output = "DP-1";
      mode = "2560x1440@144.0";
      position = "0x0";
      scale = 1;
      bitdepth = 10;
      cm = "dcip3";
    }
    {
      output = "DP-2";
      mode = "2560x1440@144.0";
      position = "2560x0";
      scale = 1;
      bitdepth = 10;
      cm = "dcip3";
    }
    {
      output = "eDP-1";
      mode = "preferred";
      position = "auto";
      scale = 1;
    }
  ];

  # Workspace to monitor assignments
  workspace = [
    "1,monitor:DP-1,default:true"
    "2,monitor:DP-1"
    "3,monitor:DP-1"
    "4,monitor:DP-1"
    "5,monitor:DP-1"
    "6,monitor:DP-2,default:true"
    "7,monitor:DP-2"
    "8,monitor:DP-2"
    "9,monitor:DP-2"
    "10,monitor:DP-2"
    "11,monitor:DP-1"
    "12,monitor:DP-1"
    "13,monitor:DP-1"
    "14,monitor:DP-1"
    "15,monitor:DP-1"
    "16,monitor:DP-2"
    "17,monitor:DP-2"
    "18,monitor:DP-2"
    "19,monitor:DP-2"
    "20,monitor:DP-2"
  ];
}
