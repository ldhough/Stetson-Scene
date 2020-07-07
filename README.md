# Stetson Scene iOS Application

"Stetson Scene" is an iOS application that I built with two friends (Madison Gipson, Aaron Stewart) for students at our school to use.  We use a Python backend to parse XML and HTML on Stetson's websites to extract information about events going on.  This information is passed to Firebase and read by the iOS application.  We provide integration with various features like Apple's calendar and sharing with friends.  We have integrated a map component and AR component to help students navigate to events.  Search features are built in so that students can filter for events they are interested in including "Cultural Credit" events that you need to graduate.  You can also see how many people have "favorited" an event as a measure of popularity.

## Tech
 - Python backend
 - Firebase Realtime Database
 - Swift
 - SwiftUI, UIKit, EventKit, ARKit, Core Data

## Contributions

Lannie: Contributions include building the Python XML and HTML parser and the Firebase integration on both sides.  Used Core Data to provide persistence for information like favorites and search criteria.  Built out part of the UI using SwiftUI, built the searching features, and worked on the Apple Calendar integration.

Maddie: Headed the AR component, working with ARKit & UIKit to deliver an interactive AR Scene in which the user sees tags above campus buildings and can tap to see a list of upcoming events in that building. Additionally, contributed to the user experience across the app using layouts, view transitions, haptics, and animation in SwiftUI.

https://www.youtube.com/watch?v=LQdyA4Y4_qM

https://www.youtube.com/watch?v=Y0MAO182c0I
