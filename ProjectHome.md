# Current Status #
This project is no longer the main project of the original developers, we are changing our focus to new software for the official SDK release.  This does not mean we are stopping working, this just means that it isn't our primary focus.
The full source + lib purple is in the SVN under apollo\_1.02.  Since we can't work on it as much as we'd like, we encourage anyone and everyone to get the source and start working on it.  If you want to see your changes merged back into the main source tree, send it to humajime @ gmail.com.  I'll be managing the source tree.  When changes are received, I will package them and release new versions of Apollo.

# What Is It? #
Currently, a libpurple based IM client which brings AIM, MSN, .Mac, and ICQ to the iPhone.

# Can I Help? #
Of Course You Can!  We may not be focused on it anymore, but you sure as heck can. It is open source and I am now taking up the role of source manager..

### 10/1/2007 ###
Version 1.0.2 released.
  * Unicode Support

### 10/1/2007 ###
Version 1.0.1 released.
Here we have some much requested bug fixes:
  * .Mac support is easier to use.  DELETE your .Mac accounts and add them again!
  * Mysterious double size buddies fixes.
  * MSN login problems fixed to the best of our testing.
  * Conversation with hidden buddies and buddies not on buddy list.
  * Login time improvements.
  * Fixed a handful of crashes.

### 9/23/2007 ###

Well, it tooks us longer, but we decided to tweak until it was perfect.  Welcome to ApolloIM 1.0 - here's our change log.

  * Added support for DotMac, ICQ, MSN in addition to AIM.  Through libpurple.
  * Buddylist notification of open conversation
  * Multiple account sign on - I've been on 8 accounts at once, although, I wouldn't recommend more than 2-3 active accounts on edge, otherwise it gets slow real quick
  * Sectioned buddy list by accounts
  * Away / Unaway via the pretty green dot in the upper right.  Tap it, turns red, you're away.  Tap it again, turns green, you're back.
  * Support for Alias'd buddy names.
  * Support for Status Messages  - shows up in the buddy list
  * Time Stamps in conversation windows
  * Removed Buddyinfo, for now
  * Preparing to add a pane to "Settings" - eliminates need for "Prefs" button for us, will allow extended user options
  * Completely brand new UI.
  * Entire application is brand new, recoded from the bottom up. Stability should be amazingly enhanced.
  * Wifi Keepalive still requires summerboard.

We've tested and retested, and while we could have released days ago we chose to keep piling on as many features as we could.  So here you go, the fruit of our labors.

While you're at it, check out our new [homepage](http://www.apolloapp.com/) - we're coming up in the world.  We'll still call our googlecode page home for our svn, but apolloapp will be used to announce more releases and hopefully soon provide more detailed information about features and the like.  Check it out.

### 9/17/2007 ###

Hey guys - just wanted to chime in and say we haven't forgotten you.  We're hard at work on 0.2.0, and we're close to a release.  It's our most feature packed version yet, better stability, keepalive works pretty well, and we're adding most of the protocols people have been requesting.  We're hoping to clear out the issues page :)

As for now, hang tight.  We don't want to put out any screenshots or anything until our release - we have some surprises in store :)

Until then, feel free to email us - arminius2@gmail.com - and once again, thanks for your support.  Really, you've kept us coding and we'll keep pioneering as long as there is community support.  Thanks guys, really.

--
Quick update - I've personally been involved with the iPod touch hacking team, and well, the second we're inside the touch we'll have an Apollo client ready.

### 9/9/2007 ###
BETA 0.1.2 is out - here's the changelog -

  * Loads of stability fixes!
  * Removed options button in favor of using the ringer button.
  * Ringer button dictates vibrate or playing sounds
  * New Sounds, only send/recv, but much more pleasant
  * Fixed Conversation window sometimes not responding after resume from suspend
  * Fixed "Disconnect not disconnecting"
  * **Added Wifi Keep Alive** If you are using SummerBoard, the latest version now works with ApolloIM to not turn off   Wifi.  There is no reconnect support yet, but this is a solid feature.  **Note: This will drain your battery much faster because Wifi is kept on while in lock while ApolloIM is running.**  But it works pretty great and the drain seems to be manageable
  * Does not vibrate on send.

In other news, we're gearing up for libpurple.  We don't know when we'll feel confident to release our work, but we do have a test client that can sign on to aim / msn / jabber.  It's not pretty yet and not all of the dangly bits are hooked up - but we're pretty happy with our progress.  Special thanks to the Adium Team as well as Sean Egan for pointing us in the right direction a few times.  There's no set timeline for when it will be ready, but as soon as we're sure it's solid, we will release it.  The release of libpurple will start the 0.2.0 versions.

As soon as we're sure libpurple is working great, we'll bump our version up to 1.0 :)

Enjoy the new beta, and please, if you have any feedback - arminius2@gmail.com  - We're also going to have a site ready for you very soon.

### 9/4/2007 ###
Released BETA 0.1.1 to fix a couple small things.  Preferences weren't sticking but should now, and back on Preferences takes you back to the buddy screen.  Badges should work better now.

### 9/3/2007 ###

Well, we've released BETA 0.1 - that's right folks, we're above Zero.  The stability in this version is far superior, and I believe that it's actually ready for "Use."  We've piled through the issues and fixed as many bugs as we could have, and for being barely a week old, I think we're doing amazing things.  We have also just gotten, as of today, libPurple fully compiled and the nullclient/ncurses client (Finch) working, and so you can expect support in the near future for MSN/Yahoo/Jabber/Gtalk and as many others as we can get linked - special thanks to Core & Nightwatch for working hard on that.

Since last week we've implemented a host of changes - mostly at the request of people like yourself.  So please keep filing "Issues" and if you've got a comment on a build or would like to say thanks - feel free to email the team (emails at the right).

