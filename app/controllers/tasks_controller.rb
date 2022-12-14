
class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  add_breadcrumb "Tasks", :root_path

  # GET /tasks or /tasks.json
  def index
    add_breadcrumb "index" , tasks_path
    @q = Task.ransack(params[:q])
    @tasks =Task.all
    if params[:q].present?
      if params[:q][:deadline_cont].present?
        params[:q][:deadline_cont] = params[:q][:deadline_cont].to_date
      end
      @tasks = @q.result(distict: true)
    end
    @pagy, @tasks = pagy(@tasks.order(created_at: :desc))

  end

  # GET /tasks/1 or /tasks/1.json
  def show
    add_breadcrumb "index" , tasks_path
    add_breadcrumb "show" , task_path(@task)
  end

  # GET /tasks/new
  def new
    add_breadcrumb "index" , tasks_path
    add_breadcrumb "new" , new_task_path
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
    add_breadcrumb "index" , tasks_path
    add_breadcrumb "edit" , edit_task_path(@task)
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to task_url(@task), notice: "Task was successfully created." }
        #format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        #format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to task_url(@task), notice: "Task was successfully updated." }
        #format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        #format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully deleted." }
      #format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:task_name, :task_description, :deadline)
    end
end
