PROJECT: THOUGHT STACK!

1.TEAM:

YESHA AILANI

ABHIJEET PRABHU


2. DESCRIPTION/ABSTRACT:

Quotes, with only few words, can tell you a story! The main concept of this project is to create positive, inspirational and thoughful quotes,save the ones you like in your ThoughtWallet to go back to revisit them and explore an explosion inspirational quotes from all users using Thought Stack! This app also has a dashboard where you can revisit the
quotes you contributed and see how many users liked them.


Features of the application:

a.		 Can create a post consisting of information like QUOTE, AUTHOR, CATEGORY, PICTURE(any relevant picture). Picture is optional but our front end accomodates both image and vanilla posts.

b.       Can see a stack of posts on the main feed page. These posts will be the ones you did not see/create/evaluate before.

c.       Can swipe left if user doesn't like the post on the top of feed. The posts swiped left will NOT appear in that particular user's feed again.

d.       Can swipe right if user likes the post on the top of feed. The posts liked will be stored in "THOUGHT WALLET", and user has the ability to navigate to Thought Wallet and revisit the posts liked. The icon at the top left is where the thoughtwallet is stored.

e. 		Can undo if user has liked/disliked a post by mistake and wants the post back in the feed section.

f.		Can navigate to Dashboard which displays all the posts which the user has created to see how the other users have reacted to his quotes.

g.       Sign up, Log in functionality supported, as it is a Multi-user app.


3. SPECIAL INSTRUCTIONS:

User needs to enable Internet access in order to get registered successfully in the application. Later, application will also need internet to be sucessfully able to store liked and disliked posts.

Since backend is Firebase, without internet the app DOES NOT function.

Add firebase google plist included with this project to connect to our firebase database instance.


4. THIRD PARTY LIBRARIES TO DOWNLOAD:

There are a many libraries used in this project.  the most significant ones are:
a.	LBTATools
b.	Koloda
c.	TinyConstraints
d.	Firebase - Firebase/Auth, Firebase/Core, Firebase/Storage, Firebase/Firestore
e.	Alamofire
f.	SwiftyJSON

All the above mentioned libraries are present in PodFile which will be submitted with the project. Use "pod install" to install all the libraries.

5. KNOWN ISSUES:

a. When User successfully logs in the application for the very first time, the amount of time needed for feed to load is directly proportional to the number of quotes (and the images in each quote) takes to be retrieved from backend. For a dataset of around 30 quotes each with images of their own, along with their owners profile pic images it can take around 30 seconds in the worst case scenario.At any rate the debug console will show you the quotes loaded so far and how many are left to go.

b. While swiping towards left or right, user needs to make a swipe motion from center of the feed till either of the extreme ends to be successfully able to execute the swipe functionality.

c. Return can be used to dismiss the keyboard to access textfields outside the view.


6. IMPORTANT NOTE:

FIRESTORE HAS MAXIMUM BANDWIDTH OF 1 GB / DAY. SO REPEATED LOADING OF FEED CAN SOMETIMES EXCEED THE QUOTA FOR FIREBASE STORAGE AND THIS WILL CAUSE THE IMAGES TO STOP SHOWING UP. THE APP MAY MISBEHAVE IF THAT HAPPENS.
