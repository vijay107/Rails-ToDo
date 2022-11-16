require 'rails_helper'

RSpec.describe Task, type: :model do
    context 'validations tests' do
        it 'ensures task name is present' do
            task = Task.new(task_description: 'description').save
            expect(task).to eq(false)
        end

        it 'ensures task description is present' do
            task = Task.new(task_name: 'name').save
            expect(task).to eq(false)
        end
    end
end
