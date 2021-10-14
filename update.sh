session="sensorInput"
function UOI () {
	git clone https://github.com/AlexanderADM/grotrian-sensor.git
	shopt -s dotglob
	mv -u grotrian-sensor/* ./
	rm -fr grotrian-sensor
	git reset --hard
	git pull --force
	git checkout .
	pip3 install -r requirements.txt
}

function run () {
	git fetch
	if [ ! -f "app.py" ]; then
		echo "Python app not found, running update/install function."
		UOI
		echo "Finished installing the script."
		tmux new -d -s $session 'python3 app.py'
		echo "Script is now running in session \'sensorInput\'"
	elif git status --branch --porcelain -uno | grep behind; then
		echo "Differences from main branch found, updating script."
		echo "Terminating python script session."
		tmux kill-session -t $session
		UOI
		echo "Finished updating the script."
		tmux new -d -s $session 'python3 app.py'
		echo "Script is now running in session \'sensorInput\'."
	else
		echo "No differences found, no action taken."
		tmux has-session -t $session 2>/dev/null
		if [ $? != 0 ]; then
			echo "The script is not running, rebooting the script."
  			tmux new -d -s $session 'python3 app.py'
			echo "Script is now running in session \'sensorInput\'."
		fi
	fi
}

while true; do run & sleep 60m; done
