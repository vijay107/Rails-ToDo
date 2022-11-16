require 'rails_helper'

RSpec.describe TasksController, type: :controller do

    render_views

    let(:page) { Capybara::Node::Simple.new(@response.body) }    # it offers the interface (page content) needed for RSpec 
    
    let(:valid_create_attributes){  
        FactoryBot.attributes_for(:task, :valid_date) 
    }

    let(:invalid_create_attributes){
        FactoryBot.attributes_for(:task, :invalid_date)
    }
        
    context 'GET#index' do
        it 'returns a successs response' do
            get :index
            expect(response).to have_http_status(200)
            expect(response).to render_template(:index)
        end
    end

    context 'GET#show' do
        it 'returns a successs response' do
            get :index
            get(:show, params: {id: Task.first.id })
            expect(response).to have_http_status(200)
            expect(response).to render_template(:show)
        end
    end

    context 'GET#new' do
        it 'returns a successs response' do
            get :new
            expect(response).to have_http_status(:success)
            expect(response).to render_template(:new)
        end
    end

    context 'POST#create' do
        it 'with valid params should create task' do
            expect do
                post(:create, params: {task: valid_create_attributes})
            end.to change(Task, :count).by(1)

            expect(Task.last.task_name).to eq(valid_create_attributes[:task_name])
            expect(response).to have_http_status(302)
            expect(response).to redirect_to(task_path(Task.last))            
        end
        it 'with invalid params should not create task' do
            expect do
                post(:create, params: {task: invalid_create_attributes})
            end.to change { Task.all.count }.by(0)
        end    
    end

    context 'GET#edit' do
        it 'return success response' do
            get(:edit, params: { id: Task.first.id })      
            expect(response).to have_http_status(200)
            expect(response).to render_template(:edit)
        end
    end

    context 'PUT#update' do
        it 'with valid params should update task' do
            binding.pry
            expect do
                put(:update, params: {id: Task.first.id, task: valid_create_attributes})
            end.to change { Task.all.count }.by(0)
            
            expect(Task.first.task_name).to eq(valid_create_attributes[:task_name])
            binding.pry
            expect(response).to have_http_status(302)
            expect(response).to redirect_to(task_path(Task.first))   
        end

        it 'with invalid params should not update task' do
            expect do
                put(:update, params: {id: Task.first.id, task: invalid_create_attributes})        
            end.to change { Task.all.count }.by(0)
        end

    end

    context 'DELETE#destroy' do
        it 'returns a successs response' do
            expect do
                delete(:destroy, params: {id: Task.last.id })
            end.to change { Task.all.count }.by(-1)

            expect(response).to redirect_to(tasks_path)
        end
    end
end