{ ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        editor = "nvim";
        diff-formatter = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
        draft_commit_description = ''
          concat(
            description,
            "i: ",
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

      git.private-commits = "description(glob:'wip:*') | description(glob:'private:*') | description(glob:'i:*')";

      fsmonitor = {
        backend = "watchman";
        watchman.register-snapshot-trigger = false;
      };
    };
  };
}
