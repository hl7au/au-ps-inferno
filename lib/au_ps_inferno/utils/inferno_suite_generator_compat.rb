# frozen_string_literal: true

# Compatibility shim for pinned inferno_suite_generator versions
# that still reference FHIR::R4::* classes.
FHIR.const_set(:R4, FHIR) if defined?(FHIR) && !FHIR.const_defined?(:R4)

require 'inferno_suite_generator'
