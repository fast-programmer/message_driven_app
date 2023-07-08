module IAM
  module Workers
    module User
      class Synced
        include Sidekiq::Job

        def perform(*args)
          Sidekiq.logger.info 'IAM::Workers::User::Synced.perform started'

          Sidekiq.logger.info 'IAM::Workers::User::Synced.perform finished'
        end
      end
    end
  end
end
