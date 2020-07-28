
                var eventLat:Double = Double(event.mainLat)!
                var eventLon:Double = Double(event.mainLon)!
                latArray.append(eventLat) //keeps track of all event lats- make sure that not all events are virtual (eventLat=0)
                //if event coordinates aren't "" (invalid) or 0 (virtual), create a node at that building
                if event.mainLat != "" && event.mainLon != "" && eventLat != 0 && eventLon != 0 && eventLat != 0.0 && eventLon != 0.0 {
                    self.noNodes = false
                    if buildingsAlreadyRepresented[event.location] == nil && ((eventLat > 5 || eventLat < -5) && (eventLon > 5 || eventLon < -5)) { //events without lat/lon set are 0.0, using 5 arbitrarily to make sure a real lat/lon is set, also key must not exist
                        if (eventLat < 0 && eventLon > 0) {
                            let temp = eventLat
                            eventLat = eventLon
                            eventLon = temp
                        }
                        buildingsAlreadyRepresented[event.location!] = true
                        createAnnotationNode(latitude: eventLat, longitude: eventLon, altitude: (userAltitude! + 15), buildingName: event.location!)
                    }
                }
            }
            // if ALL event lats are 0, all events are virtual, let the user know, but create one Stetson node
            for lat in latArray {
                if lat != 0 || lat != 0.0 {
                    self.noNodes = false
                }
            }
            if self.noNodes {createOneNode()} //if there are no events on campus, just create one node