Notable Fixes:
-Conversation Windows' scrolling is a lot smoother and works a lot more reliably (Fixed by moving to a UIScroller)

-Defaults back to the send box after sending a message (was the conversation window. Fixed by moving to a UIScroller)

-If you are disconnected, your password is wrong, or you chose to disconnect - it will not close ApolloIM.  You're free to select another account or change your pass and then reconnect.

Firsts:
-First application to implement Edge Keep Alive - found method in NetworkController.h that  should bring Edge up if it's down as well as keep edge alive while in suspend.  This however does not apply to Wifi yet - wifi is seemingly controlled by Springboard, and when springboard suspends at lockdown it will bring this down.  We're on the lookout for getting a springboard hack implemented (a la summerboard), and as soon as we get something we'll implement it asap.  For now, assuming you've got plenty of bars of coverage, Edge will stay connected.  I would warn you that there is the chance you will miss a call / text message, but every time I have received a text/call while on ApolloIM (on Edge), it has exited Apollo and allowed me to take the call.  Will require much testing.

-First application to implement vibration.  Admittedly, it's a dirty hack right now - but our buddy pumpkin in #iphone-uikit has come through and found a way to get vibrate working.  You can turn it on and off (Along with sound!) at your discretion.

Other New Features:
-Buddy info works, but isn't pretty.
-Delete button for Accounts
-UI Badges like Mail/MobileSMS for unread messages

What sort of works:
-Sound is kind of wonky at moment.  For example, if you're playing a song on the iPod  and you get a message while sound is on, it will pause your song and not resume.  We haven't figured out yet how to send the notification to turn it back on.  For now, I would recommend that you keep sound off while you intend to listen to your earphones and just use vibrate.

### 9/1/07 ###
Fixed edge / "Generic Error" problems.  Turns out the iPhone's DNS resolver is royally f'd and the new Firetalk didn't like it, but I have remedied this for now by just popping the raw IP into the server host field.

This should fix the immediate issues that cropped up from last release.  Notably "Generic Error," and this will also be the last release  until Monday night where I endeavor to clear out the "Issues" page.  Several dev's are getting ready to do  branches with sound/vibrate updates and I'm personally gearing up for a real "suspend".

Special thanks to the dude at the Apple Store in boulder who had ApolloIM on his phone.  It was really rad seeing that.

Gizmodo, I'm hoping for a "ApolloIM One Week Later:  85% less suck on the road to Beta" Tuesday morning.

### 9/1/07 ###
Wow, 7300 downloads last night.  That's really nuts.

Truth be told -.8 was just a quick fix for the buddy list, today I will be releasing a proper implementation (working on it right now, 10am on a Saturday morning).  I would hold off until Early Sunday morning if you haven't upgraded yet.

### 8/31/07 ###
Negative .8 is up and the buddylist should be fixed and there should be far less crashing.    Before you sign on, I advise you to set your account to inactive, save, then go back and set it as active.

Note:  Edge does not work in this connect.  It will be fixed Saturday  - Sept 1st - with version negative point seven five.  New firetalk is too fast, interface doesn't have a chance to come up.

### 8/30/07 ###
Firstly,  I want to thank the person who donated $300 to the new team.  These kind of donations keep me working hard, and now that we have a real team coming together, will keep us focused. If you wish to help out, every little bit helps, and will be used 100% towards materials needed while coding.  Just contact us and we'll set you up with our paypal information.

Now, on to the news...

Suspend support is partially working.  You can go and use other programs, and ApolloIM will still stay open.

The main problem with suspend is that the iPhone goes into a low power mode when shoved into your pocket waiting for a call - and this mode will shut off edge / wifi.  Simply pinging the server won't keep the wifi up, as it seems the kernel does its best to plain unload it.  I don't know what the prospective fix for this, one idea would be to move to a client/remote daemon, which would mean you would run a client on your home computer which would record all the incoming messages to you and send it over to you (and when your phone goes off, you'd still be on, because the daemon is still running).

Suspend as whole, however, should work while you're playing music.  If you're playing a song while ApolloIM is on and in your pocket, it will keep the iphone active enough to keep the program connected.  The trick for me here is to find how exactly Apple does that, and well, I'm on the case.

I've also improved the Conversation window, at the cost of making the Send button uglier - if you have problems with the send button, aim for hitting the "text" on the button.  You no longer can type in the main window, and I may release another update very soon to use "text bubbles" like iChat uses.  I have removed the keyboard button in favor of just being able to tap the main view to bring up the keyboard (or you can tap the sendfield at the bottom which,like MobileSMS, will bring up the keyboard).

This will be the last update for a while.  I have been working alone on this project since it's beginning, but the team has started to come together.  It was kind of funny to see people say "The ApolloIM team" when it was just me, but thanks to my initial release, I've gotten some star players to help out.  Notably Dankow who will be working on the interface and keeping code tidy, and Core who has stepped up to help us get libpurple worked out.   If you know libpurple well, and would enjoy helping us integrate it, please send me an email at arminius2@gmail.com .

LibPurple will enable us to have Yahoo, MSN, Jabber, and GTalk support when we get it ready, as well as fix the "Buddy's not showing up" error.  I suspect my current implementation of libfiretalk is bugged, and I can either work on exchanging it for a different version or get purple working an adding support for the other services.  I'm told one solution could be for you to create a new screen-name and import your buddylist with a "real" client, and then not to change the formatting of any names.  It's cumbersome, but until we get Libpurple working, it'll have to do.

### 8/27/07 ###
Fixed suspend support.  ApolloIM will keep running now if you press the homebutton.  SVN is up, binary may be up tonight.