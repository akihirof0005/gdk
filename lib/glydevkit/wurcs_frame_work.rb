require 'java'

module GlyDevKit

  class WurcsFrameWork

    require_relative  '../jar/wurcsframework.jar'
    java_import 'org.glycoinfo.WURCSFramework.util.validation.WURCSValidator'
    
    def validator(w,maxbranch)
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
