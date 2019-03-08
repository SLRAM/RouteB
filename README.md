# RouteB

App that lets the user save preferred routes and updates the user about the conditions along that route and bus location.

    * The user has the ability to save a starting and ending location along with selected buses.
    * The user can check live feed of buses on their saved routes.
    * The user can check route status through color coding or a detailed description

# Detailed Outline

App has (5) View Controllers:
   * Route
   * Create Route
   * Google Maps
   * Location Search
   * Bus Search

## Route

This view has:

   * Table View for user routes
   * View for empty state
   * Tabbar Button that segues to the Create Route View Controller
   
   ![deny location gif](https://github.com/SLRAM/RouteB/blob/master/Images/RoutesView.gif)
   
Overview:
   
   * The view will display the users saved routes. 
   * The cells are color coded according to service advisory notices present on that routes saved transportation methods. 
   * The cell will be red for delayed or no service, yellow for altered or other, and green for no notices. 
   * If the user wants to view the route information they can click on the cell which will segue to the Google Map View Controller. 
   * If the user no longer wants to keep a certain route they can swipe the cell from right to left to delete it. 
   * If there are no existing routes then the view will display an empty state with directions on how to create a new route. 
   * If the user wants to create a new route they can press the + Button which will segue to the Create View Controller.


### Create Route

This view has:

   * (5) Buttons
      * Starting Address
      * Ending Address
      * Add Buses
      * Create Route
      * Cancel
   * Table View for route buses
      
   ![deny location gif](https://github.com/SLRAM/RouteB/blob/master/Images/CreateView.gif)
   
Overview:

   * The view will display the users temporary route information. 
   * The user can press the Starting Address Button which will segue to the Location Search View Controller. 
   * Once a location has been created the Starting Address Button text will change to the selected address. 
   * The user can press the Ending Address Button which will segue to the Location Search View Controller. 
   * Once a location has been created the Ending Address Button text will change to the selected address. 
   * If the user wishes to update either of the location buttons they can click the button to start the process over. 
   * The user can press the Add Buses Button which will segue to the Bus Search View Controller. 
   * Once buses have been selected the Buses Table View will populate. 
   * If the user no longer wants to keep a certain bus they can swipe the cell from right to left to delete it. 
   * Once the user is satisfied with they selections they can click the Create Route Button. 
   * Once pressed they will recieve an alert informing them that their route has been saved. 
   * When the user clicks OK the app will segue back to the Route View Controller. 
   * If the user is missing any field and they click the Create Route Button they will recieve an alert message notifying them about the issue.

### Google Maps

This view has:

   * (2) Buttons
      * Cancel
      * Status
   * Google Map View
      * Starting Marker
      * Ending Marker
      * Bus Route Polyline
      * Bus Stops
      * Active Buses on Route
   
      ![deny location gif](https://github.com/SLRAM/RouteB/blob/master/Images/GoogleMapView.gif)
      
Overview:

   * The View will display the users saved route live feed. The user will be able to view their starting and ending coordinates and the polylines for their saved buses. 
   * Each bus route has clickable bus stops. 
   * Clicking on a bus stop will display the bus stop information. 
   * Along the bus route the user will be able to view active buses servicing the line. 
   * The buses location is updated every 20 seconds. 
   * If the user clicks on the bus They will be able to view the buses direction and ID number. 
   * The Status Button is color coded according to the service advisory status. 
   * If the user clicks the Status Button they will see an alert that displays all active advisory warnings for their saved buses. 
   * When the user is done viewing their route they can click cancel to return to the Route View Controller.
   

### Location Search

This view has:

   * Google Map View
      * Location Marker
   * Search Bar
   * Table View for locations
   * (2) Buttons 
      * Add
      * Return to Create Route
      
   ![deny location gif](https://github.com/SLRAM/RouteB/blob/master/Images/LocationSearchView.gif)
   
Overview:

   * The View will display the users temporarily selected location. When the user begins typing in the Search Bar a Table View will appear with suggested locations. 
   * When the user selects an address the Table View will be replaced by a Google Map View. When the user is satisfied with their location they can click the Add Button. 
   * If the user has the required information they will see an alert message notifying them that their location was added. 
   * If the user is missing the required information they will see an alert message notifying them that they need to provide an acceptable address. 
   * If the user wishes to not save their selection they can click the Return to Create Route Button.

### Bus Search

This view has:

   * Search Bar
   * Table View for Buses
   * (2) Buttons 
      * Add
      * Return to Create Route
      
   ![deny location gif](https://github.com/SLRAM/RouteB/blob/master/Images/BusSearchView.gif)
   
Overview:   

  * The View will display the user's temporarily selected buses. 
  * When the user begins typing in the Search Bar the Table View will only display related buses. 
  * When the user selects a bus on a check mark will appear on the cell. 
  * When the user is satisfied with their selection of buses they can click the Add Button. 
  * If the user has the required information they will see an alert message notifying them that their buses were added. 
  * If the user is missing the required information they will see an alert message notifying them that they need to provide at least one bus. 
  * If the user wishes to not save their selection they can click the Return to Create Route Button.    

# Endpoints 

## MTA API

### Bus Agencies
http://bustime.mta.info/api/where/agencies-with-coverage.xml?key=(APIKEY)

### Routes for Agencies
http://bustime.mta.info/api/where/routes-for-agency/\(AGENCY).json?key=\(APIKEY)

### Route Live Information
http://bustime.mta.info/api/siri/vehicle-monitoring.json?key=\(APIKEY)&version=2&LineRef=\(BUS_ID)

### Route Stops and PolyLines
http://bustime.mta.info/api/where/stops-for-route/\(BUS_ID).json?key=\(APIKEY)&includePolylines=true&version=2

## Google SDK API

### Used For MTA API Polyline decoding


    
# Authors and Acknowledgments

[Stephanie Ramirez](https://github.com/SLRAM)


# License 
MIT License
