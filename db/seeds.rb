user = User.create!(email: 'tester@fastprogrammer.co')
user_created_event = user.events.create!(name: 'User.created')

debugger
