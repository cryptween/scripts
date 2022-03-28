# scripts

## mac osx

You can stop the launchctl process by
$ sudo launchctl stop /Library/LaunchAgents/com.cryptween.plist
 You can start the launchctl process by
$ sudo launchctl start -w /Library/LaunchAgents/com.cryptween.plist
print
$ sudo launchctl print /Library/LaunchAgents/com.cryptween.plist

## linux

Cryptween use the configuration files in the environment.d/ directories that contain lists of environment variable assignments https://www.freedesktop.org/software/systemd/man/environment.d.html#Applicability

The configuration files contain a list of "KEY=VALUE" environment variable assignments, separated by newlines. The right hand side of these assignments may reference previously defined environment variables, using the "${OTHER_KEY}" and "$OTHER_KEY" format.

journalctl --user -u cryptween -f