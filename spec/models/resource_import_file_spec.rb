# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ResourceImportFile do
  fixtures :all
  use_vcr_cassette "enju_ndl/ndl_search", :record => :new_episodes

  describe "when its mode is 'create'" do
    describe "when it is written in utf-8" do
      before(:each) do
        @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/../../examples/resource_import_file_sample1.tsv")
      end

      it "should be imported" do
        old_manifestations_count = Manifestation.count
        old_items_count = Item.count
        old_patrons_count = Patron.count
        old_import_results_count = ResourceImportResult.count
        @file.import_start.should eq({:manifestation_imported => 9, :item_imported => 6, :manifestation_found => 3, :item_found => 3, :failed => 7})
        manifestation = Item.where(:item_identifier => '11111').first.manifestation
        manifestation.publishers.first.full_name.should eq 'test4'
        manifestation.publishers.first.full_name_transcription.should eq 'てすと4'
        manifestation.publishers.second.full_name_transcription.should eq 'てすと5'
        manifestation.produces.first.produce_type.name.should eq 'publisher'
        manifestation.creates.first.create_type.name.should eq 'author'
        Manifestation.count.should eq old_manifestations_count + 8
        Item.count.should eq old_items_count + 6
        Patron.count.should eq old_patrons_count + 6
        ResourceImportResult.count.should eq old_import_results_count + 17

        manifestation_101 = Manifestation.where(:manifestation_identifier => '101').first
        manifestation_101.series_statement.original_title.should eq '主シリーズ'
        manifestation_101.series_statement.title_transcription.should eq 'しゅしりーず'
        manifestation_101.series_statement.title_subseries.should eq '副シリーズ 1'
        manifestation_101.series_statement.title_subseries_transcription.should eq 'ふくしりーず いち'

        item_10101 = Item.where(:item_identifier => '10101').first
        item_10101.manifestation.creators.size.should eq 2
        item_10101.manifestation.creates.order(:id).first.create_type.name.should eq 'author'
        item_10101.manifestation.creates.order(:id).second.patron.full_name.should eq 'test1'
        item_10101.manifestation.creates.order(:id).second.create_type.name.should eq 'illustrator'
        item_10101.manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        item_10101.budget_type.name.should eq 'Public fund'
        item_10101.bookstore.name.should eq 'Example store'
        Item.where(:item_identifier => '10102').first.manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Item.where(:item_identifier => '10104').first.manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Manifestation.where(:manifestation_identifier => '103').first.original_title.should eq 'ダブル"クォート"を含む資料'
        item = Item.where(:item_identifier => '11111').first
        Shelf.find_by_name('first_shelf').should eq item.shelf
        item.manifestation.price.should eq 1000
        item.price.should eq 0
        item.manifestation.publishers.size.should eq 2

        item_10103 = Item.where(:item_identifier => '10103').first
        item_10103.budget_type.should be_nil
        item_10103.bookstore.name.should eq 'Example store'

        item_10104 = Item.where(:item_identifier => '10104').first
        item_10104.budget_type.name.should eq 'Public fund'
        item_10104.bookstore.should be_nil

        manifestation_104 = Manifestation.where(:manifestation_identifier => '104').first
        manifestation_104.isbn.should eq '9784797327038'
        manifestation_104.original_title.should eq 'test10'
        manifestation_104.creators.collect(&:full_name).should eq ['test3']
        manifestation_104.publishers.collect(&:full_name).should eq ['test4']

        @file.resource_import_fingerprint.should be_true
        @file.executed_at.should be_true
      end
    end

    describe "when it is written in shift_jis" do
      before(:each) do
        @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/../../examples/resource_import_file_sample2.tsv")
      end

      it "should be imported" do
        old_manifestations_count = Manifestation.count
        old_items_count = Item.count
        old_patrons_count = Patron.count
        old_import_results_count = ResourceImportResult.count
        @file.import_start.should eq({:manifestation_imported => 9, :item_imported => 6, :manifestation_found => 3, :item_found => 3, :failed => 7})
        manifestation = Item.where(:item_identifier => '11111').first.manifestation
        manifestation.publishers.first.full_name.should eq 'test4'
        manifestation.publishers.first.full_name_transcription.should eq 'てすと4'
        manifestation.publishers.second.full_name_transcription.should eq 'てすと5'
        Manifestation.count.should eq old_manifestations_count + 8
        Item.count.should eq old_items_count + 6
        Patron.count.should eq old_patrons_count + 6
        ResourceImportResult.count.should eq old_import_results_count + 17
        Item.find_by_item_identifier('10101').manifestation.creators.size.should eq 2
        Item.find_by_item_identifier('10101').manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Item.find_by_item_identifier('10102').manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Item.find_by_item_identifier('10104').manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Manifestation.find_by_manifestation_identifier('103').original_title.should eq 'ダブル"クォート"を含む資料'
        item = Item.find_by_item_identifier('11111')
        Shelf.find_by_name('first_shelf').should eq item.shelf
        item.manifestation.price.should eq 1000
        item.price.should eq 0
        item.manifestation.publishers.size.should eq 2

        @file.resource_import_fingerprint.should be_true
        @file.executed_at.should be_true
      end
    end

    describe "when it has only isbn" do
      before(:each) do
        @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/../../examples/isbn_sample.txt")
      end

      it "should be imported" do
        old_manifestations_count = Manifestation.count
        old_patrons_count = Patron.count
        @file.import_start
        Manifestation.count.should eq old_manifestations_count + 1
        Patron.count.should eq old_patrons_count + 4
      end
    end
  end

  describe "when its mode is 'update'" do
    it "should update items" do
      @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/../../examples/item_update_file.tsv"), :edit_mode => 'update'
      @file.modify
      Item.where(:item_identifier => '00001').first.manifestation.creators.order('patrons.id').collect(&:full_name).should eq ['たなべ', 'こうすけ']
      Item.where(:item_identifier => '00002').first.manifestation.publishers.collect(&:full_name).should eq ['test2']
      Item.where(:item_identifier => '00003').first.manifestation.original_title.should eq 'テスト3'
      Item.where(:item_identifier => '00003').first.acquired_at.should eq Time.zone.parse('2012-01-01')
    end

    it "should update series_statement" do
      manifestation = Manifestation.find(10)
      file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/../../examples/update_series_statement.tsv"), :edit_mode => 'update'
      file.modify
      manifestation.reload
      manifestation.series_statement.should eq SeriesStatement.find(2)
    end
  end

  describe "when its mode is 'destroy'" do
    it "should remove items" do
      old_count = Item.count
      @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/../../examples/item_delete_file.tsv"), :edit_mode => 'destroy'
      @file.remove
      Item.count.should eq old_count - 2
    end
  end
end

# == Schema Information
#
# Table name: resource_import_files
#
#  id                           :integer         not null, primary key
#  parent_id                    :integer
#  content_type                 :string(255)
#  size                         :integer
#  user_id                      :integer
#  note                         :text
#  executed_at                  :datetime
#  state                        :string(255)
#  resource_import_file_name    :string(255)
#  resource_import_content_type :string(255)
#  resource_import_file_size    :integer
#  resource_import_updated_at   :datetime
#  created_at                   :datetime        not null
#  updated_at                   :datetime        not null
#  edit_mode                    :string(255)
#  resource_import_fingerprint  :string(255)
#  error_message                :text
#

