# frozen_string_literal: true

require_relative '../rails_helper'

describe Graph do
  let(:gr) { described_class.new }

  let(:prm) do
    prm = instance_double('ProjectManager')
    allow(prm).to receive(:gen_projects_and_members_hash)
      .and_return('prj1' => 324, 'prj2' => 337, 'prj3' => 120)
    prm
  end

  it 'returns correct graph info' do
    expect(gr.create_projects_and_members_graph(prm))
      .to eq([337, 781, 'prj1' => 324, 'prj2' => 337, 'prj3' => 120])
  end

  it 'calls correct methods' do
    gr.create_projects_and_members_graph(prm)
    expect(prm).to have_received(:gen_projects_and_members_hash).with(no_args)
  end

  it 'manipulates calcval freely' do
    gr = described_class.new
    gr.calc_val(15)
    expect(gr.calc_val).to eq 15
  end

  it 'does not sum if calcaverage is false' do
    gr = described_class.new
    gr.calc_val(false)
    out = gr.create_projects_and_members_graph(ProjectManager.new)
    expect(out).to eq [3, 0, { 0 => 3, 101_050 => 2, 201_050 => 1 }]
  end
end
