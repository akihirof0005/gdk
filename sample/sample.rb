require 'glydevkit'

w = "WURCS=2.0/3,5,4/[a2122h-1b_1-5_2*NCC/3=O][a1122h-1b_1-5][a1122h-1a_1-5]/1-1-2-3-3/a4-b1_b4-c1_c3-d1_c6-e1"

gfc = GlyDevKit::GlycanFormatConverter.new

iupac = gfc.wurcs2iupac(w,"condensed")
iupacex = gfc.wurcs2iupac(w,"extended")
ct = gfc.wurcs2glycoct(w)
glycam = gfc.wurcs2glycam(w)

puts iupac
puts iupacex
puts ct
puts glycam

iupac = "Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-"
wurcs = gfc.iupac2wurcs(iupac,"condensed" )

puts wurcs

wfw = GlyDevKit::WURCSFramework.new
puts wfw.validator(w,10)

ssp =  GlyDevKit::Subsumption.new
pp ssp.topology(w)

gtc = GlyDevKit::GlyTouCan.new
pp gtc.archetype(w)

gb = GlyDevKit::GlycanBuilder.new
pp gb.generatePng(w,1)
pp gb.generateSvg(w)

mw = GlyDevKit::MolWURCS.new
pp mw.wurcs2mol(w,"smiles")


handler = GlyDevKit::GlytoucanDataHandler.new

pp handler.get_gtcid_by_wurcs("WURCS=2.0/4,11,10/[a2122h-1x_1-5_2*NCC/3=O][a1122h-1x_1-5][a1221m-1x_1-5][a2112h-1x_1-5]/1-1-2-2-1-1-2-1-3-3-4/a?-b1_a?-i1_b?-c1_c?-d1_c?-g1_d?-e1_d?-f1_g?-h1_j1-a?|b?|c?|d?|e?|f?|g?|h?|i?}_k1-a?|b?|c?|d?|e?|f?|g?|h?|i?}")
pp handler.get_wurcs_by_gtcid("G65107DM")