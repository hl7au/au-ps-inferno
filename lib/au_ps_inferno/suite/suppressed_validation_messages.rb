# frozen_string_literal: true

module AUPSTestKit
  # Known validation messages that are expected and should not fail AU PS tests.
  # Add entries here only once a specific message has been confirmed as a known,
  # acceptable issue (see https://github.com/hl7au/au-ps-inferno/issues/38) —
  # `type` is one of 'error', 'warning', 'info'; `pattern` is matched against the message text.
  module SuppressedValidationMessages
    REASON = 'See https://hl7.org.au/fhir/core/2.0.0/qa.html#suppressed'

    LIST = [
      {
        type: 'error',
        pattern: %r{Unknown code '[^']+' in the CodeSystem 'http://pbs\.gov\.au/code/item'},
        reason: REASON
      },
      {
        type: 'error',
        pattern: %r{No definition could be found for URL value 'http://hl7\.org/fhir/tools/StructureDefinition/expansion-parameters'},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{Reference to draft ValueSet http://hl7\.org/fhir/ValueSet/condition-severity\|4\.0\.1},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{Reference to draft ValueSet http://hl7\.org/fhir/ValueSet/device-action\|4\.0\.1},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{Reference to deprecated ValueSet http://hl7\.org/fhir/5\.0/ValueSet/jurisdiction\|5\.0\.0},
        reason: REASON
      },
      {
        type: 'info',
        pattern: /The discriminator type 'pattern' is deprecated in R5\+/,
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{
          The\ extension\ http://hl7\.org/fhir/StructureDefinition/elementdefinition-maxValueSet\|5\.2\.0\s
          is\ deprecated
        }x,
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{The extension http://hl7\.org/fhir/StructureDefinition/regex\|5\.2\.0 is deprecated},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-patient\|2\.0\.0},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-practitionerrole\|2\.0\.0},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-smokingstatus\|2\.0\.0},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-heartrate\|2\.0\.0},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org/fhir/StructureDefinition/bp\|4\.0\.1},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination\|5\.2\.0},
        reason: REASON
      },
      {
        type: 'info',
        pattern: %r{does not match any known slice defined in the profile http://hl7\.org/fhir/StructureDefinition/obligation\|5\.2\.0},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: /
          An\ HTML\ fragment\ from\ the\ set\s
          \[cross-version-analysis\.xhtml,\ cross-version-analysis-inline\.xhtml\]\s
          is\ not\ included\ anywhere\ in\ the\ produced\ implementation\ guide
        /x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: /
          The\ HTML\ fragment\ 'globals-table\.xhtml'\s
          is\ not\ included\ anywhere\ in\ the\ produced\ implementation\ guide
        /x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: /
          The\ HTML\ fragment\ 'ip-statements\.xhtml'\s
          is\ not\ included\ anywhere\ in\ the\ produced\ implementation\ guide
        /x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-address,\s
          http://hl7\.org/fhir/StructureDefinition/Address
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-australianbusinessnumber,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-dvanumber,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-employeenumber,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-hpii,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-hpio,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-ihi,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-medicalrecordnumber,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-medicareprovidernumber,\s
          http://hl7\.org/fhir/StructureDefinition/Identifier
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: /Best Practice Recommendation: In general, all observations should have a performer/,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/bodySite'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/individual-genderIdentity'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/individual-pronouns'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/individual-recordedSexOrGender'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/patient-birthPlace'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/patient-birthTime'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/patient-interpreterRequired'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/patient-mothersMaidenName'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/patient-sexParameterForClinicalUse'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/procedure-targetBodyStructure'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://hl7\.org/fhir/StructureDefinition/timezone'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{multiple different potential matches for the url 'http://terminology\.hl7\.org/ValueSet/recorded-sex-or-gender-type'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: /A Reference without an actual reference or identifier should have a display/,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unknown\ code\ '[^']+'\ in\ the\ CodeSystem\ 'http://pbs\.gov\.au/code/item';\s
          The\ provided\ code\ 'http://pbs\.gov\.au/code/item\#[^']+'\ was\ not\ found\ in\ the\ value\ set\s
          'https://healthterminologies\.gov\.au/fhir/ValueSet/australian-medication[^']*'
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          A\ definition\ for\ CodeSystem\ 'http://pbs\.gov\.au/code/item'\s
          could\ not\ be\ found,\ so\ the\ code\ cannot\ be\ validated
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          A\ definition\ for\ CodeSystem\ 'http://www\.mims\.com\.au/codes'\s
          could\ not\ be\ found,\ so\ the\ code\ cannot\ be\ validated
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://hl7\.org\.au/id/abn'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/dva'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/hi/hpii/1\.0'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/hi/hpio/1\.0'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/medicare-provider-number'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://pca\.digitalhealth\.gov\.au/id/pca-healthcare-service'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/abn-scoped/service-provider-individual/1\.0/[^']*'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/hpio-scoped/medicalrecord/1\.0/[^']*'},
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Resolved\ system\ http://pbs\.gov\.au/code/item\ \([^)]*\),\ but\ the\ definition\ doesn't\ include\s
          any\ codes,\ so\ the\ code\ has\ not\ been\ validated
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/mims\|[^']*'\s
          because\ the\ code\ system\ http://snomed\.info/sct\ was\ not\ found
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/pbs-item\|[^']*'\s
          because\ the\ code\ system\ http://snomed\.info/sct\ was\ not\ found
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\ ''\s
          because\ the\ code\ system\ http://pbs\.gov\.au/code/item\ was\ not\ found
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/pbs-item\|[^']*'\s
          because\ the\ code\ system\ http://pbs\.gov\.au/code/item\ was\ not\ found
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          The\ provided\ code\ 'http://snomed\.info/sct\#\d+'\ was\ not\ found\ in\ the\ value\ set\s
          'http://hl7\.org/fhir/ValueSet/observation-vitalsignresult\|[^']*'
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          A\ definition\ for\ CodeSystem\ 'http://snomed\.info/sct'\ version\ 'null'\s
          could\ not\ be\ found,\ so\ the\ code\ cannot\ be\ validated
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          A\ definition\ for\ CodeSystem\ 'http://terminology\.hl7\.org/CodeSystem/v3-RoleCode'\ version\ 'null'\s
          could\ not\ be\ found,\ so\ the\ code\ cannot\ be\ validated
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/v3-ServiceDeliveryLocationRoleType-extended\|[^']*'\s
          because\ the\ code\ system\ http://snomed\.info/sct\ was\ not\ found
        }x,
        reason: REASON
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/v3-ServiceDeliveryLocationRoleType-extended\|[^']*'\s
          because\ the\ code\ system\ http://terminology\.hl7\.org/CodeSystem/v3-RoleCode\ was\ not\ found
        }x,
        reason: REASON
      }
    ].freeze
  end
end
