Multiple Editions
=================
- all editions built off the same code base
- each has IAP to upgrade to the next
- an IAP simply sets its productId in NSUserDefaults, and we react accordingly
- if no productId, then we use the CFBundleIdentifier in the Info.plist

Versioning
==========
- eg. StratPad 1.1.2 (622) ( major.minor.revision (build) )
- we create a new Core Data model version every time we increment the major or minor number
- thus a change in core data model necessitates at least a minor version number change
- NB that you need to provide default values for new fields, if the fields are required values

StratFiles
==========
- each stratfile has an owner (todo), a group(todo), permissions and a model
- the model corresponds to the core data model from which it was generated
- the other fields allow us to check permissions, as you are editing
- use -[StratFile isWritable:] and -[StratFile isReadable:]

Core Data Models
================
    Before making any change, create a new model version.
    
    In Xcode 4: Select your .xcdatamodeld -> Editor -> Add Model Version.
    You should use something like StratPad 1.4.3 (next svn rev num) and base it on the previous revision
    You will see that a new .xcdatamodel is created in your .xcdatamodeld folder (which is also created if you have none).
    Save.
    
    Select your new .xcdatamodel and make the change you wish to employ in accordance with the Lightweight Migration documentation.
    Save.
    
    Set the current/active schema to the newly created schema.
    
    With the .xcdatamodeld folder selected:
     In Xcode 4: Utilities sidebar -> File Inspector -> Versioned Core Data Model -> Select the new schema.
     The green tick on the .xcdatamodel icon will move to the new schema.
    Save.
    
    Implement the necessary code to perform migration at runtime. Where your NSPersistentStoreCoordinator is created, for the options parameter, replace nil with the following code:
        
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, 
         [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil]
    Run your app. If there's no crash, you've probably successfully migrated :)
        
    IMPORTANT: Do not delete old model versions/schemas. Core Data needs the old version to migrate to the new version.
    
    Also, read through the STratFileManagerTest, which will need to be updated anyway.

Testing
=======
- the suite of tests is repeated for each edition
- you can customize a test to a particular feature of an edition using the EditionManager

Deployment
==========
- make sure you tag the deployed version
- build from the tag directory
- add a deploy directory and store the resultant .xcarchive
- this contains the .dsym and allows us to symbolicate crash reports

Structure
=========
- we start with a RootViewController
- this contains a SideBarViewController and a PageViewController
- PageViewController has a CyclicPagerView and a UIPageControl
- CyclicPagerView is entirely occupied by a scrollview
- the scrollview is populated with views from ContentViewController subclasses - 1 per page
- only 3 VC's ever make it into CyclicPagerView, current plus neighbours
- we also cache these controllers, in case you are clicking rather than scrolling
- PageViewController is told not to forward appearance and rotation events (ie maintain ios4 behaviour) to views
  of other viewcontrollers that have been added to the PageViewController view hierarchy
  - this means that you must invoke those methods manually, if desired, in these situations
  
Tricks and Considerations
=========================
- don't try and get the current page and chapter from the PageViewController, just from anywhere
    - for instance if you are in the MBReportHeader displayed on most report pages, you can't just grab the current page and chapter
    - this is because we render the page before we actually get there (the 2 neighbors thingy), so it will grab the wrong page
    - you need to hook into view[Will|Did]Appear, or pass it as a param, or grab it from the ContentViewController super class
    - you just have to remember, when we are building a page, it's not at that time the current page as reported by the pageVC
- company logos are written in several places: MBReportHeader (on screen), MBDrawableReportHeader (print), MeetingAgendaReport (html)

Dates
=====
- we select a local tz date, store it as local time without any tz or time information, and show it as local when reconstituting
- so what shows as Jan 3, 2008 in Calgary also shows as Jan 3, 2008 in Melbourne, regardless of the time of day
- these are for all dates, except created, modified and last accessed, which include the time of access, and TZ info
- for calculations, we standardize datetimes using dateWithZeroedTime, but never use it for display
- always use local tz for display

Date rules for forms/reports
============================

- normalize all dates to the first of the month for the purpose of calculations
- a duration must be at least one month, even if the actual duration is only 0 or 1 day
- a strategy's duration is defined by the earliest theme startdate, and the latest theme enddate
- a theme end date must be gte to the start date
- a metric target date must fall within its themes duration
- an activity's duration must fall within its theme duration
- an activity start and end date can be the same day

- all dates are optional
- if no theme dates, then the strategy duration is the current date to the current date + 8y
- if just a start date, then the strategy duration is start date to start date + 8y
- if just an end date, then current date to end date if valid, otherwise (end date - 1y) to end date
- when evaluating a theme, if either start or end date is missing, use the corresponding strategy date
- when evaluating an activity, if either start or end date is missing, use the corresponding theme date
    
Date rules for Financials
=========================

Fiscal Year
- if the earliest theme starts on March 12, for instance, then the fiscal year end is the end of February

Calculations
- if the earliest theme starts on March 12, for instance, then for calculations, use all of March
- ditto for the end of a theme

