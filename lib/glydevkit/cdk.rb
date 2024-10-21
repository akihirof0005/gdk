require "java"

require_relative '../jar/cdk.jar'

java_import 'org.openscience.cdk.similarity.Tanimoto'
java_import 'org.openscience.cdk.DefaultChemObjectBuilder'
java_import 'org.openscience.cdk.smiles.SmilesParser'
java_import 'org.openscience.cdk.fingerprint.CircularFingerprinter'
java_import 'org.openscience.cdk.layout.StructureDiagramGenerator'
java_import 'org.openscience.cdk.depict.DepictionGenerator'

module GlyDevKit
  class CDK
    
    def sim(seq1,seq2,format)
      if format == "wurcs"
          Tanimoto.calculate(w2bit(seq1), w2bit(seq2))
      elsif format == "smiles"
          Tanimoto.calculate(smiles2bit(seq1), smiles2bit(seq2))
      end
    end 

    def mol2svg(smiles,scale)
      
      begin
        sp = SmilesParser.new(DefaultChemObjectBuilder.getInstance)
        molecule = sp.parseSmiles(smiles)

        sdg = StructureDiagramGenerator.new(molecule)
        sdg.generateCoordinates
        molecule = sdg.molecule
          
        depiction_gen = DepictionGenerator.new
        return depiction_gen.withSize(30, 30).depict(molecule).toSvg.sub(/width=\'30.0mm\' height=\'30.0mm\' /,"/width='#{30 * scale}.0mm' height='#{30 * scale}.0mm'")
      
      rescue => e
        puts e.message
      end
    end
    
    private
    
    def w2bit(w)
      mw = GlyDevKit::MolWURCS.new
      smiles =  mw.wurcs2mol(w,"smiles")[:smiles]
    
      sp = SmilesParser.new(DefaultChemObjectBuilder.getInstance())
      molecule = sp.parseSmiles(smiles)
      fingerprinter = CircularFingerprinter.new
      fingerprinter.calculate(molecule)
      return fingerprinter.getBitFingerprint(molecule).asBitSet()
    end
    
    def smiles2bit(s)
    
      sp = SmilesParser.new(DefaultChemObjectBuilder.getInstance())
      molecule = sp.parseSmiles(s)
      fingerprinter = CircularFingerprinter.new
      fingerprinter.calculate(molecule)
      return fingerprinter.getBitFingerprint(molecule).asBitSet()
    end

  end
end
