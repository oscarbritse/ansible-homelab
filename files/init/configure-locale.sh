# Start by resetting en_GB entry in the locale file, useful when the script is ran multiple times
sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen

# Comment out the en_GB entry in the locale file
sed -i -e 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen

# Uncomment the en_US entry in the locale file
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

# gen the locale
locale-gen

# replace the locale in the debconf dir
sed -i -e 's/en_GB/en_US/g' /var/cache/debconf/config.dat

# update lang in /etc/default/locale
sed -i -e 's/en_GB/en_US/g' /etc/default/locale