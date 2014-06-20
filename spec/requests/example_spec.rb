# -*- coding: utf-8 -*-
require 'rails_helper'

describe "example" do
  it "shows as an example" do
    visit "/"
    expect(page).to have_content "范例"
  end
end
