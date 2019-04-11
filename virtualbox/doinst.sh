config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database usr/share/applications >/dev/null 2>&1
fi

if [ -x /usr/bin/update-mime-database ]; then
  /usr/bin/update-mime-database usr/share/mime >/dev/null 2>&1
fi

if [ -e usr/share/icons/hicolor/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache -f usr/share/icons/hicolor >/dev/null 2>&1
  fi
fi

# Prepare the new configuration files
config etc/vbox/vbox.cfg.new
config etc/default/virtualbox.new
preserve_perms etc/rc.d/rc.vboxdrv.new
preserve_perms etc/rc.d/rc.vboxballoonctrl-service.new
preserve_perms etc/rc.d/rc.vboxautostart-service.new

# Remove the setuid bit from the VirtualBox and add it to VirtualBoxVM binary file
# as a workaround to allow normal user to run virtualbox in hardened version
/usr/bin/chmod -s /usr/lib64/virtualbox/VirtualBox
/usr/bin/chmod +s /usr/lib64/virtualbox/VirtualBoxVM
