# Ansible | Homelab

Setup and configure a homelab on a Raspberry Pi using Ansible.

## Requirements

* Ansible installed on your local machine
* A running Raspberry Pi
* Private ssh key (`.pem` file) for the Raspberry Pi

## Steps

* Generate an ssh key pair for Raspberry Pi
`ssh-keygen -t ed25519 -C "raspberry-pi"`

* In Raspberry Pi Imager, go to `Advanced options` and choose `"Allow public-key authentication only"`

* Paste the public ssh key in `"Set authorized_keys for 'admin'"` box

* Connect via ssh and specify the private key
`ssh -i raspberry-pi admin@<ip-address>`

* Now you can reconnect without specifying the private key

* Change server public ip in the `inventory` file and `host_vars` directory

* Run bootstrap script
`ansible-playbook bootstrap.yml`

* Reboot the Raspberry Pi
`sudo reboot`

* Run site script `ansible-playbook site.yml`

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
`ssh-add -d ~/.ssh/raspberry-pi.pub`

# Resources

* [Set up locale & language](https://github.com/justinisamaker/ansible-pi)
