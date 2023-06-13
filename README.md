# Event-Driven Architecture Demo with Ruby on Rails

This project illustrates how to build an event-driven architecture in Ruby on Rails, following many Doman Driven Design principles.

## Benefits of Event-Driven Architecture

1. **Scalability**: Event-driven architectures are typically highly scalable. They can handle high volumes of events and adapt to changes in these volumes over time.

2. **Decoupling**: EDA promotes loose coupling between system components, as each component only knows about the event and how to handle it. This allows developers to work on individual components without impacting the whole system.

3. **Resiliency**: By separating the event producers from the consumers, your system becomes more resilient. If one part of the system fails, it won't directly affect the others.

4. **Asynchronous Communication**: EDA supports asynchronous communication between system components, allowing for non-blocking interactions.

5. **Better User Experience**: By responding to user interactions in real time, EDA can provide a more dynamic, responsive user experience.

6. **Easier Troubleshooting and Debugging**: By centralizing event logging, it becomes easier to monitor, troubleshoot, and debug system issues, since you can follow the path of events through your system.


It includes a stateless application service (`User.create`) that performs operations within a database transaction to create a `Models::User` and add an unpublished `Models::Event` associated with the user.

Additionally, it includes an out-of-band message publishing script that picks up unpublished messages and pushes them out to a handler, marking it as published or failed.

## Getting Started

Clone the repository and install the dependencies:

```bash
git clone https://github.com/fast-programmer/message_driven_app.git
cd message_driven_app
bundle install
```

After installing, you can create the database and run the migration:

```bash
rake db:create
rake db:migrate
```

### How to create an event (in band)

Note `User.create(...)` in `services/user.rb`

```
module User
  def create(email:, created_at: Time.now.utc)
    user = nil

    ActiveRecord::Base.transaction do
      user = Models::User.create(email: email, created_at: created_at)
      user.events.create!(name: 'User.create')
    end

    user
  end
end
```

### How to publish an event (out of band)

```bash
bin/message_publisher
```

This script enumerates through all unpublished messages and events, calling a handler for each one. A router can route events to functions based on the event name. Alternatively, you can queue Sidekiq workers. This is the best place to call external APIs.

## Additional Improvements

### Multitenant Support

This application supports multitenancy, allowing for separate, isolated user spaces.

### Accessing User

You can access the user model via the API or directly from the database for additional operations and customization.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
```
