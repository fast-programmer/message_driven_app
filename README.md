# Event-Driven Architecture Demo with Ruby on Rails

This project illustrates how to build an event-driven architecture in Ruby on Rails, following many Doman Driven Design best practices.

## Benefits of Event-Driven Architecture (EDA)

1. **Simplicity**: A shared, event-centric conceptual model provides a unified, non-technical understanding across different system components and stakeholders, reducing complexity and facilitating clearer communication.

2. **Visibility**: By centralizing event logging it becomes easier to monitor, troubleshoot, and debug system issues.

3. **Scalability**: EDA's are highly scalable. They can handle high volumes of events and adapt to changes in these volumes over time.

4. **Decoupling**: EDA promotes loose coupling between system components, as each component only knows about the event and how to handle it. This allows developers to work on individual components without impacting the whole system.

5. **Resiliency**: By separating the event producers from the consumers, the system becomes more resilient. If one part of the system fails, it won't directly affect the others.


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

And finally, start the server.

```bash
RAILS_ENV=development bin/rails s
```

### How to create an unpublished model event (in band)

```bash
curl -X POST -H "Content-Type: application/json" -d '{"user": {"email": "test@example.com"}}' http://localhost:3000/api/users
```

Note `Api::UserController#create` calls the application service `User.create(...)`, which is implemented like this:

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

### How to publish an unpublished model event (out of band)

```bash
bin/message_publisher
```

This script enumerates through all unpublished messages and events, calling a handler for each one.

### How to react to a model event being published (out of band)

The publisher would be updated to route events to stateless handler functions based on the `event.name` (e.g. `User.created`).

This is the best place to call external APIs.

Existing job processing infrastructure such as sidekiq workers can also be integrated.

Main point is that heavy lifting is done outside of web requests, based on events.

## Future Improvements

### Generate supporting code via gem

Create schema, model, test and publisher code via a generator, which can be included in a separate gem and required into main app.

### Multitenant Support

This application supports multitenancy, allowing for separate, isolated user spaces.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
```
