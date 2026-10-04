# frozen_string_literal: true

module AUPSTestKit
  # Known validation messages that are expected and should not fail AU PS tests.
  # Add entries here only once a specific message has been confirmed as a known,
  # acceptable issue (see https://github.com/hl7au/au-ps-inferno/issues/38) —
  # `type` is one of 'error', 'warning', 'info'; `pattern` is matched against the message text.
  #
  # Sourced from https://github.com/hl7au/au-fhir-ps/blob/release-1.0.0/input/ignoreWarnings.txt
  # (tag `release-1.0.0`): one entry per message line, `reason` taken from the block header, and
  # the IG Publisher `%` wildcard translated to `.*`. When the IG cuts a new release, diff that
  # file's tag against this one and update entries accordingly — do not source from a ci-build.
  #
  # Deliberately not ported from the source:
  # - ERROR 01, ERROR 02, ERROR 03, ERROR 04, WARNING 01, WARNING 05, WARNING 11,
  #   INFORMATION 03, INFORMATION 06, INFORMATION 15: IG Publisher build message
  #   (StructureDefinition/IG validation); never emitted when Inferno validates
  #   instances.
  # - WARNING 06: justified only by an IG example (literal example identifier system
  #   URL).
  # - WARNING 10: justified only by an IG example; the pattern is generic and would hide
  #   a real data-quality warning on every tester bundle (105 hits on the IG example
  #   alone).
  # - "A definition for CodeSystem 'http://snomed.info/sct' version 'null' could not be
  #   found..." (WARNING 12): hides a live SNOMED edition misconfiguration (see snomedCT
  #   in au_ps_suite_definition.rb and PR #108).
  #
  # Added on top of the source (the last entries in LIST), confirmed against live Inferno runs:
  # - Bundle.signature.targetFormat MimeType errors for FHIR canonicalization MIME types
  #   (validator false positive, see PR #107 review).
  #
  # Deliberately never suppressed, whatever a future source says:
  # - "The entry resource did not match any of the allowed profiles (Type Observation: ...)" —
  #   the Bundle slice conformance check; hiding it hides genuinely non-conformant entries.
  module SuppressedValidationMessages
    LIST = [
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-address, http://hl7\.org/fhir/StructureDefinition/Address},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-australianbusinessnumber, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-hpio, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-ihi, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-hpii, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-employeenumber, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-medicareprovidernumber, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-medicarecardnumber, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/StructureDefinition/au-pbsprescribernumber, http://hl7\.org/fhir/StructureDefinition/Identifier},
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU Base.',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path, http://hl7\.org/fhir/StructureDefinition/Observation},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-smokingstatus, http://hl7\.org/fhir/StructureDefinition/Observation},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org/fhir/StructureDefinition/Observation, http://hl7\.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-edd-uv-ips},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'warning',
        pattern: %r{Found multiple matching profiles among 2 choices: http://hl7\.org/fhir/StructureDefinition/Observation, http://hl7\.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://hl7\.org\.au/id/abn'},
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data type profile.',
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/hi/hpio/1\.0'},
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data type profile.',
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/hi/hpii/1\.0'},
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data type profile.',
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/medicare-provider-number'},
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data type profile.',
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/medicare-number'},
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data type profile.',
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'http://ns\.electronichealth\.net\.au/id/medicare-prescriber-number'},
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data type profile.',
      },
      {
        type: 'warning',
        pattern: %r{Best Practice Recommendation: In general, all observations should have a performer},
        reason: 'Flags aspects of FHIR implementation of best practice. These warnings do not indicate an error in the specification, and ignore profiled requirements.',
      },
      {
        type: 'warning',
        pattern: %r{A definition for CodeSystem 'http://pbs\.gov\.au/code/item' could not be found, so the code cannot be validated},
        reason: 'INHERITED FROM AU BASE: These AU Base CodeSystems referenced do not include any codes in their definition so can not be validated.',
      },
      {
        type: 'warning',
        pattern: %r{A definition for CodeSystem 'http://www\.mims\.com\.au/codes' could not be found, so the code cannot be validated},
        reason: 'INHERITED FROM AU BASE: These AU Base CodeSystems referenced do not include any codes in their definition so can not be validated.',
      },
      {
        type: 'warning',
        pattern: %r{Unable to check whether the code is in the value set 'http://terminology\.hl7\.org\.au/ValueSet/mims\|6\.0\.0' because the code system http://snomed\.info/sct was not found},
        reason: 'INHERITED FROM AU BASE: Example codes are tested against bound terminology (MIMS/PBS). These AU Base CodeSystems referenced do not include any codes in their definition so can not be validated.',
      },
      {
        type: 'warning',
        pattern: %r{Unable to check whether the code is in the value set 'http://terminology\.hl7\.org\.au/ValueSet/pbs-item\|6\.0\.0' because the code system http://snomed\.info/sct was not found},
        reason: 'INHERITED FROM AU BASE: Example codes are tested against bound terminology (MIMS/PBS). These AU Base CodeSystems referenced do not include any codes in their definition so can not be validated.',
      },
      {
        type: 'warning',
        pattern: %r{Unable to check whether the code is in the value set 'http://terminology\.hl7\.org\.au/ValueSet/v3-ServiceDeliveryLocationRoleType-extended\|6\.0\.0' because the code system http://terminology\.hl7\.org/CodeSystem/v3-RoleCode was not found},
        reason: 'This is a tooling environment warning indicating the ValueSet and CodeSystem cannot be found in tx.hl7.org.au. Resolution in tx.hl7.org.au is in progress.',
      },
      {
        type: 'warning',
        pattern: %r{A definition for CodeSystem 'http://terminology\.hl7\.org/CodeSystem/v3-RoleCode' version 'null' could not be found, so the code cannot be validated\. Valid versions: \[3\.0\.0, 2\.2\.0, 2018-08-12\]},
        reason: 'This is a tooling environment warning indicating the ValueSet and CodeSystem cannot be found in tx.hl7.org.au. Resolution in tx.hl7.org.au is in progress.',
      },
      {
        type: 'warning',
        pattern: %r{Unable to check whether the code is in the value set 'http://terminology\.hl7\.org\.au/ValueSet/v3-ServiceDeliveryLocationRoleType-extended\|6\.0\.0' because the code system http://snomed\.info/sct was not found},
        reason: 'This is a tooling environment warning indicating the ValueSet and CodeSystem cannot be found in tx.hl7.org.au. Resolution in tx.hl7.org.au is in progress.',
      },
      {
        type: 'info',
        pattern: %r{Reference to draft ValueSet http://hl7\.org/fhir/ValueSet/condition-severity\|4\.0\.1},
        reason: 'INHERITED FROM FHIR STANDARD: Some FHIR standard ValueSets are published as draft.',
      },
      {
        type: 'info',
        pattern: %r{Reference to draft ValueSet http://hl7\.org/fhir/ValueSet/encounter-reason\|4\.0\.1},
        reason: 'INHERITED FROM FHIR STANDARD: Some FHIR standard ValueSets are published as draft.',
      },
      {
        type: 'info',
        pattern: %r{Reference to draft ValueSet http://hl7\.org/fhir/ValueSet/c80-practice-codes\|4\.0\.1},
        reason: 'INHERITED FROM FHIR STANDARD: Some FHIR standard ValueSets are published as draft.',
      },
      {
        type: 'info',
        pattern: %r{Reference to deprecated ValueSet http://hl7\.org/fhir/5\.0/ValueSet/jurisdiction\|5\.0\.0},
        reason: 'INHERITED FROM FHIR STANDARD: Some FHIR standard ValueSets are deprecated.',
      },
      {
        type: 'info',
        pattern: %r{Reference to experimental CodeSystem http://www\.abs\.gov\.au/ausstats/abs@\.nsf/mf/1292\.0\|20130626},
        reason: 'Known NCTS published CodeSystem published as experimental.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/results-coded-values-laboratory-pathology-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/results-microorganism-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/results-presence-absence-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/results-blood-group-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/results-pathology-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/pregnancy-status-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{Reference to trial-use ValueSet http://hl7\.org/fhir/uv/ips/ValueSet/edd-method-uv-ips\|2\.0\.1},
        reason: 'INHERITED FROM AU Base or IPS: ValueSets published in AU Base and IPS are published as trial use to match the IG standards status.',
      },
      {
        type: 'info',
        pattern: %r{The entry resource matched more than one of the allowed profiles \(http://hl7\.org/fhir/StructureDefinition/Observation, http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path\)},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'info',
        pattern: %r{The entry resource matched more than one of the allowed profiles \(http://hl7\.org/fhir/StructureDefinition/Observation, http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-smokingstatus\)},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'info',
        pattern: %r{The entry resource matched more than one of the allowed profiles \(http://hl7\.org/fhir/StructureDefinition/Observation, http://hl7\.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips\)},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'info',
        pattern: %r{The entry resource matched more than one of the allowed profiles \(http://hl7\.org/fhir/StructureDefinition/Observation, http://hl7\.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-edd-uv-ips\)},
        reason: 'AU PS Bundle profile is sliced by resource type. For profiles of type Observation, the slice includes all relevant profiles and to remain open (allowing for additional profiles of Observation) includes the Observation resource. This means that Artefacts inherit multiple profiles for certain data types (e.g., Address, Identifier). The IG Publisher cannot match example instances to a single profile and generates these warnings. This behaviour is expected and consistent with the design of AU PS (and IPS).',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org/fhir/StructureDefinition/obligation\|5\.3\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'The use of the obligation extension generates multiple slicing information messages in the snapshot. This extension is reused across many resources in leading to repeated validation messages that do not appear to indicate an actual problem. Other IGs that are using obligations (e.g. IPS, IPA, EPS) show the same set of QA "element does not match any known slice" slicing information messages that have been accepted for publication (see https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/Obligations.20extension.20does.20not.20meet.20slice/with/553529895).',
      },
      {
        type: 'info',
        pattern: %r{Signing Certificate Details: Subject='OU=IG Publisher,L=Ann Arbor,CN=hl7\.org,O=HL7,ST=Missouri,C=us', Issuer='OU=IG Publisher,L=Ann Arbor,CN=hl7\.org,O=HL7,ST=Missouri,C=us', Serial='0'},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{Signing Certificate Source: -----BEGIN CERTIFICATE-----MIIDozCCAoqgAwIBAgIBADANBgkqhkiG9w0BAQ0FADBrMQswCQYDVQQGEwJ1czERMA8GA1UECAwITWlzc291cmkxDDAKBgNVBAoMA0hMNzEQMA4GA1UEAwwHaGw3Lm9yZzESMBAGA1UEBwwJQW5uIEFyYm9yMRUwEwYDVQQLDAxJRyBQdWJsaXNoZXIwHhcNMjUwNjE5MDIzMDMzWhcNMjYwNjIwMDIzMDMzWjBrMQswCQYDVQQGEwJ1czERMA8GA1UECAwITWlzc291cmkxDDAKBgNVBAoMA0hMNzEQMA4GA1UEAwwHaGw3Lm9yZzESMBAGA1UEBwwJQW5uIEFyYm9yMRUwEwYDVQQLDAxJRyBQdWJsaXNoZXIwggEjMA0GCSqGSIb3DQEBAQUAA4IBEAAwggELAoIBAgC9Us8v0UyOy\+XWLRff29GHQa9axqtDao7azsWnF2/ABdg1g6dOF/0ZkrhLdqJISj8MlSP5VLou67iZIH0RxRMfSA0e/fi9DE8QSzpIOlueeH2M8Q2VesKp3hIkp\+xCaGPbc4L0kZVkE6EW\+TUR7QTs1NkaxtwYvW87gKzn6BL0Yx/5mu1UFWcJ/XtLHkiagtIbSiEXSdsjxviObJM2SaV3taCaayGKVFpU6rPLD/VRart6ZP1CJQ2zlIskEEOnnUKEUuwcFpL7t5FXiHVOX0hZ5fsuGYt8EuLwa7giEQvf/PaQbTrTVMOdKH/EGVJI81MfNgzEbrA/CvcG/lgG3DM\+JwIDAQABo1AwTjAdBgNVHQ4EFgQUqBKo2iQ0R5r5GiNlh2sNCzEq9QIwHwYDVR0jBBgwFoAUqBKo2iQ0R5r5GiNlh2sNCzEq9QIwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQ0FAAOCAQIAi8FVsqZJ4Ofiigjgp4\+CeHDx6LJRuq6YoiNerxJ4l\+ET4Bb7j8E/DDeEfebEQvwPrhlOyFOfyoszaBnF8Ep/Hk7Oj6cpLhoAHjeV3GUy\+3xg3NB3DuE7Jhnx99kwfRL9tOXJ5\+Ll1AIhyT0JID8J6/99Q5VmwSCUeRfnhnnigZlwS4VhAoanhrqzwXvpOco\+HyhL0y3mmbBH/eKU\+H5P\+L2IFiSFL6XAL4PM3pYI/zj\+NyhAXZZZwllRjoIKflGOO8HUc5iJiTHhYo0iKS1lPxCHoKyA\+aVEaVE/goqBwoe3V9mxHAz4Uq8e/aQ0OfciFmj55s6mx5eUdy5lQqfoekE=-----END CERTIFICATE-----},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{The content was signed by OU=IG Publisher, L=Ann Arbor, CN=hl7\.org, O=HL7, ST=Missouri, C=us,OU=IG Publisher,L=Ann Arbor,CN=hl7\.org,O=HL7,ST=Missouri,C=us,ou=ig publisher,l=ann arbor,cn=hl7\.org,o=hl7,st=missouri,c=us \(and this has been verified by the signature\)},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{The content was signed for the purpose of Verification Signature \(urn:oid:1\.2\.840\.10065\.1\.12\.1\.5\) \(and this has been verified by the signature\)},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{The signature verified OK},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{Signature Verification is a work in progress\. Feedback welcome at https://chat\.fhir\.org/\#narrow/channel/179247-Security-and-Privacy/topic/Signature/with/524324965},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{The content was signed at},
        reason: 'The Bundle example that is digitally signed uses a feature in IG publisher to generate that signature when building the IG. These information messages provide the metadata around that signature generation',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-patient\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'This example demonstrates how to represent missing or supressed data and therefore uses the Data Absent Reason extension as per AU PS rules. The IG Publisher triggers a slicing information message because of this, but the example is intentionally designed to show the correct handling of missing data and does not indicate any issues with the IG.',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-practitionerrole\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the defined slices.',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-practitioner\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the defined slices.',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the defined slices.',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the defined slices.',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-immunization\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the defined slices.',
      },
      {
        type: 'info',
        pattern: %r{This element does not match any known slice defined in the profile http://hl7\.org\.au/fhir/ps/StructureDefinition/au-ps-smokingstatus\|1\.0\.0 \(this may not be a problem, but you should check that it's not intended to match a slice\)},
        reason: 'Generated due to the profile approach that mixes slice and pattern. The AU PS profile is valid and the code is valid according to the profile but is defined using pattern and is outside the slice definition.',
      },
      {
        type: 'info',
        pattern: %r{Reference to external CodeSystem http://terminology\.hl7\.org/CodeSystem/v3-RoleCode\|2018-08-12},
        reason: 'INHERITED FROM AU BASE: ValueSets references external code system.',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'GTIN' \(http://terminology\.hl7\.org/ValueSet/v3-GTIN\|3\.0\.0\) specified in an additional binding, and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Australian Medicines Terminology Vaccine' \(https://healthterminologies\.gov\.au/fhir/ValueSet/amt-vaccine-1\|1\.0\.2\) specified in an additional binding, and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Australian Immunisation Register Vaccine' \(https://healthterminologies\.gov\.au/fhir/ValueSet/australian-immunisation-register-vaccine-1\|1\.0\.2\) specified in an additional binding, and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Observation Category Codes' \(http://hl7\.org/fhir/ValueSet/observation-category\|4\.0\.1\), and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Healthcare Organisation Role Type' \(https://healthterminologies\.gov\.au/fhir/ValueSet/healthcare-organisation-role-type-1\|1\.1\.0\), and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Australian Medication' \(https://healthterminologies\.gov\.au/fhir/ValueSet/australian-medication-1\|1\.0\.2\) specified in an additional binding, and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Practitioner Role' \(https://healthterminologies\.gov\.au/fhir/ValueSet/practitioner-role-1\|1\.0\.2\), and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'info',
        pattern: %r{None of the codings provided are in the value set 'Results Coded Values Laboratory/Pathology - IPS' \(http://hl7\.org/fhir/uv/ips/ValueSet/results-coded-values-laboratory-pathology-uv-ips\|2\.0\.1\), and a coding is recommended to come from this value set},
        reason: 'The tooling is generating messages when a code is not present in all slices or all additional bindings. This message is generated even where the code is valid against the profile binding rules. See https://chat.fhir.org/#narrow/channel/179252-IG-creation/topic/New.20Terminology.20Issue.20in.20QA.20for.20AU.20core.20.2F.20PS.20etc/with/596624763',
      },
      {
        type: 'error',
        pattern: %r{Bundle\.signature\.targetFormat: The value provided \('application/fhir\+(?:json|xml);canonicalization=http://hl7\.org/fhir/canonicalization/(?:json|xml)(?:\#\w+)?'\) was not found in the value set 'MimeType' \(http://hl7\.org/fhir/ValueSet/mimetypes},
        reason: 'Bundle.signature.targetFormat carries a FHIR canonicalization MIME type (e.g. application/fhir+json;canonicalization=http://hl7.org/fhir/canonicalization/json#document), which is valid for signatures but is not enumerated in the R4 MimeType value set (BCP-13), so the validator cannot resolve it. Validator false positive; the generator already filters the equivalent (\'json\') variant for AU Core. Seen on the IG\'s own Bundle-aups-referral-endoconsult-autogen example.',
      },
      {
        type: 'error',
        pattern: %r{Bundle\.signature\.targetFormat: The System URI could not be determined for the code 'application/fhir\+(?:json|xml);canonicalization=http://hl7\.org/fhir/canonicalization/(?:json|xml)(?:\#\w+)?' in the ValueSet 'http://hl7\.org/fhir/ValueSet/mimetypes},
        reason: 'Bundle.signature.targetFormat carries a FHIR canonicalization MIME type (e.g. application/fhir+json;canonicalization=http://hl7.org/fhir/canonicalization/json#document), which is valid for signatures but is not enumerated in the R4 MimeType value set (BCP-13), so the validator cannot resolve it. Validator false positive; the generator already filters the equivalent (\'json\') variant for AU Core. Seen on the IG\'s own Bundle-aups-referral-endoconsult-autogen example.',
      }
    ].freeze
  end
end
