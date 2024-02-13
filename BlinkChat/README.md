#  Task Solution

## Approach

1. I began by drawing a very basic system design to get my head around what I'll need to do. [It can be found here](https://share.icloud.com/photos/056qkYex_i6WjxEBQsRpKteJg).
2. My preferred approach for a task, once I've understood the requirements, is to formalise them using TDD. I wrote tests against the client, building the service to get them passing.
3. Regarding services, I use protocols to define their interfaces. Using an MVVM architecture, I can use dependency injection to pass through the services. This means I can easily test their logic by passing in mock services that conform to the interface.

