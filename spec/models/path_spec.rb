require 'rails_helper'

describe Resource, :elasticsearch do

  before do
    Path.create name: "FooBar",    path: '/home',       size: 23
    Path.create name: "hello",     path: '/Sub',        size: 42
    Path.create name: "nice café", path: '/Sub/folder', size: 1024*4
    Path.refresh_index!
  end

  describe 'search with query' do
    it { expect(Path.search(""      ).results).to eq [] }
    it { expect(Path.search("baz"   ).results).to eq [] }
    it { expect(Path.search("foo"   ).results.map(&:name)).to eq ["FooBar"] }
    it { expect(Path.search("bar"   ).results.map(&:name)).to eq ["FooBar"] }
    it { expect(Path.search("foobar").results.map(&:name)).to eq ["FooBar"] }

    it { expect(Path.search("nice").results.map(&:name)).to eq ["nice café"] }
    #it { expect(Path.search("cafe").results.map(&:name)).to eq ["nice café"] }
    it { expect(Path.search("nice foo").results.map(&:name)).to eq ["nice café"] }
  end
  
  describe 'search with path' do
    it { expect(PathSearch.new(query: 'path:/not-exists nice').total).to eq 0 }
    it { expect(PathSearch.new(query: 'path:/folder     nice').total).to eq 0 }
    
    it { expect(PathSearch.new(query: 'path:/sub'       ).total).to eq 0 }
    it { expect(PathSearch.new(query: 'path:/Sub'       ).total).to eq 2 }
    it { expect(PathSearch.new(query: 'path:/Sub nice'  ).total).to eq 1 }

    it { expect(PathSearch.new(query: 'path:/Sub/folder'        ).total).to eq 1 }
    it { expect(PathSearch.new(query: 'path:/Sub/folder nice'   ).total).to eq 1 }
    it { expect(PathSearch.new(query: 'path:/Sub/folder nothing').total).to eq 0 }
  end

end
