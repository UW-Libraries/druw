# WCR Repository

This repository builds a research data repository based on the Fedora/Hydra/Sufia platform.

## Development box prerequisites:
 - Vagrant
 - Virtualbox

## Install centos 7 virtualbox image
    vagrant box add centos/7 https://atlas.hashicorp.com/centos/boxes/7

On Windows, you might be given a choice between libvirt or virtualbox. Choose *virtualbox*.

## Check that it has installed
    vagrant box list

and you should see 'centos/7' listed

## Clone uwlib's vagrant-ansible-druw repo
    git clone git@bitbucket.org:uwlib/vagrant-ansible-druw.git
    cd vagrant-ansible-druw

## Copy vars.yml.template to vars.yml.
    cp vars.yml.template vars.yml

Edit druw_home if you want it to install in someplace other than /home/vagrant/sufia   

## Start your vagrant box
    vagrant up --provider virtualbox

## ssh into vagrant box
    vagrant ssh

## scp your bitbucket private key into .ssh dir
    scp [yourbitbucketprivatekey] ~/.ssh

If the git clone below doesn't work, you might need to do either of the following:

1. Rename your private key to `id_rsa`

2. Change its permissions: `chmod 600 [yourprivatekey]`

## Clone this repo into wherever you specified druw_home to be in vars.yml
    cd ~   
    git clone git@bitbucket.org:uwlib/druw.git

## cd to ~/druw/config, then copy all *.yml.template files to *.yml.
    cd ~/druw/config   
    for f in `ls *.yml.template |rev | cut -d '.' --complement -f 1 |rev`; do cp $f{.template,}; done

Edit druw_home if you want it to install in someplace other than /home/vagrant/druw

## Copy config/initializers/devise.rb.template to config/initializers/devise.rb
    cp ~/druw/config/initializers/devise.rb.template ~/druw/config/initializers/devise.rb

## Change to vagrant sync dir and run ansible playbook for druw.yml
    cd /vagrant   
    ansible-playbook -i inventory druw.yml

## Start Up DRUW for the First Time

 You will have to start the following commands manually. You will probably also have to hit enter to return your prompt after each service starts up.   

* `cd /home/vagrant/druw`

* Start development solr   
    `bundle exec solr_wrapper -d solr/config/ --collection_name hydra-development &`

* Start FCRepo - your fedora project instance   
    `bundle exec fcrepo_wrapper -p 8984 &`

* Create a default admin set. You only need to do this step ONCE when you first create your new VM:
    `rake sufia:default_admin_set:create`

* Start development rails server (needs to start as sudo until I figure out perms)   
    `sudo rails server -b 0.0.0.0`

When you start up DRUW in the future, you will only need to start up Solr, FCrepo, and Rails. You do NOT need to recreate the default admin set.

## Check DRUW (Sufia) is Running
Open a browser and go to http://localhost:3000. The initial load will take a bit (you'll see activity in SSH window as the rails server processes the request).

## Create a User
Go to http://localhost:3000/users/sign_up and create a new user (you will be making this user an admin in the next step).

## Create admin user
Follow the instructions on the main hydra sufia github page under admin users.  https://github.com/projecthydra/sufia/wiki/Making-Admin-Users-in-Sufia#user-content-add-an-initial-admin-user-via-command-line 

 - First create a user from your browser at localhost:3000
 - Open another terminal and vagrant ssh in: `vagrant ssh `
 - Go to your druw_home: `cd [druw_home]`
 - Start a rails console: `RAILS_ENV=development bundle exec rails c`
 - Search or scroll down to "Add an initial admin user via command-line" in that github page mentioned above.
 - Follow those directions.

---

# Build demo site

On a computer with ansible installed

## Clone vagrant-ansible-druw onto a computer that has ansible installed on it.
    git clone git@bitbucket.org:uwlib/vagrant-ansible-druw.git

## cd into checked out repo and edit config/vars.yml

 - ```cd vagrant-ansible-druw```
 - ansible_target - change to demoserver
 - druw_home - change it to /var/druw

On the demo server

## ssh onto demo server (ssh -A or copy bitbucket key over.)

## Clone this repo and move it /var/druw
    cd ~   
    git clone git@bitbucket.org:uwlib/druw.git
    sudo mv druw /var

## cd to /var/druw/config, then copy all *.yml.template files to *.yml.
    cd /var/druw/config   
    for f in `ls *.yml.template |rev | cut -d '.' --complement -f 1 |rev`; do cp $f{.template,}; done

Edit /var/druw/config/secrets.yml

 - In production stanza, add the line ```secret_key_base = 'your key just copied from the private.yml.template"```
 - After this entire thing is built you could generate a secret key if you wanted to replace this ```bundle exec rake secret```

## Copy /var/druw/config/initializers/devise.rb.template to /var/druw/config/initializers/devise.rb
    cp /var/druw/config/initializers/devise.rb.template /var/druw/config/initializers/devise.rb

Edit /var/druw/config/initializers/devise.rb

 - add the line ```config.secret_key = 'your key that you just copied from private.yml.template"```
 - After this entire thing is built you could generate a secret key if you wanted to replace this ```bundle exec rake secret```

## Disable selinux for now
    sudo setenforce 0

On the computer with ansible installed

## Go to vagrant-ansible-druw repo
Run ```ansible-playbook -i inventory --ask-become-pass druw-fullstack.yml```