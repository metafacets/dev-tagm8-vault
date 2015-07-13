require 'rspec'
require_relative '../../src/app/tag'

Tagm8Db.open('tagm8-test')

describe 'Taxonomy, Tag, Album, Item composites round-tripping checks' do
  describe 'class methods' do
    Tagm8Db.wipe
    tax = Taxonomy.new('tax1')
    alm = tax.add_album('alm')
    i1 = alm.add_item("i1\n#c2,c4")
    tax_name = tax.name
    tax_id = tax._id
    i1_tax_name = i1.get_taxonomy.name
    i1_tax_id = i1.get_taxonomy._id
    tax_count = Taxonomy.count_by_name
    album_count = Album.count_by_name
    tag_count = Tag.count_by_name
    item_count = Item.count_by_name
    tax_list_tags = tax.list_tags.sort
    tax_count_tags_all = tax.count_tags
    i1_tax_count_tags_all = i1.get_taxonomy.count_tags
    i1_tax_has_tags = i1.get_taxonomy.has_tag?
    taxs_exist = Taxonomy.exist?
    alms_exist = Album.exist?
    itms_exist = Item.exist?
    tags_exist = Tag.exist?
    tax_count_tag_exists = tax.count_tags('c2')
    tax_count_tag_nonexistent = tax.count_tags('c5')
    tag_count_by_name_exists = Tag.count_by_name('c2')
    tax_count_by_name_nonexistent = tax.count_tags('c5')
    i1_t1 = i1.tags[0]
    i1_t1_id = i1_t1._id
    i1_t1_name = i1_t1.name
    # Item.Tag = Tag
    tag_get_id_by_name_exists = Tag.get_by_name(i1_t1_name).first._id                     # Tag.name not unique: therefore get first of returned array
    tag_get_by_name_nonexistent = Tag.get_by_name('xx')
    tag_get_name_by_id_exists = Tag.get_by_id(i1_t1_id).name
    tag_get_by_id_nonexistent = Tag.get_by_id('xx')
    # Item.Tag = Item.Album.Taxonomy.Tag
    i1_tax_get_tag_id_by_name_exists = i1.get_taxonomy.get_tag_by_name(i1_t1_name)._id    # Taxonomy.Tag.name is unique
    i1_tax_get_tag_by_name_nonexistent = i1.get_taxonomy.get_tag_by_name('xx')
    i1_tax_get_tag_name_by_id_exists = i1.get_taxonomy.get_tag_by_id(i1_t1_id).name
    i1_tax_get_tag_by_id_nonexistent = i1.get_taxonomy.get_tag_by_id('xx')
    it "Item.get_taxonomy.name" do expect(i1_tax_name).to eq(tax_name) end
    it "Item.get_taxonomy._id" do expect(i1_tax_id).to eq(tax_id) end
    it "Taxonomy.count_by_name" do expect(tax_count).to eq(1) end
    it "Album.count_by_name" do expect(album_count).to eq(1) end
    it "Item.count_by_name" do expect(item_count).to eq(1) end
    it "Tag.count_by_name" do expect(tag_count).to eq(2) end
    it "tax.List_tags" do expect(tax_list_tags).to eq(['c2','c4']) end
    it "tax.count_tags" do expect(tax_count_tags_all).to eq(2) end
    it "item.get_taxonomy.count_tags" do expect(i1_tax_count_tags_all).to eq(2) end
    it "item.get_taxonomy.has_tag?" do expect(i1_tax_has_tags).to be true end
    it "Taxonomy.exist?" do expect(taxs_exist).to be true end
    it "Album.exist?" do expect(alms_exist).to be true end
    it "Item.exist?" do expect(itms_exist).to be true end
    it "Tag.exist?" do expect(tags_exist).to be true end
    it "tax.count_tags(exists)" do expect(tax_count_tag_exists).to eq(1) end
    it "tax.count_tags(non-existent)" do expect(tax_count_tag_nonexistent).to eq(0) end
    it ":count_by_name exists" do expect(tag_count_by_name_exists).to eq(1) end
    it ":count_by_name non-existent" do expect(tax_count_by_name_nonexistent).to eq(0) end
    it ":get_by_name exists" do expect(tag_get_id_by_name_exists).to eq(i1_t1_id) end
    it ":get_by_name non-existent" do expect(tag_get_by_name_nonexistent).to eq([]) end
    it ":get_by_id exists" do expect(tag_get_name_by_id_exists).to eq(i1_t1_name) end
    it ":get_by_id non-existent" do expect(tag_get_by_id_nonexistent).to eq(nil) end
    it ":get_taxonomy.get_tag_by_name exists" do expect(i1_tax_get_tag_id_by_name_exists).to eq(i1_t1_id) end
    it ":get_taxonomy.get_tag_by_name non-existent" do expect(i1_tax_get_tag_by_name_nonexistent).to eq(nil) end
    it ":get_taxonomy.get_tag_by_id exists" do expect(i1_tax_get_tag_name_by_id_exists).to eq(i1_t1_name) end
    it ":get_taxonomy.get_tag_by_id non-existent" do expect(i1_tax_get_tag_by_id_nonexistent).to eq(nil) end
  end
end