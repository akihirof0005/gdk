require "java"

require_relative '../jar/cdk.jar'
require_relative '../jar/MolWURCS.jar'

java_import 'org.glycoinfo.MolWURCS.io.formats.ChemFormatType'
java_import 'org.openscience.cdk.exception.CDKException'
java_import 'org.openscience.cdk.interfaces.IAtomContainerSet'
java_import 'org.openscience.cdk.io.IChemObjectWriter'
java_import 'org.openscience.cdk.io.ISimpleChemObjectReader'
java_import 'org.openscience.cdk.silent.AtomContainerSet'
java_import 'org.openscience.cdk.DefaultChemObjectBuilder'
java_import 'org.openscience.cdk.io.SDFWriter'
java_import 'org.openscience.cdk.smiles.SmiFlavor'
java_import 'org.openscience.cdk.smiles.SmilesGenerator'
java_import 'org.openscience.cdk.silent.SilentChemObjectBuilder'
java_import 'java.nio.file.Files'
java_import 'java.nio.file.Paths'
java_import 'java.lang.System'
java_import 'java.util.ArrayList'
java_import 'java.io.StringWriter'
java_import 'java.io.IOException'
java_import 'java.io.StringReader'
java_import "org.openscience.cdk.interfaces.IAtomContainer"
java_import "org.openscience.cdk.smiles.SmilesParser"
java_import "org.glycoinfo.MolWURCS.exchange.toWURCS.MoleculeToWURCSGraph"
java_import "org.glycoinfo.WURCSFramework.util.WURCSFactory"
java_import "org.glycoinfo.WURCSFramework.wurcs.graph.WURCSGraph"
java_import "org.openscience.cdk.interfaces.IAtomContainer"

module GlyDevKit
class MolWURCS
# @param [String] w String of WURCS
# @param [String] format: smiles or sdf
# @return [String] string with specified molecular descriptor
    def wurcs2mol(w,format)
      mols = read_wurcs(w)
      return {"flag": false,"wurcs": w, "message": "WURCS strings that could not be parsed to the atomic level"} if mols.nil?

      case format
      when "sdf"
        {"wurcs": w}.merge(export_to_sdf(mols))
      when "smiles"
        {"wurcs": w}.merge(export_to_smiles(mols))
      else
        {"flag": false,"wurcs": w, "#{format}": "", "message": "Undefined format"}
      end
    end

    def mol2wurcs(smiles)
      parser = SmilesParser.new(DefaultChemObjectBuilder.getInstance)
      molecule = parser.parseSmiles(smiles)
      begin
        graphs = MoleculeToWURCSGraph.new.start(molecule)
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        puts "This method currently only supports up to WURCSFramework version 1.2.16. You need to downgrade the WURCSFramework using the command: `ruby -r init -e \'Init.switch_WFW_version(\"1.2.16\")\'`."
        raise
      end
      factory = WURCSFactory.new(graphs[0])
      return {"wurcs": factory.getWURCS(), "input": smiles} 
    end
    private

    # Reads WURCS and returns a molecule set
    def read_wurcs(w)
      begin
        reader = ChemFormatType::WURCS.createReader
        reader.setReader(StringReader.new(w))
        return nil unless reader.accepts(AtomContainerSet.java_class)
        mols = reader.read(AtomContainerSet.new)
        reader.close
        mols
      rescue CDKException, IOException => e
        e.printStackTrace
        nil
      end
    end

    # Exports molecule set to SDF format
    def export_to_sdf(mols)
      string_writer = StringWriter.new
      begin
        writer = SDFWriter.new(string_writer)
        write_molecule_set(mols, writer)
        {"sdf": string_writer.to_s}
      rescue CDKException, IOException => e
        e.printStackTrace
        {"flag": false,"sdf": "", "message": e.message}
      end
    end

    # Exports molecule set to SMILES format
    def export_to_smiles(mols)
      smiles_gen = SmilesGenerator.new(SmiFlavor::Isomeric)
      string_writer = StringWriter.new
      begin
        mols.atomContainers.each do |mol|
          smiles = smiles_gen.create(mol)
          string_writer.write(smiles)
        end
        smiles = string_writer.toString
        if (smiles == "")
          {"flag": false,"smiles": smiles, "message": "the case of successfully converted to empty characters in the library"} 
        else
          {"flag": true,"smiles": smiles} 
        end
      rescue CDKException, IOException => e
        e.printStackTrace
        {"flag": false,"smiles": "", "message": e.message}
      end
    end

    # Writes molecule set using provided writer
    def write_molecule_set(mols, writer)
      if writer.accepts(mols.java_class)
        writer.write(mols)
      elsif writer.accepts(mols.get_atom_container(0).java_class)
        writer.write(mols.get_atom_container(0))
      end
      writer.close
    end

  end
end
