class Task < ApplicationRecord
    require "active_support/core_ext"
    validates :task_name, :task_description, presence: true
    validates :task_name, :task_description, :uniqueness => true
    validates :deadline, presence: true, comparison: { greater_than_or_equal_to: DateTime.now }
end
