#  Task Solution

## Approach

1. I began by drawing a very basic system design to get my head around what I'll need to do. [It can be found here](https://share.icloud.com/photos/056qkYex_i6WjxEBQsRpKteJg).
2. My preferred approach for a task, once I've understood the requirements, is to formalise them using TDD. I wrote tests against the client, building the service to get them passing.
3. Regarding services, I use protocols to define their interfaces. Using an MVVM architecture, I can use dependency injection to pass through the services. This means I can easily test their logic by passing in mock services that conform to the interface.
4. I've used reference types for the services, allowing view models and coordinators to hold onto them weakly and share them.
5. I've used value types for the models to keep them light and immutable.
6. Realm is my local database of choice in this case because it is easy to set up and saves time. My decision to keep the models immutable requires mapping from the database models to the consumer models.
7. I modelled the endpoints as enums, allowing for easy construction against a given base URL - suitable for when an app needs to support live and dev environments.
8. I created a Store which served as the master controller of data. It did the job of synchronising the database and server side messages, and returning what was fetched.
9. Noticing that messages lacked a User ID, I dropped any intention to pretend that there was a user viewing the messages or an owner of any given message. I faked it by randomly assigning the messages to either the user of the app or somebody else. That allowed for a better looking chat screen.

## Services

### Database
The local store for the user's chats, messages, and pending messages.
There's nothing fancy here, and I've used Realm because of the ease.

### APIClient
A function for each endpoint required by the app.

### Store
The synchronising data store that appropriately fetches from the local database and the server, manages the data, and serves it to the client appropriately.
Here, I'm doing the work of failing silently if the messages cannot be fetched from the server due to bad connection.
This is also where pending messages will be stored and attempted to be sent if a connection is available.

## Comments on the Data

1. The data is unrepresentative of actual chat data in myriad ways. For my purposes, the most crucial of these was the lack of owner.
2. Also, in a real life scenario, one would not send the messages along with the chat object. The messages would probably be best fetched from a paginated endpoint for any given chat.
3. My Store, while pretending to do the job of managing online and offline data, would be inadequate in offering a satisfying user experience. The greatest of these is because it handles pending messages quite naively.

## Offline Mode

1. No effort was made to host the file on a server and fetch it. While simple, it would have added time, and the requirements explicitly advise against it.
2. I'm also displeased with how I've modelled pending messages. Greater consideration could have been placed into how they are stored and served up by the Store.

## Testing 
I vlaue testing and tried to demonstrate a TDD approach here as much as time allowed. The code coverage is not extensive and the tests aren't particularly robust, but it's an example of how I approach things.

## UI and UX

This is a poor example of how much I value the look and feel of the apps that I create. This is because the requirements de-emphasised this aspect of the test, and I wanted to focus on that which was prioritised in the evaluation.

## Error Handling
There is minimal error handling, but everything is built with it in mind.