Date columns
- whatever year the fiscal year ends in becomes the year that all quarters are named
- eg. fiscal year ends in December 2014. Jan-Mar is Q1 2014, Apr-Jun is Q2 2014, Jul-Sep is Q3 2014, Oct-Dec is Q4 2014.
- columns would be:
 Jan14, Feb14, Mar14, Apr14, May14, Jun14,       		Q3 2014, Q4 2014, Q1 2015, Q2 2015,    				2016, 2017, 2018, 2019
 - the time periods covered by each column would be:
Jan1-31, Feb1-28, Mar1-31, Apr1-30, May1-31, Jun1-30	Jul1-Sep30, Oct1-Dec31, Jan1-Mar31, Apr1-Jun30		Jul1,2015-Jun30,2016 Jul1,2016-Jun30,2017 , etc


Another example
- theme starts feb 12, 2014
- fiscal year is Feb1,2014 to Jan30, 2015
- named quarters (yes this is double-checked and correct): Feb-Apr 2014 is Q1 2015, May-Jul 2014 is Q2 2015, Aug-Oct 2014 is Q3 2015, Nov 2014-Jan 2015 is Q4 2015.

Feb14 Mar14 Apr14 May14 Jun14 Jul14		Q3-2015 Q4-2015 Q1-2016 Q2-2016		2017 2018 2019 20120


Localization
============
- in most places we use a background image and then place live, easily localized text on top
- exceptions:
    - splashscreen: Default-Landscape.png & @2x in skins
    - reference section diagrams (& @2x versions)
        - strategy-pyramid.png 
        - toolkit-expanding-profitability-1.png 
        - toolkit-expanding-profitability-2.png 
        - toolkit-expanding-profitability-3.png 
        - toolkit-leadership-circle.png
        - toolkit-sweetspot-regions.png 
        - toolkit-sweetspot.png 
        - onstrategy-goal.jpg 
        - onstrategy-themes.jpg
    - reference section screenshots (& @2x versions)
        - onstratpad-action.png
        - onstratpad-sidebar.png
        - onstratpad-stratfile.png
        - starthere-nav-sidebar.png
        - stratfiles.png
- nibs: they must all be in src/xcode/main/StratPad/en.lproj
    - use ruby script to extract .strings file
    - ../../../util/generate_xib_strings.rb .
- localizable.strings: the global strings file also in src/xcode/main/StratPad/en.lproj
- htm/html files, also in src/xcode/main/StratPad/en.lproj
- when adding new keys, add to all localizations -> we can diff (FileMerge on en.lproj and es.lproj) to see what needs to be added
- UTF-16 is default format, though UTF-8 is acceptable, probably preferred, and easier to diff

Localization Upgrade Instructions
=================================

- the problem is that between versions, we add new stuff in english
- we need to find out what was added, get that to the translator, and get that into the spanish files
- we can't just overwrite nibs because we may have changed bounds in order to fit other languages
- so run ruby script to update en .strings files
- so do a diff (FileMerge on en.lproj and es.lproj), merge where appropriate
- make a patch -> this will show all changes in one file
  - diff en.lproj/ es.lproj/ > 1.3.1-localize-patch
- most of the time it will just be differences in the .strings files
- it's important that the keys line up between the localizations, even if they are not all translated, before release


Initial Localization Instructions
=================================

Files can be translated in place. Just edit and save.
Files are either UTF-8 or UTF-16 encoded. The encoding must be preserved.
Files all have unix line-endings (LF). Line endings must be preserved.

Any decent text editor can do this. Options on Mac are TextEdit, TextWrangler, BBEdit, TextMate. Options on Windows include TextPad, NotePad++, UltraEdit, and others.Word, WordPad and NotePad are not acceptable. They will almost certainly screw everything up.

There are four types of files needing translation:

1. htm(l) files
    Only the text needs translating - the text between the tags (<tag>this is the text to translate</tag>). None of the html files have much in the way of code, so this should be fairly straight forward.

    eg. an entry 
    <div id="menubar-tip">
        <span class="bolder">Toolbar</span> buttons are where you can print and email your StratPad reports and charts.
    </div>

    and translation:
    <div id="menubar-tip">
        <span class="bolder">Boutons</span> de la Toolbar sont la location des functions pour faire l'e-mail et l'impression.
    </div>


2. .strings file
    Here is an example entry:

    /* Class = "IBUILabel"; text = "Company Name"; ObjectID = "13"; */
    "13.text" = "Company Name";

    Here is an example translation:

    /* Class = "IBUILabel"; text = "Company Name"; ObjectID = "13"; */
    "13.text" = "Nom de l'entreprise";

    The text between /* */ is just to help the translator.
        
3. Localizable.strings
    This is a special, much larger and global strings file. Please read the instructions and comments inside it.
    
4. Images
    There are 10 images which have embedded type and need translating. Each image has a corresponding TextConvert...psd.txt file with translations. We've provided the image and the TextConvert file. 9 are from the reference section and 1 is the splash screen.
    
5. Screenshots
    There are 5 images that need to be taken as a screenshot after the UI is translated.

6. Dates

7. Editions.plist


Localization changed
====================
for UIViewController:
    extend of LMViewController to automatically load the desired nib file 
    or addObserver with name kLMLocaleChanged, and implement all the necessary data overload

for html:
    when set path to resources should be used [[LocalizedManager sharedManager]currentBundle]

for image: 
    specify the desired source in html file

