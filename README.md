# WCR Repository

This repository builds a research data repository based on the Fedora/Hydra/Sufia platform.

## Development box prerequisites:
 - Vagrant
 - Virtualbox

## Install centos 7 virtualbox image
`vagrant box add centos/7 https://atlas.hashicorp.com/centos/boxes/7`

On Windows, you might be given a choice between libvirt or virtualbox. Choose *virtualbox*.

## Check that it has installed
`vagrant box list`

and you should see 'centos/7' listed

## Clone uwlib's vagrant-ansible-sufia repo

`git clone git@bitbucket.org:uwlib/vagrant-ansible-sufia.git`

`cd vagrant-ansible-sufia`

## Copy vars.yml.template to vars.yml.

`cp vars.yml.template vars.yml`
Edit application_home if you want it to install in someplace other than /home/vagrant/sufia   
Edit druw_home if you want it to install in someplace other than /home/vagrant/druw

## Start your vagrant box
`vagrant up --provider virtualbox`

## ssh into vagrant box
`vagrant ssh`

## scp your bitbucket private key into .ssh dir
scp [yourbitbucketprivatekey] ~/.ssh

## Clone this repo into wherever you specified druw_home to be in vars.yml
`cd $DRUW_HOME`   
`git clone git@bitbucket.org:uwlib/druw.git`

## cd to $DRUW_HOME/config, then copy all *.yml.template files to *.yml.
    cd $DRUW_HOME/config   

    for f in `ls *.yml.template |rev | cut -d '.' --complement -f 1 |rev`; do cp $f{.template,}; done

## Change to vagrant sync dir and run ansible playbook for druw.yml
`cd /vagrant`   
`ansible-playbook -i inventory druw.yml`
