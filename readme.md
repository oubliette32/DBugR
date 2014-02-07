
PLEASE NOTE THAT USING THIS ADDON IS QUITE HEAVY AND IS FILLED WITH BUGS
USE ONLY IF YOU'RE COMPLETELY AWARE THAT THIS WILL END UP CAUSING PROBLEMS
WHEN USED FOR PROLONGED AMOUNTS OF TIME

1. General use 
2. Important notes 
3. Instructions of use 
4. Analytics window 
5. Pinpointing window 
6. Virtualization window 
7. Comparison window 

1) GENRAL USE
======

DBugR is a Lua profiler, performance monitor and script debugger.  The three primary uses of 
DBugR would be :

* Pinpointing performance problems caused by Lua scripts
* Optimizing custom gamemodes and addons
* Server monitoring

DBugR is not designed to do the following :

* Magically fix lag
* Deal with crashes or any attempt to combat or analyze them
* Debug and profile non-lua activities

2) IMPORTANT NOTES
======

* This is a relatively heavy addon.

* This is very intrustive, running an anti-cheat alongside this is not wise.

* By default this does not attempt to profile itself.  This can however be enabled in the settings.

* Loading a log takes about 2 seconds depending on the size.  Logs are loaded when they are "compared".

* The pinpointing menu does not remove data that was not called this frame.  The time it was called
  is displayed on the far right column under "Time".

* Players should not have access to DBugR unless they need to, granting players access gives them quite
  a lot of control over your server.

* Live data in graphs will not begin to show until the menu is first opened.

* Clientside logs contain sevrerside information.  All serverside data is networked to the client.

3) INSTRUCTIONS OF USE
======

The main DBugR menu is opened by typing "dbugr_menu_open" in the console.  You should bind this to a key.

Generally there is no "way" to use DBugR, information is logged and displayed in various windows,
however there are more efficient ways of getting what you want done.

If you're encountering consistent lag all you will need to utilize is the Pinpointing menu.

If you're encountering lag that occurs almost randomly, you're going to want to write down the time
and date that lag occurs and view the corresponding logs using the Virtualiztion menu.

If you're using DBugR to optimize scripts then you will want to take a look at all the windows, really.

If you just like viewing the performance of your server in the analytics menu, then open the menu...

Explanations of what mentioned windows do and how to use them is covered below.

4) ANALYTICS WINDOW
======

The analytics menu is used to identify lag and monitor your server's performance.

The analytics window is comprised of four graphs : 

* The client's performance
* The client's outgoing network usage
* The server's performance
* The server's outgoing network usage

The analytics window is fed either live data or data from a log.

When viewing data from a log clicking on the dots shown on the graph will select
the frame they are above in the X axis.  This is useful for analyzing spikes that were
caused within a 30 second log.

Selecting a frame simulates a call to each function, so they will appear in the pinpointing
menu as if they were just called.

Right clicking any of the graphs at any time will pause live date fed into it, this is useful
if you want to hover over a dot to get the exact value.

The key at the top of each graph, just below the title shows what each colour on the graph represents.
Right clicking any of the dots in the key will hide every data type BUT the one you clicked on.

Left clicking will hide the data type that you clicked.

Hidden data types will appear as gray lines unless paused, in which case they will be completely
invisible.

If required, graphs in the analytics window can be resized horizontally by clicking and dragging the bar
in the middle of two graphs.

5) PINPOINTING WINDOW
======

The Pinpointing menu, as the name suggests is used to pinpoint certain data.  For example,
finding the location of the most expensive hook called at a certain time.

This menu is split into two, the right side contains a list of data types split into categories,
the left side is a function preview, with some key information written above it.

Generally you'd go about using this by first selecting the category you want to view from the right
then clicking on the column header of value you're most interested in, to order the results.  This will 
likely by "Value (Total)" for performance categories or "Size" for network categories.

The categories names are prefixed with N or P, respectively representing performance and networking
categories.

Clicking on any results in the right pane will download the related source for that function, that's 
displayed in the left pane with minimal syntax highlighting.  The line and name of the source file
is displayed directly above this pane.

6) VIRTUALIZATION WINDOW
======

The virtualization window's function is simple.  This is where you can manage and view 
logs from.  Keep in mind, switching back to live view is also done from this menu.

You'll find that there's a log browser on the left, basic controls on the bottom right
and a mysterious list on the top right.

This mysterious list happens to be a list of active downloads, if you're downloading 
server logs, they will appear in there until complete.

Just above the log browser on the left, there's two combo boxes, these are used to select
the folder to look for logs in and whether to look for server or client logs.

There are 6 buttons on the bottom right, they are used to :

* Download files, using the "Download File" button
* Delete files (you cannot delete server logs like this), using the "Delete Log" button
* Archive and unarchive logs, respectively removing or adding the logs to the archive (a
  list of files that aren't automatically purged every DBUGR_PURGE_TIME seconds)
  using the "Add to Archive" and "Remove from Archive" buttons.
* Viewing logs, pressing the "View Log" button will have the log data from the selected log shown in
  all other windows (besides comparisons window, as that window does nothing with data).
* and finally "Go Live", which simply switches back to live data if you were viewing logs.

7) COMPARISON WINDOW
======

The final window, Comparisons.  This window is used only as an optimization tool.

In the top middle lies two graphs, one for networking and the other for performance, each will 
have two lines, one for log set A and log set B.

Logs selected in the bottom left reresent data set A, as the big A letter above it suggests.  The same
is true for the right side, where it represents data set B.

Usage of this utlity is easy, select logs you want to compare from the left and right log views and hit
the "Compile logs" button.

You may wonder how more than one log is represented in a single 30 second timeline, the same size as a single
log.  The calculations are done with averages on both sets.  point 1 on a timeline represent the average between 
the first second in each log from the respective data set.

Though you can, comparing clientside logs with serverside logs will cause bad averages.  As stated in the important
notes section of this readme, clientside logs contain serverside data.

Operating the log views to select data sets is done the exact same way youwould in the virtualization menu.


