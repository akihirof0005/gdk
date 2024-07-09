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

wfw = GlyDevKit::WurcsFrameWork.new
puts wfw.validator(w)

ssp =  GlyDevKit::Subsumption.new
pp ssp.topology(w)

gtc = GlyDevKit::GlyTouCan.new
pp gtc.archetype(w)

gb = GlyDevKit::GlycanBuilder.new
pp gb.generatePng(w,1)
pp gb.generateSvg(w)

mw = GlyDevKit::MolWURCS.new
pp mw.wurcs2mol(w,"smiles")