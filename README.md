# scripts

## linux
Cryptween use the configuration files in the environment.d/ directories that contain lists of environment variable assignments https://www.freedesktop.org/software/systemd/man/environment.d.html#Applicability

The configuration files contain a list of "KEY=VALUE" environment variable assignments, separated by newlines. The right hand side of these assignments may reference previously defined environment variables, using the "${OTHER_KEY}" and "$OTHER_KEY" format.

journalctl --user -u cryptween -f