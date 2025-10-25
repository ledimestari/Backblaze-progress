# Backblaze-progress

A backblaze grafana display.

![Screenshot 2024-12-26 235835](https://github.com/user-attachments/assets/e90aa52a-9a95-4c7e-850a-0831a7da1208)

This is my script and a related grafana dashboard to post statistics about progress of the backblaze backup to a influxDB database, then to be displayed with grafana.

As Backblaze personal computer backup is a software made for windows and this is a bash script it needs to be run in a WSL or some other linux environment.

(Bb personal computer backup is also available for Macs but I have no experience with those, this might work on a Mac too but I don't know that.)

Elements in attached grafana json fetch data from an influxDB bucket named "Backblaze", if you use a bucket with a matchin name, you shouldn't need to modify all the elements on the dashboard.

At the end of the script is an optional extra step to save the progress into a bb_percentage.txt text file.
This file can then be used for some other application if you want to do so.
You can comment out or remove the part marked with comments.

On the grafana dash, below the graphs seen above are also graphs displaying each individual drive.

![Screenshot 2024-12-27 000225](https://github.com/user-attachments/assets/d738dda0-7c38-49d3-94cb-44d2dbf6db24)

## setup

This setup is not about influxDB or Grafana. I assume you have those already setup with influxDB Bucket named "Backblaze".

First clone the repository, install dependencies and chmod the script.

```bash
sudo apt update
sudo apt install curl bc grep coreutils
chmod +x backblaze_to_influx.sh
```

Then run the bash script `./backblaze_to_influx.sh`

Output should be similar to this:

```bash
Drive: v00080ea80b04277207090300018
  Drive letter: C
  Selected files:  5903
  Selected MB:     397
  Remaining files: 275
  Remaining MB:    7
Drive: v00100aa80a04277207090300018
  Drive letter: A
  Selected files:  63544
  Selected MB:     260806
  Remaining files: 29313
  Remaining MB:    180242

... drives one by one ...

Drive: v00a20aa100022d7709090300017
  Drive letter: K
  Selected files:  75931
  Selected MB:     20477
  Remaining files: 3494
  Remaining MB:    104
---- Totals ----
Selected files: 5053309
Selected MB: 29517684
Remaining files: 97331
Remaining MB: 10919276
Percentage saved to bb_percentage.txt
```

Now the data should be posted into your influx bucket.

Tip:

You can use terminal multiplexer like screen or tmux to run the script in the backgroud.

Using tmux you can do it like this, and then set this to run at startup.

```bash
tmux new-session -d -s backblaze
tmux send-keys -t backblaze "cd /path/to/script/folder" Enter
tmux send-keys -t backblaze "./backblaze_to_influx.sh" Enter
```
