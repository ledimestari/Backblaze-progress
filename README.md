# Backblaze-progress

This is my script and a related grafana dashboard to post statistics about progress of the backblaze backup to a influxDB database, then to be displayed with grafana.

As Backblaze personal computer backup is a software made for windows and this is a bash script it needs to be run in a WSL or some other linux environment.
(Bb personal computer backup is also available for Macs but I have no experience with those, this might work on a Mac too but I don't know that.)

elements in attached grafana json fetch data from an influxDB bucket named "Backblaze".
if you use a bucket with a similar name, you shouldn't need to modify all the elements on the dashboard.

At the end of the script is an optional extra step to save the progress into a bb_percentage.txt text file.
This file can then be used for some other application if you want to do so.
You can comment out or remove the part marked with comments.

## setup

clone the repository and install dependencies.

sudo apt update
sudo apt install curl bc grep coreutils
chmod +x script_name.sh

you can use terminal multiplexer like screen or tmux to run the script in the backgroud.
using tmux you can do it like this:

tmux new-session -d -s backblaze
tmux send-keys -t backblaze "cd /path/to/script/folder" Enter
tmux send-keys -t backblaze "./backblaze_to_influx.sh" Enter