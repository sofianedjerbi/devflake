# Custom packages defined in this flake
{pkgs, ...}: {
  # Function to import all custom packages
  importAll = self: {
    cursor = self.callPackage ./cursor {};
  };
}
