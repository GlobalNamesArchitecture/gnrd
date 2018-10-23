# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protob.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "protob.Pong" do
    optional :value, :string, 1
  end
  add_message "protob.Void" do
  end
  add_message "protob.WithText" do
    optional :value, :bool, 1
  end
  add_message "protob.WithDetails" do
    optional :value, :bool, 1
  end
  add_message "protob.WithLanguage" do
    optional :value, :string, 1
  end
  add_message "protob.WithVerification" do
    optional :value, :bool, 1
  end
  add_message "protob.Opts" do
    optional :with_text, :message, 1, "protob.WithText"
    optional :with_details, :message, 2, "protob.WithDetails"
    optional :language, :message, 3, "protob.WithLanguage"
    optional :with_verification, :message, 4, "protob.WithVerification"
  end
  add_message "protob.NameStrings" do
    optional :text, :bytes, 3
    repeated :names, :message, 6, "protob.NameString"
  end
  add_message "protob.NameString" do
    optional :value, :string, 1
    optional :odds, :float, 2
    optional :path, :string, 3
    optional :curated, :bool, 4
    optional :edit_distance, :int32, 5
    optional :edit_distance_stem, :int32, 6
    optional :source_id, :int32, 7
    optional :match, :enum, 8, "protob.MatchType"
  end
  add_enum "protob.MatchType" do
    value :NONE, 0
    value :EXACT, 1
    value :CANONICAL_EXACT, 2
    value :CANONICAL_FUZZY, 3
    value :PARTIAL_EXACT, 4
    value :PARTIAL_FUZZY, 5
  end
end

module Protob
  Pong = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.Pong").msgclass
  Void = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.Void").msgclass
  WithText = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.WithText").msgclass
  WithDetails = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.WithDetails").msgclass
  WithLanguage = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.WithLanguage").msgclass
  WithVerification = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.WithVerification").msgclass
  Opts = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.Opts").msgclass
  NameStrings = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.NameStrings").msgclass
  NameString = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.NameString").msgclass
  MatchType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.MatchType").enummodule
end
