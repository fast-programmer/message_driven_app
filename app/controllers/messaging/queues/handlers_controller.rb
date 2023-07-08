module Messaging
  module Queues
    class HandlersController < ::ApplicationController
      def show
        @queues = Models::Queue.all
        queue = @queues.find { |q| q.slug == params[:queue_slug] }

        handlers = queue.handlers
        handler = handlers.find { |h| h.slug == params[:id] }

        handler_messages = find_handler_messages(
          queue_id: queue.id,
          status: params[:status],
          order: params[:order],
          limit: params[:limit])


        render locals: {
          queues: @queues,
          queue: queue,
          handler: handler,
          handler_messages: handler_messages,
          statuses: Models::HandlerMessage::STATUS,
          status_counts: count_handler_messages_by_status
        }
      end

      def find_handler_messages(queue_id:, status: nil, order: nil, limit: nil)
        messages = Models::HandlerMessage.where(queue_id: queue_id)
        messages = messages.where(status: status) if status.present?
        messages = messages.order(created_at: order.to_sym) if order.present?
        messages = messages.limit(limit.to_i) if limit.present? && limit.to_i.positive?

        messages
      end

      def count_handler_messages_by_status
        Models::HandlerMessage
          .where(status: Models::HandlerMessage::STATUS.keys)
          .group(:status)
          .count
          .transform_keys(&:to_sym)
      end
    end
  end
end
