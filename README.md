# scripts

## mac osx
### Install
- Set INFLUXDB_TOKEN variable enviroment
- Download macos installer
- give the script executable permission
$ chmod +x  install-service-macos.sh
- excetute script
$ ./install-service-macos.sh


You can stop the launchctl process by
$ sudo launchctl stop /Library/LaunchAgents/com.cryptween.plist
 You can start the launchctl process by
$ sudo launchctl start -w /Library/LaunchAgents/com.cryptween.plist
print
$ sudo launchctl print /Library/LaunchAgents/com.cryptween.plist

### Uninstall

- Download macos uninstaller
- give the script executable permission
$ chmod +x  uninstall-service-macos.sh
- excetute script
$ ./uninstall-service-macos.sh

## linux

Cryptween use the configuration files in the environment.d/ directories that contain lists of environment variable assignments https://www.freedesktop.org/software/systemd/man/environment.d.html#Applicability

The configuration files contain a list of "KEY=VALUE" environment variable assignments, separated by newlines. The right hand side of these assignments may reference previously defined environment variables, using the "${OTHER_KEY}" and "$OTHER_KEY" format.

systemctl --user enable cryptween.service
systemctl --user start cryptween.service

journalctl --user -u cryptween -f

## Windows
### Requeriments
- [PowerShell](https://docs.microsoft.com/powershell)
All modern versions of Windows operating systems ship with PowerShell installed. If you're running a version older than 5.1, you should install the latest version.
- run PowerShell as administrator
- Verify that the PowerShell terminal permits the execution of an script by verifiying the execution policy. PowerShell scripts can't be run at all when the execution policy is set to Restricted. This is the default setting on all Windows client operating systems. E.g.
PowerShell
~~~
    Get-ExecutionPolicy
~~~
Output
~~~
    Restricted
~~~

Change the execution policy. For example
~~~
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
~~~

- go to location of the script. E.g.
~~~
     cd C:\Users\username\Documents
~~~

- execute the script
~~~
     .\install-service-win.ps1
~~~

#### Check service
- Windows + R

- type "services.msc"