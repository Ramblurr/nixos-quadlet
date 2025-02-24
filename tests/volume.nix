{
  testConfig = { pkgs, config, ... }: {
    virtualisation.quadlet = let
     inherit (config.virtualisation.quadlet) volumes;
    in {
      containers.write = {
        containerConfig = {
          image = "docker-archive:${pkgs.dockerTools.examples.bash}";
          entrypoint = "bash";
          exec = "-c 'echo 262c837a9160 > /tmp/foo/foo.txt'";
          volumes = [
            "${volumes.foo.ref}:/tmp/foo"
          ];
        };
        serviceConfig = {
          RemainAfterExit = true;
        };
      };
      volumes.foo = {
        volumeConfig = {
          type = "bind";
          device = config.home.homeDirectory or "/root";
        };
      };
    };
  };
  testScript = ''
    machine.wait_for_unit("default.target")
    machine.wait_for_unit("default.target", user=user)
    machine.wait_for_unit("write.service", user=user, timeout=30)

    path = f"/home/{user}/foo.txt" if user else "/root/foo.txt"
    machine.wait_for_file(path, timeout=10)
    assert machine.succeed(f"cat {path}").strip() == "262c837a9160"
  '';
}
