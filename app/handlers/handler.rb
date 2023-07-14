module Handler
  extend self

  def handle(message:, logger:)
    logger.info("[##{message.id}] Handler> message #{message.id} handling #{message.body.class.name}")

    [
      IAM::Handler,
      ActiveCampaignIntegration::Handler,
      MailchimpIntegration::Handler
    ].each do |handler|
      ActiveRecord::Base.transaction do
        message.jobs.create!(
          queue_id: handler.queue_id,
          handler: handler,
          attempts_max: 2)
      end
    end

    logger.info("[##{message.id}] Handler> message #{message.id} handled #{message.body.class.name}")
  end

  def handles?(message:)
    true
  end
end
