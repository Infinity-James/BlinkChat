#  Task Solution

## Approach

1. I began by drawing a very basic system design to get my head around what I'll need to do. [It can be found here](https://share.icloud.com/photos/056qkYex_i6WjxEBQsRpKteJg).
2. My preferred approach for a task, once I've understood the requirements, is to formalise them using TDD. I wrote tests against the client, building the service to get them passing.
3. Regarding services, I use protocols to define their interfaces. Using an MVVM architecture, I can use dependency injection to pass through the services. This means I can easily test their logic by passing in mock services that conform to the interface.
4. I've used reference types for the services, allowing view models and coordinators to hold onto them weakly and share them.
5. I've used value types for the models to keep them light and immutable.
6. Realm is my local database of choice in this case because it is easy to set up and saves time. My decision to keep the models immutable requires mapping from the database models to the consumer models.
7. I modelled the endpoints as enums, allowing for easy construction against a given base URL - suitable for when an app needs to support live and dev environments.
