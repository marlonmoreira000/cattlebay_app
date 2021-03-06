class ListingsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :authorisation_policy
    before_action :find_listing, only: [:show, :edit, :update, :destroy, :buy]

    def index
        #------------------------------------------------------
        # Get all current listings (dogs) to display for sale.
        # Lazy load all pictures to minimize db queries.
        #------------------------------------------------------
        @q = Listing.ransack(params[:q])
        @listings = @q.result(distinct: true)
        # @listings = Listing.includes(:picture_blob).all
    end

    def show
    end

    def new
        #------------------------------------------------------
        # Create a new listing and pass it to the view. This
        # allows a new listing to be created with user input
        # from the 'new' form.
        #------------------------------------------------------
        @listing = Listing.new
    end

    def create
        #------------------------------------------------------
        # Create a new listing using the parameters from the
        # 'new' form. This listing is linked to the current
        # user. If the listing is not valid (i.e. does not 
        # pass all validations) then display error msg.
        #------------------------------------------------------
        @listing = current_user.listings.create(listing_params)
        current_user.add_role(:seller)
        if @listing.valid?
            @listing.purchased = false
            @listing.save
            redirect_to listings_path
        else
            flash.now[:alert] = @listing.errors.full_messages.join('<br>')
            render "new"
        end
    end

    def edit
    end

    def update
        #------------------------------------------------------
        # Update the listing with new information. If there is
        # a problem with the update, display an error msg.
        #------------------------------------------------------
        begin
            @listing.update!(listing_params)
            redirect_to listing_path(@listing.id)
        rescue
            flash.now[:alert] = @listing.errors.full_messages.join('<br>').html_safe
            render "edit"
        end
    end

    def destroy
        #------------------------------------------------------
        # Remove the listing from the database if it's owner
        # requests.
        #------------------------------------------------------
        # @listing.picture.purge
        @listing.destroy
        redirect_to listings_path
    end

    def buy
        #------------------------------------------------------
        # When a user purchases a dog, mark it as purchased,
        # and record the purchase as an order. Display a 
        # confirmation msg once purchased. If there is an
        # error in the purchase, display an error msg.
        #------------------------------------------------------
        begin
            @listing.update!(purchased: true)
            current_user.add_role(:buyer)
            current_user.orders.create(listing_id: @listing.id)
            flash[:notice] = "Success! Your purchase has been confirmed.".html_safe
            redirect_to root_path
        rescue
            flash.now[:alert] = @listing.errors.full_messages.join('<br>').html_safe
            render 'show'
        end
    end

  private

    def authorisation_policy
        authorize Listing
    end

    def find_listing
        @listing = Listing.find(params[:id])
    end

    def listing_params
    return params.require(:listing).permit(:name, :picture, :description, :price)
    end
end
