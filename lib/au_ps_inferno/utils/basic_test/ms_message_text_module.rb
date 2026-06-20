# frozen_string_literal: true

module AUPSTestKit
  # Shared, status-specific Must Support message text so every conformance test speaks the same way:
  # an affirmative confirmation when something passes, a clear statement of what is wrong when it
  # fails, and consistent remediation guidance for optional (SHOULD/MAY) gaps.
  module BasicTestMsMessageTextModule
    # Standard remediation guidance appended to warnings for optional Must Support data that is absent.
    # "thing" is the kind of element, e.g. "element", "sub-element", "slice", "complex element".
    def ms_remediation(thing)
      "Provide further test data where the missing #{thing} is populated " \
        "or confirm that the system does not ever know a value for the #{thing}."
    end

    def all_mandatory_ms_populated_heading
      'All mandatory Must Support elements are correctly populated'
    end

    def mandatory_ms_missing_heading
      'At least one mandatory Must Support element is not populated'
    end

    def all_optional_ms_populated_heading
      'All optional Must Support elements are correctly populated'
    end

    def optional_ms_missing_heading
      "At least one optional Must Support element is not populated.\n\n#{ms_remediation('element')}"
    end

    # Intro line for the "all defined identifier slices populated" message (IHI, DVA, Medicare, etc.).
    def identifier_slices_intro(all_present)
      return 'All Must Support identifier slices are correctly populated' if all_present

      "Not all Must Support identifier slices are populated.\n\n#{ms_remediation('identifier slice')}"
    end

    # Status-specific heading for the Must Support sub-elements of a complex or sliced element.
    # "kind" is e.g. "complex element" or "sliced element"; "descriptor" is the path or slice name.
    def ms_status_heading(level, kind, descriptor)
      case level
      when 'error'
        "At least one mandatory Must Support sub-element of #{kind} #{descriptor} is not populated"
      when 'warning'
        "At least one optional Must Support sub-element of #{kind} #{descriptor} " \
        "is not populated.\n\n#{ms_remediation('sub-element')}"
      else
        "All Must Support sub-elements of #{kind} #{descriptor} correctly populated"
      end
    end
  end
end
