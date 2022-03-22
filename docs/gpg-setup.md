# GPG Setup

1. Install [GPG Suite](https://gpgtools.org/)
1. `gpg --full-gen-key`
1. Choose RSA and RSA (default)
1. Choose 4096 bits
1. Choose key does not expire (default)
1. Enter the information you're prompted for
1. `gpg --list-secret-keys --keyid-format LONG [email here]`
1. From the `sec` line, copy the ID (the part after the `rsa4096/`)
1. `git config --global user.signingkey [key you just copied here]`
1. `git config --global commit.gpgsign true`
1. `gpg --armor --export [key you just copied here]`
1. Copy the exported key and paste it into your GPG key settings for GitHub, GitLab, etc.
