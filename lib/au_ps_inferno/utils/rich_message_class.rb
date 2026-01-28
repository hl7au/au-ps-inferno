# frozen_string_literal: true

require 'digest'

# A class to represent a rich message for the better and informative output
class RichMessage
  attr_reader :message, :type, :resource_type, :profile, :resource_id, :idx, :ref, :signature

  def initialize(resource, message, profile, idx, ref)
    message_body = cleanup_message_body(message[:message], resource.resourceType, resource.id)
    @resource_type = resource.resourceType
    @resource_id = resource.id
    @message = message_body
    @type = message[:type]
    @profile = profile
    @idx = idx
    @ref = ref
    @signature = calculate_signature
  end

  private

  def cleanup_message_body(message, resource_type, resource_id)
    string_to_replace = resource_id.present? ? "#{resource_type}/#{resource_id}: " : "#{resource_type}: "
    message.sub(string_to_replace, '')
  end

  def calculate_signature
    Digest::MD5.hexdigest([resource_type, profile, message].compact.join('|'))
  end
end
