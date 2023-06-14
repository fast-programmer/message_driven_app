module Message
  STATUS = Models::Message::STATUS

  def self.handle(handler:)
    loop do
      message = shift

      if message
        begin
          handler.handle(message: message)

          message.update!(status: Message::STATUS[:handled])
        rescue StandardError => e
          message.update!(status: Message::STATUS[:failed])

          puts "An error occurred while handling message #{message.id}: #{e.message}"

          raise
        end
      else
        puts 'No unhandled messages found, sleeping...'

        sleep 1
      end
    end
  end

  def self.shift
    ActiveRecord::Base.transaction do
      message = Models::Message
                  .where(status: STATUS[:unhandled])
                  .order(created_at: :asc)
                  .limit(1)
                  .lock('FOR UPDATE SKIP LOCKED')
                  .first

      message&.update!(status: STATUS[:handling])
      message
    end
  end

  private_class_method :shift
end
