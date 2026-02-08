# Ansible | Homelab

Setup and configure a homelab on a Raspberry Pi using Ansible.

## Requirements

* Ansible installed on your local machine
* A running Raspberry Pi
* An SSH key pair on your local machine

## Steps

* Install Rasperry Pi Imager on your local machine

* Insert an SD card into your local machine to install Raspberry Pi OS

* Generate an ssh key pair for Raspberry Pi
`ssh-keygen -t ed25519 -C "raspberry pi"`

* In Raspberry Pi Imager:
    * Create an `admin` user and a password
    * Optionally configure WiFi and locale settings
    * Go to `Services` tab and enable `"Allow public-key authentication only"`
    * Paste the public ssh key in `"Set authorized_keys for 'admin'"` box

* Connect via ssh and specify the private key
`ssh -i raspberry_pi admin@<ip-address>`

* Now you can now reconnect without specifying the private key

* Change server public ip in the `inventory` file and `host_vars` directory

* Run the bootstrap script
`ansible-playbook bootstrap.yml`

* Reboot the Raspberry Pi
`sudo reboot`

* Run site script `ansible-playbook site.yml`

* Reboot the Raspberry Pi again
`sudo reboot`

## Validation

* Check that the ssh public key has been copied over
`cat ~/.ssh/authorized_keys`

* Check users
`cat /etc/passwd`

* Check sudoers
`cd /etc/sudoers.d/`

* Check sshd config
`cat /etc/ssh/sshd_config`

* Check user id
`id`

## SSH Agent

The following commands are useful on the ansible host (typically your local machine)

* Check if ssh-agent is running
`eval $(ssh-agent)`

* Add a private key to the ssh agent
`ssh-add <key>`

* Show all private keys handled by the ssh agent
`ssh-add -L`

* Delete all keys handled by the ssh agent
`ssh-add -D`

* Delete a specific identity (key) from the ssh agent
`ssh-add -d ~/.ssh/raspberry_pi.pub`

# Resources

* [Set up locale & language](https://github.com/justinisamaker/ansible-pi)
