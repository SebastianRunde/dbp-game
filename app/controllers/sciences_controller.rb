class SciencesController < ApplicationController
  before_action :set_science, only: [:show, :edit, :update, :destroy]

  # GET /sciences
  # GET /sciences.json
  def index
    @sciences = Science.all
  end

  # GET /sciences/1
  # GET /sciences/1.json
  def show
  end

  # GET /sciences/new
  def new
    @science = Science.new
  end

  # GET /sciences/1/edit
  def edit
  end

  def self.getSciences(user)
    scienceHash = Hash.new(0)
    user.science_instances.each do |s|
      scienceHash[s.science] = s.level
    end

    instance = nil
    Science.all.each do |s|
      if not(scienceHash.has_key? s)
        instance = ScienceInstance.new
        instance.science_id = s.id
        instance.user_id = user.id
        instance.level = 0
        ScienceInstance.create(:science_id => s.id, :user_id => user.id, :level => 0)
        scienceHash[s] = instance.level
      end
    end
    return scienceHash
  end

  def research
    url = request.original_url.split("/");

    current_user.science_instances.each do |s|

      if(url[4] == s.science_id.to_s)
        s.start_time = Time.now
        s.save
        redirect_to sciences_url, notice: 'Starting Research of ' + Science.find_by(id: s.science_id).name + ' ...'
      end
    end
  end

  def self.updateTime(instance)
    science = Science.find_by(id: instance.science_id)
    durationInMillis = (science.duration.to_i - 946684800)

    if(instance.start_time)
      timeSinceResearch = (((Time.now.to_f * 1000.0).to_i - (instance.updated_at.to_f * 1000.0).to_i) / 1000)
      restTime = durationInMillis - timeSinceResearch

      if(restTime <= 0)
        instance.level = instance.level + 1
        instance.start_time = nil
        instance.save
        return durationInMillis;
      else
        return restTime;
      end
    else
      return durationInMillis;
    end
  end

  # POST /sciences
  # POST /sciences.json
  def create
    @science = Science.new(science_params)

    respond_to do |format|
      if @science.save
        format.html { redirect_to @science, notice: 'Science was successfully created.' }
        format.json { render :show, status: :created, location: @science }
      else
        format.html { render :new }
        format.json { render json: @science.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sciences/1
  # PATCH/PUT /sciences/1.json
  def update
    respond_to do |format|
      if @science.update(science_params)
        format.html { redirect_to @science, notice: 'Science was successfully updated.' }
        format.json { render :show, status: :ok, location: @science }
      else
        format.html { render :edit }
        format.json { render json: @science.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sciences/1
  # DELETE /sciences/1.json
  def destroy
    @science.destroy
    respond_to do |format|
      format.html { redirect_to sciences_url, notice: 'Science was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_science
      @science = Science.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def science_params
      params.require(:science).permit(:cost1, :cost2, :cost3, :factor, :duration, :condition, :name, :tier)
    end
end
