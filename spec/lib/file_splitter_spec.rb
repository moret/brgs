# -*- coding: utf-8 -*-
require 'spec_helper'

describe FileSplitter do
  empty_file = "spec/assets/empty_file.txt"
  a_1_line_file = "spec/assets/1_line_file.txt"
  a_3_line_file = "spec/assets/3_lines_file.txt"
  paper_file = 'spec/assets/proposal.nt'
  paper_file_5_to_8_lines = File.read "spec/assets/paper_5_to_8.nt"

  context 'when counting lines' do
    it "detects empty files" do
      described_class.empty?(empty_file).should eq(true)
    end

    it "detects files ending on newline" do
      described_class.ends_with_newline?(paper_file).should eq(true)
    end

    it "detects files not ending on newline" do
      described_class.ends_with_newline?(a_3_line_file).should eq(false)
    end

    it "counts 12 lines on a 12 lines file" do
      described_class.count(paper_file).should eq(12)
    end

    it "counts 3 lines on a 3 lines file" do
      described_class.count(a_3_line_file).should eq(3)
    end

    it "counts 1 line on a 1 line file" do
      described_class.count(a_1_line_file).should eq(1)
    end

    it "counts 0 lines on an empty file" do
      described_class.count(empty_file).should eq(0)
    end
  end

  context 'when segmenting a file' do
    it "segments a 12 lines file into 3 pieces of 4 lines" do
      described_class.stub(:lines_limit).and_return(4)
      described_class.stub(:count).and_return(12)
      pieces = described_class.segment("")

      pieces.length.should eq(3)
      pieces.each { |v| (v[:last] - v[:first] + 1).should eq(4) }
    end

    it "doesn't segment a file smaller than the lines limit" do
      described_class.stub(:lines_limit).and_return(20)
      described_class.stub(:count).and_return(10)
      pieces = described_class.segment("")

      pieces.length.should eq(1)
      (pieces[0][:last] - pieces[0][:first] + 1).should eq(10)
    end

    it "segments last piece smaller than the rest if division is not perfect" do
      described_class.stub(:lines_limit).and_return(100)
      described_class.stub(:count).and_return(123)
      pieces = described_class.segment("")

      pieces.length.should eq(2)
      (pieces[1][:last] - pieces[1][:first] + 1).should eq(23)
    end

    it "doesn't return pieces for empty files" do
      described_class.stub(:count).and_return(0)
      described_class.segment("").should be_empty
    end
  end

  context 'when getting pieces of a file' do
    it "should get lines 5 to 8 of a 12 lines file" do
      piece = described_class.piece(paper_file, {first: 5, last: 8})
      piece.should eq(paper_file_5_to_8_lines)
    end
  end
end
