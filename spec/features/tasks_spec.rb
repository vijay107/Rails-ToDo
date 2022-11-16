require 'rails_helper'

RSpec.feature "Tasks", type: :feature do

  context 'Index page' do
    scenario 'successfully displayed' do
      visit root_path
      expect(page).to have_content('Task Names')
      expect(page).to have_current_path('/')
    end
  end

  context 'Create a task' do

    before(:each) do  #before each scenario execute this
      visit new_task_path
      fill_in "Enter Task Name",	with: Faker::Hobby.activity 
      fill_in "Enter Task Description", with: Faker::String.random(length: 3..12)
    end

    scenario 'should be successfully created' do
      within('form') do
        fill_in "Enter Deadline for Task", with: Faker::Time.forward(days: 100, period: :all, format: :default)
      end

      click_button 'Create Task'
      expect(page).to have_content("Task was successfully created.")
      expect(page).to have_current_path("/tasks/#{Task.last.id}")
    end

    scenario 'should be fail to create task' do
      visit new_task_path

      within('form') do
        fill_in "Enter Deadline for Task", with: Faker::Time.backward(days: 100, period: :all, format: :default)
      end

      click_button 'Create Task'
      expect(page).to have_content("Errors!")
    end

  end

  context 'Update a task' do
    let!(:test) { 
      {
        task_name: Faker::Hobby.activity,
        task_description: Faker::String.random(length: 3..12),
        deadline: Faker::Time.forward(days: 100, period: :all, format: :default)
      }
    }
    before(:each) do  #before each scenario execute this
      visit edit_task_url(Task.first)
    end

    scenario 'should be successfully update task' do
      within('form') do
      
        fill_in "Enter Task Name",	with: test[:task_name]
        fill_in "Enter Task Description", with: test[:task_description]
        fill_in "Enter Deadline for Task", with: test[:deadline]
      end
      
      click_button 'Update Task'
      expect(page).to have_content("Task was successfully updated.")
      expect(page).to have_current_path("/tasks/#{Task.first.id}")
    end

    scenario 'should be fail to update' do

      within('form') do
        fill_in "Enter Task Name",	with: ''
        fill_in "Enter Task Description",	with: ''
        fill_in "Enter Deadline for Task",	with: ''
      end

      click_button 'Update Task'
      expect(page).to have_content("Errors!")
    end

  end

  context 'Delete a task' do
    let!(:test) { 
      {
        task_name: Faker::Hobby.activity,
        task_description: Faker::String.random(length: 3..12),
        deadline: Faker::Time.forward(days: 100, period: :all, format: :default)
      }
    }

    before(:each) do 
        visit task_path(Task.first)
    end

    scenario 'Successfully destroyed' do
      expect{ click_button 'Delete' }.to change( Task, :count ).by(-1)
      expect(page).to have_content('Task was successfully deleted.')
      expect(page).to have_current_path('/tasks')
    end

    scenario 'fail to delete' do
      #expect(response).to redirect_to(task_path(Task.last)) 
    end

  end
end
