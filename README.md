Rutgers Repository Tools (v2)
========================

Rutgers Repository Tools is a set of tools used by Open System Solutions on
CentOS machines for the RPM package publishing process. These tools work in
conjunction with Koji and uses mash to generate the repos. It is written
mostly in bash.

The configuration files are the mash configuration options stored in
"/etc/mash", the yum conf in "/etc/repotools2-yum.conf", and the main conf
file in "/etc/rutgers-repotools-2.conf"

Prerequisites
-------------
In summary, an the root user  does the tagging and untagging of packages on 
Koji, and a user called 'roji' sends an email with the results of its operations.

These tools are designed to run on a system which has read and write access to
the Koji PostgreSQL database, as well as write access to the Rutgers RPM
repositories.  In order to access the Koji database and perform tagging
operations, the user running the commands needs SSL certificates generated 
and installed in the Koji certificate directory (typically `/etc/pki/koji`).

Publishing Scripts
------------------
Scripts for publishing to repositories.

### pushpackage
The main publishing script. This takes packages from a repository (tag) and
copies it (tags it) to a given target repository. Note that this does not erase
existing tags. This also checks the dependencies of the packages against the
repository they are being moved to with the depcheck script. At the end of the
push, mail is sent, indicating success or failure.

An example:

     $ pushpackage centos6-rutgers-testing rutgers-repotools-2-1.0.1-1.ru6

### pullpackage
This script does the opposite of pushpackage: it takes a package from a
repository and untags it. Before this occurs, it does dependency checking to
make sure that an existing package does not depend on the removed one.

The pullpackage script takes arguments in the same style as pushpackage.

Other Scripts
-----------------------------------
These scripts do dependency checking, regenerate repositories, perform backups,
and so on.

### depcheck
Does dependency checking on a given repository. This is a hack that uses
repoclosure from the yum-utils package. Essentially, it pretends that our
repository is a Yum repository, then has Yum do the dependency checking for us.

This script is run as part of the daily checks cron job; it call also be run by
hand if desired.

It's possible to give a list of exceptions for broken dependencies that this
script will ignore. By default, the list is installed at `/etc/depcheck2.ignore`.
However, it's best to avoid using exceptions and fix the broken dependencies
properly. 

### rebuild-repo
This script will regenerate the published repository for a specific koji tag. 
First, this uses mash to create the repo for a koji tag into a temporary 
directory (the directory is the same name as the koji tag it is making the repo for). 
Then, asssuming mash succeeded, the old repository is renamed to "\<tag\>-temp" and 
the newly generated repository is remaned "\<tag\>-current". If for whatever reason
the newly generated repo is bad, you can just use the old one. The "\<tag\>-temp" 
repository gets deleted after each successful run of mash.
This script is used by pullpackage and pushpackage.

For more information about where these directories are located, see the
configuration file.

### koji-backup
This dumps the PostgreSQL Koji database and saves it as a backup. Like the
rpmdb-backup script, it takes its arguments from the command line, but the cron
job automatically uses information from the configuration file by default.

Authors
=======
Written by Alexander Pavel of Rutgers University Open System Solutions to replace 
the original repotools suite (originally written in python).

License
=======
This software is licensed under the GNU General Public License v3. See LICENSE
for more info.
