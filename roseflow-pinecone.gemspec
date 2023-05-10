# frozen_string_literal: true

require_relative "lib/roseflow/pinecone/version"

Gem::Specification.new do |spec|
  spec.name = "roseflow-pinecone"
  spec.version = Roseflow::Pinecone.gem_version
  spec.authors = ["Lauri Jutila"]
  spec.email = ["git@laurijutila.com"]

  spec.summary = "Roseflow meets Pinecone"
  spec.description = "Pinecone vector database integration and support for Roseflow."
  spec.homepage = "https://github.com/roseflow-ai/roseflow-pinecone"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/roseflow-ai/roseflow-pinecone"
  spec.metadata["changelog_uri"] = "https://github.com/roseflow-ai/roseflow-pinecone/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport"
  spec.add_dependency "anyway_config", "~> 2.0"
  spec.add_dependency "dry-struct"
  spec.add_dependency "dry-validation"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday-retry"

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "roseflow"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
