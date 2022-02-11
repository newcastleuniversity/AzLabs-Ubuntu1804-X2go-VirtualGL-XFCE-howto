# `vglrun` wrapper scripts and desktop menu items

If you try to use a GL application within an X2go session, the session will crash unless you launch the application with `vglrun`.  To allow your students to launch applications without having to remember to use `vglrun`, you can use wrapper scripts and alter the desktop menu items.

The examples given are from an Azure Lab configured to teach computational chemistry but can be adapted for whatever you are teaching.  Here, I will walk through setting up the wrapper script and menu items for the application called SeeSAR.

## SeeSAR out-of-the-box

Running `vglrun seesar` in a terminal emulator gives me the SeeSAR GUI, but if I run `seesar`, my X2go session crashes. SeeSAR's installer also made a desktop menu item targetting */opt/seesar-11.2.2/seesar*. Double-clicking that item crashed my X2go session.

SeeSAR installs itself into */opt/seesar-11.2.2*.  Note that this directory is not in the student's $PATH.

```
student@ML-RefVm-422967:~$ echo $PATH
/usr/local/gromacs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/VirtualGL/bin
```

Instead, there is a symlink at */usr/bin/seesar* pointing to */opt/seesar-11.2.2/seesar*, and `which seesar` gives */usr/bin/seesar*.  This is useful for fixing the command line invocation because the real SeeSAR executable isn't directly invoked.

## Fixing command line invocation

I will replace the symlink at */usr/bin/seesar* with a wrapper script that launches SeeSAR within `vglrun`.

SeeSAR can take command-line arguments, so the wrapper script must capture and pass on those command-line arguments.  The *$@* argument in the wrapper does this.  Once I have made my wrapper, I need to become root and write it to */usr/bin/seesar* and then run `chmod 0755 /usr/bin/seesar`.

Example file: seesar

## Fixing menu items

Menu items are usually in */usr/share/applications* as [Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html) files.  Alter the line that starts *Exec=* but leave the rest of the file alone.  The *%F* is needed so that the student can open a SeeSAR project by double-clicking it.

Example file: seesar11.2.desktop

## Why not just move `seesar` to `seesar.real`?

If I had renamed */opt/seesar-11.2.2/seesar* to */opt/seesar-11.2.2/seesar.real* and put the wrapper script at */opt/seesar-11.2.2/seesar*, I'd have a *$@* in the command */opt/seesar-11.2.2/seesar* used by the menu item.  The menu item already has a *%F* mechanism for dealing with file arguments and I don't know whether the two would conflict.  Remediating that possible conflict would mean altering the menu item to say "Exec=/opt/VirtualGL/bin/vglrun /opt/seesar-11.2.2/seesar.real %F", so it doesn't save me any work.
