# frozen_string_literal: true

require 'pathname'
require_relative 'suite_spec'
require_relative 'test_file_generator'

class Generator
  # Renders a full suite (suite class, high-order groups, primitive groups, leaf tests, retrieve-CS
  # group) for one IG version from {SuiteSpec} + a built {MetadataManager}, into
  # lib/au_ps_inferno/generated/<ig_version>/, using the same relative-require/metadata-path
  # conventions as the hand-authored `lib/au_ps_inferno/suite/` tree (the original 1.0.0 suite).
  #
  # `lib/au_ps_inferno/suite/` is never read or written by this class, regardless of ig_version -
  # including 1.0.0, which this class is just as able to generate (into
  # lib/au_ps_inferno/generated/1.0.0/) as any other version.
  class SuiteFileGenerator
    # @param metadata [Generator::MetadataManager] already built (#initiate_build called)
    # @param ig_version [String] full semantic IG version, e.g. "1.1.0-ballot"
    # @param lib_root [String] absolute path to lib/au_ps_inferno
    def initialize(metadata, ig_version, lib_root)
      @metadata = metadata
      @ig_version = ig_version
      @lib_root = lib_root
      @suffix = version_suffix(ig_version)
      @version_dir = File.join(@lib_root, 'generated', ig_version)
      @suite_dir = File.join(@version_dir, 'suite')
    end

    def generate
      group_ids = SuiteSpec::FLAVORS.map { |flavor| generate_flavor(flavor) }
      group_ids << generate_cs_group
      generate_suite(group_ids)
    end

    private

    # Builds the id/file suffix for one IG version. Every separator (., -, whitespace, ...) becomes
    # its own underscore, so distinct version segments can never merge into another version's suffix
    # (e.g. "1.0.0-preview" => "1_0_0_preview", never the "100preview" a naive strip-and-join would
    # produce - which is what the hand-authored 1.0.0 suite's ids happen to use).
    def version_suffix(ig_version)
      ig_version.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/\A_+|_+\z/, '')
    end

    def pascal(snake)
      snake.to_s.split('_').map(&:capitalize).join
    end

    # Relative require path from a generated file's directory to lib/au_ps_inferno/utils, computed
    # lexically (no filesystem access) so it stays correct regardless of nesting depth.
    def utils_rel(from_dir)
      Pathname.new(File.join(@lib_root, 'utils')).relative_path_from(Pathname.new(from_dir)).to_s
    end

    # Relative path from a generated file's directory to this version's own metadata.yaml.
    def metadata_rel(from_dir)
      Pathname.new(File.join(@version_dir, 'metadata.yaml')).relative_path_from(Pathname.new(from_dir)).to_s
    end

    def render(template, output_dir, file_name, attributes)
      TestFileGenerator.new(
        template_file_path: template,
        output_file_path: file_name,
        output_base: output_dir,
        attributes: attributes
      ).generate
    end

    # --- Flavor (high-order group) ---

    def generate_flavor(flavor)
      flavor_id = "#{flavor[:id]}_#{@suffix}"
      flavor_dir = File.join(@suite_dir, flavor[:id])

      groups = [generate_bundle_validation_group(flavor, flavor_id, flavor_dir)] +
               SuiteSpec::PRIMITIVE_GROUPS.filter_map { |group| generate_primitive_group(group, flavor_id, flavor_dir) }

      render(
        'high_order_group.rb.erb', flavor_dir, "#{flavor[:id]}.rb",
        class_name: pascal(flavor_id), title: flavor[:title], description: flavor[:description],
        id: flavor_id, group_dir_names: groups.map { |g| g[:key] }, group_ids: groups.map { |g| g[:id] }
      )
      flavor_id
    end

    def generate_bundle_validation_group(flavor, flavor_id, flavor_dir)
      group_key = 'bundle_validation'
      group_id = "#{flavor_id}_#{group_key}"
      group_dir = File.join(flavor_dir, group_key)

      leaf_ids = %i[bundle_valid bundle_valid_ips].map do |leaf_key|
        generate_bundle_valid_leaf(flavor, flavor_id, group_dir, leaf_key)
      end

      render(
        'primitive_group.rb.erb', flavor_dir, "#{group_key}.rb",
        class_name: pascal(group_id), title: 'Bundle Validation',
        description: 'Validates that the bundle conforms to the Bundle profiles.', id: group_id,
        optional_group: false, group_dir_name: group_key, leaf_file_names: leaf_ids, leaf_ids: leaf_ids
      )
      { id: group_id, key: group_key }
    end

    def generate_bundle_valid_leaf(flavor, flavor_id, group_dir, leaf_key)
      leaf = flavor[leaf_key]
      leaf_id = "#{flavor_id}_bundle_validation_#{leaf_key}"
      base_require, ips_require = flavor[:bundle_validation_requires]

      render(
        'bundle_valid_leaf_test.rb.erb', group_dir, "#{leaf_id}.rb",
        class_name: pascal(leaf_id), title: leaf[:title], description: leaf[:description],
        id: leaf_id, base_class: leaf[:base_class], base_require: base_require, ips_require: ips_require,
        utils_rel: utils_rel(group_dir), metadata_rel: metadata_rel(group_dir)
      )
      leaf_id
    end

    # --- Primitive groups (composition_subject, composition_attester, ...) ---

    def generate_primitive_group(group, flavor_id, flavor_dir)
      group_id = "#{flavor_id}_#{group[:key]}"
      group_dir = File.join(flavor_dir, group[:key])

      leaf_ids = group[:leaves].filter_map do |leaf|
        next if leaf[:condition] && !leaf[:condition].call(@metadata)

        generate_primitive_leaf(leaf, group_id, group_dir)
      end
      return nil if leaf_ids.empty?

      render(
        'primitive_group.rb.erb', flavor_dir, "#{group[:key]}.rb",
        class_name: pascal(group_id), title: group[:title], description: group[:description], id: group_id,
        optional_group: group[:optional_group] || false, group_dir_name: group[:key],
        leaf_file_names: leaf_ids, leaf_ids: leaf_ids
      )
      { id: group_id, key: group[:key] }
    end

    def generate_primitive_leaf(leaf, group_id, group_dir)
      leaf_id = "#{group_id}_#{leaf[:key]}"

      render(
        'primitive_leaf_test.rb.erb', group_dir, "#{leaf_id}.rb",
        class_name: pascal(leaf_id), title: leaf[:title], description: leaf[:description], id: leaf_id,
        optional_test: leaf[:optional_test] || false, run_body: leaf[:call].call(@metadata),
        utils_rel: utils_rel(group_dir), metadata_rel: metadata_rel(group_dir)
      )
      leaf_id
    end

    # --- Retrieve CS group ---

    def generate_cs_group
      group_id = "au_ps_retrieve_cs_group_#{@suffix}"
      group_dir = File.join(@suite_dir, 'retrieve_cs_group')

      is_valid_id = generate_cs_is_valid(group_dir)
      supports_ips_id = generate_cs_supports_ips_recommended_ops(group_dir)
      supports_profiles_id = generate_cs_supports_au_ps_profiles(group_dir)

      render(
        'cs_group.rb.erb', group_dir, 'retrieve_cs_group.rb',
        class_name: "AUPSRetrieveCSGroup#{@suffix.capitalize}", id: group_id,
        is_valid_id: is_valid_id, supports_ips_recommended_ops_id: supports_ips_id,
        supports_au_ps_profiles_id: supports_profiles_id
      )
      group_id
    end

    def generate_cs_is_valid(group_dir)
      id = "au_ps_cs_is_valid_#{@suffix}"
      render(
        'cs_is_valid_test.rb.erb', group_dir, 'au_ps_cs_is_valid_test.rb',
        class_name: "AUPSCSIsValid#{@suffix.capitalize}", id: id, utils_rel: utils_rel(group_dir)
      )
      id
    end

    def generate_cs_supports_ips_recommended_ops(group_dir)
      id = "au_ps_cs_supports_ips_recommended_ops_#{@suffix}"
      render(
        'cs_supports_ips_recommended_ops.rb.erb', group_dir, 'au_ps_cs_supports_ips_recommended_ops.rb',
        class_name: "AUPSCSSupportsIPSRecommendedOPS#{@suffix.capitalize}", id: id, utils_rel: utils_rel(group_dir)
      )
      id
    end

    def generate_cs_supports_au_ps_profiles(group_dir)
      id = "au_ps_cs_supports_au_ps_profiles_#{@suffix}"
      required, other = @metadata.profiles.partition { |p| p[:required] }
      render(
        'cs_supports_au_ps_profiles.rb.erb', group_dir, 'au_ps_cs_supports_au_ps_profiles.rb',
        class_name: "AUPSCSSupportsAUPSProfiles#{@suffix.capitalize}", id: id, utils_rel: utils_rel(group_dir),
        required_profiles_hash: required.to_h { |p| [p[:url], p[:name]] },
        other_profiles_hash: other.to_h { |p| [p[:url], p[:name]] }
      )
      id
    end

    # --- Top-level suite ---

    def generate_suite(groups)
      suite_id = "suite_#{@suffix}"
      require_paths = SuiteSpec::FLAVORS.map { |flavor| "#{flavor[:id]}/#{flavor[:id]}" } +
                      ['retrieve_cs_group/retrieve_cs_group']

      render(
        'suite.rb.erb', @suite_dir, "#{suite_id}_suite.rb",
        class_name: "AUPSSuite#{@suffix.capitalize}", id: suite_id, ig_version: @ig_version,
        require_paths: require_paths, group_ids: groups
      )
      suite_id
    end
  end
end
