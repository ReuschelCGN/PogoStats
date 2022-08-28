# PokéStatistics

A mini Monitoring tool to collect performance data of Pokémon, Quests, Raids and Spawnpoints. 

It uses a little bash script to collect data from a Pokémon Scanning DB and write it in its own DB. [Grafana](https://grafana.com/grafana/) is used to display that data and even send notifications.

Current collected stats are:

- Live Pokémon
- Live Pokémon with IV
- Raids (split into their levels)
- Unkown Spawnpoints
- Quests
- Live Team GO Rocket stops
- Uptime Statistics for Devices

![Dashboard](https://user-images.githubusercontent.com/34460584/71187549-8ffaf100-227f-11ea-8f85-7497772b2f29.png)

![Device stats overview](https://camo.githubusercontent.com/53649d2e30d477a361b4d18cd92d808ab2948a51/68747470733a2f2f696d616765732d6578742d322e646973636f72646170702e6e65742f65787465726e616c2f51457247467479536663512d32644b336770536c4e5a6c4b344576785235484a39503946356c74705745342f2533467769647468253344313434322532366865696768742533443534302f68747470732f6d656469612e646973636f72646170702e6e65742f6174746163686d656e74732f3530323037343830383636323632323230382f3637313339303532313835393530363139372f756e6b6e6f776e2e706e67)

![Device uptime graph](https://camo.githubusercontent.com/38ad4b8268ec3e7421492218449c710a8c6ce49b/68747470733a2f2f63646e2e646973636f72646170702e636f6d2f6174746163686d656e74732f3637323430373231343035363636393230342f3637323433333130333230353137313230382f42657a5f74797475752e706e67)

## Installation

To simplify the setup, this tool is running on Docker. Install Docker and docker-compose first if you haven't already.

1. Create enviroment file

Just copy the example .env file and adjust the values:

```bash 
cp .env.example .env
```

2. Create grafana_data dir and change ownership

The grafana container needs a special user ID of that volume:

```bash
mkdir grafana_data && chown 472:472 grafana_data/
```

3. Start

Start the containers in the background and watch the logs:

```bash
docker-compose up -d pgsdb
docker-compose up -d pgsapp
docker-compose up -d grafana
docker-compose logs -f grafana
docker-compose logs -f pgsapp
```

## Configuration

Everything should be configured via the .env file.

### Database:

This is the database to store the performance data. You usually just need to adjust the password, everything else is fine on default

### App:

This is the little app container that runs the data collection. It needs access to the performance data database and to your scanner DB! Now this is the tricky part. Since Docker runs in its own networks, it can not access your DB running on the same server on `127.0.0.1`. You need to somehow expose the database to the app container. You can do that in two ways:

#### Socket File

You can mount the socket file of your mysql host into the app container so it feels like just connecting to `localhost`. The first step is to get the path of that file: `mysqladmin variables |grep "\.sock"`. Add that path to your .env file, change `SCANNER_HOST` to `localhost` and you're ready to go.

> Make sure to use `localhost` and not `127.0.0.1`!

#### Normal Interface (not recommended)

Binding your mysql host to normal interface is usually a security concern since, if your server is accessable from the internet, everybody can access it and thats something you should always avoid. Luckily, you can adjust your iptables to grant access from docker, but from noone else. **Make sure to change `MYSQL_CONNECTION_TYPE` to `tcp` in the .env file!**

> If you are running your scanner in docker, you can just share the network to the other container.

## Accessing the stats

Grafana is the tool to visualize the collected data. It comes with a preconfigured dashboard and should work out of the box. You can access it on port 3000. The default username and password is `admin`. You are forced to change that on the first login.

## Updating 

Updating this tool is a multi step process:

1. Update the git with  `git pull`
2. Compare your `.env` with `.env.example` and adjust it when needed
3. Update the containers. Stop your PogoStats containers with 
`docker-compose stop grafana && docker-compose stop pgsapp && docker-compose stop pgsdb`, 
update the monitoring container with 
`cd PogoStats`
`git pull https://github.com/ReuschelCGN/PogoStats.git devrework`
`cd ..`
`docker-compose build pgsapp`
and update the grafana and database container with 
`docker-compose pull grafana && docker-compose pull pgsdb`
4. Start the containers again with `docker-compose up -d pgsdb` and `docker-compose up -d grafana && docker-compose up -d pgsapp`. You may need to update the DB by hand since this tool does not have some sort of automatism to do that automatically. Every SQL update is basically a file in the sql directory. Check your current version with the `VERSION` file in the base directory and import the missing versions one by one via the commandline: `docker exec -i pogostats_database_1 mysql -u grafana -pchangeme grafana < sql/02_update.sql` for example. Make sure to adjust the mysql commandline parameters of course.


## Extras

### Notifications

Grafana is able to send messages when a alert is triggered. Set up a notification channel in the Alerting menu on the left side. To recive notifications, you either need to set that notification channel to default or add that channel to the alerting section of the dashboard settings. You need to set the `$GF_SERVER_DOMAIN` variable if you want pictures in your notifications.

### SSL

You may want to secure Grafana with a proper reverse proxy and SSL. You can achieve that by adding a reverse proxy container to the `docker-stack.yml`, using Traefik or use a classic reverse proxy on your Docker host system. Make sure that you are adjusting the Grafana settings in the env file. The port can changed to `127.0.0.1:3000` since Grafana should only be accessable via the proxy and not on its original port. Learn more [here](https://grafana.com/docs/grafana/v4.5/installation/behind_proxy/#running-grafana-behind-a-reverse-proxy).

### Home Dashboard

To change the Home Dashboard go to Configuration-->Preferences on the left side and set your Dashboard. You need to star it first to see it in the list!
