# Jenkins slave installer for OSX

Script for setting up and running a JNLP Jenkins slave on OSX.

## Instructions

1. Create a new node on your Jenkins master (Manage -> Manage Nodes). Set root directory to `/Users/OSX_HOST_USERNAME/Jenkins`
2. Extract the repo contents on the OSX slave host.
3. Run `sudo chmod +x jenkins-slave-osx.sh`  to set permissions.
5. Run `./jenkins-slave-osx.sh` to see list of available commands.

## Requirements

Java Development Kit has to be installed in order to use JNLP. Please see OS-specific instructions on how to do that.

## Credits

- Casey Garland ([Setup a Mac Slave for Jenkins](http://www.parsed.io/setup-a-mac-slave-for-jenkins/))

## License

This script is licensed under the terms of the MIT license.