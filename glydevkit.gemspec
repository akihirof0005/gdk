Gem::Specification.new do |spec|
  spec.name          = 'glydevkit'
  spec.version       = '0.2.0-beta.6'
  spec.authors       = ['Akihiro Fujita']
  spec.email         = ['akihirof0005@gmail.com']
  spec.date          = '2024-10-18'
  spec.summary       = 'The Glycoscience Development Kit (GlyDevKit) is a JRuby library for glyco-informatics'
  spec.description   = 'The Glycoscience Development Kit (GlyDevKit) is a JRuby library for glyco-informatics'
  spec.homepage      = 'https://github.com/akihirof0005/glydevkit/blob/main/README.md'
  spec.license       = 'LGPL-3.0-only'
  spec.files         = ["lib/glydevkit/Loggerinit.rb",
                        "lib/glydevkit/wurcs_frame_work.rb",
                        "lib/glydevkit/glycan_format_converter.rb",
                        "lib/glydevkit/subsumption.rb",
                        "lib/glydevkit/gly_tou_can.rb",
                        "lib/glydevkit/cdk.rb",
                        "lib/glydevkit/glytoucan_data_handler.rb",
                        "lib/glydevkit/glycan_builder.rb",
                        'lib/glydevkit/mol_wurcs.rb',
                        "lib/glydevkit.rb",
                        "lib/init.rb",
                        "jar.yml",
                        "lib/wurcsverify.rb"]
  spec.metadata = {
                        "source_code_uri" => "https://github.com/akihirof0005/glydevkit",
                        "homepage_uri" => "https://github.com/akihirof0005/glydevkit/blob/main/README.md",
                        "changelog_uri" => "https://github.com/akihirof0005/glydevkit",
                        "documentation" => "https://akihirof0005.github.io/glydevkit/index.html"
                  }
  spec.platform       = 'java'
  spec.add_dependency 'java',  '~> 0.0.2'
  spec.add_dependency 'yaml'
  spec.add_dependency 'terminal-table'
end
