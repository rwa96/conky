# My conky configuration

![screenshot](screenshot.png)

## Install
1.  Customization <br>
    The **conkyrc_** files are the actual config files for conky. Aside from those parameters you
    can also look for tables named **params** *(files in scripts folder)* to make changes.

2.  Autostart <br>
    Change the user directory name in **conky.desktop** accordingly and copy that file to
    the autostart folder.

```
cp conky/conky.desktop ~/.config/autostart/
```

3.  Move folder to the right location

```
mv conky ~/.conky
```

4.  Restart and enjoy
