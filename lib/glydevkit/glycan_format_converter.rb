require 'java'

require_relative '../jar/glycanformatconverter.jar'
require_relative '../jar/wurcsframework.jar'
require_relative "../jar/MolecularFramework.jar"

java_import 'org.glycoinfo.GlycanFormatconverter.io.GlycoCT.WURCSToGlycoCT'
java_import 'org.glycoinfo.GlycanFormatconverter.io.IUPAC.IUPACStyleDescriptor'
java_import 'org.glycoinfo.GlycanFormatconverter.io.WURCS.WURCSImporter'
java_import 'org.glycoinfo.GlycanFormatconverter.util.ExporterEntrance'
java_import 'org.glycoinfo.GlycanFormatconverter.Glycan.GlyContainer'
java_import 'org.glycoinfo.GlycanFormatconverter.Glycan.GlycanException'
java_import 'org.glycoinfo.GlycanFormatconverter.io.GlyCoExporterException'
java_import 'org.glycoinfo.GlycanFormatconverter.io.GlyCoImporterException'
java_import 'org.glycoinfo.GlycanFormatconverter.io.IUPAC.IUPACStyleDescriptor'
java_import 'org.glycoinfo.GlycanFormatconverter.io.IUPAC.condensed.IUPACCondensedImporter'
java_import 'org.glycoinfo.GlycanFormatconverter.io.IUPAC.extended.IUPACExtendedImporter'
    
module GlyDevKit
  class GlycanFormatConverter

    # Converts a WURCS string to IUPAC format.
    #
    # @param wurcs [String] The WURCS string to be converted.
    # @param style [String] The desired IUPAC style ("condensed", "extended", or "glycam").
    # @return [Hash] A hash containing the input WURCS string and the resulting IUPAC format.
    #
    # @example
    #   converter = GlyDevKit::GlycanFormatConverter.new
    #   result = converter.wurcs2iupac("WURCS=2.0/...", "condensed")
    def wurcs2iupac(wurcs, style)
      ret = {}
      ret["input"] = wurcs

      begin
        wi = WURCSImporter.new
        gc = wi.start(wurcs)
        ee = ExporterEntrance.new(gc)

        if style == "condensed"
          iupaccondensed = ee.toIUPAC(IUPACStyleDescriptor::CONDENSED)
          ret["IUPACcondensed"] = iupaccondensed
        elsif style == "extended"
          iupacextended = ee.toIUPAC(IUPACStyleDescriptor::GREEK)
          ret["IUPACextended"] = iupacextended
        else
          glycam = ee.toIUPAC(IUPACStyleDescriptor::GLYCANWEB)
          ret["GLYCAM"] = glycam
        end

      rescue GlyCoExporterException, GlycanException, TrivialNameException, WURCSException => e
        logger.error("{}", e)
        ret["message"] = e.to_s
      rescue Exception => e
        logger.error("{}", e)
        ret["message"] = e.to_s
      end
      return ret
    end

    # Converts a WURCS string to GlycoCT format.
    #
    # @param wurcs [String] The WURCS string to be converted.
    # @return [Hash] A hash containing the input WURCS string and the resulting GlycoCT format.
    #
    # @example
    #   converter = GlyDevKit::GlycanFormatConverter.new
    #   result = converter.wurcs2glycoct("WURCS=2.0/...")
    def wurcs2glycoct(wurcs)
      ret = {}
      ret["input"] = wurcs
      begin
        converter = WURCSToGlycoCT.new
        converter.start(wurcs)
        message = converter.getErrorMessages
        if message.empty?
          ret["GlycoCT"] = converter.getGlycoCT
          ret["message"] = ""
        else
          ret["GlycoCT"] = ""
          ret["message"] = message
        end
      rescue Exception => e
        ret["GlycoCT"] = ""
        ret["message"] = e.to_s
      end
      return ret
    end

    # Converts a WURCS string to GLYCAM format.
    #
    # @param wurcs [String] The WURCS string to be converted.
    # @return [String] The resulting GLYCAM format string.
    #
    # @example
    #   converter = GlyDevKit::GlycanFormatConverter.new
    #   result = converter.wurcs2glycam("WURCS=2.0/...")
    def wurcs2glycam(wurcs)
      wi = WURCSImporter.new
      ee = ExporterEntrance.new(wi.start(wurcs))
      begin
        ee.toIUPAC(IUPACStyleDescriptor::GLYCANWEB)
      rescue => e
        e.printStackTrace()
      end
    end

    # Converts an IUPAC string to WURCS format.
    #
    # @param iupac [String] The IUPAC string to be converted.
    # @param style [String] The style of the IUPAC string ("condensed" or "extended").
    # @return [Hash] A hash containing the input IUPAC string and the resulting WURCS format.
    #
    # @example
    #   converter = GlyDevKit::GlycanFormatConverter.new
    #   result = converter.iupac2wurcs("Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-", "condensed")
    def iupac2wurcs(iupac, style)
        ret = {}
        ret["input"] = iupac
      
        begin
          if style == "condensed"
            ici = IUPACCondensedImporter.new
            gc = ici.start(iupac)
          else
            iei = IUPACExtendedImporter.new
            gc = iei.start(iupac)
          end
      
          ee = ExporterEntrance.new(gc)
          wurcs = ee.toWURCS
          ret["wurcs"] = wurcs
      
        rescue GlyCoImporterException, GlycanException, WURCSException => e
          ret["message"] = e.to_s
        rescue StandardError => e
          ret["message"] = e.to_s
        end
        return ret
    end
  end
end
