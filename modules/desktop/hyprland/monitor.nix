# Hyprland Monitor Configuration and Workspace Assignments
# Usage: import ./monitor.nix { }
{ }:
{
  # Monitor configuration
  monitorv2 = [
    {
      output = "DP-2";
      mode = "2560x1440@144.0";
      position = "0x0";
      scale = 1;
      bitdepth = 10;
      cm = "dcip3";
      supports_hdr = -1;
    }
    {
      output = "DP-1";
      mode = "2560x1440@144.0";
      position = "2560x0";
      scale = 1;
      bitdepth = 10;
      cm = "dcip3";
      supports_hdr = -1;
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
    "1,monitor:DP-2,default:true"
    "2,monitor:DP-2"
    "3,monitor:DP-2"
    "4,monitor:DP-2"
    "5,monitor:DP-2"
    "6,monitor:DP-1,default:true"
    "7,monitor:DP-1"
    "8,monitor:DP-1"
    "9,monitor:DP-1"
    "10,monitor:DP-1"
    "11,monitor:DP-2"
    "12,monitor:DP-2"
    "13,monitor:DP-2"
    "14,monitor:DP-2"
    "15,monitor:DP-2"
    "16,monitor:DP-1"
    "17,monitor:DP-1"
    "18,monitor:DP-1"
    "19,monitor:DP-1"
    "20,monitor:DP-1"
  ];
}
