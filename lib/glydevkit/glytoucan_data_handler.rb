require 'json'
require 'uri'
require 'net/http'
require 'zlib'
java_import 'java.util.Base64'

module GlyDevKit
    class GlytoucanDataHandler
    attr_reader :all_data

    def initialize
        @gtcfilepath = File.join(Dir.home, '.glycobook', 'gtcdata.json')
        if File.exist?(@gtcfilepath)
        creation_time = File.ctime(@gtcfilepath)
        one_hours_ago = Time.now - (1 * 60 * 60) # 1時間前の時刻
        if creation_time > one_hours_ago
            @all_data = JSON.parse(File.read(@gtcfilepath))
            return
        end
        end
        @all_data = save_glytoucan_data
    end

    def get_wurcs_by_gtcid(id)
        return "not found" if @all_data["wurcs"][id].nil?
        decode_lambda = ->(encoded_str) { decode(encoded_str) }
        @all_data["wurcs"][id]&.map(&decode_lambda)
    end

    def get_gtcid_by_wurcs(w)
        return "not found" if @all_data["encode-wurcs-key"][encode(w)].nil?
        @all_data["encode-wurcs-key"][encode(w)]
    end

    private

    require 'zlib'
    java_import 'java.util.Base64'
    
    def encode(input_string)
      compressed_data = Zlib::Deflate.deflate(input_string)
      encoder = Base64.getUrlEncoder()
      encoder.encodeToString(compressed_data.to_java_bytes)
    end
    
    def decode(encoded_string)
      decoder = Base64.getUrlDecoder()
      compressed_data = decoder.decode(encoded_string)
      Zlib::Inflate.inflate(String.from_java_bytes(compressed_data))
    end
    

    def sparql_query
        <<-EOS
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX glycan: <http://purl.jp/bio/12/glyco/glycan#>

SELECT DISTINCT ?Saccharide ?WurcsSeq
WHERE {
GRAPH <http://rdf.glytoucan.org/core> {
    ?Saccharide glycan:has_resource_entry ?ResEntry .
    ?s glycan:has_resource_entry ?ResEntry .
}

?Saccharide glycan:has_glycosequence ?GSeq .

GRAPH <http://rdf.glytoucan.org/sequence/wurcs> {
    OPTIONAL {
    ?GSeq glycan:has_sequence ?WurcsSeq .
    }
}

FILTER NOT EXISTS {
    GRAPH <http://rdf.glytoucan.org/archive> {
    ?Saccharide rdf:type ?ArchiveSaccharide .
    }
}
}
EOS
    end

    def fetch_glytoucan_data
        hash1 = {}
        hash2 = {}
        api = 'https://ts.glytoucan.org/sparql?default-graph-uri=&query=' + URI.encode_www_form_component(sparql_query) + '&format=application%2Fsparql-results%2Bjson&timeout=0&signal_void=on'
        response = JSON.parse(Net::HTTP.get(URI(api)))
        response['results']['bindings'].map do |item|
        id = URI(item['Saccharide']['value']).path.split('/').last
        encode_wurcs = encode(item['WurcsSeq']['value'])
        if hash1[id].nil?
            hash1[id] = [encode_wurcs]
        else
            hash1[id].push(encode_wurcs)
        end
        if hash2[encode_wurcs].nil?
            hash2[encode_wurcs] = [id]
        else
            hash2[encode_wurcs].push(id)
        end
        end
        return {"wurcs" => hash1, "encode-wurcs-key" => hash2}
    end

    def save_glytoucan_data
        data = fetch_glytoucan_data
        File.write(@gtcfilepath, data.to_json)
        data
    end
    end
end
