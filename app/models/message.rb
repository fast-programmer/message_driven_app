class Message < ApplicationRecord
  enum status: { unprocessed: 0, processing: 1, processed: 2, failed: 3 }
end
