# Event-Driven Architecture Demo with Ruby on Rails

This project illustrates how to build an event-driven architecture in Ruby on Rails, following many Doman Driven Design best practices.

## Benefits of Event-Driven Architecture (EDA)

1. **Simplicity**: A shared, event-centric conceptual model provides a unified, non-technical understanding across different system components and stakeholders, reducing complexity and facilitating clearer communication.

2. **Visibility**: By centralizing event logging it becomes easier to monitor, troubleshoot, and debug system issues.

3. **Scalability**: EDA's are highly scalable. They can handle high volumes of events and adapt to changes in these volumes over time.

4. **Decoupling**: EDA promotes loose coupling between system components, as each component only knows about the event and how to handle it. This allows developers to work on individual components without impacting the whole system.

5. **Resiliency**: By separating the event producers from the consumers, the system becomes more resilient. If one part of the system fails, it won't directly affect the others.

## Conceptual Model Example

![Screenshot from 2023-06-14 02-50-06](https://github.com/fast-programmer/message_driven_app/assets/394074/1c3f3612-9159-4032-bf57-8eee6ff87243)

## Getting Started

Clone the repository and install the dependencies:

```bash
git clone https://github.com/fast-programmer/message_driven_app.git
cd message_driven_app
bundle install
```

After installing, you can create the database and run the migration:

```bash
RAILS_ENV=development bin/rake db:create
RAILS_ENV=development bin/rake db:migrate
```

### How to create an unpublished model event (in band)

```bash
RAILS_ENV=development bin/rails c
```

```
ActiveRecord::Base.transaction do
  user = Models::User.create(email: email)
  user.events.create!(name: 'User.create')
end
```

```
SELECT * FROM messages ORDER BY created_at ASC;
```

![Screenshot from 2023-06-14 02-45-38](https://github.com/fast-programmer/message_driven_app/assets/394074/fe34c94f-2de8-4264-8a3d-0753c8b6499d)

```
irb(main):005:0> Models::User.find(1).events.map { |event| event.name }
=> ["User.created"]
```

### How to publish an unpublished model event (out of band)

```bash
bin/message_publisher
```

This script enumerates through all unpublished events, calling a handler for each one and

* if the handler did not throw an exception, the message status is set to `published`
* if the handler did throw an exception, the message status is set to `failed`

### How to react to a model event being published (out of band)

The publisher would be updated to route events to stateless handler functions based on the `event.name` (e.g. `User.created`).

This is the best place to call external APIs.

Existing job processing infrastructure such as sidekiq workers can also be integrated.

Main point is that heavy lifting is done outside of web requests, based on events.

## Future Improvements

### Generate supporting code via gem

Create schema, model, test and publisher code via a generator, which can be included in a separate gem and required into main app.

### Multitenant Support

Allowing for separate, isolated user spaces.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
```
