# Home Assistant

[Home Assistant](https://www.home-assistant.io/) is cool, but requires some manual setup
that unfortunately I can't really configure with Nix. Besides setting up users, you have
to install the integrations through the UI.

Some integrations require additional dependencies. Try installing them, then check the error logs
to figure out what is missing, and add it to the Nix config for Home Assistant.
