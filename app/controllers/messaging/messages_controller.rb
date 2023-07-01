module Messaging
  class MessagesController < ApplicationController
    def index
      queues = Models::Messaging::Queue.all

      statuses = Models::Messaging::Message::STATUS
      status_counts = count_messages_by_status(statuses.keys)

      messages = find_messages(
        queue_id: params[:queue_id],
        status: params[:status],
        order: params[:order],
        limit: params[:limit])

      render locals: {
        queues: queues, statuses: statuses, status_counts: status_counts, messages: messages
      }
    end

    def find_messages(status: nil, queue_id: nil, order: nil, limit: nil)
      messages = Models::Messaging::Message.all

      messages = messages.where(queue_id: queue_id) if queue_id.present?
      messages = messages.where(status: status) if status.present?
      messages = messages.order(created_at: order.to_sym) if order.present?
      messages = messages.limit(limit.to_i) if limit.present? && limit.to_i.positive?

      messages
    end

    def count_messages_by_status(statuses)
      Models::Messaging::Message.where(status: statuses).group(:status).count.transform_keys(&:to_sym)
    end
  end
end
