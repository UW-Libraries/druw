# WCR Repository

This repository builds a research data repository based on the Fedora/Hydra/Sufia platform.

## Development box prerequisites:
 - Vagrant
 - Virtualbox

## Install centos 7 virtualbox image
    vagrant box add centos/7 https://atlas.hashicorp.com/centos/boxes/7

On Windows, you might be given a choice between libvirt or virtualbox. Choose *virtualbox*.

## Check that it has installed
    vagrant box list`

and you should see 'centos/7' listed

## Clone uwlib's vagrant-ansible-sufia repo
    git clone git@bitbucket.org:uwlib/vagrant-ansible-sufia.git
    cd vagrant-ansible-sufia

## Copy vars.yml.template to vars.yml.
    cp vars.yml.template vars.yml

Edit application_home if you want it to install in someplace other than /home/vagrant/sufia   
Edit druw_home if you want it to install in someplace other than /home/vagrant/druw

## Start your vagrant box
    vagrant up --provider virtualbox

## ssh into vagrant box
    vagrant ssh

## scp your bitbucket private key into .ssh dir
    scp [yourbitbucketprivatekey] ~/.ssh

## Clone this repo into wherever you specified druw_home to be in vars.yml
    cd ~   
    git clone git@bitbucket.org:uwlib/druw.git

## cd to ~/druw/config, then copy all *.yml.template files to *.yml.
    cd ~/druw/config   
    for f in `ls *.yml.template |rev | cut -d '.' --complement -f 1 |rev`; do cp $f{.template,}; done

## Change to vagrant sync dir and run ansible playbook for druw.yml
    cd /vagrant   
    ansible-playbook -i inventory druw.yml

* You will have to start the following commands manually. You will probably also have to hit enter to return your prompt after each service starts up.   
    `cd /home/vagrant/druw`

* Start development solr   
    `bundle exec solr_wrapper -d solr/config/ --collection_name hydra-development &`

* Start FCRepo - your fedora project instance   
    `bundle exec fcrepo_wrapper -p 8984 &`

* Start development rails server (needs to start as sudo until I figure out perms)   
    `sudo rails server -b 0.0.0.0`

## Check DRUW (Sufia) is Running
Open a browser and go to http://localhost:3000. The initial load will take a bit (you'll see activity in SSH window as the rails server processes the request).

## Create a User
Go to http://localhost:3000/users/sign_up and create a new user (you will be making this user an admin in the next step).

## Create admin user
Follow the instructions on the main hydra sufia github page under admin users.  https://github.com/projecthydra/sufia/wiki/Making-Admin-Users-in-Sufia (via https://github.com/projecthydra/sufia/wiki/Sufia-Management-Guide)


 - First create a user from your browser at localhost:3000
 - Open another terminal and vagrant ssh in: `vagrant ssh `
 - Go to your application_home: `cd [yourapplicationhome]`
 - Start a rails console: `RAILS_ENV=development bundle exec rails c`
 - Search or scroll down to "Adding an admin user" in that github page mentioned above.
 - Follow those directions.