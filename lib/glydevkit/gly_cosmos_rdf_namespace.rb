require 'rdf'
require 'rdf/turtle'

module GlyDevKit
  class GlyCosmosRdfNamespace
    GLYTOUCAN = RDF::Vocabulary.new("http://rdf.glycoinfo.org/glycan/")
    GLYCAN = RDF::Vocabulary.new("http://purl.jp/bio/12/glyco/glycan#")
    RDF = RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
  #  @@archetype_version = ENV['ARCHETYPE_VERSION']
    
    # Returns the RDF URI for a saccharide with the given ID.
    #
    # @param id [String] The identifier of the saccharide.
    # @return [RDF::URI] The RDF URI for the saccharide.
    # @raise [ArgumentError] If the id is nil or empty.
    def self.saccharide(id)
      if id.nil? || id.empty?
        raise ArgumentError, "please assign 'id'"
      end
      return GLYTOUCAN[id]
    end
  
    # Returns the RDF URI for the reducing end monosaccharide of a saccharide with the given ID.
    #
    # @param id [String] The identifier of the saccharide.
    # @return [{RDF::URI}] The RDF URI for the reducing end monosaccharide.
    # @raise [ArgumentError] If the id is nil or empty.
    def self.red_end_ms(id)
      if id.nil? || id.empty?
        raise ArgumentError, "please assign 'id'"
      end
      return GLYTOUCAN[id + "/red_end_ms"]
    end
  
    # Returns the RDF URI for the property indicating a reducing end monosaccharide residue.
    #
    # @return [{RDF::URI}] The RDF URI for the property.
    def self.has_reducing_end_monosaccharide_residue
      return GLYCAN["has_reducing_end_monosaccharide_residue"]
    end
  
    # Returns the RDF URI for the given anomeric status.
    #
    # @param status [String] The anomeric status.
    # @return [{RDF::URI}] The RDF URI for the anomeric status.
    def self.anomeric_status(status)
      return GLYCAN[status]
    end
  
    # Returns the RDF URI for the given ring status.
    #
    # @param status [String] The ring status.
    # @return [{RDF::URI}] The RDF URI for the ring status.
    def self.ring_status(status)
      return GLYCAN[status]
    end

    # Returns the RDF URI for the property indicating a ring type.
    #
    # @return [{RDF::URI}] The RDF URI for the property.
    def self.has_ring_type
      return GLYCAN["has_ring_type"]
    end
    
    # Returns the RDF URI for the property indicating an archetype.
    #
    # @return [{RDF::URI}] The RDF URI for the property.
    def self.has_archetype
      return GLYCAN["has_archetype"]
    end
  
    # Returns the RDF URI for the property indicating an anomer.
    #
    # @return [{RDF::URI}] The RDF URI for the property.
    def self.has_anomer
      return GLYCAN["has_anomer"]
    end
    
    # Returns the RDF URI for the property indicating that something is an archetype of another entity.
    #
    # @return [{RDF::URI}] The RDF URI for the property.
    def self.is_archetype_of
      return GLYCAN["is_archetype_of"]
    end
    
    # Returns the RDF URI for the RDF type property.
    #
    # @return [{RDF::URI}] The RDF URI for the type property.
    def self.type
      return RDF["type"]
    end
  
    # Returns the RDF URI for the archetype class.
    #
    # @return [{RDF::URI}] The RDF URI for the archetype class.
    def self.archetype
      return GLYCAN["Archetype"]
    end
  
  #  # Returns the URI for the generator based on the ARCHETYPE_VERSION environment variable.
  #  #
  #  # @return [String] The URI for the generator.
  #  # @raise [ArgumentError] If the ARCHETYPE_VERSION environment variable is not set or empty.
  #  def self.generator_uri
  #    if @@archetype_version.nil? || @@archetype_version.empty?
  #      raise ArgumentError, "please assign 'archetype_version'"
  #    end
  #    return "https://glytoucan.org/api/archetype/#{@@archetype_version}/generator"
  #  end
    
    # Returns the RDF URI for the property indicating a message in the archetype logs.
    #
    # @return [{RDF::URI}] The RDF URI for the archetype logs class.
    def has_message
      RDF::URI.new("http://rdf.glycoinfo.org/glycan/archetype/logs#has_message")
    end
  end
end
