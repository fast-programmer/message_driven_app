user = Models.User.create!(email: 'tester@fastprogrammer.co')
user.events.create!(name: 'User.created', body: { 'descripton' => 'testing' })
