class WikisController < ApplicationController
  def index
    @wikis = Wiki
  end

  def new
    @wiki = Wiki.new
  end

  def create
    @wiki = Wiki.new(params[:wiki].permit(:name))

    if @wiki.save
      @wiki.add_member(current_user)
      WikiInitializer.create_wiki(@wiki)
      flash[:notice] = "Dude! Nice job creating that wiki."
      redirect_to root_url
    else
      flash.now[:notice] = "Could not create wiki."
      render :new
    end
  end

  def edit
    @wiki = Wiki.find(params[:id])
  end

  def update
    @wiki = Wiki.find(params[:id])

    old_name = @wiki.name

    @wiki.name = params[:wiki][:name]

    if @wiki.save
      old_path = Rails.root.join('wikis', old_name)
      new_path = Rails.root.join('wikis', @wiki.name)

      `mv "#{old_path}" "#{new_path}"`

      flash[:notice] = "Wiki was successfully renamed."
      redirect_to root_url and return
    else
      flash[:error] = "Could not rename wiki."
      render :edit
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])
    `rm -rf "#{Rails.root.to_s + '/wikis/' + @wiki.name}"`
    @wiki.destroy
    redirect_to root_url, notice:  "Wiki has been destroyed!"
  end
end