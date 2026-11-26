{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true; # battery level reporting for headsets/controllers
      FastConnectable = true;
      JustWorksRepairing = "always"; # lets controllers re-pair without manual removal
    };
    # Controllers (DS4/DualSense) often connect then immediately drop without this.
    # Trade-off: accepts HID input from devices that haven't fully bonded.
    input.General.ClassicBondedOnly = false;
  };
}
