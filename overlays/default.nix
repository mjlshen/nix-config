/* This contains various packages we want to overlay. Note that the
 * other ".nix" files in this directory are automatically loaded.
 */
self: super: {
  # Have to force Go 1.17 because the default is fixed to 1.16
  # for reasons in the nixpkgs repository. We'll undo this when
  # they switch.
  go = self.go_1_17;
}
