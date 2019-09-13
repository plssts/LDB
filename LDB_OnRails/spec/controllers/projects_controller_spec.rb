# frozen_string_literal: true

require_relative '../rails_helper'

describe ProjectsController do
  include Devise::Test::ControllerHelpers
  fixtures :all

  let(:newpr) do
    { project: { manager: 'tg@gmail.com', id: '201812',
                 status: 'Proposed', name: 'nauj', budget: 809 } }
  end

  let(:edt) do
    { project: { manager: 'ar@mail.com', id: '201050', budget: 21,
                 status: 'Postponed', name: 'act8t' } }
  end

  it 'covers mutation -if key' do
    expect { post :update, params: {} }.not_to raise_error(NoMethodError)
  end

  it 'actually deletes project' do
    post :destroy, params: { id: '201_050' }
    proj = Project.find_by(id: 201_050)
    expect(proj).to be nil
  end

  it 'member is actually added' do
    expect_any_instance_of(Project).to receive(:add_member).with('naujas')
    post :addmem, params: { project: { member: 'naujas' },
                            id: '201_050' }
  end

  it 'member is not added with empty params' do
    expect_any_instance_of(Project).not_to receive(:add_member)
    post :addmem, params: {}
  end

  it 'member name is written' do
    post :addmem, params: { project: { member: 'naujas' },
                            id: '201_050' }
    expect(ProjectMember.find_by(projid: 201_050, member: 'naujas').member)
      .to eq 'naujas'
  end

  context 'when creating a project' do
    # rubocop complains without this
    subject(:subj) { described_class.new }

    before do
      allow_any_instance_of(described_class)
        .to receive(:params).and_return(newpr)
      # has a valid new project
    end

    it 'actually creates project - manager' do
      subj.send(:create)
      proj = Project.find_by(name: 'nauj')
      expect(proj.manager).to eq 'tg@gmail.com'
    end

    it 'actually creates project - budget' do
      subj.send(:create)
      proj = Project.find_by(name: 'nauj')
      expect(proj.budget).to eq 809.0
    end

    it 'actually creates project - status' do
      subj.send(:create)
      proj = Project.find_by(name: 'nauj')
      expect(proj.status).to eq 'Proposed'
    end
  end

  context 'when editing a project' do
    before do
      allow_any_instance_of(described_class)
        .to receive(:params).and_return(edt)
      # hashes passed for editing current project
    end

    it do
      controller.bdgts
      expect(assigns(:proj)).to eq manager: 'ar@mail.com', id: '201050',
                                   budget: 21, status: 'Postponed',
                                   name: 'act8t'
    end

    it 'present params used in post update' do
      expect_any_instance_of(BudgetManager).to receive(:budgets_setter)
      post :update
    end

    it 'only loads view when getting edit form' do
      expect_any_instance_of(BudgetManager).not_to receive(:budgets_setter)
      get :edit # routes to update
    end

    it 'actually edits the name' do
      post :update
      proj = Project.find_by(id: edt[:project][:id])
      expect(proj.name).to eq 'act8t'
    end

    it 'actually edits the status' do
      post :update
      proj = Project.find_by(id: edt[:project][:id])
      expect(proj.status).to eq 'Postponed'
    end

    it 'actually edits the manager' do
      post :update
      proj = Project.find_by(id: edt[:project][:id])
      expect(proj.manager).to eq 'ar@mail.com'
    end

    it 'actually edits the budget' do
      post :update
      proj = Project.find_by(id: edt[:project][:id])
      expect(proj.budget).to be 21.0
    end
  end

  it 'also covers -if key mutation' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    expect { post :update }
      .not_to raise_error(ActionController::ParameterMissing)
  end
end
