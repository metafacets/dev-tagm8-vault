require 'rspec'
require_relative '../../src/app/facade'

Tagm8Db.open('tagm8-test')

describe Tagm8Db do
  describe :wipe do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_taxonomy('tax2')
    _,_,*list_tax_before = face.list_taxonomies
    result_code,result_msg,*result_data = face.wipe
    _,_,*list_tax_after = face.list_taxonomies
    it "before wipe 'tax1 & tax2' listed" do expect(list_tax_before).to eq(['tax1','tax2']) end
    it "wipe result_code" do expect(result_code).to eq(0) end
    it "wipe result message" do expect(result_msg).to eq('database wiped') end
    it "wipe result data" do expect(result_data).to eq([]) end
    it "after wipe no taxonomies listed" do expect(list_tax_after).to eq([]) end
  end
end
describe Taxonomy do
  describe :add_taxonomy do
    describe 'add succeeds' do
      describe 'name ok, dag default' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name ok, dag prevent' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy('tax1','prevent')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name ok, dag fix' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy('tax1','fix')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'add fails' do
      describe 'name ok, dag invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy('tax1','invalid')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: dag "invalid" invalid - use prevent, fix or free') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_taxonomy('tax1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: "tax1" taken') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_taxonomy('tax%')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_taxonomy "tax%" failed: "tax%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :delete_taxonomies do
    describe 'delete succeeds' do
      describe '1 of 1 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.delete_taxonomies('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 1 taxonomies "tax1" found and deleted') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '2 of 2 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_taxonomy('tax2')
        result_code,result_msg,*result_data = face.delete_taxonomies('tax1,tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 of 2 taxonomies "tax1,tax2" found and deleted') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '1 of 2 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_taxonomy('tax2')
        result_code,result_msg,*result_data = face.delete_taxonomies('tax1,tax3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 taxonomies "tax1,tax3" found and deleted') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '2 of 3 found and deleted with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_taxonomy('tax2')
        face.add_taxonomy('tax3')
        result_code,result_msg,*result_data = face.delete_taxonomies('tax1,tax2,tax4',true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("taxonomy \"tax1\" deleted\ntaxonomy \"tax2\" deleted\n2 of 3 taxonomies \"tax1,tax2,tax4\" found and deleted") end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'delete fails' do
      describe 'no listed taxonomies found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_taxonomy('tax2')
        result_code,result_msg,*result_data = face.delete_taxonomies('tax3,tax4')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_taxonomies "tax3,tax4" failed: no listed taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy list missing - empty' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.delete_taxonomies('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_taxonomies "" failed: taxonomy list missing') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy list missing - nil' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.delete_taxonomies(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_taxonomies "nil:NilClass" failed: taxonomy list missing') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :rename_taxonomy do
    describe 'rename succeeds' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Taxonomy "tax1" renamed to "tax2"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy('','tax2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "" to "tax2" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy(nil,'tax2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "nil:NilClass" to "tax2" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax2" failed: "tax1" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "" failed: taxonomy rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "nil:NilClass" failed: taxonomy rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unchanged' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax1" failed: rename unchanged') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_taxonomy('tax2')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax2" failed: "tax2" taken') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax%')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax%" failed: "tax%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :count_taxonomies do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_taxonomy('tax2')
    describe 'count succeeds' do
      describe 'taxonomy specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.count_taxonomies('tax1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([1]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_taxonomies('tax3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'nothing specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_taxonomies
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.count_taxonomies('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_taxonomies with name "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :list_taxonomies do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #t1>t2 #f1')
    face.add_item('tax1','alm1','itm2\ncontent2')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_taxonomy('tax3')
    describe 'list succeeds' do
      describe 'taxonomy specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.list_taxonomies('tax1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('1 taxonomy found with name "tax1"') end
          it "result data" do expect(result_data).to eq(['tax1']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_taxonomies('tax')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no taxonomies found with name "tax"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'nothing specified with[out] reverse|details' do
        describe '3 found' do
          result_code,result_msg,*result_data = face.list_taxonomies
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 taxonomies found') end
          it "result data" do expect(result_data).to eq(['tax1','tax2','tax3']) end
        end
        describe '3 found reversed' do
          result_code,result_msg,*result_data = face.list_taxonomies(nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 taxonomies found') end
          it "result data" do expect(result_data).to eq(['tax3','tax2','tax1']) end
        end
        describe '3 found with details' do
          result_code,result_msg,*result_data = face.list_taxonomies(nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 taxonomies found') end
          it "result data" do expect(result_data).to eq(['taxonomy "tax1" DAG: prevent has 3 tags, 1 roots, 1 folks, 1 links and 2 albums','          tax2       prevent     0       0        0        0           1        ','          tax3       prevent     0       0        0        0           0        ']) end
        end
        describe '3 found reversed with details' do
          result_code,result_msg,*result_data = face.list_taxonomies(nil,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 taxonomies found') end
          it "result data" do expect(result_data).to eq(['taxonomy "tax3" DAG: prevent has 0 tags, 0 roots, 0 folks, 0 links and 0 albums','          tax2       prevent     0       0        0        0           1        ','          tax1       prevent     3       1        1        1           2        ']) end
        end
      end
    end
    describe 'list fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.list_taxonomies('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_taxonomies with name "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'list paginates' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax01')
      face.add_album('tax01','alm1')
      face.add_item('tax01','alm1','itm1\ncontent1 #f1,t1>t2')
      face.add_item('tax01','alm1','itm2\ncontent2')
      face.add_album('tax01','alm2')
      face.add_taxonomy('tax02')
      face.add_album('tax02','alm1')
      face.add_taxonomy('tax03')
      face.add_taxonomy('tax04')
      face.add_taxonomy('tax05')
      face.add_taxonomy('tax06')
      face.add_taxonomy('tax07')
      face.add_taxonomy('tax08')
      face.add_taxonomy('tax09')
      face.add_taxonomy('tax10')
      face.add_taxonomy('tax11')
      result_code,result_msg,*result_data = face.list_taxonomies(nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 taxonomies found') end
      it "result data" do expect(result_data).to eq(['taxonomy "tax01" DAG: prevent has 3 tags, 1 roots, 1 folks, 1 links and 2 albums','          tax02       prevent     0       0        0        0           1        ','          tax03       prevent     0       0        0        0           0        ','          tax04       prevent     0       0        0        0           0        ','          tax05       prevent     0       0        0        0           0        ','          tax06       prevent     0       0        0        0           0        ','          tax07       prevent     0       0        0        0           0        ','          tax08       prevent     0       0        0        0           0        ','          tax09       prevent     0       0        0        0           0        ','          tax10       prevent     0       0        0        0           0        ','taxonomy "tax11" DAG: prevent has 0 tags, 0 roots, 0 folks, 0 links and 0 albums']) end
    end
  end
  describe :dag_set do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.dag_set('tax1','prevent')
    face.dag_set('tax2','fix')
    face.dag_set('tax3','false')
    describe 'dag_set succeeds' do
      describe 'false' do
        result_code,result_msg,*result_data = face.dag_set('tax1','false')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Taxonomy "tax1" dag set to "false"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'fix' do
        result_code,result_msg,*result_data = face.dag_set('tax1','fix')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Taxonomy "tax1" dag set to "fix"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'prevent' do
        result_code,result_msg,*result_data = face.dag_set('tax1','prevent')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Taxonomy "tax1" dag set to "prevent"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'dag_set fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.dag_set('','prevent')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag_prevent for taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        result_code,result_msg,*result_data = face.dag_set(nil,'prevent')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag_prevent for taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        result_code,result_msg,*result_data = face.dag_set('tax','prevent')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag_prevent for taxonomy "tax" failed: taxonomy "tax" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'dag invalid' do
        result_code,result_msg,*result_data = face.dag_set('tax1','stop')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag_stop for taxonomy "tax1" failed: dag "stop" invalid, use "prevent", "fix" or "false"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'dag invalid - empty' do
        result_code,result_msg,*result_data = face.dag_set('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag_ for taxonomy "tax1" failed: dag "" invalid, use "prevent", "fix" or "false"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'dag invalid - nil' do
        result_code,result_msg,*result_data = face.dag_set('tax1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag_nil:NilClass for taxonomy "tax1" failed: dag "nil:NilClass" invalid, use "prevent", "fix" or "false"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :dag? do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_taxonomy('tax2')
    face.add_taxonomy('tax3')
    face.dag_set('tax1','prevent')
    face.dag_set('tax2','fix')
    face.dag_set('tax3','false')
    describe 'dag? succeeds' do
      describe 'prevent' do
        result_code,result_msg,*result_data = face.dag?('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq(['prevent']) end
      end
      describe 'fix' do
        result_code,result_msg,*result_data = face.dag?('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq(['fix']) end
      end
      describe 'false' do
        result_code,result_msg,*result_data = face.dag?('tax3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq(['false']) end
      end
    end
    describe 'dag? fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.dag?('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag? for taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        result_code,result_msg,*result_data = face.dag?(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag? for taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        result_code,result_msg,*result_data = face.dag?('tax')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('dag? for taxonomy "tax" failed: taxonomy "tax" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
end
describe Album do
  describe :add_album do
    describe 'add succeeds' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_album('tax1','alm1')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Album "alm1" added to taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'add fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_album('','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_album(nil,'alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_album('tax1','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "tax1" failed: taxonomy "tax1" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_album('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "" to taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_album('tax1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "nil:NilClass" to taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_album('tax1','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "tax1" failed: album "alm1" taken by taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_album('tax1','alm%')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_album "alm%" to taxonomy "tax1" failed: album "alm%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :delete_albums do
    describe 'delete succeeds' do
      describe '1 of 1 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.delete_albums('tax1','alm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 1 albums "alm1" found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '2 of 2 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_album('tax1','alm2')
        result_code,result_msg,*result_data = face.delete_albums('tax1','alm1,alm2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 of 2 albums "alm1,alm2" found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '1 of 2 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_album('tax1','alm2')
        result_code,result_msg,*result_data = face.delete_albums('tax1','alm1,alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 albums "alm1,alm3" found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '2 of 3 found and deleted with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_album('tax1','alm2')
        face.add_album('tax1','alm3')
        result_code,result_msg,*result_data = face.delete_albums('tax1','alm1,alm2,alm4',true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("album \"alm1\" deleted\nalbum \"alm2\" deleted\n2 of 3 albums \"alm1,alm2,alm4\" found and deleted from taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'delete fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.delete_albums('','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.delete_albums(nil,'alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.delete_albums('tax2','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "tax2" failed: taxonomy "tax2" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album list missing - empty' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.delete_albums('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_albums "" from taxonomy "tax1" failed: album list missing') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album list missing - nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.delete_albums('tax1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_albums "nil:NilClass" from taxonomy "tax1" failed: album list missing') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no listed albums found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_album('tax1','alm2')
        result_code,result_msg,*result_data = face.delete_albums('tax1','alm3,alm4')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_albums "alm3,alm4" from taxonomy "tax1" failed: no listed albums found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :rename_album do
    describe 'rename succeeds' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Album renamed from "alm1" to "alm2" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('','alm1','alm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album(nil,'alm1','alm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax2','alm1','alm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1','','alm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "" to "alm2" in taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1',nil,'alm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "nil:NilClass" to "alm2" in taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1','alm2','alm3')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm2" to "alm3" in taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1','alm1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "" in taxonomy "tax1" failed: album rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1','alm1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "nil:NilClass" in taxonomy "tax1" failed: album rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unchanged' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm1" in taxonomy "tax1" failed: album rename unchanged') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_album('tax1','alm2')
        result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "tax1" failed: album "alm2" taken by taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm%')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm%" in taxonomy "tax1" failed: album "alm%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :count_albums do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_taxonomy('tax3')
    describe 'count succeeds' do
      describe 'taxonomy, album specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.count_albums('tax1','alm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([1]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_albums('tax1','alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'taxonomy specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_albums('tax1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_albums('tax3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'album specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_albums(nil,'alm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_albums(nil,'alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'nothing specified' do
        describe '3 found' do
          result_code,result_msg,*result_data = face.count_albums
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([3]) end
        end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.count_albums('','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_albums with name "alm1" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy, album specified' do
          result_code,result_msg,*result_data = face.count_albums('tax5','alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_albums with name "alm1" in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.count_albums('tax5')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_albums in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album unspecified' do
        result_code,result_msg,*result_data = face.count_albums('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_albums with name "" in taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'album specified' do
          result_code,result_msg,*result_data = face.count_albums(nil,'alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_albums with name "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'nothing specified' do
          result_code,result_msg,*result_data = face.count_albums
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_albums failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
    end
  end
  describe :list_albums do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1')
    face.add_item('tax1','alm1','itm2\ncontent2')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_taxonomy('tax3')
    describe 'list succeeds' do
      describe 'taxonomy, album specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.list_albums('tax1','alm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('1 album found with name "alm1" in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['alm1']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_albums('tax1','alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no albums found with name "alm3" in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy specified with[out] reverse|details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_albums('tax1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['alm1','alm2']) end
        end
        describe '2 found reversed' do
          result_code,result_msg,*result_data = face.list_albums('tax1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['alm2','alm1']) end
        end
        describe '2 found with details' do
          result_code,result_msg,*result_data = face.list_albums('tax1',nil,false,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm2               tax1      0      ']) end
        end
        describe '2 found reversed with details' do
          result_code,result_msg,*result_data = face.list_albums('tax1',nil,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['album "alm2" in taxonomy "tax1" has 0 items','       alm1               tax1      2      ']) end
        end
      end
      describe 'album specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_albums(nil,'alm1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found with name "alm1"') end
          it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm1               tax2      0      ']) end
        end
        describe "2 found, specified 'no' fullnames" do
          result_code,result_msg,*result_data = face.list_albums(nil,'alm1',nil,true,'no')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found with name "alm1"') end
          it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm1               tax2      0      ']) end
        end
        describe '2 found, bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,'alm1',nil,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found with name "alm1"') end
          it "result data" do expect(result_data).to eq(['alm1.tax1 has 2 items','alm1.tax2     0      ']) end
        end
        describe '2 found, topdown fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,'alm1',nil,true,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 albums found with name "alm1"') end
          it "result data" do expect(result_data).to eq(['tax1.alm1 has 2 items','tax2.alm1     0      ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_albums(nil,'alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no albums found with name "alm3"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'nothing specified' do
        describe '3 found' do
          result_code,result_msg,*result_data = face.list_albums
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['alm1','alm1','alm2']) end
        end
        describe '3 found with bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['alm1.tax1','alm1.tax2','alm2.tax1']) end
        end
        describe '3 found with topdown fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,nil,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['tax1.alm1','tax1.alm2','tax2.alm1']) end
        end
        describe '3 found with details' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm1               tax2      0      ','       alm2               tax1      0      ']) end
        end
        describe '3 found with details and bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['alm1.tax1 has 2 items','alm1.tax2     0      ','alm2.tax1     0      ']) end
        end
        describe '3 found with details and topdown fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,true,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['tax1.alm1 has 2 items','tax1.alm2     0      ','tax2.alm1     0      ']) end
        end
        describe '3 found reversed with details' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['album "alm2" in taxonomy "tax1" has 0 items','       alm1               tax2      0      ','       alm1               tax1      2      ']) end
        end
        describe '3 found reversed with details and bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,true,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['alm2.tax1 has 0 items','alm1.tax2     0      ','alm1.tax1     2      ']) end
        end
        describe '3 found reversed with details and topdown fullnames' do
          result_code,result_msg,*result_data = face.list_albums(nil,nil,true,true,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 albums found') end
          it "result data" do expect(result_data).to eq(['tax2.alm1 has 0 items','tax1.alm2     0      ','tax1.alm1     2      ']) end
        end
      end
    end
    describe 'list fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.list_albums('','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_albums with name "alm1" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy, album specified' do
          result_code,result_msg,*result_data = face.list_albums('tax5','alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_albums with name "alm1" in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.list_albums('tax5')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_albums in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album unspecified' do
        result_code,result_msg,*result_data = face.list_albums('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_albums with name "" in taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'fullnames invalid' do
        result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,nil,'none')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq("list_albums failed: fullnames \"none\" invalid - use 'no', 'topdown' or 'bottomup' only") end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'album specified' do
          result_code,result_msg,*result_data = face.list_albums(nil,'alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_albums with name "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'nothing specified' do
          result_code,result_msg,*result_data = face.list_albums
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_albums failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
    end
    describe 'list paginates' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm01')
      face.add_item('tax1','alm01','itm1\ncontent1')
      face.add_item('tax1','alm01','itm2\ncontent2')
      face.add_item('tax1','alm01','itm3\ncontent1')
      face.add_album('tax1','alm02')
      face.add_album('tax1','alm03')
      face.add_item('tax1','alm03','itm4\ncontent2')
      face.add_item('tax1','alm03','itm5\ncontent1')
      face.add_album('tax1','alm04')
      face.add_album('tax1','alm05')
      face.add_album('tax1','alm06')
      face.add_album('tax1','alm07')
      face.add_album('tax1','alm08')
      face.add_album('tax1','alm09')
      face.add_album('tax1','alm10')
      face.add_album('tax1','alm11')
      result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 albums found') end
      it "result data" do expect(result_data).to eq(['album "alm01" in taxonomy "tax1" has 3 items','       alm02               tax1      0      ','       alm03               tax1      2      ','       alm04               tax1      0      ','       alm05               tax1      0      ','       alm06               tax1      0      ','       alm07               tax1      0      ','       alm08               tax1      0      ','       alm09               tax1      0      ','       alm10               tax1      0      ','album "alm11" in taxonomy "tax1" has 0 items']) end
    end
  end
end
describe Item do
  describe :add_item do
    describe 'add succeeds' do
      describe 'name ok' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm1','itm1\n#tag1,tag2\ncontent line 1\ncontent line 2')
        items = Item.list.sort
        alm1_items = Album.get_by_name('alm1').first.list_items.sort
        itm1 = Item.get_by_name('itm1').first
        itm1_name = itm1.name
        itm1_content = itm1.get_content
        tax1_tags = Taxonomy.get_by_name('tax1').list_tags.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Item "itm1" added to album "alm1" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "items added OK" do expect(items).to eq(['itm1']) end
        it "alm1 items added OK" do expect(alm1_items).to eq(['itm1']) end
        it "itm1 name correct" do expect(itm1_name).to eq('itm1') end
        it "itm1 content correct" do expect(itm1_content).to eq("#tag1,tag2\ncontent line 1\ncontent line 2") end
        it "tax1 tags added OK" do expect(tax1_tags).to eq(['tag1','tag2']) end
      end
      describe 'name ok, stripping test' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm1','  itm1 \n#tag1>tag2,tag3 \n content line 1 \n content line 2 \n \n')
        items = Item.list.sort
        alm1_items = Album.get_by_name('alm1').first.list_items.sort
        itm1 = Item.get_by_name('itm1').first
        itm1_name = itm1.name
        itm1_content = itm1.get_content
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tag_count = tax1.count_tags
        tax1_tags = tax1.list_tags.sort
        tax1_root_count = tax1.count_roots
        tax1_roots = tax1.list_roots.sort
        tax1_folk_count = tax1.count_folksonomies
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Item "itm1" added to album "alm1" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "items added OK" do expect(items).to eq(['itm1']) end
        it "alm1 items added OK" do expect(alm1_items).to eq(['itm1']) end
        it "itm1 name correct" do expect(itm1_name).to eq('itm1') end
        it "itm1 content correct" do expect(itm1_content).to eq("#tag1>tag2,tag3 \n content line 1 \n content line 2") end
        it "tax1 tag count OK" do expect(tax1_tag_count).to eq(3) end
        it "tax1 root count OK" do expect(tax1_root_count).to eq(1) end
        it "tax1 folk count OK" do expect(tax1_folk_count).to eq(1) end
        it "tax1 coorect tags added" do expect(tax1_tags).to eq(['tag1','tag2','tag3']) end
        it "tax1 correct roots added" do expect(tax1_roots).to eq(['tag1']) end
        it "tax1 correct folks added" do expect(tax1_folks).to eq(['tag3']) end
      end
    end
    describe 'add fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('','alm1','itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item(nil,'alm1','itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax2','alm1','itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','','itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "" in taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1',nil,'itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "nil:NilClass" in taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm2','itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm2" in taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm1','itm1\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item "itm1" taken by album "alm1" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        result_code,result_msg,*result_data = face.add_item('tax1','alm1','itm%\ncontent1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item "itm%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :delete_items do
    describe 'delete succeeds' do
      describe '1 of 1 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 1 items "itm1" found and deleted from album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '2 of 2 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        face.add_item('tax1','alm1','itm2\ncontent2')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1,itm2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 of 2 items "itm1,itm2" found and deleted from album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '1 of 2 found and deleted' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        face.add_item('tax1','alm1','itm2\ncontent2')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1,itm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 items "itm1,itm3" found and deleted from album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '2 of 3 found and deleted with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        face.add_item('tax1','alm1','itm2\ncontent2')
        face.add_item('tax1','alm1','itm3\ncontent3')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1,itm2,itm4',true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("item \"itm1\" deleted\nitem \"itm2\" deleted\n2 of 3 items \"itm1,itm2,itm4\" found and deleted from album \"alm1\" of taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'associated tag deletion' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\n#t1,t2,t3,t4\ncontent1')
        face.add_item('tax1','alm1','itm2\n#t3\ncontent2')
        face.add_tags('tax1','t2')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        pre_independent_kept = tax1.has_tag?('t1')
        post_independent_kept = tax1.has_tag?('t2')
        dependent_with_item_kept = tax1.has_tag?('t3')
        dependent_without_item_deleted = !tax1.has_tag?('t4')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("1 of 1 items \"itm1\" found and deleted from album \"alm1\" of taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "correct tags remain" do expect(tax1_tags).to eq(['t1','t2','t3']) end
        it "independent tag added before items kept" do expect(pre_independent_kept).to be_truthy end
        it "independent tag added after items kept" do expect(post_independent_kept).to be_truthy end
        it "dependent tag with items kept" do expect(dependent_with_item_kept).to be_truthy end
        it "dependent tag without items deleted" do expect(dependent_without_item_deleted).to be_truthy end
      end
    end
    describe 'delete fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('','alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items(nil,'alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax2','alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "tax2" failed: taxonomy "tax2" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax1','','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax1',nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "nil:NilClass" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm2','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm2" of taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item list missing - empty' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "" from album "alm1" of taxonomy "tax1" failed: item list missing') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item list missing - nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "nil:NilClass" from album "alm1" of taxonomy "tax1" failed: item list missing') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no listed items found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        face.add_item('tax1','alm1','itm2\ncontent2')
        result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm3,itm4')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_items "itm3,itm4" from album "alm1" of taxonomy "tax1" failed: no listed items found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :rename_item do
    describe 'rename succeeds' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item renamed from "itm1" to "itm2" in album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('','alm1','itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item(nil,'alm1','itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax2','alm1','itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "tax2" failed: taxonomy "tax2" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','','itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1',nil,'itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "nil:NilClass" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm2','itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm2" of taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "" to "itm2" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1',nil,'itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "nil:NilClass" to "itm2" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm" to "itm2" in album "alm1" of taxonomy "tax1" failed: item "itm" not found in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "" in album "alm1" of taxonomy "tax1" failed: item rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "nil:NilClass" in album "alm1" of taxonomy "tax1" failed: item rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unchanged' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm1" in album "alm1" of taxonomy "tax1" failed: item rename unchanged') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        face.add_item('tax1','alm1','itm2\ncontent2')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "tax1" failed: item "itm2" name taken by album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\ncontent1')
        result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm%')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm%" in album "alm1" of taxonomy "tax1" failed: item "itm%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :count_items do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1')
    face.add_item('tax1','alm1','itm2\ncontent2')
    face.add_album('tax1','alm2')
    face.add_item('tax1','alm2','itm2\ncontent2')
    face.add_album('tax1','alm3')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_item('tax2','alm1','itm1\ncontent1')
    face.add_album('tax2','alm2')
    face.add_item('tax2','alm2','itm2\ncontent2')
    face.add_album('tax2','alm3')
    face.add_taxonomy('tax3')
    face.add_album('tax3','alm1')
    face.add_taxonomy('tax4')
    describe 'count succeeds' do
      describe 'taxonomy, album, name specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.count_items('tax1','alm1','itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([1]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items('tax1','alm2','itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'taxonomy, album specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_items('tax1','alm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items('tax1','alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'taxonomy, name specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_items('tax1',nil,'itm2')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items('tax1',nil,'itm4')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'album, name specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_items(nil,'alm1','itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items(nil,'alm2','itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'taxonomy specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_items('tax2')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items('tax3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'album specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_items(nil,'alm2')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items(nil,'alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'name specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_items(nil,nil,'itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_items(nil,nil,'itm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'nothing specified' do
        result_code,result_msg,*result_data = face.count_items
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([5]) end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.count_items('','alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy, album, item specified' do
          result_code,result_msg,*result_data = face.count_items('tax5','alm1','itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy, album specified' do
          result_code,result_msg,*result_data = face.count_items('tax5','alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy, name specified' do
          result_code,result_msg,*result_data = face.count_items('tax5',nil,'itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items with name "itm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.count_items('tax5')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album unspecified' do
        result_code,result_msg,*result_data = face.count_items('tax1','','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found in taxonomy' do
        result_code,result_msg,*result_data = face.count_items('tax3','alm2','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm2" of taxonomy "tax3" failed: album "alm2" not found in taxonomy "tax3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm4','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm4" failed: album "alm4" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no albums found in taxonomy' do
        result_code,result_msg,*result_data = face.count_items('tax4')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items of taxonomy "tax4" failed: no albums found in taxonomy "tax4"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name unspecified' do
        result_code,result_msg,*result_data = face.count_items('tax1','alm1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'album, name specified' do
          result_code,result_msg,*result_data = face.count_items(nil,'alm1','itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'album specified' do
          result_code,result_msg,*result_data = face.count_items(nil,'alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items in album "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'item specified' do
          result_code,result_msg,*result_data = face.count_items(nil,nil,'itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items with name "itm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'nothing specified' do
          result_code,result_msg,*result_data = face.count_items(nil,nil,nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_items failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'no albums found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.count_items(nil,nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" failed: no albums found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :list_items do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1')
    face.add_item('tax1','alm1','itm2\ncontent2.1 \n content 2.2#t1,t2 \n content2.3 \n \n')
    face.add_album('tax1','alm2')
    face.add_item('tax1','alm2','itm2\ncontent2')
    face.add_album('tax1','alm3')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_item('tax2','alm1','itm1\ncontent1')
    face.add_album('tax2','alm2')
    face.add_item('tax2','alm2','itm2\ncontent2')
    face.add_album('tax2','alm3')
    face.add_taxonomy('tax3')
    face.add_album('tax3','alm1')
    face.add_taxonomy('tax4')
    describe 'list succeeds' do
      describe 'taxonomy, album, name specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1','itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('1 item found with name "itm1" in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm1']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm2','itm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found with name "itm1" in album "alm2" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy, album specified, with[out] reverse|details|content|fullnames' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm1','itm2']) end
        end
        describe '2 found reversed' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm2','itm1']) end
        end
        describe '2 found with details no content' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm2            alm1               tax1      2     ']) end
        end
        describe '2 found with content no details' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,false,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(["itm1\ncontent1\n\n","itm2\ncontent2.1 \n content 2.2#t1,t2 \n content2.3\n\n"]) end
        end
        describe '2 found with content and details' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(["item \"itm1\" in album \"alm1\" of taxonomy \"tax1\" has 0 tags:\n\ncontent1\n\n","item \"itm2\" in album \"alm1\" of taxonomy \"tax1\" has 2 tags:\n\ncontent2.1 \n content 2.2#t1,t2 \n content2.3\n\n"]) end
        end
        describe '2 found reversed with details' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['item "itm2" in album "alm1" of taxonomy "tax1" has 2 tags','      itm1            alm1               tax1      0     ']) end
        end
        describe '2 found with bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax1','itm2.alm1.tax1']) end
        end
        describe '2 found with topdown fullnames' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,nil,nil,nil,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['tax1.alm1.itm1','tax1.alm1.itm2']) end
        end
        describe '2 found reversed with bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,true,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm2.alm1.tax1','itm1.alm1.tax1']) end
        end
        describe '2 found with details no content and bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,true,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax1 has 0 tags','itm2.alm1.tax1     2     ']) end
        end
        describe '2 found with content and bottomup fullnames no details' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,false,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(["itm1.alm1.tax1\ncontent1\n\n","itm2.alm1.tax1\ncontent2.1 \n content 2.2#t1,t2 \n content2.3\n\n"]) end
        end
        describe '2 found with content, details and bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,true,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(["itm1.alm1.tax1 has 0 tags:\n\ncontent1\n\n","itm2.alm1.tax1 has 2 tags:\n\ncontent2.1 \n content 2.2#t1,t2 \n content2.3\n\n"]) end
        end
        describe '2 found reversed with details and bottomup fullnames' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,true,true,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm2.alm1.tax1 has 2 tags','itm1.alm1.tax1     0     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items('tax1','alm3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found in album "alm3" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy, name specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_items('tax1',nil,'itm2',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found with name "itm2" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['item "itm2" in album "alm1" of taxonomy "tax1" has 2 tags','      itm2            alm2               tax1      0     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items('tax1',nil,'itm4',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found with name "itm4" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album, name specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_items(nil,'alm1','itm1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found with name "itm1" in album "alm1"') end
          it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items(nil,'alm2','itm1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found with name "itm1" in album "alm2"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_items('tax2',nil,nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found of taxonomy "tax2"') end
          it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax2" has 0 tags','      itm2            alm2               tax2      0     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items('tax3',nil,nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found of taxonomy "tax3"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_items(nil,'alm2',nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found in album "alm2"') end
          it "result data" do expect(result_data).to eq(['item "itm2" in album "alm2" of taxonomy "tax1" has 0 tags','      itm2            alm2               tax2      0     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items(nil,'alm3',nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found in album "alm3"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'name specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_items(nil,nil,'itm1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found with name "itm1"') end
          it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_items(nil,nil,'itm3',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found with name "itm3"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'nothing specified, details' do
        result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('5 items found') end
        it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ','      itm2            alm1               tax1      2     ','      itm2            alm2               tax1      0     ','      itm2            alm2               tax2      0     ']) end
      end
      describe "nothing specified, specified 'no' fullnames, details" do
        result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true,nil,'no')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('5 items found') end
        it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ','      itm2            alm1               tax1      2     ','      itm2            alm2               tax1      0     ','      itm2            alm2               tax2      0     ']) end
      end
      describe "nothing specified, bottomup fullnames, details" do
        result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true,nil,'bottomup')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('5 items found') end
      end
      describe "nothing specified, topdown fullnames, details" do
        result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true,nil,'topdown')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('5 items found') end
        it "result data" do expect(result_data).to eq(['tax1.alm1.itm1 has 0 tags','tax1.alm1.itm2     2     ','tax1.alm2.itm2     0     ','tax2.alm1.itm1     0     ','tax2.alm2.itm2     0     ']) end
      end
    end
    describe 'list fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.list_items('','alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy, album, item specified' do
          result_code,result_msg,*result_data = face.list_items('tax5','alm1','itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy, album specified' do
          result_code,result_msg,*result_data = face.list_items('tax5','alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy, name specified' do
          result_code,result_msg,*result_data = face.list_items('tax5',nil,'itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items with name "itm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.list_items('tax5')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album unspecified' do
        result_code,result_msg,*result_data = face.list_items('tax1','','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found in taxonomy' do
        result_code,result_msg,*result_data = face.list_items('tax3','alm2','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm2" of taxonomy "tax3" failed: album "alm2" not found in taxonomy "tax3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm4','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm4" failed: album "alm4" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no albums found in taxonomy' do
        result_code,result_msg,*result_data = face.list_items('tax4')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items of taxonomy "tax4" failed: no albums found in taxonomy "tax4"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'name unspecified' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'fullnames invalid' do
        result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true,nil,'none')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq("list_items failed: fullnames \"none\" invalid - use 'no', 'topdown' or 'bottomup' only") end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'album, name specified' do
          result_code,result_msg,*result_data = face.list_items(nil,'alm1','itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'album specified' do
          result_code,result_msg,*result_data = face.list_items(nil,'alm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items in album "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'item specified' do
          result_code,result_msg,*result_data = face.list_items(nil,nil,'itm1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items with name "itm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'nothing specified' do
          result_code,result_msg,*result_data = face.list_items(nil,nil,nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_items failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'no albums found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.list_items(nil,nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" failed: no albums found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'list paginates' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm01\ncontent1')
      face.add_item('tax1','alm1','itm02\ncontent2')
      face.add_item('tax1','alm1','itm03\ncontent1')
      face.add_item('tax1','alm1','itm04\ncontent2')
      face.add_item('tax1','alm1','itm05\ncontent1')
      face.add_item('tax1','alm1','itm06\ncontent2')
      face.add_item('tax1','alm1','itm07\ncontent1')
      face.add_item('tax1','alm1','itm08\ncontent2')
      face.add_item('tax1','alm1','itm09\ncontent1')
      face.add_item('tax1','alm1','itm10\ncontent2')
      face.add_item('tax1','alm1','itm11\ncontent1')
      result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 items found') end
      it "result data" do expect(result_data).to eq(['item "itm01" in album "alm1" of taxonomy "tax1" has 0 tags','      itm02            alm1               tax1      0     ','      itm03            alm1               tax1      0     ','      itm04            alm1               tax1      0     ','      itm05            alm1               tax1      0     ','      itm06            alm1               tax1      0     ','      itm07            alm1               tax1      0     ','      itm08            alm1               tax1      0     ','      itm09            alm1               tax1      0     ','      itm10            alm1               tax1      0     ','item "itm11" in album "alm1" of taxonomy "tax1" has 0 tags']) end
    end
  end
  describe 'query[_items]' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1',':tag1>[:tag1a,:tag1b>:tag1b1],:f1,:f2')
    face.add_taxonomy('tax2')
    face.add_taxonomy('tax3')
    face.add_tags('tax2',':f1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\n#tag1b,f2')
    face.add_item('tax1','alm1','itm2\n#f1')
    face.add_album('tax1','alm2')
    face.add_item('tax1','alm2','itm1\n#f2')
    face.add_album('tax2','alm1')
    face.add_item('tax2','alm1','itm1\n#f1')
    describe 'query succeeds' do
      describe 'taxonomy, album, name specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.query_items('tax1','alm1','f1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('1 item found matching "f1" in album "alm1" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm2']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.query_items('tax1','alm2','f3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found matching "f3" in album "alm2" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'query only with[out] reverse|details|content|fullnames' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm1','itm2']) end
        end
        describe '2 found reversed' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm2','itm1']) end
        end
        describe '2 found with details no content' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',false,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax2" has 1 tags','      itm2            alm1               tax1      1     ']) end
        end
        describe '2 found with content no details' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',false,false,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(["itm1\n#f1\n\n","itm2\n#f1\n\n"]) end
        end
        describe '2 found with content and details' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',false,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(["item \"itm1\" in album \"alm1\" of taxonomy \"tax2\" has 1 tags:\n\n#f1\n\n","item \"itm2\" in album \"alm1\" of taxonomy \"tax1\" has 1 tags:\n\n#f1\n\n"]) end
        end
        describe '2 found reversed with details' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['item "itm2" in album "alm1" of taxonomy "tax1" has 1 tags','      itm1            alm1               tax2      1     ']) end
        end
        describe "2 found with specified 'no' fullnames" do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',nil,nil,nil,'no')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm1','itm2']) end
        end
        describe '2 found with bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax2','itm2.alm1.tax1']) end
        end
        describe '2 found with topdown fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',nil,nil,nil,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['tax1.alm1.itm2','tax2.alm1.itm1']) end
        end
        describe '2 found reversed with bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',true,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm2.alm1.tax1','itm1.alm1.tax2']) end
        end
        describe '2 found reversed with topdown fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',true,nil,nil,'topdown')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['tax2.alm1.itm1','tax1.alm1.itm2']) end
        end
        describe '2 found with details no content and bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',false,true,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax2 has 1 tags','itm2.alm1.tax1     1     ']) end
        end
        describe '2 found with content and bottomup fullnames no details' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',false,false,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(["itm1.alm1.tax2\n#f1\n\n","itm2.alm1.tax1\n#f1\n\n"]) end
        end
        describe '2 found with content, details and bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',false,true,true,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(["itm1.alm1.tax2 has 1 tags:\n\n#f1\n\n","itm2.alm1.tax1 has 1 tags:\n\n#f1\n\n"]) end
        end
        describe '2 found reversed with details and bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',true,true,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1"') end
          it "result data" do expect(result_data).to eq(['itm2.alm1.tax1 has 1 tags','itm1.alm1.tax2     1     ']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found matching "f3"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.query_items('tax1',nil,'f2')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f2" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm1','itm1']) end
        end
        describe '2 found with bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items('tax1',nil,'f2',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f2" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax1','itm1.alm2.tax1']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.query_items('tax1',nil,'f3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found matching "f3" of taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.query_items(nil,'alm1','f1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1" in album "alm1"') end
          it "result data" do expect(result_data).to eq(['itm1','itm2']) end
        end
        describe '2 found with bottomup fullnames' do
          result_code,result_msg,*result_data = face.query_items(nil,'alm1','f1',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "f1" in album "alm1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax2','itm2.alm1.tax1']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.query_items(nil,'alm1','f3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no items found matching "f3" in album "alm1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'query logic with bottomup fullnames' do
        describe 'AND with exact semantic scope - 1 found' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'tag1b&f2',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('1 item found matching "tag1b&f2"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax1']) end
        end
        describe 'OR with exact semantic scope - 3 found' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'tag1b|f1',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 items found matching "tag1b|f1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax1','itm1.alm1.tax2','itm2.alm1.tax1']) end
        end
        describe 'OR with superset semantic scope - 3 found' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'tag1|f1',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 items found matching "tag1|f1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax1','itm1.alm1.tax2','itm2.alm1.tax1']) end
        end
        describe 'OR with subset semantic scope - 2 found' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'tag1b1|f1',nil,nil,nil,'bottomup')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 items found matching "tag1b1|f1"') end
          it "result data" do expect(result_data).to eq(['itm1.alm1.tax2','itm2.alm1.tax1']) end
        end
      end
    end
    describe 'query fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.query_items('','alm1','f1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('query_items matching "f1" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy and album specified' do
          result_code,result_msg,*result_data = face.query_items('tax5','alm1','f1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('query_items matching "f1" in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.query_items('tax5',nil,'f1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('query_items matching "f1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'album unspecified' do
        result_code,result_msg,*result_data = face.query_items('tax1','','f1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('query_items matching "f1" in album "" of taxonomy "tax1" failed: album unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found in taxonomy' do
        result_code,result_msg,*result_data = face.query_items('tax2','alm2','f1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('query_items matching "f1" in album "alm2" of taxonomy "tax2" failed: album "alm2" not found in taxonomy "tax2"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album not found' do
        result_code,result_msg,*result_data = face.query_items(nil,'alm3','f1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('query_items matching "f1" in album "alm3" failed: album "alm3" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no albums found in taxonomy' do
        result_code,result_msg,*result_data = face.query_items('tax3',nil,'f1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('query_items matching "f1" of taxonomy "tax3" failed: no albums found in taxonomy "tax3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'query missing' do
        describe 'query empty' do
          result_code,result_msg,*result_data = face.query_items('tax1','alm1','')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('query_items matching "" in album "alm1" of taxonomy "tax1" failed: query missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'query nil' do
          result_code,result_msg,*result_data = face.query_items('tax1','alm1',nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('query_items matching "nil:NilClass" in album "alm1" of taxonomy "tax1" failed: query missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'fullnames invalid' do
        result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',nil,true,nil,'none')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq("query_items matching \"f1\" failed: fullnames \"none\" invalid - use 'no', 'topdown' or 'bottomup' only") end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'album specified' do
          result_code,result_msg,*result_data = face.query_items(nil,'alm1','f1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('query_items matching "f1" in album "alm1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'album unspecified' do
          result_code,result_msg,*result_data = face.query_items(nil,nil,'f1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('query_items matching "f1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'no albums found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.query_items(nil,nil,'f1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('query_items matching "f1" failed: no albums found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'list paginates' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm01\n#f1')
      face.add_item('tax1','alm1','itm02\n#f1')
      face.add_item('tax1','alm1','itm03\n#f1')
      face.add_item('tax1','alm1','itm04\n#f1')
      face.add_item('tax1','alm1','itm05\n#f1')
      face.add_item('tax1','alm1','itm06\n#f1')
      face.add_item('tax1','alm1','itm07\n#f1')
      face.add_item('tax1','alm1','itm08\n#f1')
      face.add_item('tax1','alm1','itm09\n#f1')
      face.add_item('tax1','alm1','itm10\n#f1')
      face.add_item('tax1','alm1','itm11\n#f1')
      result_code,result_msg,*result_data = face.query_items(nil,nil,'f1',nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 items found matching "f1"') end
      it "result data" do expect(result_data).to eq(['item "itm01" in album "alm1" of taxonomy "tax1" has 1 tags','      itm02            alm1               tax1      1     ','      itm03            alm1               tax1      1     ','      itm04            alm1               tax1      1     ','      itm05            alm1               tax1      1     ','      itm06            alm1               tax1      1     ','      itm07            alm1               tax1      1     ','      itm08            alm1               tax1      1     ','      itm09            alm1               tax1      1     ','      itm10            alm1               tax1      1     ','item "itm11" in album "alm1" of taxonomy "tax1" has 1 tags']) end
    end
  end
end
describe Tag do
  describe :add_tags do
    describe 'add succeeds' do
      describe '"t1" 1 tag' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','t1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 tag and no links added to taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '"t1" same tag added to 2nd taxonomy' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax2')
        face.add_tags('tax2','t1')
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','t1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 tag and no links added to taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '"tag1>tag2,tag3" 3 tags, 1 link, 1 root, 1 folk' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','tag1>tag2,tag3')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tag_count = tax1.count_tags
        tax1_tags = tax1.list_tags.sort
        tax1_root_count = tax1.count_roots
        tax1_roots = tax1.list_roots.sort
        tax1_folk_count = tax1.count_folksonomies
        tax1_folks = tax1.list_folksonomies.sort
        face.add_taxonomy('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 tags and 1 link added to taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "tax1 tag count OK" do expect(tax1_tag_count).to eq(3) end
        it "tax1 root count OK" do expect(tax1_root_count).to eq(1) end
        it "tax1 folk count OK" do expect(tax1_folk_count).to eq(1) end
        it "tax1 coorect tags added" do expect(tax1_tags).to eq(['tag1','tag2','tag3']) end
        it "tax1 correct roots added" do expect(tax1_roots).to eq(['tag1']) end
        it "tax1 correct folks added" do expect(tax1_folks).to eq(['tag3']) end
      end
      describe '"tag3,tag1>tag2" 3 tags, 1 link, 1 root, 1 folk with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','tag3,tag1>tag2',true)
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tag_count = tax1.count_tags
        tax1_tags = tax1.list_tags.sort
        tax1_root_count = tax1.count_roots
        tax1_roots = tax1.list_roots.sort
        tax1_folk_count = tax1.count_folksonomies
        tax1_folks = tax1.list_folksonomies.sort
        face.add_taxonomy('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("tag \"tag1\" added\ntag \"tag2\" added\ntag \"tag3\" added\n3 tags and 1 link added to taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "tax1 tag count OK" do expect(tax1_tag_count).to eq(3) end
        it "tax1 root count OK" do expect(tax1_root_count).to eq(1) end
        it "tax1 folk count OK" do expect(tax1_folk_count).to eq(1) end
        it "tax1 coorect tags added" do expect(tax1_tags).to eq(['tag1','tag2','tag3']) end
        it "tax1 correct roots added" do expect(tax1_roots).to eq(['tag1']) end
        it "tax1 correct folks added" do expect(tax1_folks).to eq(['tag3']) end
      end
    end
    describe 'add_tags fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_tags('','t1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_tags "t1" to taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.add_tags(nil,'t1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_tags "t1" to taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax','t1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('add_tags "t1" to taxonomy "tax" failed: taxonomy "tax" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :delete_tags do
    describe 'delete succeeds' do
      describe '+ t1: - t1' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 1 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '+ t1>t2>t3,t4: - t2,t4' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2>t3,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2,t4')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 of 2 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "[t1,t3] tags remain" do expect(tax1_tags).to eq(['t1','t3']) end
        it "[t1] roots remain" do expect(tax1_roots).to eq(['t1']) end
        it "[] folks remain" do expect(tax1_folks).to eq([]) end
      end
      describe '+ t1>t2>t3,t4: - t2,t4 with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2>t3,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2,t4,t5',nil,true)
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("tag \"t2\" deleted\ntag \"t4\" deleted\n2 of 3 supplied tags found and deleted from taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "[t1,t3] tags remain" do expect(tax1_tags).to eq(['t1','t3']) end
        it "[t1] roots remain" do expect(tax1_roots).to eq(['t1']) end
        it "[] folks remain" do expect(tax1_folks).to eq([]) end
      end
      describe '+ t1>t2>t3,t4: - t2,t4 branch with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2>t3,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2,t4,t5',true,true)
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("tag \"t2\" deleted\ntag \"t3\" deleted\ntag \"t4\" deleted\n2 of 3 supplied tags found, 3 deleted from taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "[t1] tags remain" do expect(tax1_tags).to eq(['t1']) end
        it "[] roots remain" do expect(tax1_roots).to eq([]) end
        it "[t1] folks remain" do expect(tax1_folks).to eq(['t1']) end
      end
      describe '+ t1>t2,t3: - t1,t4' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2,t3')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1,t4')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "[t2,t3] tags remain" do expect(tax1_tags).to eq(['t2','t3']) end
        it "[] roots remain" do expect(tax1_roots).to eq([]) end
        it "[t2,t3] folks remain" do expect(tax1_folks).to eq(['t2','t3']) end
      end
      describe '+ t1>t2,t3 - t1,t4: -t1,t2 ' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2,t3')
        face.delete_tags('tax1','t1,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1,t2')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "t3 tags remain" do expect(tax1_tags).to eq(['t3']) end
        it "[] roots remain" do expect(tax1_roots).to eq([]) end
        it "[t3] folks remain" do expect(tax1_folks).to eq(['t3']) end
      end
    end
    describe 'delete_tags fails' do
      describe 'taxonomy unspecified' do
        describe 'other taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy nil' do
        describe 'other taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags(nil,'t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags(nil,'t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy not found' do
        describe 'other taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax2')
          face.add_tags('tax2','t1')
          result_code,result_msg,*result_data = face.delete_tags('tax1','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "tax1" failed: taxonomy "tax1" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags('tax1','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "tax1" failed: taxonomy "tax1" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'tag syntax missing - empty' do
        describe 'taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('tax1','')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags('tax1','')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'tag syntax missing - nil' do
        describe 'taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('tax1',nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "nil:NilClass" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags('tax1',nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "nil:NilClass" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'no supplied tags found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_tags "t2" from taxonomy "tax1" failed: no supplied tags found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :rename_tag do
    describe 'rename valid' do
      describe 'rename succeeds' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1','nt1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Tag renamed from "t1" to "nt1" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item sourced tag renamed' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_album('tax1','alm1')
        face.add_item('tax1','alm1','itm1\n#t1,t2\ncontent line 1\ncontent line 2')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1','nt1')
        itm1_content = Item.get_by_name('itm1').first.get_content
        tax1_tags = Taxonomy.get_by_name('tax1').list_tags.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('Tag renamed from "t1" to "nt1" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "tag is renamed in items" do expect(itm1_content).to eq("#nt1,t2\ncontent line 1\ncontent line 2") end
        it "tag is renamed in taxonomy" do expect(tax1_tags).to eq(['nt1','t2']) end
      end
    end
    describe 'rename fails' do
      describe 'taxonomy unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('','t1','nt1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "nt1" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag(nil,'t1','nt1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "nt1" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax2','t1','nt1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "nt1" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'tag unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','','nt1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "" to "nt1" in taxonomy "tax1" failed: tag unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'tag nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1',nil,'nt1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "nil:NilClass" to "nt1" in taxonomy "tax1" failed: tag unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'tag not found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t2','nt2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t2" to "nt2" in taxonomy "tax1" failed: tag "t2" not found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "" in taxonomy "tax1" failed: tag rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename nil' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1',nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "nil:NilClass" in taxonomy "tax1" failed: tag rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename unchanged' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1','t1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "t1" in taxonomy "tax1" failed: tag rename unchanged') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename taken' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1,nt1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1','nt1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "nt1" in taxonomy "tax1" failed: tag "nt1" taken by taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'rename invalid' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.rename_tag('tax1','t1','nt%')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_tag "t1" to "nt%" in taxonomy "tax1" failed: tag "nt%" invalid - use alphanumeric and _ characters only') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :count_tags do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1','tag1,tag2')
    face.add_taxonomy('tax2')
    face.add_tags('tax2','tag1')
    face.add_taxonomy('tax3')
    describe 'count succeeds' do
      describe 'taxonomy, tag specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.count_tags('tax1','tag1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([1]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_tags('tax1','tag3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'taxonomy specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_tags('tax1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_tags('tax3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'tag specified' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.count_tags(nil,'tag1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([2]) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.count_tags(nil,'tag3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([0]) end
        end
      end
      describe 'nothing specified' do
        describe '3 found' do
          result_code,result_msg,*result_data = face.count_tags
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('') end
          it "result data" do expect(result_data).to eq([3]) end
        end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.count_tags('','tag1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_tags with name "tag1" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy, tag specified' do
          result_code,result_msg,*result_data = face.count_tags('tax5','tag1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_tags with name "tag1" in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.count_tags('tax5')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_tags in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'tag unspecified' do
        result_code,result_msg,*result_data = face.count_tags('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_tags with name "" in taxonomy "tax1" failed: tag unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'tag specified' do
          result_code,result_msg,*result_data = face.count_tags(nil,'tag1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_tags with name "tag1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'nothing specified' do
          result_code,result_msg,*result_data = face.count_tags
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('count_tags failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
    end
  end
  describe :count_links do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1','f5')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #a1>b1>[c1>d1,c2],f1,f2,f3')
    face.add_taxonomy('tax2')
    describe 'count succeeds' do
      describe 'links found' do
        result_code,result_msg,*result_data = face.count_links('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([4]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_links('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified - empty' do
        result_code,result_msg,*result_data = face.count_links('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_links in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy unspecified - nil' do
        result_code,result_msg,*result_data = face.count_links(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_links in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        result_code,result_msg,*result_data = face.count_links('tax')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_links in taxonomy "tax" failed: taxonomy "tax" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :count_roots do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1','r2>b2,f5')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #r1>b1>[c1>d1,c2],f1,f2,f3')
    face.add_taxonomy('tax2')
    describe 'count succeeds' do
      describe 'roots found' do
        result_code,result_msg,*result_data = face.count_roots('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_roots('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified - empty' do
        result_code,result_msg,*result_data = face.count_roots('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_roots in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy unspecified - nil' do
        result_code,result_msg,*result_data = face.count_roots(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_roots in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        result_code,result_msg,*result_data = face.count_roots('tax')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_roots in taxonomy "tax" failed: taxonomy "tax" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :count_folksonomies do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1','f5')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #a1>b1>[c1>d1,c2],f1,f2,f3')
    face.add_taxonomy('tax2')
    describe 'count succeeds' do
      describe 'folksonomies found' do
        result_code,result_msg,*result_data = face.count_folksonomies('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([4]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_folksonomies('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'count fails' do
      describe 'taxonomy unspecified - empty' do
        result_code,result_msg,*result_data = face.count_folksonomies('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_folksonomies in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy unspecified - nil' do
        result_code,result_msg,*result_data = face.count_folksonomies(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_folksonomies in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        result_code,result_msg,*result_data = face.count_folksonomies('tax')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_folksonomies in taxonomy "tax" failed: taxonomy "tax" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
  describe :list_tags do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1','f5')
    face.add_tags('tax1','f7')
    face.rename_tag('tax1','f7','fn7')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #a1>b1>[c1>d1,c2],f1,f2,f3')
    face.add_item('tax1','alm1','itm2\ncontent2 #a1>[b1>c3,b2>c4]')
    face.add_item('tax1','alm1','itm3\ncontent3 #f3')  # duplicate item dependent tag: delete itm3 keep f3
    face.add_item('tax1','alm1','itm4\ncontent4 #f4')  # only item dependent tag: delete itm4 delete f4
    face.add_item('tax1','alm1','itm5\ncontent5 #f5')  # item independent tag pre defined: delete itm5 keep f5
    face.add_item('tax1','alm1','itm6\ncontent6 #f6')  # item independent tag post defined: delete itm6 keep f6
    face.add_item('tax1','alm1','itm7\ncontent7 #fn7') # item independent tag pre defined & renamed: delete itm7 keep fn7
    face.add_item('tax1','alm1','itm8\ncontent8 #f8')  # item independent tag post defined & renamed: delete itm8 keep fn8
    face.add_tags('tax1','f6,f8')
    face.rename_tag('tax1','f8','fn8')
    face.delete_items('tax1','alm1','itm5,itm6,itm7,itm8')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_item('tax2','alm1','itm1\ncontent1 #c1>d1,f3')
    face.add_taxonomy('tax3')
    describe 'list succeeds' do
      describe 'taxonomy, tag specified' do
        describe '1 found' do
          result_code,result_msg,*result_data = face.list_tags('tax1','b1')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('1 tag found with name "b1" in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq(['b1']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_tags('tax1','b3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no tags found with name "b3" in taxonomy "tax1"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy specified with[out] reverse|details' do
        describe '3 found' do
          result_code,result_msg,*result_data = face.list_tags('tax2')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 tags found in taxonomy "tax2"') end
          it "result data" do expect(result_data).to eq(['c1','d1','f3']) end
        end
        describe '3 found reversed' do
          result_code,result_msg,*result_data = face.list_tags('tax2',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 tags found in taxonomy "tax2"') end
          it "result data" do expect(result_data).to eq(['f3','d1','c1']) end
        end
        describe '3 found with details' do
          result_code,result_msg,*result_data = face.list_tags('tax2',nil,false,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 tags found in taxonomy "tax2"') end
          # items are only tagged by leaves and folksonomies
          it "result data" do expect(result_data).to eq(['tag "c1" of type "root"       in taxonomy "tax2" tags 1 items and is item dependent','     d1           leaf                     tax2       1                   dependent','     f3           folksonomy               tax2       1                   dependent']) end
        end
        describe '3 found reversed with details' do
          result_code,result_msg,*result_data = face.list_tags('tax2',nil,true,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('3 tags found in taxonomy "tax2"') end
          it "result data" do expect(result_data).to eq(['tag "f3" of type "folksonomy" in taxonomy "tax2" tags 1 items and is item dependent','     d1           leaf                     tax2       1                   dependent','     c1           root                     tax2       1                   dependent']) end
        end
      end
      describe 'tag specified, details' do
        describe '2 found' do
          result_code,result_msg,*result_data = face.list_tags(nil,'c1',nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('2 tags found with name "c1"') end
          it "result data" do expect(result_data).to eq(['tag "c1" of type "branch" in taxonomy "tax1" tags 1 items and is item dependent','     c1           root                 tax2       1                   dependent']) end
        end
        describe 'none found' do
          result_code,result_msg,*result_data = face.list_tags(nil,'a3')
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('no tags found with name "a3"') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'nothing specified, list paginates, various deletions and renames also tested' do
        describe '19 found, details' do
          result_code,result_msg,*result_data = face.list_tags(nil,nil,nil,true)
          it "result_code" do expect(result_code).to eq(0) end
          it "result message" do expect(result_msg).to eq('19 tags found') end
          it "result data" do expect(result_data).to eq(['tag "a1"  of type "root"       in taxonomy "tax1" tags 2 items and is item dependent  ',\
                                                         '     b1            branch                   tax1       2                   dependent  ',\
                                                         '     b2            branch                   tax1       1                   dependent  ',\
                                                         '     c1            branch                   tax1       1                   dependent  ',\
                                                         '     c1            root                     tax2       1                   dependent  ',\
                                                         '     c2            leaf                     tax1       1                   dependent  ',\
                                                         '     c3            leaf                     tax1       1                   dependent  ',\
                                                         '     c4            leaf                     tax1       1                   dependent  ',\
                                                         '     d1            leaf                     tax1       1                   dependent  ',\
                                                         '     d1            leaf                     tax2       1                   dependent  ',\
                                                         'tag "f1"  of type "folksonomy" in taxonomy "tax1" tags 1 items and is item dependent  ',\
                                                         '     f2            folksonomy               tax1       1                   dependent  ',\
                                                         '     f3            folksonomy               tax1       2                   dependent  ',\
                                                         '     f3            folksonomy               tax2       1                   dependent  ',\
                                                         '     f4            folksonomy               tax1       1                   dependent  ',\
                                                         '     f5            folksonomy               tax1       0                   independent',\
                                                         '     f6            folksonomy               tax1       0                   independent',\
                                                         '     fn7           folksonomy               tax1       0                   independent',\
                                                         '     fn8           folksonomy               tax1       0                   independent']) end
        end
      end
    end
    describe 'list fails' do
      describe 'taxonomy unspecified' do
        result_code,result_msg,*result_data = face.list_tags('','a1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_tags with name "a1" in taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found, various error location msgs' do
        describe 'taxonomy, tag specified' do
          result_code,result_msg,*result_data = face.list_tags('tax5','a1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_tags with name "a1" in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy specified' do
          result_code,result_msg,*result_data = face.list_tags('tax5')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_tags in taxonomy "tax5" failed: taxonomy "tax5" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'tag unspecified' do
        result_code,result_msg,*result_data = face.list_tags('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_tags with name "" in taxonomy "tax1" failed: tag unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        describe 'album specified' do
          result_code,result_msg,*result_data = face.list_tags(nil,'a1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_tags with name "a1" failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'nothing specified' do
          result_code,result_msg,*result_data = face.list_tags
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('list_tags failed: no taxonomies found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
    end
  end
  describe :list_structure do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_tags('tax1','f5')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #a1>b1>[c1>d1,c2],f1,f2,f3')
    face.add_taxonomy('tax2')
    describe 'structure succeeds' do
      describe 'found' do
        result_code,result_msg,*result_data = face.list_structure('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("1 hierarchy found containing 5 tags and 4 links\n4 folksonomy tags found\n9 tags found in total for taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq(["a1\n", "   b1\n", "      c1\n", "         d1\n", "      c2\n", "f1", "f2", "f3", "f5"]) end
      end
      describe 'found, reversed' do
        result_code,result_msg,*result_data = face.list_structure('tax1',true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("1 hierarchy found containing 5 tags and 4 links\n4 folksonomy tags found\n9 tags found in total for taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq(["a1\n", "   b1\n", "      c2\n", "      c1\n", "         d1\n", "f5", "f3", "f2", "f1"]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_structure('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no tags found for taxonomy "tax2"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'structure fails' do
      describe 'taxonomy unspecified - empty' do
        result_code,result_msg,*result_data = face.list_structure('')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_structure for taxonomy "" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy unspecified - nil' do
        result_code,result_msg,*result_data = face.list_structure(nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_structure for taxonomy "nil:NilClass" failed: taxonomy unspecified') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy not found' do
        result_code,result_msg,*result_data = face.list_structure('tax5')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_structure for taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'no taxonomies found, various locations for error msg' do
        Tagm8Db.wipe
        face = Facade.instance
        result_code,result_msg,*result_data = face.list_structure('tax1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_structure for taxonomy "tax1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
end



