# Readme

This document reflects the current development status. When we release the main version, we plan to publish documentation including API documentation.

## Install

### Java (version Latest)

```bash
# https://sdkman.io/
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# example for Mac
sdk install java
sdk default java 
```

### JRuby

```bash
# https://github.com/rbenv/rbenv#basic-git-checkout
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
echo 'eval "$(~/.rbenv/bin/rbenv init - zsh)"' >> ~/.zshrc

source ~/.bashrc
source ~/.zshrc

git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

rbenv install jruby
rbenv global jruby

# optional
gem install iruby && iruby register --force
```

### GlyDevKit

```bash
gem install glydevkit --pre
#This command has an issue because it will fail the first time, so please try again. 
ruby -r init -e Init.run
```

## Build (for develop)

```bash
gem build glydevkit.gemspec
```

## sample program

```ruby
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
```