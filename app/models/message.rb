class Message < ApplicationRecord
  STATUS = {
    unpublished: 0,
    publishing: 1,
    published: 2,
    failed: 3
  }.freeze

  enum status: STATUS
end
