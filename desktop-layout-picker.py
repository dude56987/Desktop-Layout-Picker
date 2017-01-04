#! /usr/bin/python3
########################################################################
# Script to change between custom panel layouts for xfce4
# Copyright (C) 2016  Carl J Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################
from os import system
from os import popen
from os import listdir
from dialog import Dialog
########################################################################
# This program changes the current users desktop layout for xfce4
########################################################################
# TODO #################################################################
########################################################################
# create the root dialog object
root=Dialog()
choices=[]
config=''
########################################################################
# Build the user interface
########################################################################
# grab a list of available desktop settings for the user to pick from
for item in listdir("/usr/share/desktop-layout-picker/layouts/"):
	# ignore core settings,hidden files, and any files that are not folders
	if (item != "CORE") and (("." in item) != True):
		if "default" in item:
			choices.append((item,'',1))
		else:
			choices.append((item,'',0))
if len(choices)>1:
	userChoice=root.radiolist('Which desktop environment layout would you like to be the default?',20,60,15,choices)
	if userChoice[0] == 'cancel':
		print('Not changing anything and closing program...')
		exit()
	# returns a 2 value tuple, grab value # 1
	userChoice=("/usr/share/desktop-layout-picker/layouts/"+userChoice[1])
	# add to the config file
	desktopLine=userChoice
########################################################################
# stop xfce4-panel and kill xfconfd which stores settings in ram
system('xfce4-panel --quit')
system('pkill xfconfd')
# remove users old config files
print('rm -rv ~/.config/xfce4/panel/')
system('rm -rv ~/.config/xfce4/panel/')
print('rm -v ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml')
system('rm -v ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml')
print('rm -v ~/.config/xfce4/xfce4-panel.xml')
system('rm -v ~/.config/xfce4/xfce4-panel.xml')
# install user picked settings package into the current users home directory
if len(desktopLine) > 1:
	print("cp -rvf "+desktopLine+"/. ~/")
	system("cp -rvf "+desktopLine+"/. ~/")
# if xfce4-panel has been closed successfully relaunch it
while (('xfce4-panel' in popen('ps -e').read()) != True):
	# start the xfce4 panel to show new settings
	print('nohup xfce4-panel > /dev/null &')
	system('nohup xfce4-panel > /dev/null &')
