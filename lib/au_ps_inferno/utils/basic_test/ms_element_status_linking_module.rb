# frozen_string_literal: true

require 'inferno_suite_generator/test_utils/ms_checker'

module AUPSTestKit
  # Rebuilds InfernoSuiteGenerator::MSChecker's element-status line
  # formatting (icons, "(M)" suffix, "|- " child prefix) with the path
  # turned into a FHIRPath Lab link when `resource` has a type/id to
  # address it by — see CompositionUtils#element_fhirpath_line. A linked
  # line can't also lead with "|- ": FhirpathLabMessageLinker's pattern
  # requires the resource/id to start the line, so the child-indent prefix
  # is only added in the unlinked fallback case.
  module BasicTestMsElementStatusLinkingModule
    private

    # `message` is MSChecker#build_report_message's [details, profile,
    # header, *element lines] (flattened); the last `elements_statuses.length`
    # entries are the per-element lines we're replacing with linked
    # versions, whatever the header line count turns out to be.
    def linked_ms_report_message(message, elements_statuses, resource)
      header_lines = message.first(message.length - elements_statuses.length)
      element_lines = elements_statuses.map { |status| ms_element_status_line(status, resource) }

      header_lines + element_lines
    end

    def ms_element_status_line(element_status, resource)
      path = element_status[:path]
      mandatory = element_status[:mandatory]
      status_text = ms_element_status_icon_text(element_status)
      detail = mandatory ? "#{status_text} (M)" : status_text

      element_fhirpath_line(resource, '', path, detail) || ms_element_status_plain_line(path, status_text, mandatory)
    end

    def ms_element_status_icon_text(element_status)
      return "#{InfernoSuiteGenerator::MSChecker::SUCCESS_ICON} Populated" if element_status[:present]

      "#{ms_missing_icon(element_status[:mandatory])} Missing"
    end

    def ms_missing_icon(mandatory)
      mandatory ? InfernoSuiteGenerator::MSChecker::ERROR_ICON : InfernoSuiteGenerator::MSChecker::WARNING_ICON
    end

    def ms_element_status_plain_line(path, status_text, mandatory)
      line = "#{status_text}: #{path}#{' (M)' if mandatory}"
      path.include?('.') ? "|- #{line}" : line
    end
  end
end
