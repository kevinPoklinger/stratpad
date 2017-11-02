This is just to keep track of the changes made from version to version, so that we can
pass them on to the translator and merge them back into the source tree.

There are lots more comments in the app ReadMe.txt

The trick is to know what has changed, get the changes off to the translator, and then update/recreate all the es files.
For now we will not change any xibs, in terms of their layout (in future, if we do, we can record which ones got changed).

During development, not all xibs need localizing - only those with text in them, generally.
So make sure you create an english localization of any new xibs, or make changes to the existing en versions - then they will show up in a diff between es.lproj and en.lproj, thereby identifying what we need to send to the translator.
Once the changeset has been identified, then we can start to update es.lproj.

Random notes:

If you access an image from a localized nib, then that image must also be localized. You only need to do the english localization though, if it is an image common to all localizations. The fallback seems to work.
