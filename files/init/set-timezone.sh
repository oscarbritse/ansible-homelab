# Set time zone and time 
echo "Europe/Stockholm" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata