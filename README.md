## Kubic Ark

A setup for making [ARK: Survival Evolved](https://store.steampowered.com/app/346110/ARK_Survival_Evolved) work in a Kubernetes cluster, with extra conveniences around config files (stored in ConfigMaps) and full *game* cluster setup within the same Kubernetes cluster, sharing config details when able to avoid duplication and hassle.

An eventual goal is to include automatic server hibernation to keep hosting costs down while using [ChatOps](https://docs.stackstorm.com/chatops/chatops.html) for server maintenance tasks (for instance: asking a bot on Discord to please start up the server hosting map `x` when somebody wants to play there)

Uses the [Docker image](https://hub.docker.com/r/nightdragon1/ark-docker) from https://github.com/NightDragon1/Ark-docker which in turn uses https://github.com/arkmanager/ark-server-tools for helpful management of the game server installation on Linux.

## Instructions

Apply the resources to a target Kubernetes cluster with some attention paid to order (config maps and storage before the deployment). Consider using the `apply-all.sh` script to do it all in one go and the `delete-all.sh` to reset everything.

*Note:* There are placeholder passwords in `ark-server-secrets.yaml` - you'll want to update these _but only locally where you run `kubectl` from_ - don't check your passwords into Git!

## ARK Configuration files

To easily configure a given ARK server via Git without touching the server several server config files are included via Kubernetes Config Maps (CMs)

* `GameUserSettings.ini` - contains most the general gameplay related settings, such as pvp settings, some cluster stuff, basic player rules
* `Game.ini` - contains deeper gameplay settings like auto-enabled engrams and bunches of ratios + multipliers.  But really ... the inis overlap a fair bit. Can be confusing.
* `AllowedCheaterSteamIDs.txt` - for Steam profile ids that will automatically have access to console cheats
* `PlayersJoinNoCheck.txt` & `PlayersExclusiveJoinList.txt` - for allowing player access in some fashion - exact distinction should be clarified but hasn't been tested here yet
* `arkmanager.cfg` - SPECIAL - this config file is actually for the Ark Manager utility, which in turn will apply a few settings to the game server with complete disregard for the game server config files (will override entries in `GameUserSettings.ini` for instance)

There are _two_ separate CMs for files like `GameUserSettings.ini` - the base set, intended to be used globally within a cluster (to not have to repeat yourself), and an override set meant to be used per-map for anything uniquely defined just there (may be little to nothing in some cases)

**Note:** The ARK server or maybe the ark-manager utility doesn't like incomplete config files and will restore a default if some things are missing - maybe even client-side entries that make no sense in the context of a headless server. If a config file like `GameUserSettings.ini` seems to _reset_ that might be the problem. Try to start fresh with a default config file then apply your customizations. Likewise `Game.ini` may really want its `[/script/shootergame.shootergamemode]` header - or it could be weird file permission issues still.

### Making changes

Game config changes usually go into one of three main files - the `arkmanager.cfg`, `GameUserSettings.ini`, or `Game.ini`

For instance with `GameUserSettings.ini` favor leaving a set of boring / default entries in the `GlobalGameUserSettingsCM.yaml` file then add the more interesting values you care about in `OverrideGameUserSettingsCM.yaml` making it easier to see what you've changed and how. Although game cluster-wide config settings may be best to leave in the global CM to avoid overlap.

After initial config and provisioning you can change the CMs either via files or directly, such as via the nice Google Kubernetes Engine dashboard. Then simply delete the server pod (not the deployment) via dashboard or eventually using ChatOps. The persistent volume survives including the installed game server files, so it may not make an appreciable difference to restart the server (via Ark Manager in a remote shell) or blow it up. The deployment will auto-recreate the pod if deleted.

Note that the `arkmanager.cfg` entries will overwrite anything else, such as the server name.

### Gory details

On initial creating of a game server pod the CMs associated with that pod will be mapped to a projected volume in `/ark/config/` - essentially meaning you'll get files there representing the CMs. As part of initialization those files are either copied forward to somewhere else or used for symbolic links.

The CMs that come in pairs will be combined to a "merged" file in the `/ark/` dir. This is crudely done and won't necessarily result in a pretty file, but ultimately the settings should be used by the game server. For `GameUserSettings.ini` for instance the Ark Manager is instructed via its config file `arkmanager.cfg` to copy in the merged file to the server directory at `/ark/server/ShooterGame/Saved/Config/LinuxServer` as the server starts up. This approach has the added benefit of working on the very first server start, no restart needed, all your customizations will be already applied.

During Ark Manager and game server startup the file appears to be somewhat rewritten. The ini file `[category]` blocks for instance won't merge cleanly from the CM process, so it may be easier to exclude the category tags in the CM files, yet by the time the server is online those categories will have been readded (although not necessarily grouped correctly)

## Connecting to your server

Find your IP via `kubectl get svc arkgame-service`, add `[IP]:[port]` to the Steam server panel then find games at that address and mark your server as a favorite. It should now show up in-game. It takes a little while for the server to come online, you can watch it with `kubectl logs arkgame-7d74dd65bc-gqckv` (adjust accordingly to your pod name, seen with `kubectl get pods`) or by using `arkmanager status` on a remote shell.

## License

This project is licensed under Apache v2.0 with contributions and forks welcome. The associated tools and ARK itself of course are governed by their own project details.
