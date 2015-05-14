# ProjectZT_CM03

Only supporting from IOS 8 and futher. Is capable of installing on IOS 7, but no crashes are not guarenteed!

Pull in Xcode!

##Main features
- Loginscreen with username and passcode for login in
- The Carousel itself, where the user can scroll through his own messages, clubnews or news, chosen inside the website
- The Carousel colors will correspond those from the website settings
- Notification sounds when getting a new item (when enabled inside website)
- Automatic speeching every item + when getting a new item (when enabled inside website)
- When having no messages, clubnews or news, the app will automatically fetch new items of that type. Otherwise, a normal fetch is done when the user is at the end of every type of item.
- The app will remove all items (except personal messages) when reopening the app that are older then the given time (see report)
- Opening an item is done with single tapping (whole screen is covered)
- The item colors will be corresponding those from the website settings
- Item will be speeched (when enabled inside website)
- Item can be closed with swiping to the left
- Item will be deleted after an amount of time (can be edited inside website)
- Accessibility support
+++ Much more minor features....

##VoiceOver
When enabling voice over, the first element will be the categorytypeview. This is necessary, otherwise the carousel scroll does not work.
- The scroll will work with three fingers left and right
- Opening a message is done with double tapping

Inside the message, the user has to swipe with one finger to go to another element
- To scroll inside the textView, it is necessary to dubble tap the view and hold (three fingers not working at this moment)
- Closing is done with three fingers sliding to the left, inside the messagecontent or outside the messagecontent (not at the title!)

When the user returns to the Carousel, the user will have to swipe to the right one time so the highlighted element will be the categorytypeview again. It is also possible to tick the categorytypeview at once. When done, the user can scroll with three fingers again.
