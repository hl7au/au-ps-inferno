# frozen_string_literal: true

# Decorator for FHIR::CapabilityStatement
class CapabilityStatementDecorator < FHIR::CapabilityStatement
  def all_profiles
    profiles + supported_profiles
  end

  def profiles
    rest.map do |rest_item|
      rest_item.resource.map(&:profile)
    end.flatten.compact.uniq
  end

  def supported_profiles
    rest.map do |rest_item|
      rest_item.resource.map(&:supportedProfile)
    end.flatten.compact.uniq
  end
end
