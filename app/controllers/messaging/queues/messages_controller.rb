module Messaging
  module Queues
    class MessagesController < ::ApplicationController
      def show
        @queues = Models::Queue.all
        queue = @queues.find { |q| q.slug == params[:queue_slug] }
        message = queue.messages.find_by!(id: params[:id])

        render locals: {
          queues: @queues,
          queue: queue,
          message: message
        }
      end

      # def index
      #   queues = Models::Queue.all
      #   queue = queues.find_by!(slug: params[:queue_slug])

      #   handler_messages = Models::HandlerMessages.where(queue_id: queue.id)

      #   statuses = Models::HandlerMessage::STATUS
      #   status_counts = count_handler_messages_by_status(statuses.keys)

      #   messages = find_messages(
      #     queue_id: params[:queue_id],
      #     status: params[:status],
      #     order: params[:order],
      #     limit: params[:limit])

      #   render locals: {
      #     queues: queues, statuses: statuses, status_counts: status_counts, messages: messages
      #   }
      # end

    end
  end
end
