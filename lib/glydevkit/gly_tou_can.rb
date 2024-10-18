require 'java'

require_relative '../jar/archetype.jar'
require_relative '../jar/wurcsframework.jar'

java_import 'org.glytoucan.Archetype'
java_import 'org.glycoinfo.WURCSFramework.wurcs.graph.WURCSGraph'
java_import 'org.glycoinfo.WURCSFramework.util.WURCSException'

module GlyDevKit
  class GlyTouCan
    # Converts a WURCS string to its archetype representation.
    #
    # @param w [String] The WURCS string.
    # @return [Hash] The archetype representation of the WURCS string.
    #
    # @example
    #   require glydevkit
    #   glytoucan = GlyDevKit::GlyTouCan.new
    #   archetype = glytoucan.archetype("WURCS=2.0/...")
    def archetype(w)
      Hash[Archetype.beBorn(w)]
    end
  end
end
