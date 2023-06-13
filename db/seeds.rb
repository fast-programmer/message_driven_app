user = Models.User.create!(email: 'tester@fastprogrammer.co')
account = Models.Account.create!(name: 'Account 1', slug: 'account-1');
user.events.create!(name: 'User.created', body: { 'descripton' => 'testing' })
