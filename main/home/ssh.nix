{ ... }:
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "1h";

        ControlMaster = "auto";
        ControlPath = "~/.ssh/control-%r@%h:%p";
        ControlPersist = "10m";

        ForwardAgent = false;
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };

      "github.com" = {
        HostName = "ssh.github.com";
        User = "git";
        Port = 443;
        IdentityFile = "~/.ssh/id_github";
        IdentitiesOnly = true;
      };
    };
  };

  services.ssh-agent.enable = true;
}
