# touch-scroll-listboxes
Subclassing Win32 controls in Clarion to achieve touch-scrollable list boxes 
(similar to mobile touch scrolling). 

This consists of a class which overrides the default handling for 
Win32 listboxes and processes the appropriate gesture messages that are built 
in on Windows 7+. Works on touch-enabled laptops, monitors and tablets. 

Usage:
1) In your core module, before the global map, do this:

   INCLUDE('TouchScrollList.inc'),ONCE ! Touch-Scroll ListBox class

2) For any window where you want to use this, in the main declarations 
before the code, create an instance of the class. 

   For example:

   ThisTouchList       CLASS(TouchScrollList)

   END

3) In your ThisWindow.Init method, after the window is opened, do this 
(substituting the name of your listbox control):

   ThisTouchList.Init(?listcontrol)

4) In your ThisWindow.Kill method code, add this:

   ThisTouchList.Kill()

....and that's it! If you want more than one listbox on one screen, 
repeat steps 2-4 with different names for the class instance (eg. 
ThisTouchList) and control.

One little caveat is that this does not provide perfect 1:1 scrolling - 
the list scrolls at a very slightly different rate than the gesture. 
I think this is because of padding on the cells (I'm using PROP:LineHeight) 
but have not worked out the exact details. Also, the animations aren't as 
silky smooth as on smartphones, but it does have inertia at least.

For the technically minded, I've left in some commented debug code, some 
commented code both for stuff I tried to do to smooth out the animations 
(which didn't work out), for places to add additional stuff, and some 
equates which are mostly for reference.

It could probably use some improvement, and certainly could be modified 
for other similar purposes, so do with it what you will and sharing some 
of that back would be appreciated. I'm sure it could be converted into 
template format, as well. 

Very special thanks go to several people on the Clarion newsgroups, 
who may or may not want to be named, but all of whom helped greatly 
to shepherd me through learning some of the things I needed to accomplish this. 
Thanks gentlemen! If you're ever in Toronto I owe you some drinks.

Cheers!

Tom
