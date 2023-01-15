#!/bin/ruby

# require 'pry'
require 'json'

def build_body(file_path)
  file_lines = File.read(file_path)

  file_lines.split("\n")
end

def build_file_attributes(bs_version, file_path)
  file_type = "-#{File.basename(File.dirname(file_path))}"
  file_name = File.basename(file_path, '.haml')

  prefix_name = file_name == 'default' ? '' : "-#{file_name}"
  prefix = "bs#{bs_version}#{file_type}#{prefix_name}"

  if file_name == 'html5'
    file_type = ''
    prefix = "!bs4#{prefix_name}"
  end

  {
    name: "bs#{bs_version}#{file_type}#{prefix_name}",
    attributes: {
      prefix: prefix,
      body: build_body(file_path)
    }
  }
end

bs_versions = Dir['templates/*'].select { |path| File.directory?(path) }

bs_versions.each do |bs_version_path|
  snippets_content = {}
  bs_version = File.basename(bs_version_path)
  bs_templates = Dir["#{bs_version_path}/**/*.haml"].select { |path| File.file?(path) }

  bs_templates.each do |file_path|
    snippet = build_file_attributes(bs_version, file_path)

    snippets_content[snippet[:name]] = snippet[:attributes]
  end

  snippets_formatted_content = JSON.pretty_generate(snippets_content)

  File.open("snippets/bootstrap#{bs_version}.code-snippets", "w") do |f|
    f.write(snippets_formatted_content)
  end
end
