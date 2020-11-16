## Kubic Ark

A setup for making [ARK: Survival Evolved](https://store.steampowered.com/app/346110/ARK_Survival_Evolved) work in a Kubernetes cluster, with extra conveniences around config files (stored in ConfigMaps) and full *game* cluster setup within the same Kubernetes cluster, sharing config details when able to avoid duplication and hassle.

An eventual goal is to include automatic server hibernation to keep hosting costs down while using [ChatOps](https://docs.stackstorm.com/chatops/chatops.html) for server maintenance tasks (for instance: asking a bot on Discord to please start up the server hosting map `x` when somebody wants to play there)

Uses the [Docker image](https://hub.docker.com/r/nightdragon1/ark-docker) from https://github.com/NightDragon1/Ark-docker which in turn uses https://github.com/arkmanager/ark-server-tools for helpful management of the game server installation on Linux.
