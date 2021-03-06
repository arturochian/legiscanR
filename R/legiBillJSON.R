##' @title Legiscan Bill Data
##' @description Parses and arranges JSON output from 
##' Legiscan master data dumps vote subdirectory
##' @param file A JSON file object from the vote subdirectory
##' @return Creates a list object containing a data frame 
##' for voting metadata and individual legislators' votes
##' @export
##' @examples
#' require(legiscanR)
#' directoryTree <- fileStructure("data/msHistorical/")
#' files <- fileLists(directoryTree)
#' bills <- legiBillJSON(files[["votes"]][[1]][[1]])

# Function to parse/clean JSON output from LegiScan API calls
legiBillJSON <- function(fileobject) {
  
  # Parse the JSON object
  bill <- fromJSON(fileobject)
  
  # Strip the outer layer elements
  billobject <- bill[["bill"]]
  
  # Create the session ID/name list
  session <- as.data.frame(billobject[["session"]], 
                           stringsAsFactors = FALSE)
  
  # Define named list with all of the single element values
  singleValueList <- list(bill_id = "bill_id", change_hash = "change_hash", url = "url", 
                          state_link = "state_link", completed = "completed", 
                          status = "status", status_date = "status_date", state = "state",
                          state_id = "state_id", bill_number = "bill_number", 
                          bill_type = "bill_type", body = "body",
                          body_id = "body_id", current_body = "current_body", 
                          current_body_id = "current_body_id", title = "title", 
                          description = "description", committee = "committee")
  
  # Build the list containing all the single element values
  billData <- lapply(singleValueList, FUN = function(singles){
    as.list(billobject[[singles]])
  })
  
  # Pull variable names from the name elements fo the billData
  # list object
  bdnames <- names(billData)
  
  # Replace any NULL values with NA values
  billData <- lapply(billData, FUN = function(rmNulls) {
    if (length(rmNulls) == 0) rmNulls <- ""
    else rmNulls <- rmNulls
  }) %>% as.data.frame(stringsAsFactors = FALSE) 
  
  # Attach original variable names to new data frame
  names(billData) <- bdnames
  
  # Recast the date values as dates
  billData$status_date <- ymd(billData$status_date)
  
  # Create bill metadata data frame object
  billData <- cbind(session[1], as.data.frame(billData, 
                                              stringsAsFactors = FALSE))
  
  # List of names that identify the data frame elements from the 
  # JSON output (these are used to generate the tables for bill data)
  bdDataFrames <- list(progress = "progress", history = "history", 
                       sponsors = "sponsors", texts = "texts")
  
  # Create a list object storing the dataframes from the JSON file
  # Also converts date fields to POSIX formatted dates and adds 
  # identifying fields to the data frame
  multiDF <- lapply(bdDataFrames, FUN = function(billDF) {
    
    # Add the ID columns to the data frames and fill the required 
    # number of records to rectangularize the data frame
    cbind(billData[rep(seq_len(nrow(billData[, c(1, 2, 10, 11)])), 
                       nrow(billobject[[billDF]])), ],
          billobject[[billDF]], stringsAsFactors = FALSE)
    
  }) # End of sub-function call
  
  # Create list of standardized data frame names
  dfNames <- list("billProg", "billHist", "billSpons", "billTxt")
  
  # Name the data frame elements
  names(multiDF) <- dfNames
  
  # Structure the list object to be returned
  theOb <- unlist(list(list(billMeta = billData), multiDF), recursive = FALSE)
  
  # Return the structured data object
  return(theOb)
  
  # End function call
}


