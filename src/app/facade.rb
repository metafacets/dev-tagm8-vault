#!/bin/env jruby
require_relative 'tag'
require 'singleton'

class Facade
  attr_accessor :taxonomy, :album
  include Singleton

  def name_ok?(name) name =~ /^[A-Za-z0-9_]+$/ end

  def grammar(msg)
    # convert nouns from plural to singular form excluding 'n of m' groups
    # hyphonate adjectives to nouns eg. 5 folksonomy_tags
    msg.gsub!(/((?<!\sof\s|[1-9])1\s)([a-zA-Z"][a-z_"]+)(ies)(\b)/,'\1\2y\4')
    msg.gsub!(/((?<!\sof\s|[1-9])1\s)([a-zA-Z"][a-z_"]+)(s)(\b)/,'\1\2\4')
    msg.gsub!(/(.*)(_)(.*)/,'\1 \3')
    # convert 0 to no excluding 'n of m' groups
    msg.gsub!(/((?<!\sof\s|[1-9])0\s(?!of\s))([a-zA-Z][a-z]+\b)/,'no \2')
    msg
  end

  def wipe
    begin
      Tagm8Db.wipe
      [0,'database wiped']
    rescue => e
      [1,"wipe failed: #{e}"]
    end
  end

  def add_taxonomy(taxonomy_name,dag='prevent')
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "\"#{taxonomy_name}\" taken" if Taxonomy.exists?(taxonomy_name)
      raise "\"#{taxonomy_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(taxonomy_name)
      raise "dag \"#{dag}\" invalid - use prevent, fix or free" unless ['prevent','fix','free'].include?(dag)
      tax = Taxonomy.new(taxonomy_name,dag)
      raise "taxonomy \"#{taxonomy_name}\" remains non-existent" unless Taxonomy.exists?(taxonomy_name)
      raise 'taxonomy added, but dag not set' unless tax.dag == dag
      [0,"Taxonomy \"#{taxonomy_name}\" added"]
    rescue => e
      [1,"add_taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_taxonomies(taxonomy_list,details=false)
    begin
      taxonomy_list = 'nil:NilClass' if taxonomy_list.nil?
      raise 'taxonomy list missing' if taxonomy_list.empty? || taxonomy_list == 'nil:NilClass'
      list = taxonomy_list.gsub(/\s/,'').split(',')
      found = list&Taxonomy.list
      raise 'no listed taxonomies found' if found.empty?
      Taxonomy.delete_taxonomies(found)
      deleted = found-Taxonomy.list
      details_msg = ''
      unless deleted.empty?
        deleted.each{|name| details_msg += "taxonomy \"#{name}\" deleted\n"} if details
        found.size == deleted.size ? d_insert = ' and' : d_insert = ", #{deleted}"
      else
        d_insert = ' but none'
      end
      msg = grammar("#{found.size} of #{list.size} taxonomies \"#{taxonomy_list}\" found#{d_insert} deleted")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"delete_taxonomies \"#{taxonomy_list}\" failed: #{e}"]
    end
  end

  def rename_taxonomy(taxonomy_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise 'taxonomy rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'rename unchanged' if taxonomy_name == new_name
      raise "\"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "\"#{new_name}\" taken" if Taxonomy.exists?(new_name)
      raise "\"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      tax.rename(new_name)
      raise "name is \"#{tax.name}\"" unless tax.name == new_name
      [0,"Taxonomy \"#{taxonomy_name}\" renamed to \"#{new_name}\""]
    rescue => e
      [1,"rename_taxonomy \"#{taxonomy_name}\" to \"#{new_name}\" failed: #{e}"]
    end
  end

  def count_taxonomies(taxonomy_name=nil)
    begin
      what = ''
      what += " with name \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'taxonomy unspecified' if !taxonomy_name.nil? && taxonomy_name.empty?
      [0,'',Taxonomy.count_by_name(taxonomy_name)]
    rescue => e
      [1,"count_taxonomies#{what} failed: #{e}"]
    end
  end

  def list_taxonomies(taxonomy_name=nil,reverse=false,details=false)
    begin
      what = ''
      what += " with name \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'taxonomy unspecified' if !taxonomy_name.nil? && taxonomy_name.empty?
      res = Taxonomy.list(taxonomy_name).sort
      res_count = res.size
      unless res.empty?
        res.reverse! if reverse && taxonomy_name.nil?
        if details
          extras,tax_name_length,tax_dag_length,tag_count_length,root_count_length,folk_count_length,link_count_length,alm_count_length = [],res.max_by(&:length).size,0,0,0,0,0,0
          res.each_with_index do |tax_name,i|
            tax = Taxonomy.get_by_name(tax_name)
            tax_dag,tag_count,root_count,folk_count,link_count,alm_count = tax.dag,tax.count_tags,tax.count_roots,tax.count_folksonomies,tax.count_links,tax.count_albums
            extras[i] = [tax_name,tax_dag,tag_count,root_count,folk_count,link_count,alm_count]
            tax_dag_length    = tax_dag.size    if tax_dag.size    > tax_dag_length
            tag_count_length  = tag_count/10+1  if tag_count/10+1  > tag_count_length
            root_count_length = root_count/10+1 if root_count/10+1 > root_count_length
            folk_count_length = folk_count/10+1 if folk_count/10+1 > folk_count_length
            link_count_length = link_count/10+1 if link_count/10+1 > link_count_length
            alm_count_length  = alm_count/10+1  if alm_count/10+1  > alm_count_length
          end
          res = []
          extras.each_with_index do |extra,i|
            if i%10 > 0
              res[i] = "          %-#{tax_name_length}s       %-#{tax_dag_length}s     %#{tag_count_length}s       %#{root_count_length}s        %#{folk_count_length}s        %#{link_count_length}s           %#{alm_count_length}s        " % [extra[0],extra[1],extra[2],extra[3],extra[4],extra[5],extra[6]]
            else
              res[i] = "taxonomy %-#{tax_name_length+2}s DAG: %-#{tax_dag_length}s has %#{tag_count_length}s tags, %#{root_count_length}s roots, %#{folk_count_length}s folks, %#{link_count_length}s links and %#{alm_count_length}s albums" % ["\"#{extra[0]}\"",extra[1],extra[2],extra[3],extra[4],extra[5],extra[6]]
            end
          end
        end
      end
      [0,grammar("#{res_count} taxonomies found#{what}")] + res
    rescue => e
      [1,"list_taxonomies#{what} failed: #{e}"]
    end
  end

  def has_taxonomy?(name)
    [0,'',Taxonomy.exists?(name)]
  end

  def dag?(taxonomy_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.lazy(taxonomy_name).dag]
    rescue => e
      [1,"dag? for taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def dag_set(taxonomy_name,dag)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      dag = 'nil:NilClass' if dag.nil?
      raise "dag \"#{dag}\" invalid, use \"prevent\", \"fix\" or \"false\"" unless ['prevent','fix','false'].include?(dag)
      tax = Taxonomy.lazy(taxonomy_name)
      tax.set_dag(dag)
      confirmed = tax.dag
      raise "dag = #{confirmed}" if confirmed != dag
      [0,"Taxonomy \"#{taxonomy_name}\" dag set to \"#{dag}\""]
    rescue => e
      [1,"dag_#{dag} for taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def add_tags(taxonomy_name,tag_syntax,details=false)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      tag_syntax = 'nil:NilClass' if tag_syntax.nil?
      raise 'tags unspecified' if tag_syntax.empty? || tag_syntax == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      tags_before = tax.list_tags
      links_before = tax.count_links
      tax.instantiate(tag_syntax,false)
      tax = Taxonomy.get_by_name(taxonomy_name) # refresh tax after instantiate
      tags_added = (tax.list_tags-tags_before).sort
      details_msg = ''
      tags_added.each{|name| details_msg += "tag \"#{name}\" added\n"} if details
      links_added = tax.count_links-links_before
      msg = grammar("#{tags_added.size} tags and #{links_added} links added to taxonomy \"#{taxonomy_name}\"")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"add_tags \"#{tag_syntax}\" to taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_tags(taxonomy_name,tag_syntax,branch=false,details=false)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      tag_syntax = 'nil:NilClass' if tag_syntax.nil?
      raise 'tag syntax missing' if tag_syntax.empty? || tag_syntax == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      supplied,found,deleted,deleted_list = tax.exstantiate(tag_syntax,branch,true)
      raise 'no supplied tags found' if found < 1
      details_msg = ''
      deleted_list.each{|tag| details_msg += "tag \"#{tag}\" deleted\n"} if details
      found == deleted ? insert = ' and' : insert = ", #{deleted}"
      [0,"#{details_msg}#{found} of #{supplied} supplied tags found#{insert} deleted from taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"delete_tags \"#{tag_syntax}\" from taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def rename_tag(taxonomy_name,tag_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      tag_name = 'nil:NilClass' if tag_name.nil?
      raise 'tag unspecified' if tag_name.empty? || tag_name == 'nil:NilClass'
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'tag rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'tag rename unchanged' if tag_name == new_name
      raise "tag \"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "tag \"#{tag_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_tag?(tag_name)
      raise "tag \"#{new_name}\" taken by taxonomy \"#{taxonomy_name}\"" if tax.has_tag?(new_name)
      tag = tax.get_tag_by_name(tag_name)
      tag.rename(new_name)
      raise "name is \"#{tag.name}\"" unless tag.name == new_name
      [0,"Tag renamed from \"#{tag_name}\" to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"rename_tag \"#{tag_name}\" to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def count_tags(taxonomy_name=nil,tag_name=nil)
    begin
      what = ''
      what += " with name \"#{tag_name}\"" unless tag_name.nil?
      what += " in taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'tag unspecified' if !tag_name.nil? && tag_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        res = Tag.count_by_name(tag_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        res = Taxonomy.get_by_name(taxonomy_name).count_tags(tag_name)
      end
      [0,'',res]
    rescue => e
      [1,"count_tags#{what} failed: #{e}"]
    end
  end

  def count_links(taxonomy_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.get_by_name(taxonomy_name).count_links]
    rescue => e
      [1,"count_links in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def count_roots(taxonomy_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.get_by_name(taxonomy_name).count_roots]
    rescue => e
      [1,"count_roots in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def count_folksonomies(taxonomy_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.get_by_name(taxonomy_name).count_folksonomies]
    rescue => e
      [1,"count_folksonomies in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def list_tags(taxonomy_name=nil,tag_name=nil,reverse=false,details=false)
    begin
      what = ''
      what += " with name \"#{tag_name}\"" unless tag_name.nil?
      what += " in taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'tag unspecified' if !tag_name.nil? && tag_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        tags = Tag.get_by_name(tag_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        tags = []
        if tag_name.nil?
          tags = tax.tags
        else
          tag = tax.get_tag_by_name(tag_name)
          tags += [tag] unless tag.nil?
        end
      end
      res = tags.map{|tag| [tag.name,tag]}
      res_count = res.size
      unless res.empty?
        if tag_name.nil?
          res.sort_by!(&:first)
          res.reverse! if reverse
        end
        if details
          extras,tag_name_max_size,tag_type_max_size,tax_name_max_size,itm_count_max_size,itm_dep_max_size,i = [],0,0,0,0,0,0
          res.each do |tag_name,tag|
            if tag.is_root
              tag_type = 'root'
            elsif tag.is_folk
              tag_type = 'folksonomy'
            elsif tag.has_child?
              tag_type = 'branch'
            else
              tag_type = 'leaf'
            end
            tag.item_dependent ? itm_dep = 'dependent' : itm_dep = 'independent'
            tax_name,itm_count = tag.get_taxonomy.name,tag.items.size
            extras[i] = [tag_name,tag_type,tax_name,itm_count,itm_dep]
            tag_name_max_size = tag_name.size if tag_name.size > tag_name_max_size
            tag_type_max_size = tag_type.size if tag_type.size > tag_type_max_size
            tax_name_max_size = tax_name.size if tax_name.size > tax_name_max_size
            itm_count_max_size = itm_count/10+1 if itm_count/10+1 > itm_count_max_size
            itm_dep_max_size = itm_dep.size if itm_dep.size > itm_dep_max_size
            i += 1
          end
          res = []
          extras.each_with_index do |extra,i|
            if i%10 == 0
              res[i] = "tag %-#{tag_name_max_size+2}s of type %-#{tag_type_max_size+2}s in taxonomy %-#{tax_name_max_size+2}s tags %#{itm_count_max_size}s items and is item %-#{itm_dep_max_size}s" % ["\"#{extra[0]}\"","\"#{extra[1]}\"","\"#{extra[2]}\"",extra[3],extra[4]]
            else
              res[i] = "     %-#{tag_name_max_size}s           %-#{tag_type_max_size}s               %-#{tax_name_max_size}s       %#{itm_count_max_size}s                   %-#{itm_dep_max_size}s" % [extra[0],extra[1],extra[2],extra[3],extra[4]]
            end
          end
        else
          res.map!{|row| row[0]}
        end
      end
      [0,grammar("#{res_count} tags found#{what}")]+res
    rescue => e
      [1,"list_tags#{what} failed: #{e}"]
    end
  end

  def list_structure(taxonomy_name,reverse=false)
    begin
      show_nested = lambda{|taxonomy,tag_name,reverse,depth=0|
        indent = '   '*depth if depth > 0
        tree = ["#{indent}#{tag_name}\n"]
        list_children = taxonomy.get_tag_by_name(tag_name).get_children.map{|child| child.name}.sort
        list_children.reverse! if reverse
        list_children.each{|child_name| tree += show_nested.call(taxonomy,child_name,reverse,depth+1)}
        tree
      }
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise 'no taxonomies found' unless Taxonomy.exists?
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      res = []
      unless tax.empty?
        tags_count = tax.count_tags
        roots_count = tax.count_roots
        folks_count = tax.count_folksonomies
        if roots_count > 0
          roots = tax.roots.map{|tag| tag.name}.sort!
          roots.reverse! if reverse
          roots.each{|root_name| res += show_nested.call(tax,root_name,reverse)}
          msg = "#{roots_count} hierarchies found containing #{tags_count-folks_count} tags and #{tax.count_links} links\n"
        else
          msg = "no tag hierarchies found\n"
        end
        if folks_count > 0
          folks = tax.folksonomies.map{|tag| tag.name}.sort!
          folks.reverse! if reverse
          res += folks
          msg += "#{folks_count} folksonomy_tags found\n"
        else
          msg += "no folksonomy_tags found\n"
        end
        msg += "#{tags_count} tags found in total"
      else
        msg = 'no tags found'
      end
      [0,"#{grammar(msg)} for taxonomy \"#{taxonomy_name}\""] + res
    rescue => e
      [1,"list_structure for taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def list_genealogy(genealogy,taxonomy_name,list,reverse=false)
    # supports list_ancestors and list_descendents
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.lazy(taxonomy_name)
      list = list.gsub(/\s/,'').split(',')
      list.size > 1 ? common = 'common_' : common = ''
      bad = list.select{|name| name unless tax.has_tag?(name)}
      unless bad.empty?
        bad.size > 1 ? insert = 's' : insert = ''
        raise "Tag#{insert} \"#{bad.join(', ')}\" not found"
      end
      # get [[tag1_relatives],..[tagn_relatives]]
      relatives = list.map{|name| tax.get_lazy_tag(name).send("get_#{genealogy}")}
      # get [[tag1_relatives]&[..]&[tagn_relatives]]
      relatives = relatives.inject(:&)
      # get [common_relative_names]
      res = relatives.map{|relative| relative.name}.sort!
      res.reverse! if reverse
      [0,grammar("#{res.size} #{common}#{genealogy} found")] + res
    rescue => e
      [1,"list_#{genealogy} failed: #{e}"]
    end
  end

  def add_album(taxonomy_name,album_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" taken by taxonomy \"#{taxonomy_name}\"" if tax.has_album?(album_name)
      raise "album \"#{album_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(album_name)
      tax.add_album(album_name)
      raise "album \"#{album_name}\" remains non-existent" unless Album.exists?(album_name)
#      raise "album \"#{album_name}\" created but not added to taxonomy #{taxonomy_name}" unless tax.has_album?(album_name)
      [0,"Album \"#{album_name}\" added to taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"add_album \"#{album_name}\" to taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_albums(taxonomy_name,album_list,details=false)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_list = 'nil:NilClass' if album_list.nil?
      raise 'album list missing' if album_list.empty? || album_list == 'nil:NilClass'
      list = album_list.gsub(/\s/,'').split(',')
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      found = tax.list_albums&list
      raise 'no listed albums found' if found.empty?
      tax.delete_albums(found)
      tax = Taxonomy.get_by_name(taxonomy_name) # refresh tax after delete_albums
      deleted = found-tax.list_albums
      details_msg = ''
      unless deleted.empty?
        deleted.each{|name| details_msg += "album \"#{name}\" deleted\n"} if details
        found.size == deleted.size ? d_insert = ' and' : d_insert = ", #{deleted}"
      else
        d_insert = ' but none'
      end
      msg = grammar("#{found.size} of #{list.size} albums \"#{album_list}\" found#{d_insert} deleted from taxonomy \"#{taxonomy_name}\"")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"delete_albums \"#{album_list}\" from taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def rename_album(taxonomy_name,album_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'album rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'album rename unchanged' if album_name == new_name
      raise "album \"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      raise "album \"#{new_name}\" taken by taxonomy \"#{taxonomy_name}\"" if tax.has_album?(new_name)
      renamed = Album.count_by_name(new_name)
      tax.get_album_by_name(album_name).rename(new_name)
      renamed = Album.count_by_name(new_name) - renamed
      raise "no albums renamed to \"#{new_name}\"" if renamed == 0
      [0,"Album renamed from \"#{album_name}\" to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"rename_album \"#{album_name}\" to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def count_albums(taxonomy_name=nil,album_name=nil)
    begin
      what = ''
      what += " with name \"#{album_name}\"" unless album_name.nil?
      what += " in taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        res = Album.count_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        res = Taxonomy.get_by_name(taxonomy_name).count_albums(album_name)
      end
      [0,'',res]
    rescue => e
      [1,"count_albums#{what} failed: #{e}"]
    end
  end

  def list_albums(taxonomy_name=nil,album_name=nil,reverse=false,details=false,fullnames='no')
    begin
      what = ''
      what += " with name \"#{album_name}\"" unless album_name.nil?
      what += " in taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        albums = Album.get_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        albums = []
        if album_name.nil?
          albums = tax.albums
        else
          album = tax.get_album_by_name(album_name)
          albums += [album] unless album.nil?
        end
      end
      fullnames = 'no' if fullnames.nil?
      raise "fullnames \"#{fullnames}\" invalid - use 'no', 'topdown' or 'bottomup' only" unless ['no','topdown','bottomup'].include?(fullnames)
      res = albums.map{|album| fullnames == 'topdown' ? ["#{album.taxonomy.name}.#{album.name}",album.name,album] : ["#{album.name}.#{album.taxonomy.name}",album.name,album]}
      res_count = res.size
      unless res.empty?
        if album_name.nil?
          res.sort_by!(&:first)
          res.reverse! if reverse
        end
        if details
          extras,fullname_max_size,alm_name_max_size,tax_name_max_size,itm_count_max_size,i = [],0,0,0,0,0
          res.each do |fullname,alm_name,album|
            itm_count = album.items.size
            itm_count_max_size = itm_count/10+1 if itm_count/10+1 > itm_count_max_size
            if fullnames != 'no'
              extras[i] = [fullname,itm_count]
              fullname_max_size = fullname.size if fullname.size > fullname_max_size
            else
              tax_name = album.taxonomy.name
              extras[i] = [alm_name,tax_name,itm_count]
              alm_name_max_size = alm_name.size if alm_name.size > alm_name_max_size
              tax_name_max_size = tax_name.size if tax_name.size > tax_name_max_size
            end
            i += 1
          end
          res = []
          extras.each_with_index do |extra,i|
            if i%10 == 0
              if fullnames != 'no'
                res[i] = "%-#{fullname_max_size}s has %#{itm_count_max_size}s items" % [extra[0],extra[1]]
              else
                res[i] = "album %-#{alm_name_max_size+2}s in taxonomy %-#{tax_name_max_size+2}s has %#{itm_count_max_size}s items" % ["\"#{extra[0]}\"","\"#{extra[1]}\"",extra[2]]
              end
            else
              if fullnames != 'no'
                res[i] = "%-#{fullname_max_size}s     %#{itm_count_max_size}s      " % [extra[0],extra[1]]
              else
                res[i] = "       %-#{alm_name_max_size}s               %-#{tax_name_max_size}s      %#{itm_count_max_size}s      " % [extra[0],extra[1],extra[2]]
              end
            end
          end
        else
          res.map!{|row| fullnames != 'no' ? row[0] : row[1]}
        end
      end
      [0,grammar("#{res_count} albums found#{what}")]+res
    rescue => e
      [1,"list_albums#{what} failed: #{e}"]
    end
  end

  def add_item(taxonomy_name,album_name,item)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      item = 'nil:NilClass' if item.nil?
      raise 'item unspecified' if item.empty? || item == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      album = tax.get_album_by_name(album_name)
      item_name,*rest = item.split('\n')
      item_name.strip!
      raise "item \"#{item_name}\" taken by album \"#{album_name}\" in taxonomy \"#{taxonomy_name}\"" if album.has_item?(item_name)
      raise "item \"#{item_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(item_name)
      items_added = Item.count
      item = album.add_item("#{item_name}\n#{rest.join("\n")}")
      items_added = Item.count - items_added
      raise 'No items were added' if items_added == 0
      [0,"Item \"#{item.name}\" added to album \"#{album_name}\" in taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"add_item to album \"#{album_name}\" in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_items(taxonomy_name,album_name,item_list,details=false)
    # details could report on item_dependent tags that are deleted
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      item_list = 'nil:NilClass' if item_list.nil?
      raise 'item list missing' if item_list.empty? || item_list == 'nil:NilClass'
      list = item_list.gsub(/\s/,'').split(',')
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      album = tax.get_album_by_name(album_name)
      found = album.list_items&list
      raise 'no listed items found' if found.empty?
      album.delete_items(found)
      deleted = found-album.list_items
      details_msg = ''
      unless deleted.empty?
        deleted.each{|name| details_msg += "item \"#{name}\" deleted\n"} if details
        found.size == deleted.size ? d_insert = ' and' : d_insert = ", #{deleted}"
      else
        d_insert = ' but none'
      end
      msg = grammar("#{found.size} of #{list.size} items \"#{item_list}\" found#{d_insert} deleted from album \"#{album_name}\" of taxonomy \"#{taxonomy_name}\"")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"delete_items \"#{item_list}\" from album \"#{album_name}\" of taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def rename_item(taxonomy_name,album_name,item_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      album_name = 'nil:NilClass' if album_name.nil?
      location = "album \"#{album_name}\" of taxonomy \"#{taxonomy_name}\""
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      item_name = 'nil:NilClass' if item_name.nil?
      raise 'item unspecified' if item_name.empty? || item_name == 'nil:NilClass'
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'item rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'item rename unchanged' if item_name == new_name
      raise "item \"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      album = tax.get_album_by_name(album_name)
      raise "item \"#{item_name}\" not found in #{location}" unless album.has_item?(item_name)
      raise "item \"#{new_name}\" name taken by #{location}" if album.has_item?(new_name)
      item = album.get_item_by_name(item_name)
      item.rename(new_name)
      raise "name is \"#{item.name}\"" unless item.name == new_name
      [0,"Item renamed from \"#{item_name}\" to \"#{new_name}\" in #{location}"]
    rescue => e
      [1,"rename_item \"#{item_name}\" to \"#{new_name}\" in #{location} failed: #{e}"]
    end
  end

  def count_items(taxonomy_name=nil,album_name=nil,item_name=nil)
    begin
      what = ''
      what += " with name \"#{item_name}\"" unless item_name.nil?
      what += " in album \"#{album_name}\"" unless album_name.nil?
      what += " of taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      raise 'item unspecified' if !item_name.nil? && item_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        unless Album.exists?(album_name)
          raise 'no albums found' if album_name.nil?
          raise "album \"#{album_name}\" not found"
        end
        albums = Album.get_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        unless tax.has_album?(album_name)
          album_name.nil? ? msg = 'no albums' : msg = "album \"#{album_name}\" not"
          raise "#{msg} found in taxonomy \"#{taxonomy_name}\""
        end
        album_name.nil? ? albums = tax.albums : albums = [tax.get_album_by_name(album_name)]
      end
      res = albums.map{|album| album.count_items(item_name)}.inject(:+)
      [0,'',res]
    rescue => e
      [1,"count_items#{what} failed: #{e}"]
    end
  end

  def list_items(taxonomy_name=nil,album_name=nil,item_name=nil,reverse=false,details=false,content=false,fullnames='no')
    begin
      what = ''
      what += " with name \"#{item_name}\"" unless item_name.nil?
      what += " in album \"#{album_name}\"" unless album_name.nil?
      what += " of taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      raise 'item unspecified' if !item_name.nil? && item_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        unless Album.exists?(album_name)
          raise 'no albums found' if album_name.nil?
          raise "album \"#{album_name}\" not found"
        end
        albums = Album.get_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        unless tax.has_album?(album_name)
          album_name.nil? ? msg = 'no albums' : msg = "album \"#{album_name}\" not"
          raise "#{msg} found in taxonomy \"#{taxonomy_name}\""
        end
        album_name.nil? ? albums = tax.albums : albums = [tax.get_album_by_name(album_name)]
      end
      fullnames = 'no' if fullnames.nil?
      raise "fullnames \"#{fullnames}\" invalid - use 'no', 'topdown' or 'bottomup' only" unless ['no','topdown','bottomup'].include?(fullnames)
      res = []
      albums.each do |album|
        if album.has_item?(item_name)
          item_name.nil? ? res += album.items : res += [album.get_item_by_name(item_name)]
        end
      end
      res_count = res.size
      unless res.empty?
        res.map!{|item| fullnames == 'topdown' ? ["#{item.album.taxonomy.name}.#{item.album.name}.#{item.name}",item.name,item] : ["#{item.name}.#{item.album.name}.#{item.album.taxonomy.name}",item.name,item]}
        if item_name.nil?
          res.sort_by!(&:first)
          res.reverse! if reverse
        end
        if details || content
          extras,fullname_max_size,itm_name_max_size,tax_name_max_size,alm_name_max_size,tag_count_max_size,i = [],0,0,0,0,0,0
          res.each do |fullname,itm_name,item|
            tag_count = item.tags.size
            tag_count_max_size = tag_count/10+1 if tag_count/10+1 > tag_count_max_size
            if fullnames != 'no'
              extras[i] = [item,fullname,tag_count]
              fullname_max_size = fullname.size if fullname.size > fullname_max_size
            else
              alm_name,tax_name = item.album.name,item.album.taxonomy.name
              extras[i] = [item,itm_name,alm_name,tax_name,tag_count]
              itm_name_max_size = itm_name.size if itm_name.size > itm_name_max_size
              alm_name_max_size = alm_name.size if alm_name.size > alm_name_max_size
              tax_name_max_size = tax_name.size if tax_name.size > tax_name_max_size
            end
            i += 1
          end
          res = []
          extras.each_with_index do |extra,i|
            if i%10 == 0 || content
              if details
                if fullnames != 'no'
                  res[i] = "%-#{fullname_max_size}s has %#{tag_count_max_size}s tags" % [extra[1],extra[2]]
                else
                  res[i] = "item %-#{itm_name_max_size+2}s in album %-#{alm_name_max_size+2}s of taxonomy %-#{tax_name_max_size+2}s has %#{tag_count_max_size}s tags" % ["\"#{extra[1]}\"","\"#{extra[2]}\"","\"#{extra[3]}\"",extra[4]]
                end
                res[i] += ":\n" if content
              else
                res[i] = extra[1]
              end
              res[i] += "\n#{extra[0].get_content}\n\n" if content
            else
              if fullnames != 'no'
                res[i] = "%-#{fullname_max_size}s     %#{tag_count_max_size}s     " % [extra[1],extra[2]]
              else
                res[i] = "      %-#{itm_name_max_size}s            %-#{alm_name_max_size}s               %-#{tax_name_max_size}s      %#{tag_count_max_size}s     " % [extra[1],extra[2],extra[3],extra[4]]
              end
            end
          end
        else
          res.map!{|row| fullnames != 'no' ? row[0] : row[1]}
        end
      end
      [0,grammar("#{res_count} items found#{what}")]+res
    rescue => e
      [1,"list_items#{what} failed: #{e}"]
    end
  end

  def query_items(taxonomy_name=nil,album_name=nil,query=nil,reverse=false,details=false,content=false,fullnames='no')
    begin
      query = 'nil:NilClass' if query.nil?
      what = ''
      what += " \"#{query}\""
      what += " in album \"#{album_name}\"" unless album_name.nil?
      what += " of taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      raise 'query missing' if query == 'nil:NilClass' || query.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        unless Album.exists?(album_name)
          raise 'no albums found' if album_name.nil?
          raise "album \"#{album_name}\" not found"
        end
        albums = Album.get_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        unless tax.has_album?(album_name)
          album_name.nil? ? msg = 'no albums' : msg = "album \"#{album_name}\" not"
          raise "#{msg} found in taxonomy \"#{taxonomy_name}\""
        end
        album_name.nil? ? albums = tax.albums : albums = [tax.get_album_by_name(album_name)]
      end
      fullnames = 'no' if fullnames.nil?
      raise "fullnames \"#{fullnames}\" invalid - use 'no', 'topdown' or 'bottomup' only" unless ['no','topdown','bottomup'].include?(fullnames)
      res = []
      albums.each {|album| res += album.query_items(query)}
      res_count = res.size
      unless res.empty?
        res.map!{|item| fullnames == 'topdown' ? ["#{item.album.taxonomy.name}.#{item.album.name}.#{item.name}",item.name,item] : ["#{item.name}.#{item.album.name}.#{item.album.taxonomy.name}",item.name,item]}
        res.sort_by!(&:first)
        res.reverse! if reverse
        if details || content
          extras,fullname_max_size,itm_name_max_size,tax_name_max_size,alm_name_max_size,tag_count_max_size,i = [],0,0,0,0,0,0
          res.each do |fullname,itm_name,item|
            tag_count = item.tags.size
            tag_count_max_size = tag_count/10+1 if tag_count/10+1 > tag_count_max_size
            if fullnames != 'no'
              extras[i] = [item,fullname,tag_count]
              fullname_max_size = fullname.size if fullname.size > fullname_max_size
            else
              alm_name,tax_name = item.album.name,item.album.taxonomy.name
              extras[i] = [item,itm_name,alm_name,tax_name,tag_count]
              itm_name_max_size = itm_name.size if itm_name.size > itm_name_max_size
              alm_name_max_size = alm_name.size if alm_name.size > alm_name_max_size
              tax_name_max_size = tax_name.size if tax_name.size > tax_name_max_size
            end
            i += 1
          end
          res = []
          extras.each_with_index do |extra,i|
            if i%10 == 0 || content
              if details
                if fullnames != 'no'
                  res[i] = "%-#{fullname_max_size}s has %#{tag_count_max_size}s tags" % [extra[1],extra[2]]
                else
                  res[i] = "item %-#{itm_name_max_size+2}s in album %-#{alm_name_max_size+2}s of taxonomy %-#{tax_name_max_size+2}s has %#{tag_count_max_size}s tags" % ["\"#{extra[1]}\"","\"#{extra[2]}\"","\"#{extra[3]}\"",extra[4]]
                end
                res[i] += ":\n" if content
              else
                res[i] = extra[1]
              end
              res[i] += "\n#{extra[0].get_content}\n\n" if content
            else
              if fullnames != 'no'
                res[i] = "%-#{fullname_max_size}s     %#{tag_count_max_size}s     " % [extra[1],extra[2]]
              else
                res[i] = "      %-#{itm_name_max_size}s            %-#{alm_name_max_size}s               %-#{tax_name_max_size}s      %#{tag_count_max_size}s     " % [extra[1],extra[2],extra[3],extra[4]]
              end
            end
          end
        else
          res.map!{|row| fullnames != 'no' ? row[0] : row[1]}
        end
      end
      [0,grammar("#{res_count} items found matching#{what}")]+res
    rescue => e
      [1,"query_items matching#{what} failed: #{e}"]
    end
  end
end

#f = Facade.instance
#puts "#{f.grammar('0 of 1 taxonomies found with 5 links and 3 tags in 1 albums and 1 taxonomies and 5 taxonomies and 0 items')}"
#puts "#{f.grammar('0 albums and 1 taxonomies in 0 of 1 taxonomies and 0 items')}"
