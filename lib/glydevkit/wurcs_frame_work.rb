require 'java'

module GlyDevKit

  class WURCSFramework

    # Import the JAR file
    require_relative '../jar/wurcsframework.jar'
    java_import 'org.glycoinfo.WURCSFramework.util.validation.WURCSValidator'

    # Validates a WURCS data string.
    #
    # @param w [String] The WURCS string to be validated.
    # @param maxbranch [Integer] The maximum allowed branch count for validation.
    # @return [Hash] A hash containing the validation results, including any warnings, errors, and unverifiable issues.
    #
    # @example
    #   wurcs = "WURCS=2.0/3,5,4/[a2122h-1b_1-5_2*NCC/3=O][a1122h-1b_1-5][a1122h-1a_1-5]/1-1-2-3-3/a4-b1_b4-c1_c3-d1_c6-e1"
    #   result = validator(wurcs, 10)
    def validator(w, maxbranch)
      validator = WURCSValidator.new
      validator.setMaxBranchCount(maxbranch)
      validator.start(w)
      report = validator.getReport()

      {
        "message" => {
          "VALIDATOR" => ["WURCSFramework-1.2.14"],
          "WARNING" => report.hasWarning(),
          "ERROR" => report.hasError(),
          "UNVERIFIABLE" => report.hasUnverifiable()
        },
        "StandardWURCS" => report.standard_string(),
        "RESULTS" => report.getResults()
      }
    end


    # Converts WURCS data to a graph object.
    #
    # @param w [String] WURCS format data
    # @return [Object, nil] Graph object or nil if an error occurs
    def to_graph(w)
      wgn = WURCSGraphNormalizer.new
      begin
        factory = WURCSFactory.new(w)
        graph = factory.getGraph
        wgn.start(graph)
        graph
      rescue WURCSException => e
        e.printStackTrace
        nil
      end
    end
    
    # Retrieves the anomeric status of a backbone.
    # @param a_o_backbone [Backbone] The backbone object to evaluate.
    # @return [String, nil] A string representing the anomeric status, or nil if it cannot be determined.
    #
    # @example
    #   status = get_anomeric_status(backbone)
    def get_anomeric_status(a_o_backbone)
      a_o_backbone.get_backbone_carbons.each do |t_o_bc|
        return "archetype_anomer" if %w[u U].include?(t_o_bc.get_descriptor.get_char.chr)
      end

      case a_o_backbone.get_anomeric_symbol.chr
      when 'x'
        "anomer_unknown"
      when 'a'
        "anomer_alpha"
      when 'b'
        "anomer_beta"
      else
        a_o_backbone.get_anomeric_position != 0 ? "openchain" : nil
      end
    end


    # Retrieves the ring type of a backbone.
    #
    # @param a_o_backbone [Object] Backbone object
    # @return [String, nil] Ring type as a string or nil if not applicable
    def get_ring_type(a_o_backbone)
      a_o_backbone.get_backbone_carbons.each do |t_o_bc|
        return "archetype_ringtype" if %w[u U].include?(t_o_bc.get_descriptor.get_char.chr)
      end

      a_o_backbone.get_edges.each do |edge|
        next unless edge.is_anomeric && edge.get_modification.is_ring

        ring_start = edge.get_linkages[0].get_backbone_position
        ring_end = edge.get_modification.get_edges[1].get_linkages[0].get_backbone_position
        ring_size = ring_end - ring_start

        return case ring_size
               when 6 then "octanose"
               when 5 then "septanose"
               when 4 then "pyranose"
               when 3 then "furanose"
               when 2 then "oxetose"
               when 1 then "oxirose"
               end
      end
      nil
    end

    # Calculates the mass of a WURCS data string.
    #
    # @param w [String] WURCS format data
    # @return [Float, nil] Mass or nil if an error occurs
    def getWURCSMass(w)
      importer = WURCSImporter.new
      wurcs_array = importer.extractWURCSArray(w)
      WURCSMassCalculator.calcMassWURCS(wurcs_array)
    rescue WURCSException, WURCSMassException, StandardError => e
      e.printStackTrace
      nil
    end
  end
end
