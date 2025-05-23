## Kubic Ark

A setup for making [ARK: Survival Evolved](https://store.steampowered.com/app/346110/ARK_Survival_Evolved) work in a Kubernetes cluster, with extra conveniences around config files (stored in ConfigMaps) and full *game* cluster setup, sharing config details when able to avoid duplication and hassle.

An eventual goal is to include automatic server hibernation to keep hosting costs down while using [ChatOps](https://docs.stackstorm.com/chatops/chatops.html) for server maintenance tasks (for instance: asking a bot on Discord to please start up the server hosting map `x` when somebody wants to play there)

Uses the [Docker image](https://hub.docker.com/r/nightdragon1/ark-docker) from https://github.com/NightDragon1/Ark-docker which in turn uses https://github.com/arkmanager/ark-server-tools for helpful management of the game server installation on Linux.

**Important:** This project as written has a dependency on the dynamic NFS storage from [KubicGameHosting](https://github.com/Cervator/KubicGameHosting) since the cluster file share must be `ReadWriteMany` access mode for multiple pods to work with it at once.

Alternatively if you only ever plan on a single server and don't want the cluster share to work (and thus not need to install the custom storage type piece mentioned) you can remove the `storageClassName` and `accessModes` parts of `ark-pvc-shared.yaml` - just beware that running a second server will then fail as it cannot mount the shared volume to a second pod.

## Instructions

Initial creation of a Kubernetes cluster is beyond the scope of this guide, but The Terasology Foundation's setup (used by the author here) can be reviewed at https://github.com/MovingBlocks/Logistics - although that covers a lot more than the sort of basic cluster setup you'd need for ARK. It includes credential setup to connect to a Kubernetes cluster as well as a GCP bucket to store backups online.

Realistically even hosting ARK in a Kubernetes cluster is somewhat overly nerdy and expensive, unless you're bored, have a reason to nerd out, and/or may need to support a larger number of players to where paying per-slot on a typical game host would actually end up more costly. Although at that point a bare metal or simple VM server would probably still be easier and cheaper! :-)

To do it the nerdy way: Use the included scripts which will work against an `ark` namespace - execute these while in a context where credentials for Kubernetes (and in the case of backups also one for GCP Storage) are present

* `./create-ns-and-auth.sh` would create the `ark` namespace and the auth setup (service user, role, and role binding) - just needed once 
* `./start-server.sh gen1` would create the Genesis Part 1 server (and any missing global resources)
* `./start.server.sh valg` would likewise create Valguero
* `./stop-server.sh gen1` would delete the Genesis specific resources (but *not* global ones), retaining the map save
* `./stop-server.sh` would delete *only* global resources, but not servers
* `./wipe-server.sh valg` does the same as stop but also **wipes** the server map (or the cluster save if used without a server arg!)

As the exposing of servers happen using a NodePort (LoadBalancers are overkill are problematic to get working with UDP traffic) you need to manually add a firewall rule as well, Google Cloud example:

`gcloud compute firewall-rules create ark-gen1 --allow udp:31011-31013` would prepare the ports for Genesis (except the RCON port, which uses TCP and can be covered separately) - this _could_ be automated as well but is a one time thing that outside manual execution by a user (you) would take a somewhat unreasonable amount of complexity/access for what it achieves.

*Note:* There are placeholder passwords in `ark-server-secrets.yaml` - you'll want to update these _but only locally where you run `kubectl` from_ - don't check your passwords into Git! You might also want to change your cluster id if you leave clustering enabled (and especially if you set no password - see below)

TODO: There should probably be a better way to set the password, such as via manually created Kubernetes secret, with a fallback if not present on what's in the local copy of `ark-server-secrets.yaml` - this would allow unattended execution from something like Jenkins to rely on an externally set password. Just applying the existing Secret once manually wouldn't help if the automation then goes and reapplies the pristine version every time it does something related.

### Connecting to your server

Find an IP to one of your cluster nodes (the longer lived the better) by using `kubectl get nodes -o wide`, then add the right ####3 port (with the Steam name) from your server set, for instance `31013` for Genesis to get `[IP]:[port]` for the Steam server panel then find games at that address and mark your server as a favorite. It should now show up in-game with the favorites filter selected. It takes a while for the server to come online (half an hour or even longer first time), you can watch it with `kubectl logs <map-name>-<gibberish>` (adjust accordingly to your pod name, seen with `kubectl get pods`) or execute a status check with something like `kubectl exec arklost-0 -n ark -- arkmanager status`

Note that over time your external IP may change. The Steam server panel actually stores `IP:Port` even if you supply a domain name that points to your IP, so if you originally entered it that way it will _not_ update even if you update the target IP via DNS. You'll have to re-add the server at the new IP.

To connect to a server for the first time from the Epic client you may have to first start any single player world then hit `tab` and enter `open [IP]:[port]` - this will connect you to the server and likely auto-favorite it for future use.

### Empty password, Epic Crossplay, and Game Cluster travel

The config by default allows game cluster travel and crossplay between the Steam and Epic versions of ARK, however the default also sets a server password which is _not_ supported with Epic

With no password Epic crossplay was tested successfully at the very beginning of 2025, as was _game cluster travel_ between maps, which is supported between any servers configured with the same cluster id (set in `ArkManagerCfgCM`) - so you should probably also change that id or you might find yourself clustered with total strangers!

However, server travel with or without a password can apparently be problematic. One case with an empty password set allowed both Steam and Epic to initially connect without entering a password, but if attempting to _travel_ between servers (on Steam, at least) a password prompt on connecting still showed up. On simply submitting an empty password an error appeared ("Connection error - Invalid server password (Empty Password Field)") but the character _was_ transferred to the cluster "limbo" space meaning you could go back to the server list, again select the target server (may have to re-select the "Favorites" filter first), and connect - your character then is given the option to spawn on the target map with their inventory and such complete.

## Technical details

### Isolated namespace

For extra security and to be able to hand out credentials to others (or robots) it helps to put everything into its own namespace and have a service user to allow access.

For more details and the quick bit of inspiration used to write these examples see https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html

Start within a shell with admin (or otherwise enough) access to the target Kubernetes cluster, such as an authenticated Google Cloud Shell, and use the files in the `auth` directory:

* (Note: the first three steps are included if you simply run `./create-ns-and-auth.sh`)
* `kubectl create namespace ark` - if not already done
* `kubectl apply -f auth` - creates the user-related resources
* `kubectl describe sa ark-user -n ark`
* Note the full name of the secret and token, for instance `ark-user-token-4smst`, then get the full user token and certificate
* `kubectl get secret ark-user-token-4smst -n ark -o "jsonpath={.data.token}" | base64 -d` (remember to change the gibberish after "token")
* `kubectl get secret ark-user-token-4smst -n ark -o "jsonpath={.data['ca\.crt']}"`
* Fill the `auth/config.sample` in with the cert and token
* Use that file however needed for Kubernetes access limited to the given namespace!


#### Using SA in Jenkins

TODO: This is outdated, probably refer to the scripts / Logistics then also need to doc the bucket setup 

If the created service account is meant to be used in Jenkins for automatically interacting with a target Kubernetes cluster in a job do the following as well:

* Make sure to install the https://plugins.jenkins.io/kubernetes-cli/ plugin
* Create a new credential of the "secret text" type, paste the user token in there
* Enable the "Setup Kubernetes CLI (kubectl)" step in a job (using a node with access to the `kubectl` executable)
* Enter the API endpoint of the target cluster and select the secret text credential
  * Do **not** enter the certificate in this case! For whatever reason it works locally in something like [Lens](https://k8slens.dev/) but in Jenkins including the cert will cause a weird cert failure (leaving the field blank seems to disable cert checking entirely - works fine)
  
At this point you should be able to run `kubectl` commands against the cluster, such as by using the included utility scripts.


### ARK Configuration files

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

After initial config and provisioning you can change the CMs either via files or directly, such as via the nice Google Kubernetes Engine dashboard. Then simply delete the server pod (not the statefulset) via dashboard or eventually using ChatOps. The persistent volume survives including the installed game server files, so it may not make an appreciable difference to restart the server (via Ark Manager in a remote shell) or blow it up. The statefulset will auto-recreate the pod if deleted.

Note that the `arkmanager.cfg` entries will overwrite anything else, such as the server name.

### Additional Gory details

On initial creating of a game server pod the CMs associated with that pod will be mapped to a projected volume in `/ark/config/` - essentially meaning you'll get files there representing the CMs. As part of initialization those files are either copied forward to somewhere else or used for symbolic links.

The CMs that come in pairs will be combined to a "merged" file in the `/ark/` dir. This is crudely done and won't necessarily result in a pretty file, but ultimately the settings should be used by the game server. For `GameUserSettings.ini` for instance the Ark Manager is instructed via its config file `arkmanager.cfg` to copy in the merged file to the server directory at `/ark/server/ShooterGame/Saved/Config/LinuxServer` as the server starts up. This approach has the added benefit of working on the very first server start, no restart needed, all your customizations will be already applied.

During Ark Manager and game server startup the file appears to be somewhat rewritten. The ini file `[category]` blocks for instance won't merge cleanly from the CM process, so it may be easier to exclude the category tags in the CM files, yet by the time the server is online those categories will have been readded (although not necessarily grouped correctly)

## License

This project is licensed under Apache v2.0 with contributions and forks welcome. The associated tools and ARK itself of course are governed by their own project details.

## Thanks to

* Inspiration drawn from https://guido.appenzeller.net/2018/09/12/how-to-run-an-ark-survival-evolved-private-server-on-google-kubernetes-engine-gke/
* The awesome ARK server tools project - https://github.com/arkmanager/ark-server-tools
* Docker image from https://github.com/NightDragon1/Ark-docker as well as past maintainers - lots of forks but this one seemed tidy and well-organized!
