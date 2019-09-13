# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'
require 'uri'

describe UserManager do
  fixtures :all

  let(:umstb) do
    umstb = described_class.new
    # Assume no projects are managed
    allow(umstb).to receive(:manages_project?).and_return(false)
    umstb
  end

  let(:um) do
    um = described_class.new
    # Don't care about actual links right now
    allow(um).to receive(:valid_url).and_return(true)
    um
  end

  it 'always checks for projects this user manages' do
    umstb.delete_user('tg@gmail.com')
    expect(umstb).to have_received(:manages_project?)
  end

  it 'url is always validated' do
    url = 'http://www.fisica.net/relatividade/stephen_hawking_'\
          'a_brief_history_of_time.pdf'
    um.upl_certif(url, 'someguy')
    expect(um).to have_received(:valid_url)
  end

  it 'invalid url throws' do
    url = 'http:// fails'
    expect { described_class.new.valid_url(url) }
      .to raise_error(URI::InvalidURIError)
  end

  it 'wrong extension falses' do
    url = 'https://www.tutorialspoint.com/online_css_editor.php'
    expect(described_class.new.valid_url(url)).to be false
  end

  it 'accepts doc' do
    url = 'https://cs.wmich.edu/elise/courses/cs580/notes/Chapter67.doc'
    expect(described_class.new.valid_url(url)).to be true
  end

  it 'accepts pdf' do
    url = 'www.mentorum.nl/docs/Traindocs/dotNET_Tutorial_for_Beginners.pdf'
    expect(described_class.new.valid_url(url)).to be true
  end

  it 'depends on state' do
    um = described_class.new
    um.stater(false)
    url = 'www.mentorum.nl/docs/Traindocs/dotNET_Tutorial_for_Beginners.pdf'
    expect(um.valid_url(url)).to be false
  end

  it 'manipulates state freely' do
    um = described_class.new
    um.stater(15)
    expect(um.stater).to eq 15
  end

  it 'unregistered user should not be able to login' do
    e = 't@t.com'
    expect(described_class.new.login(e, 'pass')).to be false
  end

  it 'registered user should be able to login' do
    e = 'ar@gmail.com'
    expect(described_class.new.login(e, 'p4ssw1rd')).to be true
  end

  it 'rejects bad password' do
    e = 'ar@gmail.com'
    expect(described_class.new.login(e, 'incorrect')).to be false
  end

  it 'rejects if state is false' do
    e = 'ar@gmail.com'
    um = described_class.new
    um.stater(false)
    expect(um.login(e, 'p4ssw1rd')).to be false
  end

  it 'existing user cannot register again' do
    e = 'tg@gmail.com'
    v1 = described_class.new
    expect(v1.register(['', ''], e, 'p4ss-r')).to be false
  end

  it 'new user registration, true' do
    e = 'newmail'
    outp = described_class.new.register(%w[nme kname], e, '-7')
    expect(outp).to be true
  end

  it 'new user registration, name' do
    e = 'newmail'
    described_class.new.register(%w[nme kname], e, '-7')
    expect(User.find_by(email: 'newmail').name).to eq 'nme'
  end

  it 'new user registration, lname' do
    e = 'newmail'
    described_class.new.register(%w[nme kname decoy], e, '-7')
    expect(User.find_by(email: 'newmail').lname).to eq 'kname'
  end

  it 'new user registration, pass' do
    e = 'newmail'
    described_class.new.register(%w[nme kname], e, '-7')
    expect(User.find_by(email: 'newmail').pass).to eq '-7'
  end

  it 'deleting existing user' do
    e = 'tg@gmail.com'
    v1 = described_class.new
    expect(v1.delete_user(e)).to be true
  end

  it 'deleting non-existing user' do
    e = 'no@no.com'
    v1 = described_class.new
    expect(v1.delete_user(e)).to be false
  end

  it 'actually deleting existing user' do
    e = 'tg@gmail.com'
    described_class.new.delete_user(e)
    expect(User.find_by(email: e)).to be nil
  end

  it 'stops deleting with active projects' do
    e = 'tg@gmail.com'
    Project.create(manager: e, name: 'test')
    out = described_class.new.delete_user(e)
    expect(out).to be false
  end

  it 'actually uploads certificate' do
    e = 'tg@gmail.com'
    url = 'www.mentorum.nl/docs/Traindocs/dotNET_Tutorial_for_Beginners.pdf'
    described_class.new.upl_certif(url, e)
    expect(Certificate.find_by(user: e, link: url)).not_to be nil
  end

  it 'returns false if url is bad' do
    e = 'tg@gmail.com'
    url = 'https://www.tutorialspoint.com/online_css_editor.php'
    expect(described_class.new.upl_certif(url, e)).to be false
  end

  it 'doesnt create it in that case' do
    e = 'tg@gmail.com'
    url = 'https://www.tutorialspoint.com/online_css_editor.php'
    described_class.new.upl_certif(url, e)
    expect(Certificate.find_by(user: e, link: url)).to be nil
  end

  it 'returns false if state is false' do
    e = 'tg@gmail.com'
    Project.create(manager: e)
    um = described_class.new
    um.stater(false)
    expect(um.manages_project?(e)).to be false
  end
end
