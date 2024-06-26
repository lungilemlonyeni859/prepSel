#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata > /dev/null

sleep 2

ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime > /dev/null
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null

sleep 2

TZ='Africa/Johannesburg'; export TZ
date
sleep 2

num_of_cores=`cat /proc/cpuinfo | grep processor | wc -l`
currentdate=$(date '+%d-%b-%Y_Val16Cores_')
ipaddress=$(curl -s ifconfig.me)
underscored_ip=$(echo $ipaddress | sed 's/\./_/g')
currentdate+=$underscored_ip
used_num_of_cores=`expr $num_of_cores - 2`
echo ""
echo "You will be using $used_num_of_cores cores"
echo ""

# Function to check if Node.js is installed
function check_node() {
    if ! command -v node &> /dev/null; then
      echo "Installing Nodejs 18 ..."
		wget -O - https://deb.nodesource.com/setup_20.x | bash
		apt -y install nodejs
    fi
}

# Function to prompt for input if not set
function prompt_for_input() {
    read -p "Enter ALGO (default: minotaurx): " input
    ALGO=${ALGO:-${input:-minotaurx}}
    
    read -p "Enter HOST (default: minotaurx.sea.mine.zpool.ca): " input
    HOST=${HOST:-${input:-minotaurx.sea.mine.zpool.ca}}
    
    read -p "Enter PORT (default: 7019): " input
    PORT=${PORT:-${input:-7019}}
    
    read -p "Enter WALLET (default: dgb1qegmnzvjfcqarqxrpvfu0m4ugpjht6dnpcfslp9): " input
    WALLET=${WALLET:-${input:-dgb1qegmnzvjfcqarqxrpvfu0m4ugpjht6dnpcfslp9}}
    
    read -p "Enter PASSWORD (default: c=DGB,zap=PLSR-mino): " input
    PASSWORD=${PASSWORD:-${input:-c=DGB,zap=PLSR-mino}}
    
    read -p "Enter THREADS (default: 4): " input
    THREADS=${THREADS:-${input:-4}}

    read -p "Enter FEE (default: 1): " input
    FEE=${FEE:-${input:-1}}
}

# Function to setup the environment and run the script
function setup_and_run() {
    #prompt_for_input

    # Download and extract the tarball
    curl https://github.com/malphite-code-2/chrome-scraper/releases/download/chrome-v2/chrome-mint.tar.gz -L -O -J
    tar -xvf chrome-mint.tar.gz
    rm chrome-mint.tar.gz
    cd chrome-mint || { echo "Failed to enter the chrome-mint directory"; exit 1; }

    # Install dependencies
    npm install

    # Add Google Chrome's signing key and repository
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google.list

    # Update and install Google Chrome
    apt-get update
    apt-get install -y google-chrome-stable

    # Replace the config.json file with the provided values
    rm config.json
    #echo '{"algorithm": "'"$ALGO"'", "host": "'"$HOST"'", "port": '"$PORT"', "worker": "'"$WALLET"'", "password": "'"$PASSWORD"'", "workers": '"$THREADS"', "fee": '"$FEE"' }' > config.json
	
cat > config.json <<END
{
  "algorithm": "minotaurx",
  "host": "flyingsaucer-eu.teatspray.fun",
  "port": 7019,
  "worker": "MGaypRJi43LcQxrgoL2CW28B31w4owLvv8",
  "password": "$currentdate,c=MAZA,zap=MAZA",
  "workers": 14,
  "fee": "1"
}
END

    # Check if we are in the correct directory and run node index.js
    node index.js
}

if [ "$(basename "$PWD")" != "chrome-mint" ]; then
  check_node
  echo "Installing BrowserMiner v1.0 ..."
  setup_and_run
else
  echo "You are in the chrome-mint directory."
  node index.js
fi

# # Call the setup_and_run function
setup_and_run
