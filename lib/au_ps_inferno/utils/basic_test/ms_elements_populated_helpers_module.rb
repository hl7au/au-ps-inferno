# frozen_string_literal: true

module AUPSTestKit
  # Internal helpers to keep the populated-message module concise.
  module BasicTestMsElementsPopulatedHelpersModule
    private

    def assert_message
      'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def get_target_metadata_by_container_type(container_type)
      case container_type
      when 'subject'
        metadata_manager.subject_metadata
      when 'author'
        metadata_manager.author_metadata
      when 'custodian'
        metadata_manager.custodian_metadata
      when 'attester'
        metadata_manager.attester_metadata
      end
    end

    def get_resource_by_container_type(container_type)
      case container_type
      when 'subject'
        subject_resource
      when 'author'
        author_resource
      when 'custodian'
        custodian_resource
      when 'attester'
        attester_party_resource
      end
    end
  end
end
